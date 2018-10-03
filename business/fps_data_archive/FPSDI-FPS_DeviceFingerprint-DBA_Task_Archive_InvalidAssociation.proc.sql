SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
ALTER PROCEDURE		dbo.DBA_Task_Archive_InvalidAssociation
AS
/*
	Creator:	20180927@Billy
	Task:		Delete archived associations - [Redmine: #101008]
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
	
	DECLARE	@InnerQuery		NVARCHAR(MAX)
		,	@OuterQuery		NVARCHAR(MAX)
		,	@InnerExecute	NVARCHAR(MAX)
		,	@OuterExecute	NVARCHAR(MAX)
		,	@Parameter		NVARCHAR(MAX)
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
ORDER BY subs.SubscriberId
') AS subs;


	-- Copy association to archive database --
	RAISERROR('Copy Association', 0, 0) WITH NOWAIT;

	SELECT	@InnerQuery = N'';
	SELECT	@InnerQuery = @InnerQuery + N'
INSERT INTO	[~~SubscriberKey~~].Associations (Ass_ID, DeviceID, AccountID, CreatedDate, LastAccessedDate, ExceptionID)
SELECT	Ass_ID, DeviceID, AccountID, CreatedDate, LastAccessedDate, ExceptionID
FROM	OPENQUERY(~~ServerName~~, N''
SELECT	ass.Ass_ID, ass.DeviceID, ass.AccountID, ass.CreatedDate, ass.LastAccessedDate, ass.ExceptionID
FROM		~~DatabaseName~~.dbo.Associations AS ass WITH (NOLOCK)
LEFT JOIN	FPSDEV.FPS_DEV.dbo.DevMaster AS dev WITH (NOLOCK)
		ON	ass.DeviceID = dev.DeviceId
WHERE	dev.DeviceId IS NULL;
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

		SELECT	@InnerExecute = REPLACE(REPLACE(REPLACE(@InnerQuery, N'~~ServerName~~', @ServerName), N'~~DatabaseName~~', @DatabaseName), N'~~SubscriberKey~~', @SubscriberKey);

		EXECUTE	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.sys.sp_executesql @InnerExecute;
	END;


	-- Delete archived association --
	RAISERROR('Delete Association', 0, 0) WITH NOWAIT;

	SELECT	@InnerQuery = N'';
	SELECT	@InnerQuery = @InnerQuery + N'
CREATE TABLE	#Archived (
				Ass_ID			INT
					PRIMARY KEY CLUSTERED
			);

INSERT INTO	#Archived (Ass_ID)
SELECT	Ass_ID
FROM	OPENQUERY(FPSARCHIVE, N''
SELECT	Ass_ID
FROM	FPS_SUB_ARCHIVE_STAGING.[~~SubscriberKey~~].Associations WITH (NOLOCK);
'');

DELETE	tbl WITH (PAGLOCK)
FROM		dbo.Associations AS tbl
INNER JOIN	#Archived AS tmp WITH (TABLOCK)
		ON	tbl.Ass_ID = tmp.Ass_ID;
';

	SELECT	@OuterQuery = N'';
	SELECT	@OuterQuery = @OuterQuery + N'
EXECUTE	~~ServerName~~.~~DatabaseName~~.sys.sp_executesql @Query;
'
		,	@Parameter = N'@Query NVARCHAR(MAX)'
		;

	WHILE	0 = 0
	BEGIN;
		UPDATE	TOP(1) subs
		SET		@SubscriberId = subs.SubscriberId
			,	@SubscriberKey = subs.SubscriberKey
			,	@ServerName = subs.ServerName
			,	@DatabaseName = subs.DatabaseName
			,	IsDone = 0
		FROM	@Subscribers AS subs
		WHERE	subs.IsDone = 1;

		IF	@@ROWCOUNT = 0
			BREAK;

		RAISERROR('	Running Subscriber %d - %s.%s ...', 0, 0, @SubscriberId, @ServerName, @DatabaseName) WITH NOWAIT;

		SELECT	@InnerExecute = REPLACE(@InnerQuery, N'~~SubscriberKey~~', @SubscriberKey)
			,	@OuterExecute = REPLACE(REPLACE(@OuterQuery, N'~~ServerName~~', @ServerName), N'~~DatabaseName~~', @DatabaseName)
			;

		EXECUTE	sys.sp_executesql @OuterExecute, @Parameter, @InnerExecute;
	END;
END;
GO
/*<info serverAlias="FPSDI-FPS_DeviceFingerprint" executers="" viewers="" isFunction="0" isNested="0"></info>*/
