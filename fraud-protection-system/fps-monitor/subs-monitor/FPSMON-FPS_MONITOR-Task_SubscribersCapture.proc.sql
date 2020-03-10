SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	subs.Task_SubscribersCapture
AS
/*
	Creator:	20200310@Billy
	Task:		Capture subscribers rowcount of FPS system - [Redmine: #112758]
	Database:	FPSMON.FPS_MONITOR

	Revisions:
		- 20200310@Billy:	Initial - [Redmine: #112758]
*/
BEGIN;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	-- Variables --
	DECLARE	@SubscriberId	INT
		,	@Server			NVARCHAR(128)
		,	@Database		NVARCHAR(128)
		,	@Now			DATETIME
		;

	-- Dynamic variables --
	DECLARE	@Query			NVARCHAR(MAX)
		,	@Execute		NVARCHAR(MAX)
		;

	-- Table variables --
	DECLARE	@ServerMapping AS TABLE (
				ServerName		NVARCHAR(128)
			,	MappedServer	NVARCHAR(128)
			,	PRIMARY KEY CLUSTERED (ServerName)
			);

	DECLARE	@Subscribers AS TABLE (
				SubscriberId		INT
			,	SubscriberName		NVARCHAR(128)
			,	ServerName			NVARCHAR(128)
			,	DatabaseName		NVARCHAR(128)
			,	isDone				BIT
					DEFAULT (0)
			,	PRIMARY KEY CLUSTERED (isDone, SubscriberName)
			);

	DECLARE	@Rowcounts AS TABLE (
				TableName			NVARCHAR(128)
			,	Rows				BIGINT
			,	PRIMARY KEY CLUSTERED (TableName)
			);


	-- Init mapping --
	INSERT INTO	@ServerMapping (ServerName, MappedServer)
	VALUES	(N'FPSLIC107WEB', N'KBTFPS_DB01_MSSQLSERVERWEB')
		,	(N'FPSCR', N'KBTFPS_DB02_FPS_01')
		;


	-- Capture once per second --
	SELECT	@Now = DATEADD(SECOND, DATEDIFF(SECOND, d.d, GETDATE()), d.d)
	FROM	(VALUES(CAST(CAST(GETDATE() AS DATE) AS DATETIME))) AS d(d);

	IF	EXISTS (SELECT 1 FROM subs.SubscribersRowcount WITH (NOLOCK) WHERE CapturedTime = @Now)
		RETURN;


	-- PHASE 1: Collect subscribers information --
	BEGIN;
		SELECT	@Query = N'';
		SELECT	@Query += N'\
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT	[SubscriberId]		= sub.SubscriberID
	,	[SubscriberName]	= sub.SubscriberName
	,	[ServerName]		= db.ServerName
	,	[DatabaseName]		= db.DbName
FROM		dbo.Subscribers AS sub WITH (NOLOCK)
INNER JOIN	dbo.SubDBServers AS db WITH (NOLOCK)
		ON	sub.SubscriberID = db.SubscriberId;
';

		INSERT INTO	@Subscribers (SubscriberId, SubscriberName, ServerName, DatabaseName)
		EXECUTE	FPSADMIN.FPS_ADMIN.sys.sp_executesql @Query;

		UPDATE	sub
		SET		sub.ServerName = map.MappedServer
		FROM		@Subscribers AS sub
		INNER JOIN	@ServerMapping AS map
				ON	sub.ServerName = map.ServerName;

		MERGE	subs.Subscribers WITH (ROWLOCK) AS sub
		USING	@Subscribers AS tmp
			ON	sub.SubscriberName = tmp.SubscriberName
		WHEN MATCHED THEN
			UPDATE SET	sub.ServerName		= tmp.ServerName
					,	sub.DatabaseName	= tmp.DatabaseName
					,	sub.isActive		= 1
		WHEN NOT MATCHED BY TARGET THEN
			INSERT	(SubscriberId, SubscriberName, ServerName, DatabaseName, isActive)
			VALUES	(tmp.SubscriberId, tmp.SubscriberName, tmp.ServerName, tmp.DatabaseName, 1)
		WHEN NOT MATCHED BY SOURCE THEN
			UPDATE SET	sub.ServerName		= NULL
					,	sub.DatabaseName	= NULL
					,	sub.isActive		= 0
		;
	END; -- PHASE 1

	-- PHASE 2: Collect rowcount information --
	BEGIN;
		SELECT	@Query = N'';
		SELECT	@Query += N'\
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT	[TableName]	= SCHEMA_NAME(obj.schema_id) + N''.'' + obj.name
	,	[Rows]		= prt.rows
FROM		sys.objects AS obj WITH (NOLOCK)
INNER JOIN	sys.partitions AS prt WITH (NOLOCK)
		ON	obj.object_id = prt.object_id
		AND	prt.index_id IN (0, 1)
WHERE	obj.schema_id <> 4;
';

		-- Loop for each subscriber --
		UPDATE	@Subscribers
		SET		isDone = 0;

		WHILE	0 = 0
		BEGIN;
			UPDATE	TOP(1)
					tbl
			SET		tbl.isDone		= 1
				,	@SubscriberId	= tbl.SubscriberId
				,	@Server			= tbl.ServerName
				,	@Database		= tbl.DatabaseName
			FROM	@Subscribers AS tbl
			WHERE	tbl.isDone = 0;

			IF	@@ROWCOUNT = 0
				BREAK;

			DELETE	@Rowcounts;

			SELECT	@Execute = QUOTENAME(@Server) + N'.' + QUOTENAME(@Database) + N'.sys.sp_executesql';
			INSERT INTO	@Rowcounts (TableName, Rows)
			EXECUTE	@Execute @Query;

			-- Update metadata --
			INSERT INTO	subs.Tables (TableName)
			SELECT	tmp.TableName
			FROM	@Rowcounts AS tmp
			WHERE	NOT EXISTS (SELECT 1 FROM subs.Tables AS tbl WITH (NOLOCK) WHERE tbl.TableName = tmp.TableName);

			-- Record result --
			INSERT INTO	subs.SubscribersRowcount (CapturedTime, SubscriberId, TableId, Rows)
			SELECT	@Now, @SubscriberId, tbl.TableId, tmp.Rows
			FROM		subs.Tables AS tbl
			INNER JOIN	@Rowcounts AS tmp
					ON	tbl.TableName = tmp.TableName;
		END; -- WHILE
	END; -- PHASE 2
END;
GO
/*<info serverAlias="FPSMON-FPS_MONITOR" executers="" viewers="" isFunction="0" isNested="0"></info>*/