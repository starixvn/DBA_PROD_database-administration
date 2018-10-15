
SET NOCOUNT ON;


-- Declare variables --
DECLARE	@Subscriber		NVARCHAR(128)
	,	@SchemaId		INT
	,	@ServerName		NVARCHAR(128)
	,	@DBName			NVARCHAR(128)
	,	@TableName		NVARCHAR(128)
	;

DECLARE	@Msg			NVARCHAR(MAX)
	,	@Query			NVARCHAR(MAX)
	;


-- List of tables to be created --
IF	OBJECT_ID('tempdb..#tables') IS NOT NULL
	DROP TABLE	#tables;

CREATE TABLE	#tables (
					TableName		NVARCHAR(128)
						PRIMARY KEY CLUSTERED
				,	Done			BIT
				);

INSERT INTO	#tables (TableName, Done)
VALUES	('Transactions', 0)
	,	('Associations', 0)
	;


-- Schema Table --
IF	OBJECT_ID('tempdb..#schema') IS NOT NULL
	DROP TABLE	#schema;

CREATE TABLE	#schema (
					TableName		NVARCHAR(128)
				,	DefineName		NVARCHAR(128)
				,	DefineId		INT
				,	DefineType		NVARCHAR(128)
				,	Definition		NVARCHAR(MAX)
				);


-- List of subscribers --
IF	OBJECT_ID('tempdb..#subs') IS NOT NULL
	DROP TABLE	#subs;

CREATE TABLE	#subs (
					Subscriber		NVARCHAR(128)
						PRIMARY KEY CLUSTERED
				,	SchemaId		INT
				,	ServerName		NVARCHAR(128)
				,	DBName			NVARCHAR(128)
				,	Done			BIT
				);

INSERT INTO	#subs (Subscriber, SchemaId, ServerName, DBName, Done)
SELECT	[Subscriber]	= op.SubsciberKey
	,	[SchemaId]		= SCHEMA_ID(op.SubsciberKey)
	,	[ServerName]	= op.ServerName
	,	[DBName]		= op.DbName
	,	[Done]			= 0
