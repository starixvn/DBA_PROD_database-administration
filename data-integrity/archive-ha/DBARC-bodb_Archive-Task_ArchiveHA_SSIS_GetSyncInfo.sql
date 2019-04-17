SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.Task_ArchiveHA_SSIS_GetSyncInfo
						@TableType		INT
AS
/*
	Creator:	20190417@Billy
	Task:		Description - [Redmine: #111418]
	Database:	DBARC.bodb_Archive
	
	Revisions:
		- 20190417@Billy:	Initial - [Redmine: #111418]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@Date		DATETIME
		,	@Server		NVARCHAR(128)
		,	@Database	NVARCHAR(128)
		,	@Table		NVARCHAR(128)
		;

	SELECT	TOP(1)
			@Server = rr.StandbyServer
		,	@Table = rr.TableName
		,	@Database = rr.DatabaseName
		,	@Date = rr.WinLostDate
	FROM		dbo.Task_ArchiveHA_RowcountResult AS rr WITH (NOLOCK)
	INNER JOIN	dbo.Task_ArchiveHA_ArchiveTables AS tbl WITH (NOLOCK)
			ON	rr.DatabaseName = tbl.DatabaseName
			AND	rr.TableName = tbl.TableName
	WHERE	rr.TimeType = 'DAY'
		AND	tbl.TableType = @TableType;

	IF @@ROWCOUNT = 0
		SELECT	[server]		= @Server
			,	[database]		= @Database
			,	[table]			= @Table
			,	[winlostdate]	= @Date
			,	[condition]		= CONVERT(BIT, 0)
			;
	ELSE
		SELECT	[server]		= @Server
			,	[database]		= @Database
			,	[table]			= @Table
			,	[winlostdate]	= @Date
			,	[condition]		= CONVERT(BIT, 1)
			;
END;
GO
/*<info serverAlias="DBARC-bodb_Archive" executers="" viewers="" isFunction="0" isNested="0"></info>*/