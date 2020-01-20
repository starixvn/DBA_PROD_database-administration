SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	sync.ProcedureSynchronization_Single
						@source_server			NVARCHAR(128)
					,	@source_database		NVARCHAR(128)
					,	@destination_server		NVARCHAR(128)
					,	@destination_database	NVARCHAR(128)
					,	@object					NVARCHAR(128)
					,	@schema					NVARCHAR(128)	= NULL
					,	@action					VARCHAR(128)	= NULL
AS
/*
	Creator:	20200120@Billy
	Task:		Synchronize procedure definition and permission - [Redmine: #126744]
	Database:	DBTOOL-ToolkitDB

	Revisions:
		- 20200120@Billy:	Initial - [Redmine: #126744]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	-- Variables --
	DECLARE	@DatabaseId		INT
		,	@ObjectName		NVARCHAR(256)
		,	@Definition		NVARCHAR(MAX)
		,	@Permission		NVARCHAR(MAX)
		,	@Existing		BIT
		;

	-- Dynamic Query variables --
	DECLARE	@Query			NVARCHAR(MAX)
		,	@Param			NVARCHAR(MAX)
		,	@ExecuteSP		NVARCHAR(256)
		;

	-- Object metadata --
	DECLARE	@ObjectModule AS TABLE (
				ObjectId			INT
			,	ObjectType			CHAR(2)
			,	ObjectName			NVARCHAR(256)
			,	ObjectDefinition	NVARCHAR(MAX)
			,	ObjectPermission	NVARCHAR(MAX)
			,	Existing			BIT
			);

	-- Parameter verification --
	BEGIN;
		-- Verify source server --
		IF	NOT EXISTS (SELECT 1 FROM sys.servers WITH (NOLOCK) WHERE name = @source_server)
		BEGIN;
			RAISERROR(N'\
[ERROR]			Invalid source server!!!
', 16, 1) WITH NOWAIT;
			RETURN;
		END;

		-- Verify destination server --
		IF	NOT EXISTS (SELECT 1 FROM sys.servers WITH (NOLOCK) WHERE name = @destination_server)
		BEGIN;
			RAISERROR(N'\
[ERROR]			Invalid destination server!!!
', 16, 1) WITH NOWAIT;
			RETURN;
		END;

		SELECT	@Query = N'';
		SELECT	@Query += N'\
SELECT	@database_id = DB_ID(@database_name);
';

		SELECT	@Param = N'';
		SELECT	@Param += N'@database_name NVARCHAR(128), @database_id INT OUTPUT';

		-- Verify source database --
		SELECT	@DatabaseId = NULL;
		SELECT	@ExecuteSP = QUOTENAME(@source_server) + N'.master.sys.sp_executesql';
		EXECUTE	@ExecuteSP @Query, @Param, @source_database, @DatabaseId OUTPUT;

		IF	@DatabaseId IS NULL
		BEGIN;
			RAISERROR(N'\
[ERROR]			Invalid source database!!!
', 16, 1) WITH NOWAIT;
			RETURN;
		END;

		-- Verify destination database --
		SELECT	@DatabaseId = NULL;
		SELECT	@ExecuteSP = QUOTENAME(@destination_server) + N'.master.sys.sp_executesql';
		EXECUTE	@ExecuteSP @Query, @Param, @destination_database, @DatabaseId OUTPUT;

		IF	@DatabaseId IS NULL
		BEGIN;
			RAISERROR(N'\
[ERROR]			Invalid destination database!!!
', 16, 1) WITH NOWAIT;
			RETURN;
		END;
	END;

	-- Object verification --
	BEGIN;
		SELECT	@Query = N'';
		SELECT	@Query += N'\
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT	[ObjectId]			= obj.object_id
	,	[ObjectType]		= obj.type
	,	[ObjectName]		= sch.name + N''.'' + obj.name
	,	[ObjectDefinition]	= sm.definition
	,	[ObjectPermission]	= ps.permission
FROM		sys.schemas AS sch WITH (NOLOCK)
INNER JOIN	sys.objects AS obj WITH (NOLOCK)
		ON	sch.schema_id = obj.schema_id
INNER JOIN	sys.sql_modules AS sm WITH (NOLOCK)
		ON	obj.object_id = sm.object_id
CROSS APPLY	(
	SELECT	[permission] = dp.state_desc + N'' '' + dp.permission_name + N'' ON '' + QUOTENAME(sch.name) + N''.'' + QUOTENAME(obj.name) + N'' TO '' + QUOTENAME(usr.name) + N'';
''
	FROM		sys.database_permissions AS dp WITH (NOLOCK)
	INNER JOIN	sys.database_principals AS usr WITH (NOLOCK)
			ON	dp.grantee_principal_id = usr.principal_id
	WHERE	dp.major_id = obj.object_id
		AND	usr.name NOT IN (''vnteam'', ''vndba'')
	FOR XML PATH ('''')
	,	TYPE
) AS px(xml)
CROSS APPLY	(
	SELECT	[permission] = px.xml.value(''.[1]'', ''NVARCHAR(MAX)'')
) AS ps
WHERE	sch.name = ISNULL(@schema, sch.name)
	AND	obj.name = @object
	AND	obj.type = ''P'';
';

		SELECT	@Param = N'';
		SELECT	@Param += N'@schema NVARCHAR(128), @object NVARCHAR(128)';

		SELECT	@ExecuteSP = QUOTENAME(@source_server) + N'.' + QUOTENAME(@source_database) + N'.sys.sp_executesql';

		INSERT INTO	@ObjectModule (ObjectId, ObjectType, ObjectName, ObjectDefinition, ObjectPermission)
		EXECUTE	@ExecuteSP @Query, @Param, @schema, @object;

		IF	NOT EXISTS (SELECT 1 FROM @ObjectModule)
		BEGIN;
			RAISERROR(N'\
[ERROR]			Invalid object!!!
', 16, 1) WITH NOWAIT;
			RETURN;
		END;

		IF	(SELECT COUNT(1) FROM @ObjectModule) > 1
		BEGIN;
			RAISERROR(N'\
[ERROR]			More than 1 object returned. Can sync only 1 object at a time!!!
', 16, 1) WITH NOWAIT;
			RETURN;
		END;

		SELECT	TOP(1)
				@ObjectName = om.ObjectName
			,	@Definition = om.ObjectDefinition
			,	@Permission = om.ObjectPermission
		FROM	@ObjectModule AS om;

		SELECT	@Query = N'';
		SELECT	@Query += N'\
SELECT	@existing = CASE WHEN OBJECT_ID(@object) IS NOT NULL THEN 1 ELSE 0 END;
';

		SELECT	@Param = N'';
		SELECT	@Param += N'@object NVARCHAR(256), @existing BIT OUTPUT';

		SELECT	@ExecuteSP = QUOTENAME(@destination_server) + N'.' + QUOTENAME(@destination_database) + N'.sys.sp_executesql';
		EXECUTE	@ExecuteSP @Query, @Param, @ObjectName, @Existing OUTPUT;

		UPDATE	@ObjectModule
		SET		Existing = @Existing;

		SELECT	ObjectId, ObjectType, ObjectName, ObjectDefinition, ObjectPermission, Existing
		FROM	@ObjectModule;

		IF	@action = 'SYNC'
		BEGIN;
			IF	@Existing = 1
			BEGIN;
				SELECT	@Definition = SUBSTRING(@Definition, 0, PATINDEX('%CREATE[ 	
]%', @Definition)) + N'ALTER' + SUBSTRING(@Definition, PATINDEX('%CREATE[ 	
]%', @Definition) + 6, LEN(@Definition));

			RAISERROR(N'\
[SYNCING]		Object %s exists, changed definition to ALTER.
', 0, 0, @ObjectName) WITH NOWAIT;
			END;

			SELECT	@ExecuteSP = QUOTENAME(@destination_server) + N'.' + QUOTENAME(@destination_database) + N'.sys.sp_executesql';
			EXECUTE	@ExecuteSP @Definition;

			RAISERROR(N'\
[SYNCING]		Object %s deployed to %s.%s.
', 0, 0, @ObjectName, @destination_server, @destination_database) WITH NOWAIT;

			IF	LEN(LTRIM(RTRIM(@Permission))) > 10
			BEGIN;
				EXECUTE	@ExecuteSP @Permission;

				RAISERROR(N'\
[SYNCING]		Object %s''s permissions deployed to %s.%s.
', 0, 0, @ObjectName, @destination_server, @destination_database) WITH NOWAIT;
			END;
			ELSE
			BEGIN;
				RAISERROR(N'\
[SYNCING]		Object %s has no permissions. Skipped.
', 0, 0, @ObjectName, @destination_server, @destination_database) WITH NOWAIT;
			END;
		END;
	END;

	RAISERROR(N'[DONE]', 0, 0) WITH NOWAIT;
END;
GO
/*<info serverAlias="DBTOOL-ToolkitDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/