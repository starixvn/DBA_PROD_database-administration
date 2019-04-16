SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.Task_ArchiveHA_SyncMetaTables_Child
AS
/*
	Creator:	20190416@Billy
	Task:		Sync meta tables to standby servers - Standby execution - [Redmine: #111418]
	Database:	DBARC.bodb_Archive
	
	Revisions:
		- 20190416@Billy:	Initial - [Redmine: #111418]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	BEGIN TRANSACTION;
	TRUNCATE TABLE	dbo.Task_ArchiveHA_StandbyServers;
	INSERT INTO	dbo.Task_ArchiveHA_StandbyServers
		(	ServerName, LinkedServer, DataMonthLimit, isActive)
	SELECT	ServerName, LinkedServer, DataMonthLimit, isActive
	FROM	OPENQUERY(DB061, N'
SELECT	ServerName, LinkedServer, DataMonthLimit, isActive
FROM	bodb_Archive.dbo.Task_ArchiveHA_StandbyServers WITH (NOLOCK)
');
	COMMIT;

	BEGIN TRANSACTION;
	TRUNCATE TABLE	dbo.Task_ArchiveHA_ArchiveTables;
	INSERT INTO	dbo.Task_ArchiveHA_ArchiveTables
		(	DatabaseName, TableName, TableType)
	SELECT	DatabaseName, TableName, TableType
	FROM	OPENQUERY(DB061, N'
SELECT	DatabaseName, TableName, TableType
FROM	bodb_Archive.dbo.Task_ArchiveHA_ArchiveTables WITH (NOLOCK)
');
	COMMIT;
END;
GO
/*<info serverAlias="DBARC-bodb_Archive" executers="" viewers="" isFunction="0" isNested="0"></info>*/