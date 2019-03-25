SET NOCOUNT ON;

DECLARE	@BaseQuery		NVARCHAR(MAX)
	,	@OuterQuery		NVARCHAR(MAX)
	,	@ExecuteQuery	NVARCHAR(MAX)
	,	@DBName			NVARCHAR(128)
	,	@SubscriberId	INT
	;

IF	OBJECT_ID('tempdb..#Subscribers') IS NOT NULL
	DROP TABLE	#Subscribers;

CREATE TABLE	#Subscribers (
					SubscriberId		INT				NOT NULL	PRIMARY KEY CLUSTERED
				,	SubscriberName		NVARCHAR(50)	NOT NULL
				,	ServerName			NVARCHAR(128)	NOT NULL
				,	DBName				NVARCHAR(128)	NOT NULL
				,	IsDone				BIT				NOT NULL
				);

INSERT INTO	#Subscribers WITH (TABLOCK) (SubscriberId, SubscriberName, ServerName, DBName, IsDone)
SELECT	SubscriberId, SubscriberName, ServerName, DBName, 0
FROM	OPENQUERY(FPSADMIN, N'
SELECT	sub.SubscriberId, sub.SubscriberName, db.ServerName, db.DBName
FROM		FPS_ADMIN.dbo.Subscribers AS sub WITH (NOLOCK)
INNER JOIN	FPS_ADMIN.dbo.SubDBServers AS db WITH (NOLOCK)
		ON	sub.SubscriberId = db.SubscriberId
WHERE	sub.IsActive = 1
	AND	sub.IsTest = 0
')
WHERE	ServerName = CASE @@SERVERNAME WHEN N'FPS_DB01\MSSQLSERVERWEB' THEN N'FPSLIC107WEB' WHEN N'FPS_DB02\FPS_01' THEN N'FPSCR' ELSE NULL END
	AND	SubscriberName <> N'Spondemo';


SELECT	@BaseQuery = N'';
SELECT	@BaseQuery = @BaseQuery + N'
DECLARE	@ArchivedTime		DATETIME
	;

DECLARE	@Trans AS TABLE (
			TransId		INT
		,	TransDate	DATETIME
		);

SELECT	@ArchivedTime = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 6, 0)
	;

WHILE	0 = 0
BEGIN;
	DELETE	@Trans;
	INSERT INTO	@Trans (TransId, TransDate)
	SELECT	TOP(1000)
			trn.TransId, trn.TransDate
	FROM	dbo.Transactions AS trn WITH (NOLOCK)
	WHERE	TransDate < @ArchivedTime;

	IF	@@ROWCOUNT = 0
		BREAK;

	BEGIN TRY
		INSERT INTO	FPSARCHIVE.FPS_SUB_ARCHIVE.dbo.Transactions_bk
			(	 SubscriberID,     TransID,     AccountID,     DeviceID,     TransDate,     ActionName,     IP,     Country,     CountryCode,     Region,     City,     ServiceProvider,     ISP,     Browser,     PluginID,     Flagged,     RuleSetID,     ResultType,     RuleVersionID,     URL,     ActionResult,     UserAgent)
		SELECT	@SubscriberID, trn.TransID, trn.AccountID, trn.DeviceID, trn.TransDate, trn.ActionName, trn.IP, trn.Country, trn.CountryCode, trn.Region, trn.City, trn.ServiceProvider, trn.ISP, trn.Browser, trn.PluginID, trn.Flagged, trn.RuleSetID, trn.ResultType, trn.RuleVersionID, trn.URL, trn.ActionResult, trn.UserAgent
		FROM			@Trans AS tmp
		INNER LOOP JOIN	dbo.Transactions AS trn WITH (NOLOCK)
					ON	trn.TransDate = tmp.TransDate
					AND	trn.TransId = tmp.TransId;
	END TRY
	BEGIN CATCH
		INSERT INTO	FPSARCHIVE.FPS_SUB_ARCHIVE.dbo.Transactions_bk
			(	 SubscriberID,     TransID,     AccountID,     DeviceID,     TransDate,     ActionName,     IP,     Country,     CountryCode,     Region,     City,     ServiceProvider,     ISP,     Browser,     PluginID,     Flagged,     RuleSetID,     ResultType,     RuleVersionID,     URL,     ActionResult,     UserAgent)
		SELECT	@SubscriberID, trn.TransID, trn.AccountID, trn.DeviceID, trn.TransDate, trn.ActionName, trn.IP, trn.Country, trn.CountryCode, trn.Region, trn.City, trn.ServiceProvider, trn.ISP, trn.Browser, trn.PluginID, trn.Flagged, trn.RuleSetID, trn.ResultType, trn.RuleVersionID, trn.URL, trn.ActionResult, trn.UserAgent
		FROM			@Trans AS tmp
		INNER LOOP JOIN	dbo.Transactions AS trn WITH (NOLOCK)
					ON	trn.TransDate = tmp.TransDate
					AND	trn.TransId = tmp.TransId
		OUTER APPLY	(
			SELECT	TOP(1)
					TransId
			FROM	FPSARCHIVE.FPS_SUB_ARCHIVE.dbo.Transactions_bk AS bk
			WHERE	bk.SubscriberId = trn.SubscriberId
				AND	bk.TransDate = trn.TransDate
				AND	bk.TransId = trn.TransId
		) AS bk
		WHERE	bk.TransId IS NULL;
	END CATCH

	DELETE	trn WITH (ROWLOCK)
	FROM			@Trans AS tmp
	INNER LOOP JOIN	dbo.Transactions AS trn WITH (ROWLOCK)
				ON	trn.TransDate = tmp.TransDate
				AND	trn.TransId = tmp.TransId;
END;
';

SELECT	@OuterQuery = N'';
SELECT	@OuterQuery = @OuterQuery + N'
EXECUTE	[~DBName~].sys.sp_executesql @Query, N''@SubscriberId INT'', @SubscriberId;
';

WHILE	0 = 0
BEGIN;
	SELECT	TOP(1)
			@SubscriberId	= SubscriberId
		,	@DBName			= DBName
	FROM	#Subscribers WITH (NOLOCK)
	WHERE	IsDone = 0;

	IF	@@ROWCOUNT = 0
		BREAK;

	RAISERROR('Running %d - %s', 0, 0, @SubscriberId, @DBName) WITH NOWAIT;

	SELECT	@ExecuteQuery = REPLACE(@OuterQuery, N'~DBName~', @DBName);
	EXECUTE	sys.sp_executesql @ExecuteQuery, N'@Query NVARCHAR(MAX), @SubscriberId INT', @BaseQuery, @SubscriberId;

	UPDATE	#Subscribers
	SET		IsDone = 1
	WHERE	SubscriberId = @SubscriberId;
END;