FROM	OPENQUERY(FPSADMIN, '
SELECT	sub.SubsciberKey, lnk.ServerName, lnk.DbName
FROM		FPS_ADMIN.dbo.Subscribers AS sub WITH (NOLOCK)
INNER JOIN	FPS_ADMIN.dbo.SubDBServers AS lnk WITH (NOLOCK)
		ON	sub.SubscriberId = lnk.SubscriberId
WHERE	IsActive = 1
	AND	IsTest = 0;
') AS op;

SELECT	*
FROM	#subs WITH (NOLOCK);


-- Generate schema modification script (if any) --
WHILE	0 = 0
BEGIN;
	-- Get unprocessed subscriber --
	SELECT	TOP(1)
			@Subscriber		= s.Subscriber
		,	@SchemaId		= s.SchemaId
		,	@ServerName		= s.ServerName
		,	@DBName			= s.DBName
	FROM	#subs AS s WITH (NOLOCK)
	WHERE	s.Done = 0;

	IF	@@ROWCOUNT = 0
		BREAK;

	-- Reset schema table --
	TRUNCATE TABLE	#schema;

	-- Get source schema --
	SELECT	@Query = N'';
	SELECT	@Query = @Query + N'
INSERT INTO	#schema (TableName, DefineName, DefineId, DefineType, Definition)
SELECT	''TableName''		= t.name
	,	''DefineName''	= c.name
	,	''DefineId''		= c.column_id
	,	''DefineType''	= N''COLUMN''
	,	''Definition''	= N''['' + c.name + N''] '' + UPPER(ft.name) + CASE c.is_nullable WHEN 0 THEN N'' NOT NULL'' ELSE N'' NULL'' END
FROM		#tables AS tbl
INNER JOIN	' + @ServerName + N'.' + @DBName + N'.sys.tables AS t WITH (NOLOCK)
		ON	tbl.TableName = t.name
INNER JOIN	' + @ServerName + N'.' + @DBName + N'.sys.columns AS c WITH (NOLOCK)
		ON	c.object_id = t.object_id
INNER JOIN	' + @ServerName + N'.' + @DBName + N'.sys.types AS tp WITH (NOLOCK)
		ON	c.user_type_id = tp.user_type_id
CROSS APPLY	(	SELECT	name	= tp.name +	CASE tp.name	WHEN N''BINARY''			THEN N''('' + CAST(c.max_length AS NVARCHAR) + N'')''
															WHEN N''CHAR''			THEN N''('' + CAST(c.max_length AS NVARCHAR) + N'')''
															WHEN N''DATETIME2''		THEN N''('' + CAST(c.scale AS NVARCHAR) + N'')''
															WHEN N''DATETIMEOFFSET''	THEN N''('' + CAST(c.scale AS NVARCHAR) + N'')''
															WHEN N''DECIMAL''			THEN N''('' + CAST(c.precision AS NVARCHAR) + N'','' + CAST(c.scale AS NVARCHAR) + N'')''
															WHEN N''NCHAR''			THEN N''('' + CAST(c.max_length / 2 AS NVARCHAR) + N'')''
															WHEN N''NUMERIC''			THEN N''('' + CAST(c.precision AS NVARCHAR) + N'','' + CAST(c.scale AS NVARCHAR) + N'')''
															WHEN N''NVARCHAR''		THEN N''('' + CASE c.max_length WHEN -1 THEN N''MAX'' ELSE CAST(c.max_length / 2 AS NVARCHAR) END + N'')''
															WHEN N''TIME''			THEN N''('' + CAST(c.scale AS NVARCHAR) + N'')''
															WHEN N''VARBINARY''		THEN N''('' + CASE c.max_length WHEN -1 THEN N''MAX'' ELSE CAST(c.max_length AS NVARCHAR) END + N'')''
															WHEN N''VARCHAR''			THEN N''('' + CASE c.max_length WHEN -1 THEN N''MAX'' ELSE CAST(c.max_length AS NVARCHAR) END + N'')''
															ELSE N''''
											END
			) ft;
';
			
	EXECUTE	sys.sp_executesql @Query;
	
	-- KEYS --
	SELECT	@Query = N'';
	SELECT	@Query = @Query + N'
INSERT INTO	#schema (TableName, DefineName, DefineId, DefineType, Definition)
SELECT	''TableName''		= t.name
	,	''DefineName''	= kc.name
	,	''DefineId''		= 99999
	,	''DefineType''	= N''KEY_CONSTRAINT''
	,	''Definition''	= N''CONSTRAINT ['' + kc.name + N'']'' + CASE kc.type WHEN ''PK'' THEN N'' PRIMARY KEY '' WHEN ''UQ'' THEN N'' UNIQUE '' END
						+ i.type_desc + N'' ('' + ics.str + N'') ''
						+ CASE i.type_desc WHEN ''NONCLUSTERED'' THEN ISNULL(N''INCLUDE ('' + iccs.str + N'') '', N'''') ELSE N'''' END
						+ N''WITH (DATA_COMPRESSION = PAGE) ON ['' + CASE i.type_desc WHEN ''CLUSTERED'' THEN N''FPS_SUB_' + UPPER(@Subscriber) + N'_DATA]'' ELSE N''FPS_SUB_' + UPPER(@Subscriber) + N'_IDX]'' END
						  COLLATE SQL_Latin1_General_CP1_CI_AS
FROM		#tables AS tbl
INNER JOIN	' + @ServerName + N'.' + @DBName + N'.sys.tables AS t WITH (NOLOCK)
		ON	tbl.TableName = t.name
INNER JOIN	' + @ServerName + N'.' + @DBName + N'.sys.key_constraints AS kc WITH (NOLOCK)
		ON	t.object_id = kc.parent_object_id
INNER JOIN	' + @ServerName + N'.' + @DBName + N'.sys.indexes AS i WITH (NOLOCK)
		ON	kc.parent_object_id = i.object_id
		AND	kc.unique_index_id = i.index_id
CROSS APPLY	(
	SELECT	N''['' + _c.name + N'']'' + CASE _ic.is_descending_key WHEN 1 THEN N'' DESC'' ELSE N'' ASC'' END + N'', ''
	FROM	' + @ServerName + N'.' + @DBName + N'.sys.index_columns AS _ic WITH (NOLOCK)
	INNER JOIN	' + @ServerName + N'.' + @DBName + N'.sys.columns AS _c WITH (NOLOCK)
			ON	_ic.column_id = _c.column_id
			AND	_ic.object_id = _c.object_id
	WHERE	i.index_id = _ic.index_id
		AND	i.object_id = _ic.object_id
		AND	_ic.is_included_column = 0
	ORDER BY _ic.key_ordinal
	FOR XML PATH ('''')
	,	TYPE
) xic(xml)
CROSS APPLY	(
	SELECT	LEFT(_xq.str, LEN(_xq.str) - 1)
	FROM	(
		SELECT	xic.xml.value(''.[1]'', ''NVARCHAR(MAX)'')
	) AS _xq(str)
) AS ics(str)
OUTER APPLY	(
	SELECT	N''['' + _c.name + N''], ''
	FROM		' + @ServerName + N'.' + @DBName + N'.sys.index_columns AS _ic WITH (NOLOCK)
	INNER JOIN	' + @ServerName + N'.' + @DBName + N'.sys.columns AS _c WITH (NOLOCK)
			ON	_ic.column_id = _c.column_id
			AND	_ic.object_id = _c.object_id
	WHERE	i.index_id = _ic.index_id
		AND	i.object_id = _ic.object_id
		AND	_ic.is_included_column = 1
	ORDER BY _ic.key_ordinal
	FOR XML PATH ('''')
	,	TYPE
) xicc(xml)
OUTER APPLY	(
	SELECT	LEFT(_xq.str, LEN(_xq.str) - 1)
	FROM	(
		SELECT	ISNULL(xicc.xml, NULL).value(''.[1]'', ''NVARCHAR(MAX)'')
	) AS _xq(str)
) AS iccs(str);
';

	EXECUTE	sys.sp_executesql @Query;
			
	-- INDEXES --
	SELECT	@Query = N'';
	SELECT	@Query = @Query + N'
INSERT INTO	#schema (TableName, DefineName, DefineId, DefineType, Definition)
SELECT	''TableName''		= t.name
	,	''DefineName''	= i.name
	,	''DefineId''		= NULL
	,	''DefineType''	= N''INDEX''
	,	''Definition''	= N''IF	INDEXPROPERTY(OBJECT_ID(''''[' + LOWER(@Subscriber) + N'].['' + t.name + N'']''''), '''''' + i.name + N'''''', ''''IndexID'''') IS NULL
	CREATE '' + CASE i.is_unique WHEN 1 THEN N''UNIQUE '' ELSE N'''' END
						+ i.type_desc + N'' INDEX ['' + i.name + N''] ON [' + LOWER(@Subscriber) + N'].['' + t.name + N''] ('' + ics.str + N'') ''
						+ CASE i.type_desc WHEN ''NONCLUSTERED'' THEN ISNULL(N''INCLUDE ('' + iccs.str + N'') '', N'''') ELSE N'''' END
						+ N''WITH (DATA_COMPRESSION = PAGE) ON ['' + CASE i.type_desc WHEN ''CLUSTERED'' THEN N''FPS_SUB_' + UPPER(@Subscriber) + N'_DATA'' ELSE N''FPS_SUB_' + UPPER(@Subscriber) + N'_IDX'' END + N''];
ELSE
	RAISERROR(''''	Index ['' + i.name + N''] on [' + LOWER(@Subscriber) + N'].['' + t.name + N''] existed!'''', 0, 0) WITH NOWAIT;''
						  COLLATE SQL_Latin1_General_CP1_CI_AS
FROM		#tables AS tbl
INNER JOIN	' + @ServerName + N'.' + @DBName + N'.sys.tables AS t WITH (NOLOCK)
		ON	tbl.TableName = t.name
INNER JOIN	' + @ServerName + N'.' + @DBName + N'.sys.indexes AS i WITH (NOLOCK)
		ON	t.object_id = i.object_id
		AND	i.is_primary_key | i.is_unique_constraint = 0
CROSS APPLY	(
	SELECT	N''['' + _c.name + N'']'' + CASE _ic.is_descending_key WHEN 1 THEN N'' DESC'' ELSE N'' ASC'' END + N'', ''
	FROM	' + @ServerName + N'.' + @DBName + N'.sys.index_columns AS _ic WITH (NOLOCK)
	INNER JOIN	' + @ServerName + N'.' + @DBName + N'.sys.columns AS _c WITH (NOLOCK)
			ON	_ic.column_id = _c.column_id
			AND	_ic.object_id = _c.object_id
	WHERE	i.index_id = _ic.index_id
		AND	i.object_id = _ic.object_id
		AND	_ic.is_included_column = 0
	ORDER BY _ic.key_ordinal
	FOR XML PATH ('''')
	,	TYPE
) xic(xml)
CROSS APPLY	(
	SELECT	LEFT(_xq.str, LEN(_xq.str) - 1)
	FROM	(
		SELECT	xic.xml.value(''.[1]'', ''NVARCHAR(MAX)'')
	) AS _xq(str)
) AS ics(str)
OUTER APPLY	(
	SELECT	N''['' + _c.name + N''], ''
	FROM		' + @ServerName + N'.' + @DBName + N'.sys.index_columns AS _ic WITH (NOLOCK)
	INNER JOIN	' + @ServerName + N'.' + @DBName + N'.sys.columns AS _c WITH (NOLOCK)
			ON	_ic.column_id = _c.column_id
			AND	_ic.object_id = _c.object_id
	WHERE	i.index_id = _ic.index_id
		AND	i.object_id = _ic.object_id
		AND	_ic.is_included_column = 1
	ORDER BY _ic.key_ordinal
	FOR XML PATH ('''')
	,	TYPE
) xicc(xml)
OUTER APPLY	(
	SELECT	LEFT(_xq.str, LEN(_xq.str) - 1)
	FROM	(
		SELECT	ISNULL(xicc.xml, NULL).value(''.[1]'', ''NVARCHAR(MAX)'')
	) AS _xq(str)
) AS iccs(str);
';

	EXECUTE	sys.sp_executesql @Query;

	
	-- Schema for this subscriber wasn't created ⟹ Create schema and all tables --
	BEGIN;
		PRINT	'IF	FILEGROUP_ID(''[FPS_SUB_' + UPPER(@Subscriber) + '_DATA]'') IS NULL
	ALTER DATABASE [' + DB_NAME() + '] ADD FILEGROUP [FPS_SUB_' + UPPER(@Subscriber) + '_DATA];
ELSE
	RAISERROR(''	Filegroup [FPS_SUB_' + UPPER(@Subscriber) + '_DATA] existed!'', 0, 0) WITH NOWAIT;';

		PRINT	'IF	FILEGROUP_ID(''[FPS_SUB_' + UPPER(@Subscriber) + '_IDX]'') IS NULL
	ALTER DATABASE [' + DB_NAME() + '] ADD FILEGROUP [FPS_SUB_' + UPPER(@Subscriber) + '_IDX];
ELSE
	RAISERROR(''	Filegroup [FPS_SUB_' + UPPER(@Subscriber) + '_IDX] existed!'', 0, 0) WITH NOWAIT;';

		PRINT	'IF	FILE_ID(''FPS_SUB_' + UPPER(@Subscriber) + ''') IS NULL
	ALTER DATABASE [' + DB_NAME() + '] ADD FILE (NAME = N''FPS_SUB_' + UPPER(@Subscriber) + '_DATA_01'', FILENAME = N''T:\Archive\' + DB_NAME() + N'\FPS_SUB_' + UPPER(@Subscriber) + '_DATA_01.ndf'', SIZE = 512KB, MAXSIZE = UNLIMITED, FILEGROWTH = 32768KB) TO FILEGROUP [FPS_SUB_' + UPPER(@Subscriber) + '_DATA];
ELSE
	RAISERROR(''	File [FPS_SUB_' + UPPER(@Subscriber) + '_DATA_01] existed!'', 0, 0) WITH NOWAIT;';

		PRINT	'IF	FILE_ID(''FPS_SUB_' + UPPER(@Subscriber) + '_IDX_01'') IS NULL
	ALTER DATABASE [' + DB_NAME() + '] ADD FILE (NAME = N''FPS_SUB_' + UPPER(@Subscriber) + '_IDX_01'', FILENAME = N''T:\Archive\' + DB_NAME() + N'\FPS_SUB_' + UPPER(@Subscriber) + '_IDX_01.ndf'', SIZE = 512KB, MAXSIZE = UNLIMITED, FILEGROWTH = 32768KB) TO FILEGROUP [FPS_SUB_' + UPPER(@Subscriber) + '_IDX];
ELSE
	RAISERROR(''	File [FPS_SUB_' + UPPER(@Subscriber) + '_IDX_01] existed!'', 0, 0) WITH NOWAIT;';

		PRINT	'RAISERROR(''Added FILEGROUP and FILE for FPS_SUB_' + UPPER(@Subscriber) + N''', 0, 0) WITH NOWAIT;
GO';

		PRINT	'IF	SCHEMA_ID(''' + LOWER(@Subscriber) + ''') IS NULL
	EXECUTE	sys.sp_executesql N''CREATE SCHEMA	[' + LOWER(@Subscriber) + ']'';
ELSE
	RAISERROR(''	Schema ' + LOWER(@Subscriber) + ' existed!'', 0, 0) WITH NOWAIT;
GO';
		
		SELECT	@Query = N'';
		SELECT	@Query = @Query + tbls.str
		FROM	(
			SELECT	N'IF	OBJECT_ID(''[' + LOWER(@Subscriber) + N'].[' + _tbl.TableName + N']'') IS NULL
	CREATE TABLE	[' + LOWER(@Subscriber) + N'].[' + _tbl.TableName + N'] (
						' + _cols.str + N'
					);
ELSE
	RAISERROR(''	Table [' + LOWER(@Subscriber) + N'].[' + _tbl.TableName + N'] existed!'', 0, 0) WITH NOWAIT;
'
			FROM	#tables AS _tbl WITH (NOLOCK)
			CROSS APPLY	(
				SELECT	__sch.Definition + N'
					,	'
				FROM	#schema AS __sch WITH (NOLOCK)
				WHERE	__sch.TableName = _tbl.TableName
					AND	__sch.DefineId IS NOT NULL
				ORDER BY __sch.DefineId
				FOR XML PATH ('')
				,	TYPE
			) AS _xcol(xml)
			CROSS APPLY	(
				SELECT	LEFT(__xq.str, LEN(__xq.str) - 8)
				FROM	(
					SELECT	_xcol.xml.value('.[1]', 'NVARCHAR(MAX)')
				) AS __xq(str)
			) AS _cols(str)
			FOR XML PATH ('')
			,	TYPE
		) AS xtbl(xml)
		CROSS APPLY	(
			SELECT	LEFT(_xq.str, LEN(_xq.str) - 2)
			FROM	(
				SELECT	xtbl.xml.value('.[1]', 'NVARCHAR(MAX)')
			) AS _xq(str)
		) AS tbls(str);
		
		PRINT	@Query;
		
		SELECT	@Query = N'';
		SELECT	@Query = @Query + cons.str
		FROM	(
			SELECT	_sch.Definition + N'
'
			FROM	#schema AS _sch WITH (NOLOCK)
			WHERE	_sch.DefineId IS NULL
			ORDER BY _sch.DefineId
			FOR XML PATH ('')
			,	TYPE
		) AS xcon(xml)
		CROSS APPLY	(
			SELECT	LEFT(_xq.str, LEN(_xq.str) - 1)
			FROM	(
				SELECT	xcon.xml.value('.[1]', 'NVARCHAR(MAX)')
			) AS _xq(str)
		) AS cons(str);
		
		PRINT	@Query;

		PRINT	'RAISERROR(''Created SCHEMA and TABLEs for FPS_SUB_' + UPPER(@Subscriber) + N''', 0, 0) WITH NOWAIT;';

		RAISERROR('', 0, 0) WITH NOWAIT;
	END;
	

	UPDATE	#subs
	SET		Done			= 1
		,	SchemaId		= @SchemaId
	WHERE	Subscriber = @Subscriber;
END;

