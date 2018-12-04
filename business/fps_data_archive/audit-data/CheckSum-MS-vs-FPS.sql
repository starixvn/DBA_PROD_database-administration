USE	FPS_MiddleService;
GO

SET NOCOUNT ON;

DECLARE	@Query			NVARCHAR(MAX)
	,	@SubscriberId	INT
	,	@ServerName		VARCHAR(100)
	,	@DbName			VARCHAR(100)
	;

IF	OBJECT_ID('tempdb..#Subs') IS NOT NULL
	DROP TABLE	#Subs;

CREATE TABLE	#Subs (
					SubscriberId	INT				PRIMARY KEY CLUSTERED
				,	SubscriberName	NVARCHAR(50)
				,	IsActive		BIT
				,	IsTest			BIT
				,	ServerName		VARCHAR(100)
				,	DbName			VARCHAR(100)
				,	IsDone			BIT
				,	CustChk_MS		INT
				,	CustChk_FPS		INT
				,	CustCnt_MS		INT
				,	CustCnt_FPS		INT
				);

IF	OBJECT_ID('tempdb..#Ass') IS NOT NULL
	DROP TABLE	#Ass;

CREATE TABLE	#Ass (
					SubscriberId	INT
				,	AccountId		INT
				,	AssChk_MS		INT
				,	AssChk_FPS		INT
				,	AssCnt_MS		INT
				,	AssCnt_FPS		INT
				,	PRIMARY KEY CLUSTERED (SubscriberId, AccountId)
				);

WITH cte AS (
	SELECT	TOP(1)
			_cst.SubscriberId
	FROM	FPS_MiddleService.dbo.Customers AS _cst WITH (NOLOCK)
	ORDER BY SubscriberId ASC
	UNION ALL
	SELECT	_cst.SubscriberId
	FROM	(
		SELECT	__cst.SubscriberId, [rn] = ROW_NUMBER() OVER(ORDER BY __cst.SubscriberId ASC)
		FROM		FPS_MiddleService.dbo.Customers AS __cst WITH (NOLOCK)
		INNER JOIN	cte
				ON	__cst.SubscriberId > cte.SubscriberId
	) AS _cst
	WHERE	_cst.rn = 1
)
INSERT INTO	#Subs (SubscriberId, IsDone)
SELECT	SubscriberId, 0
FROM	cte
OPTION (MAXRECURSION 0);

UPDATE	tbl
SET		SubscriberName = sub.SubscriberName
	,	IsActive = sub.IsActive
	,	IsTest = sub.IsTest
	,	ServerName = db.ServerName
	,	DbName = db.DbName
FROM		#Subs AS tbl
INNER JOIN	FPS_ADMIN.dbo.Subscribers AS sub WITH (NOLOCK)
		ON	tbl.SubscriberId = sub.SubscriberID
INNER JOIN	FPS_ADMIN.dbo.SubDBServers AS db WITH (NOLOCK)
		ON	tbl.SubscriberId = db.SubscriberId;

IF	EXISTS (SELECT 1 FROM #Subs WITH (NOLOCK) WHERE SubscriberName IS NULL OR IsTest = 1 OR IsActive = 0)
BEGIN;
	RAISERROR('MS has terminated subscriber.', 16, 1) WITH NOWAIT;
END;

UPDATE	tbl WITH (TABLOCK)
SET		CustChk_MS = ms.Chk
	,	CustCnt_MS = ms.Cnt
FROM		#Subs AS tbl
CROSS APPLY	(
	SELECT	[Chk] = CHECKSUM_AGG(BINARY_CHECKSUM(_cst.FPSAccountId)), [Cnt] = COUNT(_cst.FpsAccountId)
	FROM	FPS_MiddleService.dbo.Customers AS _cst WITH (NOLOCK)
	WHERE	_cst.SubscriberId = tbl.SubscriberId
) AS ms

WHILE	0 = 0
BEGIN;
	UPDATE	TOP(1)
			tbl WITH (TABLOCK)
	SET		@SubscriberID = tbl.SubscriberId
		,	@ServerName = tbl.ServerName
		,	@DbName = tbl.DbName
		,	IsDone = 1
	FROM	#Subs AS tbl
	WHERE	IsDone = 0;

	IF	@@ROWCOUNT = 0
		BREAK;

	RAISERROR('Start %d - %s', 0, 0, @SubscriberId, @DbName) WITH NOWAIT;

	SELECT	@Query = N'';
	SELECT	@Query = @Query + N'
UPDATE	tbl WITH (TABLOCK)
SET		CustChk_FPS = fps.Chk
	,	CustCnt_FPS = fps.Cnt
FROM		#Subs AS tbl
INNER JOIN	OPENQUERY(' + @ServerName + N', N''
SELECT	[Chk] = CHECKSUM_AGG(BINARY_CHECKSUM(acc.AccountId)), [Cnt] = COUNT(acc.AccountId)
FROM	[' + @DbName + N'].dbo.Accounts AS acc WITH (NOLOCK)
'') AS fps
		ON	tbl.SubscriberId = @SubscriberId;
';

	EXECUTE	sys.sp_executesql @Query, N'@SubscriberId INT', @subscriberId;

	INSERT INTO	#Ass (SubscriberId, AccountId, AssChk_MS, AssCnt_MS)
	SELECT	cst.SubscriberId, cst.FpsAccountId, CHECKSUM_AGG(BINARY_CHECKSUM(ass.DeviceId)), COUNT(ass.DeviceId)
	FROM			FPS_MiddleService.dbo.Customers AS cst WITH (NOLOCK)
	LEFT MERGE JOIN	FPS_MiddleService.dbo.Associations AS ass WITH (NOLOCK)
				ON	cst.CustId = ass.CustId
	WHERE	cst.SubscriberId = @SubscriberId
	GROUP BY	cst.SubscriberId, cst.FpsAccountId;

	SELECT	@Query = N'';
	SELECT	@Query = @Query + N'
UPDATE	tbl WITH (TABLOCK)
SET		AssChk_FPS = fps.Chk
	,	AssCnt_FPS = fps.Cnt
FROM		#Ass AS tbl
INNER JOIN	OPENQUERY(' + @ServerName + N', N''
SELECT	acc.AccountId, [Chk] = CHECKSUM_AGG(BINARY_CHECKSUM(ass.DeviceId)), [Cnt] = COUNT(ass.DeviceId)
FROM			[' + @DbName + N'].dbo.Accounts AS acc WITH (NOLOCK)
LEFT MERGE JOIN	[' + @DbName + N'].dbo.Associations AS ass WITH (NOLOCK)
			ON	acc.AccountId = ass.AccountId
GROUP BY acc.AccountId;
'') AS fps
		ON	tbl.SubscriberId = @SubscriberId
		AND	tbl.AccountId = fps.AccountId;
';

	EXECUTE	sys.sp_executesql @Query, N'@SubscriberId INT', @subscriberId;

	DELETE	#Ass WITH (TABLOCK)
	WHERE	AssChk_MS = AssChk_FPS
		AND	AssCnt_MS = AssCnt_FPS;

	RAISERROR('	Done %d - %s', 0, 0, @SubscriberId, @DbName) WITH NOWAIT;
END;

SELECT	*
FROM	#Subs WITH (NOLOCK)
WHERE	CustChk_FPS <> CustChk_MS
	OR	CustCnt_FPS <> CustCnt_MS;

SELECT	COUNT(1)
FROM	#Ass WITH (NOLOCK)
