SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
ALTER PROCEDURE		dbo.DBA_Task_Archive_CopyAssociation
AS
/*
	Creator:	20180927@Billy
	Task:		Copy unused associations to archive - [Redmine: #101008]
	Database:	FPSDI.FPS_DeviceFingerprint
	
	Revisions:
		- 20180927@Billy:	Initial - [Redmine: #101008]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
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
	SELECT	subs.SubscriberId, subs.SubsciberKey, subs.ServerName, subs.DbName, 0
	FROM	OPENQUERY(FPSADMIN, N'
SELECT	subs.SubscriberId, subs.SubsciberKey, subdb.ServerName, subdb.DbName
FROM		FPS_ADMIN.dbo.Subscribers AS subs WITH (NOLOCK)
INNER JOIN	FPS_ADMIN.dbo.SubDBServers AS subdb WITH (NOLOCK)
		ON	subs.SubscriberId = subdb.SubscriberId
WHERE	subs.IsTest = 0
	AND	subs.IsActive = 1
ORDER BY subs.SubscriberId;
') AS subs;


	-- Copy association to archive database --
	RAISERROR('Copy Association', 0, 0) WITH NOWAIT;

	SELECT	@Query = N'';
	SELECT	@Query = @Query + N'
INSERT INTO	[~~SubscriberKey~~].Associations (Ass_ID, DeviceID, AccountID, CreatedDate, LastAccessedDate, ExceptionID)
SELECT	Ass_ID, DeviceID, AccountID, CreatedDate, LastAccessedDate, ExceptionID
FROM	OPENQUERY(~~ServerName~~, N''
DECLARE	@SubscriberId	INT		= ~~SubscriberId~~;
SELECT	ass.Ass_ID, ass.DeviceID, ass.AccountID, ass.CreatedDate, ass.LastAccessedDate, ass.ExceptionID
FROM		~~DatabaseName~~.dbo.Associations AS ass WITH (NOLOCK)
INNER JOIN	FPSDI.FPS_DeviceFingerprint.dbo.DBA_Archive_DeviceSingleAssociation AS arc
		ON	ass.DeviceId = arc.DeviceId
WHERE	arc.SubscriberId = @SubscriberId;
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

		EXECUTE	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.sys.sp_executesql @Execute;
	END;
END;
GO
/*<info serverAlias="FPSDI-FPS_DeviceFingerprint" executers="" viewers="" isFunction="0" isNested="0"></info>*/
