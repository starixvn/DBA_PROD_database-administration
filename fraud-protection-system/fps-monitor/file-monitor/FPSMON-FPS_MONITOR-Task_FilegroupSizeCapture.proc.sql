SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	_file.Task_FilegroupSizeCapture
AS
/*
	Creator:	20200310@Billy
	Task:		Capture filegroup size of FPS system - [Redmine: #112758]
	Database:	FPSMON.FPS_MONITOR

	Revisions:
		- 20200310@Billy:	Initial - [Redmine: #112758]
*/
BEGIN;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	-- Variables --
	DECLARE	@Server		NVARCHAR(128)
		,	@Database	NVARCHAR(128)
		,	@DatabaseId	INT
		,	@Now		DATETIME
		;

	-- Dynamic variables --
	DECLARE	@Query		NVARCHAR(MAX)
		,	@Param		NVARCHAR(MAX)
		,	@Execute	NVARCHAR(MAX)
		;

	-- Table variables --
	DECLARE	@Servers AS TABLE (
				ServerName		NVARCHAR(128)
			,	isDone			BIT
					DEFAULT (0)
			,	PRIMARY KEY CLUSTERED (isDone, ServerName)
			);

	DECLARE	@Databases AS TABLE (
				ServerName		NVARCHAR(128)
			,	ServerInstance	NVARCHAR(128)
			,	DatabaseName	NVARCHAR(128)
			,	isDone			BIT
					DEFAULT (0)
			,	PRIMARY KEY CLUSTERED (isDone, ServerName, DatabaseName)
			);

	DECLARE	@Filegroups AS TABLE (
				FilegroupName	NVARCHAR(128)
			,	SizeKB			BIGINT
			,	PRIMARY KEY CLUSTERED (FilegroupName)
			);


	-- Capture once per second --
	SELECT	@Now = DATEADD(SECOND, DATEDIFF(SECOND, d.d, GETDATE()), d.d)
	FROM	(VALUES(CAST(CAST(GETDATE() AS DATE) AS DATETIME))) AS d(d);

	IF	EXISTS (SELECT 1 FROM _file.FileSizeCaptured WITH (NOLOCK) WHERE CapturedTime = @Now)
		RETURN;


	-- Select monitoring servers --
	INSERT INTO	@Servers (ServerName, isDone)
	SELECT	srv.ServerName, 0
	FROM	dbo.Servers AS srv WITH (NOLOCK)
	WHERE	srv.isActive = 1;

	-- PHASE 1: Collect database information --
	BEGIN;
		SELECT	@Query = N'';
		SELECT	@Query += N'\
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT	[ServerName]		= @ServerName
	,	[ServerInstance]	= @@SERVERNAME
	,	[DatabaseName]		= db.name
FROM	sys.databases AS db WITH (NOLOCK)
WHERE	db.state = 0
	AND	db.is_read_only = 0;
';

		SELECT	@Param = N'';
		SELECT	@Param += N'@ServerName NVARCHAR(128)';

		-- Loop for each server --
		UPDATE	@Servers
		SET		isDone = 0;

		WHILE	0 = 0
		BEGIN;
			UPDATE	TOP(1)
					tbl
			SET		tbl.isDone	= 1
				,	@Server		= tbl.ServerName
			FROM	@Servers AS tbl
			WHERE	tbl.isDone = 0;

			IF	@@ROWCOUNT = 0
				BREAK;

			SELECT	@Execute = QUOTENAME(@Server) + N'.master.sys.sp_executesql';
			INSERT INTO	@Databases (ServerName, ServerInstance, DatabaseName)
			EXECUTE	@Execute @Query, @Param, @Server;
		END; -- WHILE

		-- Update metadata --
		MERGE	dbo.Databases WITH (ROWLOCK) AS db
		USING	@Databases AS tmp
			ON	db.ServerName = tmp.ServerInstance
			AND	db.DatabaseName = tmp.DatabaseName
		WHEN MATCHED AND db.isActive = 0 THEN
			UPDATE SET	db.isActive = 1
		WHEN NOT MATCHED BY TARGET THEN
			INSERT	(ServerName, DatabaseName, isActive)
			VALUES	(tmp.ServerInstance, tmp.DatabaseName, 1)
		WHEN NOT MATCHED BY SOURCE THEN
			UPDATE SET	db.isActive = 0
		;
	END; -- PHASE 1

	-- PHASE 2: Collect Filegroup size information --
	BEGIN;
		SELECT	@Query = N'';
		SELECT	@Query += N'\
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT	[FilegroupName]	= ISNULL(fg.name, QUOTENAME(f.type_desc))
	,	[SizeKB]		= SUM(f.size) * 8
FROM		sys.database_files AS f WITH (NOLOCK)
LEFT JOIN	sys.filegroups AS fg WITH (NOLOCK)
		ON	f.data_space_id = fg.data_space_id
GROUP BY ISNULL(fg.name, QUOTENAME(f.type_desc));
';

		-- Loop for each database --
		UPDATE	@Databases
		SET		isDone = 0;

		WHILE	0 = 0
		BEGIN;
			UPDATE	TOP(1)
					tbl
			SET		tbl.isDone	= 1
				,	@Server		= tbl.ServerName
				,	@Database	= tbl.DatabaseName
				,	@DatabaseId	= db.DatabaseId
			FROM		@Databases AS tbl
			INNER JOIN	dbo.Databases AS db
					ON	tbl.ServerInstance = db.ServerName
					AND	tbl.DatabaseName = db.DatabaseName
			WHERE	tbl.isDone = 0;

			IF	@@ROWCOUNT = 0
				BREAK;

			DELETE	@Filegroups;

			SELECT	@Execute = QUOTENAME(@Server) + N'.' + QUOTENAME(@Database) + N'.sys.sp_executesql';
			INSERT INTO	@Filegroups (FilegroupName, SizeKB)
			EXECUTE	@Execute @Query;

			-- Update metadata --
			INSERT INTO	_file.Filegroups (DatabaseId, FilegroupName)
			SELECT	@DatabaseId, tmp.FilegroupName
			FROM	@Filegroups AS tmp
			WHERE	NOT EXISTS (SELECT 1 FROM _file.Filegroups AS fg WITH (NOLOCK) WHERE fg.DatabaseId = @DatabaseId AND fg.FilegroupName = tmp.FilegroupName);

			-- Record result --
			INSERT INTO	_file.FileSizeCaptured (CapturedTime, FilegroupId, SizeKB)
			SELECT	@Now, fg.FilegroupId, tmp.SizeKB
			FROM		_file.Filegroups AS fg
			LEFT JOIN	@Filegroups AS tmp
					ON	fg.FilegroupName = tmp.FilegroupName
			WHERE	fg.DatabaseId = @DatabaseId;
		END; -- WHILE
	END; -- PHASE 2
END;
GO
/*<info serverAlias="FPSMON-FPS_MONITOR" executers="" viewers="" isFunction="0" isNested="0"></info>*/