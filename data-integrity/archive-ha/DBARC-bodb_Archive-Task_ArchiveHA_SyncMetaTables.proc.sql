SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.Task_ArchiveHA_SyncMetaTables
AS
/*
	Creator:	20190416@Billy
	Task:		Sync meta tables to standby servers - [Redmine: #111418]
	Database:	DBARC.bodb_Archive
	
	Revisions:
		- 20190416@Billy:	Initial - [Redmine: #111418]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE	@Server			NVARCHAR(128)
		,	@LinkedServer	NVARCHAR(128)
		,	@Query			NVARCHAR(MAX)
		,	@Execute		NVARCHAR(MAX)
		;

	CREATE TABLE	#StandbyServers (
						ServerName		NVARCHAR(128)	NOT NULL
					,	LinkedServer	NVARCHAR(128)	NOT NULL
					,	isDone			BIT				NOT NULL
					,	PRIMARY KEY CLUSTERED (isDone, ServerName)
					);

	INSERT INTO	#StandbyServers
		(	ServerName, LinkedServer, isDone)
	SELECT	ServerName, LinkedServer, 0
	FROM	dbo.Task_ArchiveHA_StandbyServers
	WHERE	isActive = 1;

	-- Dynamic query for standby execution --
	SELECT	@Query = N'';
	SELECT	@Query = @Query + N'
EXECUTE	[~~Server~~].bodb_Archive.dbo.Task_ArchiveHA_SyncMetaTables_Child;
';

	WHILE	0 = 0
	BEGIN;
		UPDATE	TOP(1)
				tbl WITH (ROWLOCK)
		SET		@Server			= tbl.ServerName
			,	@LinkedServer	= tbl.LinkedServer
			,	isDone = 1
		FROM	#StandbyServers AS tbl
		WHERE	isDone = 0;

		IF	@@ROWCOUNT = 0
			BREAK;

		-- Import data from standby --
		SELECT	@Execute = REPLACE(@Query, N'~~Server~~', @LinkedServer);
		EXECUTE	sys.sp_executesql @Execute;
	END;
END;
GO
/*<info serverAlias="DBARC-bodb_Archive" executers="" viewers="" isFunction="0" isNested="0"></info>*/