SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
ALTER PROCEDURE		dbo.DBA_Task_Archive_CopyAssociation
AS
/*
	Creator:	20180925@Billy
	Task:		Collect unuseful devices for archive - [Redmine: #101008]
	Database:	FPSDI.FPS_DeviceFingerprint
	
	Revisions:
		- 20180925@Billy:	Initial - [Redmine: #101008]
		
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
		,	@Parameter		NVARCHAR(MAX)
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
	SELECT	subs.SubscriberId, subs.SubscriberKey, subs.ServerName, subs.DbName, 0
	FROM	OPENQUERY(FPSADMIN, N'
SELECT	subs.SubscriberId, subs.SubscriberKey, subdb.ServerName, subdb.DbName
FROM		FPS_ADMIN.dbo.Subscribers AS subs WITH (NOLOCK)
INNER JOIN	FPS_ADMIN.dbo.SubDBServers AS subdb WITH (NOLOCK)
		ON	subs.SubscriberId = subdb.SubscriberId
WHERE	subs.IsTest = 0
	AND	subs.IsActive = 1
ORDER BY subs.SubscriberId
') AS subs;


	-- Copy association to archive database --
	RAISERROR('Copy Association', 0, 0) WITH NOWAIT;

	SELECT	@Query = N'';
	SELECT	@Query = @Query + N'
INSERT INTO	~~SubscriberKey~~.Associations (Ass_ID, DeviceID, AccountID, CreatedDate, LastAccessedDate, ExceptionID)
SELECT	*
FROM	OPENQUERY(~~ServerName~~, N''
DECLARE	@SubscriberId	INT		= ~~SubscriberId~~
SELECT	*
FROM		~~DatabaseName~~.dbo.Associations AS ass WITH (NOLOCK)
INNER JOIN	FPSDI.FPS_DeviceFingerprint.dbo.DBA_Archive_DeviceSingleAssociation AS arc
		ON	ass.DeviceId = arc.DeviceId
WHERE	arc.SubscriberId = @SubscriberId;
'');
'

END;
GO
/*<info serverAlias="FPSDI-FPS_DeviceFingerprint" executers="" viewers="" isFunction="0" isNested="0"></info>*/
