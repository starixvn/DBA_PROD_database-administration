SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	sync.ObjectSynchronization_Single
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
		- 20200121@Billy:	Add table log
							Add re-checksum step - [Redmine: #126945]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	-- Variables --
	DECLARE	@DatabaseId		INT
		,	@ObjectType		CHAR(2)
		,	@ObjectSchema	NVARCHAR(128)
		,	@ObjectName		NVARCHAR(128)
		,	@ObjectChecksum	INT
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
			,	ObjectSchema		NVARCHAR(128)
			,	ObjectName			NVARCHAR(128)
			,	ObjectDefinition	NVARCHAR(MAX)
			,	ObjectPermission	NVARCHAR(MAX)
			,	ObjectChecksum		INT
			,	DestinationChecksum	INT
			,	Existing			BIT
			);

	-- Log table --
	DECLARE	@Log AS TABLE (
				Id					INT				IDENTITY(1,1)
					PRIMARY KEY CLUSTERED
			,	Category			VARCHAR(128)
			,	Message				NVARCHAR(MAX)
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
	,	[ObjectSchema]		= sch.name
	,	[ObjectName]		= obj.name
	,	[ObjectDefinition]	= sm.definition
	,	[ObjectPermission]	= ps.permission
	,	[ObjectChecksum]	= BINARY_CHECKSUM(obj.name, obj.type, sm.definition)
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
	AND	obj.name = @object;
';

		SELECT	@Param = N'';
		SELECT	@Param += N'@schema NVARCHAR(128), @object NVARCHAR(128)';

		SELECT	@ExecuteSP = QUOTENAME(@source_server) + N'.' + QUOTENAME(@source_database) + N'.sys.sp_executesql';

		INSERT INTO	@ObjectModule (ObjectId, ObjectType, ObjectSchema, ObjectName, ObjectDefinition, ObjectPermission, ObjectChecksum)
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
				@ObjectSchema	= om.ObjectSchema
			,	@ObjectName		= om.ObjectName
			,	@Definition		= om.ObjectDefinition
			,	@Permission		= om.ObjectPermission
		FROM	@ObjectModule AS om;

		SELECT	@Query = N'';
		SELECT	@Query += N'\
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT	@existing	= CASE WHEN obj.object_id IS NOT NULL THEN 1 ELSE 0 END
	,	@type		= obj.type
	,	@checksum	= BINARY_CHECKSUM(obj.name, obj.type, sm.definition)
FROM		sys.schemas AS sch WITH (NOLOCK)
INNER JOIN	sys.objects AS obj WITH (NOLOCK)
		ON	sch.schema_id = obj.schema_id
INNER JOIN	sys.sql_modules AS sm WITH (NOLOCK)
		ON	obj.object_id = sm.object_id
WHERE	sch.name = @schema
	AND	obj.name = @object;
';

		SELECT	@Param = N'';
		SELECT	@Param += N'@schema NVARCHAR(128), @object NVARCHAR(128), @existing BIT OUTPUT, @type CHAR(2) OUTPUT, @checksum INT OUTPUT';

		SELECT	@ExecuteSP = QUOTENAME(@destination_server) + N'.' + QUOTENAME(@destination_database) + N'.sys.sp_executesql';
		EXECUTE	@ExecuteSP @Query, @Param, @ObjectSchema, @ObjectName, @Existing OUTPUT, @ObjectType OUTPUT, @ObjectChecksum OUTPUT;

		UPDATE	@ObjectModule
		SET		Existing = @Existing
			,	DestinationChecksum = @ObjectChecksum
			;

		SELECT	ObjectId, ObjectType, ObjectName, ObjectDefinition, ObjectPermission, ObjectChecksum, DestinationChecksum, Existing
		FROM	@ObjectModule;

		-- Object synchronization --
		IF	@action = 'SYNC' AND NOT EXISTS (SELECT 1 FROM @ObjectModule WHERE ObjectChecksum <> DestinationChecksum)
		BEGIN;
			RAISERROR(N'\
[VERBOSE]		Object %s is synchronized, skipped synchronizing.
', 0, 0, @ObjectName) WITH NOWAIT;

			INSERT INTO	@Log (Category, Message)
			VALUES	('VERBOSE', N'Object ' + @ObjectName + N' is synchronized, skipped synchronizing.');
		END;
		ELSE IF	@action = 'SYNC'
		BEGIN;
			SELECT	@ExecuteSP = QUOTENAME(@destination_server) + N'.' + QUOTENAME(@destination_database) + N'.sys.sp_executesql';

			IF	EXISTS (SELECT 1 FROM @ObjectModule WHERE ObjectType IN ('FN', 'IF', 'TF') AND ObjectType <> @ObjectType)
			BEGIN;
				SELECT	@Query = N'';
				SELECT	@Query += N'DROP FUNCTION [~~SchemaName~~].[~~ObjectName~~];';
				SELECT	@Query = REPLACE(REPLACE(@Query, N'~~SchemaName~~', @ObjectSchema), N'~~ObjectName~~', @ObjectName);

				EXECUTE	@ExecuteSP @Query;

				RAISERROR(N'\
[SYNCING]		Object %s''s function type is changed, drop existing function.
', 0, 0, @ObjectName) WITH NOWAIT;

				INSERT INTO	@Log (Category, Message)
				VALUES	('SYNCING', N'Object ' + @ObjectName + N'''s function type is changed, drop existing function.');
			END;

			IF	@Existing = 1
			BEGIN;
				SELECT	@Definition = SUBSTRING(@Definition, 0, PATINDEX('%CREATE[ 	
]%', @Definition)) + N'ALTER' + SUBSTRING(@Definition, PATINDEX('%CREATE[ 	
]%', @Definition) + 6, LEN(@Definition));

				RAISERROR(N'\
[SYNCING]		Object %s exists, changed definition to ALTER.
', 0, 0, @ObjectName) WITH NOWAIT;

				INSERT INTO	@Log (Category, Message)
				VALUES	('SYNCING', N'Object ' + @ObjectName + N' exists, changed definition to ALTER.');
			END;

			EXECUTE	@ExecuteSP @Definition;

			RAISERROR(N'\
[SYNCING]		Object %s was deployed to %s.%s.
', 0, 0, @ObjectName, @destination_server, @destination_database) WITH NOWAIT;

			INSERT INTO	@Log (Category, Message)
			VALUES	('SYNCING', N'Object ' + @ObjectName + N' was deployed to ' + @destination_server + N'.' + @destination_database + N'.');

			IF	LEN(LTRIM(RTRIM(@Permission))) > 10
			BEGIN;
				EXECUTE	@ExecuteSP @Permission;

				RAISERROR(N'\
[SYNCING]		Object %s''s permissions were deployed to %s.%s.
', 0, 0, @ObjectName, @destination_server, @destination_database) WITH NOWAIT;

				INSERT INTO	@Log (Category, Message)
				VALUES	('SYNCING', N'Object ' + @ObjectName + N'''s permissions were deployed to ' + @destination_server + N'.' + @destination_database + N'.');
			END;
			ELSE
			BEGIN;
				RAISERROR(N'\
[SYNCING]		Object %s has no permissions. Skipped.
', 0, 0, @ObjectName, @destination_server, @destination_database) WITH NOWAIT;

				INSERT INTO	@Log (Category, Message)
				VALUES	('SYNCING', N'Object ' + @ObjectName + N' has no permissions. Skipped.');
			END;

			-- Re-checksum --
			SELECT	@Query = N'';
			SELECT	@Query += N'\
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT	@existing	= CASE WHEN obj.object_id IS NOT NULL THEN 1 ELSE 0 END
	,	@type		= obj.type
	,	@checksum	= BINARY_CHECKSUM(obj.name, obj.type, sm.definition)
FROM		sys.schemas AS sch WITH (NOLOCK)
INNER JOIN	sys.objects AS obj WITH (NOLOCK)
		ON	sch.schema_id = obj.schema_id
INNER JOIN	sys.sql_modules AS sm WITH (NOLOCK)
		ON	obj.object_id = sm.object_id
WHERE	sch.name = @schema
	AND	obj.name = @object;
';

			SELECT	@Param = N'';
			SELECT	@Param += N'@schema NVARCHAR(128), @object NVARCHAR(128), @existing BIT OUTPUT, @type CHAR(2) OUTPUT, @checksum INT OUTPUT';

			SELECT	@ExecuteSP = QUOTENAME(@destination_server) + N'.' + QUOTENAME(@destination_database) + N'.sys.sp_executesql';
			EXECUTE	@ExecuteSP @Query, @Param, @ObjectSchema, @ObjectName, @Existing OUTPUT, @ObjectType OUTPUT, @ObjectChecksum OUTPUT;

			IF	EXISTS (SELECT 1 FROM @ObjectModule WHERE ObjectChecksum = @ObjectChecksum)
			BEGIN;
				RAISERROR(N'\
[SYNCING]		Object %s''s checksum is OK.
', 0, 0, @ObjectName, @destination_server, @destination_database) WITH NOWAIT;

				INSERT INTO	@Log (Category, Message)
				VALUES	('SYNCING', N'Object ' + @ObjectName + N'''s checksum is OK.');
			END;
			ELSE
			BEGIN;
				RAISERROR(N'\
[SYNCING]		Object %s''s checksum is NG. Please verify again.
', 0, 0, @ObjectName, @destination_server, @destination_database) WITH NOWAIT;

				INSERT INTO	@Log (Category, Message)
				VALUES	('SYNCING', N'Object ' + @ObjectName + N'''s checksum is NG. Please verify again.');
			END;
		END;
	END;

	SELECT	Category, Message
	FROM	@Log;

	RAISERROR(N'[DONE]', 0, 0) WITH NOWAIT;
END;
GO
/*<info serverAlias="DBTOOL-ToolkitDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/