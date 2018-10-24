
SET NOCOUNT ON;

-- Declare variables --
DECLARE	@SubscriberId	INT
	,	@SubscriberKey	NVARCHAR(50)
	,	@ServerName		NVARCHAR(128)
	,	@DatabaseName	NVARCHAR(128)
	;
	
DECLARE	@Query			NVARCHAR(MAX)
	,	@OuterQuery		NVARCHAR(MAX)
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
	AND	subdb.ServerName = 'FPSLIC107WEB'
ORDER BY subs.SubscriberId;


-- Delete accounts --
RAISERROR('Delete Accounts', 0, 0) WITH NOWAIT;

SELECT	@Query = N'';
SELECT	@Query = @Query + N'
DELETE	tbl WITH (ROWLOCK)
FROM		dbo.Accounts AS tbl
LEFT JOIN	FPS_SUB_Template.dbo.OWUsers AS arc WITH (NOLOCK)
		ON	tbl.UserName = arc.username
WHERE	arc.username IS NULL
	AND	tbl.UserName2 IS NULL
	AND	tbl.AccountID > 0
	AND	tbl.CreatedDate < ''20181005'';
';

SELECT	@OuterQuery = N'';
SELECT	@OuterQuery = @OuterQuery + N'
EXECUTE	~~DatabaseName~~.sys.sp_executesql @Query;
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

	SELECT	@Execute = REPLACE(REPLACE(REPLACE(REPLACE(@OuterQuery, N'~~ServerName~~', @ServerName), N'~~DatabaseName~~', @DatabaseName), N'~~SubscriberKey~~', @SubscriberKey), N'~~SubscriberId~~', @SubscriberId);

	EXECUTE	FPSLIC107WEB.master.sys.sp_executesql @Execute, N'@Query NVARCHAR(MAX)', @Query;
END;
