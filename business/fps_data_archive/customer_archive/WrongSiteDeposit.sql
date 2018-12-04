SET NOCOUNT ON;

DECLARE	@site			VARCHAR(20)
	,	@SubscriberId	INT
	,	@SubscriberName	NVARCHAR(20)
	,	@Query			NVARCHAR(MAX)
	;

IF	OBJECT_ID('tempdb..#Invalid') IS NOT NULL
	DROP TABLE	#Invalid;

CREATE TABLE	#Invalid (
					AccountID		INT
				,	UserName		VARCHAR(50)
				,	UserName2		VARCHAR(50)
				,	CreatedDate		DATETIME
				,	Site			VARCHAR(20)
				);
CREATE CLUSTERED INDEX #CIX_Invalid ON #Invalid (AccountID);

IF	OBJECT_ID('tempdb..##Archive') IS NOT NULL
	DROP TABLE	##Archive;

CREATE TABLE	##Archive (
					AccountID		INT
				,	UserName		VARCHAR(50)
				,	UserName2		VARCHAR(50)
				,	CreatedDate		DATETIME
				);
CREATE CLUSTERED INDEX ##CIX_Archive ON ##Archive (AccountID);

SELECT	@site = LEFT(IBCUserName_Prefix, LEN(IBCUserName_Prefix) - 1)
	,	@SubscriberId = SubscriberID
	,	@SubscriberName = SubscriberName
FROM	FPS_SUB_Template.dbo.Subscribers WITH (NOLOCK)
WHERE	DbName = DB_NAME()

RAISERROR('%s - %d', 0, 0, @SubscriberName, @SubscriberId) WITH NOWAIT;

INSERT INTO	#Invalid (AccountID, UserName, UserName2, CreatedDate, Site)
SELECT	acc.AccountID, acc.UserName, acc.UserName2, acc.CreatedDate, ow.site
FROM		dbo.Accounts AS acc WITH (NOLOCK)
LEFT JOIN	FPS_SUB_Template.dbo.OWCustomer_20181102 AS ow WITH (NOLOCK)
		ON	acc.UserName = ow.username3
WHERE	ISNULL(ow.sssite, '') <> @site
	AND	ISNULL(acc.CreatedDate, 0) < '20181102'
	
DELETE	tbl WITH (TABLOCK)
FROM	#Invalid AS tbl
CROSS APPLY	(
	SELECT	TOP(1)
			sssite
	FROM	FPS_SUB_Template.dbo.OWCustomer_20181102 AS _cst WITH (NOLOCK)
	WHERE	_cst.username3 = tbl.UserName
		AND	_cst.sssite = @site
) AS cst
WHERE	cst.sssite = @site;

DELETE	tbl WITH (TABLOCK)
FROM	#Invalid AS tbl
OUTER APPLY	(
	SELECT	TOP(1)
			_trn.TransDate
	FROM	dbo.Transactions AS _trn WITH (NOLOCK)
	WHERE	_trn.AccountID = tbl.AccountID
	ORDER BY _trn.TransDate DESC
) AS trn
WHERE	ISNULL(trn.TransDate, 0) >= '20180501'
	AND	tbl.Site = @site;

DELETE	tbl
FROM	(
	SELECT	*, [rn] = ROW_NUMBER() OVER (PARTITION BY AccountID ORDER BY AccountID)
	FROM	#Invalid
) AS tbl
WHERE	tbl.rn > 1;

INSERT INTO	##Archive (AccountID, UserName, UserName2, CreatedDate)
SELECT	acc.AccountID, acc.UserName, acc.UserName2, acc.CreatedDate
FROM		dbo.Accounts AS acc WITH (NOLOCK)
CROSS APPLY	(
	SELECT	[cnt] = COUNT(1)
	FROM	dbo.Transactions AS _trn WITH (NOLOCK)
	WHERE	_trn.AccountID = acc.AccountID
) AS trn
WHERE	acc.CreatedDate IS NULL
	AND	trn.cnt = 0

RAISERROR('Done Collecting!', 0, 0) WITH NOWAIT;

INSERT INTO	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.trash.Accounts
SELECT	acc.*
FROM		#Invalid AS tbl WITH (NOLOCK)
INNER JOIN	dbo.Accounts AS acc WITH (NOLOCK)
		ON	acc.AccountID = tbl.AccountID

RAISERROR('Insert Accounts - %d rows', 0, 0, @@ROWCOUNT) WITH NOWAIT;

INSERT INTO	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.trash.Associations
SELECT	ass.*, @SubscriberId
FROM		#Invalid AS tbl WITH (NOLOCK)
INNER JOIN	dbo.Associations AS ass WITH (NOLOCK)
		ON	ass.AccountID = tbl.AccountID

