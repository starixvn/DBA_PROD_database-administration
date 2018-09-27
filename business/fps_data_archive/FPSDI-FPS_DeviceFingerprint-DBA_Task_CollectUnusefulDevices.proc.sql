SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
ALTER PROCEDURE		dbo.DBA_Task_CollectUnusefulDevices
						@ArchiveMonths			SMALLINT		= 6
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
	DECLARE	@ArchiveDate	DATETIME
		,	@SubscriberId	INT
		,	@ServerName		NVARCHAR(128)
		,	@DatabaseName	NVARCHAR(128)
		;
	
	DECLARE	@Query			NVARCHAR(MAX)
		,	@Parameter		NVARCHAR(MAX)
		,	@Execute		NVARCHAR(MAX)
		;

	DECLARE	@Subscribers	AS TABLE (
								SubscriberId		INT
							,	ServerName			NVARCHAR(128)
							,	DatabaseName		NVARCHAR(128)
							,	IsDone				BIT
							);


	-- Clean-up temporary tables --
	TRUNCATE TABLE	dbo.DBA_Archive_DeviceSingleAssociation;


	-- Archive date --
	SELECT	@ArchiveDate	= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - @ArchiveMonths, 0);

	-- Subscriber list --
	INSERT INTO	@Subscribers (SubscriberId, ServerName, DatabaseName, IsDone)
	SELECT	subs.SubscriberId, subs.ServerName, subs.DbName, 0
	FROM	OPENQUERY(FPSADMIN, N'
SELECT	subs.SubscriberId, subdb.ServerName, subdb.DbName
FROM		FPS_ADMIN.dbo.Subscribers AS subs WITH (NOLOCK)
INNER JOIN	FPS_ADMIN.dbo.SubDBServers AS subdb WITH (NOLOCK)
		ON	subs.SubscriberId = subdb.SubscriberId
WHERE	subs.IsTest = 0
	AND	subs.IsActive = 1
ORDER BY subs.SubscriberId
') AS subs;


	-- Collect single association devices --
	RAISERROR('Collect Single Association Devices', 0, 0) WITH NOWAIT;

	SELECT	@Query = N'';
	SELECT	@Query = @Query + N'
INSERT INTO	dbo.DBA_Archive_DeviceSingleAssociation (SubscriberId, DeviceId)
SELECT	@SubscriberId, DeviceId
FROM	OPENQUERY(~~Server~~, N''
DECLARE	@ArchiveDate DATETIME = ''''' + CONVERT(NVARCHAR, @ArchiveDate, 120) + N''''';
SELECT	DeviceId, [AccountCnt] = COUNT(DISTINCT AccountId)
FROM	~~Database~~.dbo.Associations WITH (NOLOCK)
GROUP BY DeviceId
HAVING	MAX(LastAccessedDate) < @ArchiveDate
	AND	COUNT(DISTINCT AccountId) = 1;
'');
'
		,	@Parameter = N'@SubscriberId INT'
		;

	WHILE	0 = 0
	BEGIN;
		UPDATE	TOP(1) subs
		SET		@SubscriberId = subs.SubscriberId
			,	@ServerName = subs.ServerName
			,	@DatabaseName = subs.DatabaseName
			,	IsDone = 1
		FROM	@Subscribers AS subs
		WHERE	subs.IsDone = 0;

		IF	@@ROWCOUNT = 0
			BREAK;

		RAISERROR('	Running Subscriber %d - %s.%s ...', 0, 0, @SubscriberId, @ServerName, @DatabaseName) WITH NOWAIT;

		SELECT	@Execute = REPLACE(REPLACE(@Query, N'~~Server~~', @ServerName), N'~~Database~~', @DatabaseName);

		EXECUTE	sys.sp_executesql @Execute, @Parameter, @SubscriberId;
	END;


	-- Filter out devices which have direct evidences --
	RAISERROR('Filter Devices with Evidences', 0, 0) WITH NOWAIT;
	DELETE	tbl WITH (TABLOCK)
	FROM		dbo.DBA_Archive_DeviceSingleAssociation AS tbl
	INNER JOIN	FPSADMIN.FPS_EVI.dbo.EvidenceMaster AS evi
			ON	evi.ItemID = tbl.DeviceId
			AND	evi.ItemType = 1;


	-- Filter out devices which is used by other subscribers --
	RAISERROR('Filter Devices used by other subscribers', 0, 0) WITH NOWAIT;

	SELECT	@Query = N'';
	SELECT	@Query = @Query + N'
DELETE	tbl WITH (TABLOCK)
FROM		dbo.DBA_Archive_DeviceSingleAssociation AS tbl
INNER JOIN	OPENQUERY(~~Server~~, N''
DECLARE	@ArchiveDate DATETIME = ''''' + CONVERT(NVARCHAR, @ArchiveDate, 120) + N''''';
SELECT	DeviceId
FROM	~~Database~~.dbo.Associations WITH (NOLOCK)
WHERE	LastAccessedDate >= @ArchiveDate;
'') AS subs
		ON	tbl.DeviceId = subs.DeviceId;
';

	WHILE	0 = 0
	BEGIN;
		UPDATE	TOP(1) subs
		SET		@SubscriberId = subs.SubscriberId
			,	@ServerName = subs.ServerName
			,	@DatabaseName = subs.DatabaseName
			,	IsDone = 0
		FROM	@Subscribers AS subs
		WHERE	subs.IsDone = 1;

		IF	@@ROWCOUNT = 0
			BREAK;

		RAISERROR('	Running Subscriber %d - %s.%s ...', 0, 0, @SubscriberId, @ServerName, @DatabaseName) WITH NOWAIT;

		SELECT	@Execute = REPLACE(REPLACE(@Query, N'~~Server~~', @ServerName), N'~~Database~~', @DatabaseName);

		EXECUTE	sys.sp_executesql @Execute;
	END;

	RAISERROR('Finished!', 0, 0) WITH NOWAIT;
END;
GO
/*<info serverAlias="FPSDI-FPS_DeviceFingerprint" executers="" viewers="" isFunction="0" isNested="0"></info>*/
