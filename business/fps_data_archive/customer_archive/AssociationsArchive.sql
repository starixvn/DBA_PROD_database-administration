
SET NOCOUNT ON;

-- Declare variables --
DECLARE	@SubscriberId	INT
	,	@SubscriberKey	NVARCHAR(50)
	,	@ServerName		NVARCHAR(128)
	,	@DatabaseName	NVARCHAR(128)
	;
	
DECLARE	@Query			NVARCHAR(MAX)
	,	@Execute		NVARCHAR(MAX)
	;

DECLARE	@Subscribers	AS TABLE (
							SubscriberId		INT
						,	SubscriberKey		NVARCHAR(50)
						,	ServerName			NVARCHAR(128)
						,	DatabaseName		NVARCHAR(128)
						,	IsDone				BIT
						);


-- Subscriber list --
INSERT INTO	@Subscribers (SubscriberId, SubscriberKey, ServerName, DatabaseName, IsDone)
SELECT	subs.SubscriberId, subs.SubsciberKey, subdb.ServerName, subdb.DbName, 0
FROM		FPS_ADMIN.dbo.Subscribers AS subs WITH (NOLOCK)
INNER JOIN	FPS_ADMIN.dbo.SubDBServers AS subdb WITH (NOLOCK)
		ON	subs.SubscriberId = subdb.SubscriberId
WHERE	subs.IsTest = 0
	AND	subs.IsActive = 1
ORDER BY subs.SubscriberId;


-- Copy Associations to archive database --
RAISERROR('Copy Associations', 0, 0) WITH NOWAIT;

SELECT	@Query = N'';
SELECT	@Query = @Query + N'
INSERT INTO	trash.Associations (Ass_ID, DeviceID, AccountID, CreatedDate, LastAccessedDate, ExceptionID, SubscriberID)
SELECT	Ass_ID, DeviceID, AccountID, CreatedDate, LastAccessedDate, ExceptionID, @SubscriberID
FROM	OPENQUERY(~~ServerName~~, N''
SELECT	ass.Ass_ID, ass.DeviceID, ass.AccountID, ass.CreatedDate, ass.LastAccessedDate, ass.ExceptionID
FROM		~~DatabaseName~~.dbo.Associations AS ass WITH (NOLOCK)
LEFT JOIN	~~DatabaseName~~.dbo.Accounts AS acc WITH (NOLOCK)
		ON	ass.AccountID = acc.AccountID
WHERE	acc.AccountID IS NULL
	AND	ass.AccountID > 0;
'');
';

WHILE	0 = 0
BEGIN;
	UPDATE	TOP(1) subs
	SET		@SubscriberId = subs.SubscriberId
		,	@SubscriberKey = subs.SubscriberKey
		,	@ServerName = subs.ServerName
		,	@DatabaseName = subs.DatabaseName
		,	IsDone = 1
	FROM	@Subscribers AS subs
	WHERE	subs.IsDone = 0;

	IF	@@ROWCOUNT = 0
		BREAK;

	RAISERROR('	Running Subscriber %d - %s.%s ...', 0, 0, @SubscriberId, @ServerName, @DatabaseName) WITH NOWAIT;

	SELECT	@Execute = REPLACE(REPLACE(REPLACE(REPLACE(@Query, N'~~ServerName~~', @ServerName), N'~~DatabaseName~~', @DatabaseName), N'~~SubscriberKey~~', @SubscriberKey), N'~~SubscriberId~~', @SubscriberId);

	EXECUTE	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.sys.sp_executesql @Execute, N'@SubscriberId INT', @SubscriberId;
END;