RAISERROR('Insert Associations - %d rows', 0, 0, @@ROWCOUNT) WITH NOWAIT;

INSERT INTO	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.trash.Transactions
SELECT	trn.*
FROM		#Invalid AS tbl WITH (NOLOCK)
INNER JOIN	dbo.Transactions AS trn WITH (NOLOCK)
		ON	trn.AccountID = tbl.AccountID

RAISERROR('Insert Transactions - %d rows', 0, 0, @@ROWCOUNT) WITH NOWAIT;

DELETE	acc
FROM		#Invalid AS tbl WITH (NOLOCK)
INNER JOIN	dbo.Accounts AS acc WITH (NOLOCK)
		ON	acc.AccountID = tbl.AccountID

RAISERROR('Delete Accounts - %d rows', 0, 0, @@ROWCOUNT) WITH NOWAIT;

DELETE	ass
FROM		#Invalid AS tbl WITH (NOLOCK)
INNER JOIN	dbo.Associations AS ass WITH (NOLOCK)
		ON	ass.AccountID = tbl.AccountID

RAISERROR('Delete Associations - %d rows', 0, 0, @@ROWCOUNT) WITH NOWAIT;

DELETE	trn
FROM		#Invalid AS tbl WITH (NOLOCK)
INNER JOIN	dbo.Transactions AS trn WITH (NOLOCK)
		ON	trn.AccountID = tbl.AccountID

RAISERROR('Delete Transactions - %d rows', 0, 0, @@ROWCOUNT) WITH NOWAIT;

UPDATE	acc WITH (ROWLOCK)
SET		UserName2 = ISNULL(ow.username, acc.UserName2)
	,	CreatedDate = CASE WHEN acc.CreatedDate IS NULL THEN trn.TransDate ELSE acc.CreatedDate END
FROM		dbo.Accounts AS acc
LEFT JOIN	FPS_SUB_Template.dbo.OWCustomer_20181102 AS ow WITH (NOLOCK)
		ON	acc.UserName = ow.username3
		AND	ow.sssite = @site
OUTER APPLY	(
	SELECT	TOP(1)
			_trn.Transdate
	FROM	dbo.Transactions AS _trn WITH (NOLOCK)
	WHERE	_trn.AccountID = acc.AccountID
	ORDER BY _trn.TransDate ASC
) AS trn

RAISERROR('Done update %d rows.', 0, 0, @@ROWCOUNT) WITH NOWAIT;

SELECT	@Query = N'';
SELECT	@Query = @Query + N'
INSERT INTO	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.[' + @SubscriberName + N'].Accounts
SELECT	acc.*
FROM		##Archive AS tbl WITH (NOLOCK)
INNER JOIN	dbo.Accounts AS acc WITH (NOLOCK)
		ON	acc.AccountID = tbl.AccountID

RAISERROR(''Insert Accounts - %d rows'', 0, 0, @@ROWCOUNT) WITH NOWAIT;

INSERT INTO	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.[' + @SubscriberName + N'].Associations
SELECT	ass.*
FROM		##Archive AS tbl WITH (NOLOCK)
INNER JOIN	dbo.Associations AS ass WITH (NOLOCK)
		ON	ass.AccountID = tbl.AccountID

RAISERROR(''Insert Associations - %d rows'', 0, 0, @@ROWCOUNT) WITH NOWAIT;

INSERT INTO	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.[' + @SubscriberName + N'].Transactions
SELECT	trn.*
FROM		##Archive AS tbl WITH (NOLOCK)
INNER JOIN	dbo.Transactions AS trn WITH (NOLOCK)
		ON	trn.AccountID = tbl.AccountID

RAISERROR(''Insert Transactions - %d rows'', 0, 0, @@ROWCOUNT) WITH NOWAIT;

DELETE	acc
FROM		##Archive AS tbl WITH (NOLOCK)
INNER JOIN	dbo.Accounts AS acc WITH (NOLOCK)
		ON	acc.AccountID = tbl.AccountID

RAISERROR(''Delete Accounts - %d rows'', 0, 0, @@ROWCOUNT) WITH NOWAIT;

DELETE	ass
FROM		##Archive AS tbl WITH (NOLOCK)
INNER JOIN	dbo.Associations AS ass WITH (NOLOCK)
		ON	ass.AccountID = tbl.AccountID

RAISERROR(''Delete Associations - %d rows'', 0, 0, @@ROWCOUNT) WITH NOWAIT;

DELETE	trn
FROM		##Archive AS tbl WITH (NOLOCK)
INNER JOIN	dbo.Transactions AS trn WITH (NOLOCK)
		ON	trn.AccountID = tbl.AccountID

RAISERROR(''Delete Transactions - %d rows'', 0, 0, @@ROWCOUNT) WITH NOWAIT;
';

EXECUTE	sys.sp_executesql @Query;