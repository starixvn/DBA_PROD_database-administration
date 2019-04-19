SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.Task_ArchiveHA_SSIS_MarkSynced
						@Server			NVARCHAR(128)
					,	@Database		NVARCHAR(128)
					,	@Table			NVARCHAR(128)
					,	@WinLostDate	DATETIME
AS
/*
	Creator:	20190417@Billy
	Task:		Mark rowcount record as synced - [Redmine: #111418]
	Database:	DB234.bodb_Archive
	
	Revisions:
		- 20190417@Billy:	Initial - [Redmine: #111418]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	UPDATE	tbl WITH (ROWLOCK)
	SET		TimeType = 'SYNCED'
	FROM	dbo.Task_ArchiveHA_RowcountResult AS tbl
	WHERE	tbl.StandbyServer = @Server
		AND	tbl.DatabaseName = @Database
		AND	tbl.TableName = @Table
		AND	tbl.WinLostDate = @WinLostDate
		AND	tbl.TimeType = 'DAY';
END;
GO
/*<info serverAlias="DBARC-bodb_Archive" executers="" viewers="" isFunction="0" isNested="0"></info>*/