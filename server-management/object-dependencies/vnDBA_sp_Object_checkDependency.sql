ALTER PROCEDURE	dbo.vnDBA_sp_Object_checkDependency
						@isDelete		BIT					= 0
					,	@session_id		UNIQUEIDENTIFIER	= NULL		OUTPUT
					,	@server_name	NVARCHAR(128)		= NULL
					,	@db_name		NVARCHAR(128)
					,	@schema_name	NVARCHAR(128)		= 'dbo'
					,	@object_name	NVARCHAR(128)
					,	@result			BIT					= 0			OUTPUT
					,	@level			INT					= 0
AS
/*
	Creator:	20160715@Billy
	Task:		Return dependency objects - [Redmine: #61014]
	Database:	*ALL_SERVERS*.MonDB
	
	Revisions:
		- 20160715@Billy:	v1.00	*start tracking*
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE	@query				NVARCHAR(MAX)
		,	@cross_server		NVARCHAR(128)
		,	@cross_database		NVARCHAR(128)
		,	@cross_schema		NVARCHAR(128)
		,	@cross_entity		NVARCHAR(128)
		,	@query_params		NVARCHAR(128)
		,	@query_result		BIT
		,	@debug_message		NVARCHAR(500)
		,	@running_level		INT
		;

	CREATE TABLE	#vnDBA_Objects_Dependencies (
						referencer			NVARCHAR(256)
					,	referencer_type		CHAR(2)
					,	referenced_server	NVARCHAR(128)
					,	referenced_database	NVARCHAR(128)
					,	referenced_schema	NVARCHAR(128)
					,	referenced_entity	NVARCHAR(128)
					,	referenced_type		CHAR(2)
					,	level				INT
					);

	CREATE TABLE	#cross_referenced (
						referenced_server	NVARCHAR(128)
					,	referenced_database	NVARCHAR(128)
					,	referenced_schema	NVARCHAR(128)
					,	referenced_entity	NVARCHAR(128)
					,	level				INT
					,	isDone				BIT
					);

	CREATE TABLE	#aliases (
						id					INT IDENTITY(1, 1)
					,	alias				AS CAST('(' + CAST(id AS NVARCHAR) + ')' AS NVARCHAR(10)) PERSISTED
					,	name				NVARCHAR(256)
					);

	SELECT	@result = 0;

	IF	@isDelete = 1
	BEGIN
	    IF	@session_id IS NULL
			RETURN;

		DELETE FROM	MonDB.dbo.vnDBA_Objects_Dependencies
		WHERE	session_id = @session_id;

		SELECT	@result = 1;

		RETURN;
	END;

	IF	@session_id IS NULL
	BEGIN
		SELECT	@session_id = NEWID();
	END;
	ELSE
	BEGIN
	    IF	@server_name IS NULL
			RETURN;
	END;

	SELECT	@query = N'
	WITH cte AS (
		SELECT	DISTINCT
				referencer			= CAST(N''' + @db_name + N'.' + @schema_name + N'.' + @object_name + N''' AS NVARCHAR(256))
			,	referencer_type		= r.type
			,	referenced_server	= dsre.referenced_server_name
			,	referenced_database	= ISNULL(dsre.referenced_database_name, ''' + @db_name + N''')
			,	referenced_schema	= ISNULL(dsre.referenced_schema_name, ''dbo'')
			,	referenced_entity	= dsre.referenced_entity_name
			,	referenced_type		= t.type
			,	level				= ' + CAST(@level AS NVARCHAR) + N'
		FROM	' + @db_name + N'.' + N'sys.dm_sql_referenced_entities(N''' + @schema_name + N'.' + @object_name + N''', ''OBJECT'') AS dsre
		OUTER APPLY (
			SELECT	o.type
			FROM	' + @db_name + N'.sys.objects AS o
			WHERE	o.name = ''' + @object_name + N'''
		) r
		OUTER APPLY (
			SELECT	o.type
			FROM	' + @db_name + N'.sys.objects AS o
			WHERE	o.name = dsre.referenced_entity_name
		) t
		WHERE	dsre.referenced_minor_id = 0

		UNION ALL

		SELECT	referencer			= CAST(ISNULL(cte.referenced_server + N''.'', '''') + ISNULL(cte.referenced_database + N''.'', '''') + cte.referenced_schema + N''.'' + cte.referenced_entity AS NVARCHAR(256))
			,	referencer_type		= cte.referenced_type
			,	referenced_server	= dsre.referenced_server_name
			,	referenced_database	= ISNULL(dsre.referenced_database_name, ''' + @db_name + N''')
			,	referenced_schema	= ISNULL(dsre.referenced_schema_name, ''dbo'')
			,	referenced_entity	= dsre.referenced_entity_name
			,	referenced_type		= t.type
			,	level				= cte.level + 1
		FROM	cte
		CROSS APPLY ' + @db_name + N'.sys.dm_sql_referenced_entities(cte.referenced_schema + N''.'' + cte.referenced_entity, ''OBJECT'') AS dsre
		OUTER APPLY (
			SELECT	o.type
			FROM	' + @db_name + N'.sys.objects AS o
			WHERE	o.name = dsre.referenced_entity_name
		) t
		WHERE	dsre.referenced_minor_id = 0
			AND	cte.referenced_type <> ''U''
	)
	INSERT INTO	#vnDBA_Objects_Dependencies
			(	    referencer,     referencer_type,     referenced_server,     referenced_database,     referenced_schema,     referenced_entity,     referenced_type,     level)
		SELECT	DISTINCT
				cte.referencer, cte.referencer_type, cte.referenced_server, cte.referenced_database, cte.referenced_schema, cte.referenced_entity, cte.referenced_type, cte.level
	FROM	cte;';

	EXECUTE	sys.sp_executesql @stmt = @query;

	INSERT INTO	#cross_referenced
		(	   referenced_server,    referenced_database,    referenced_schema,    referenced_entity,    level, isDone)
	SELECT	DISTINCT
			od.referenced_server, od.referenced_database, od.referenced_schema, od.referenced_entity, od.level, 0
	FROM	#vnDBA_Objects_Dependencies AS od
	WHERE	referenced_type IS NULL;

	-- Check cross database dependencies --
	WHILE	0 = 0
	BEGIN
		UPDATE	TOP(1) cr
		SET		@cross_database	= cr.referenced_database
			,	@cross_schema	= cr.referenced_schema
			,	@cross_entity	= cr.referenced_entity
			,	@running_level	= cr.level
			,	isDone			= 1
		FROM	#cross_referenced AS cr
		WHERE	referenced_server IS NULL
			AND	isDone = 0;
		
		IF	@@ROWCOUNT = 0
			BREAK;
		
		SELECT	@query = N'
		WITH cte AS (
			SELECT	DISTINCT
					referencer			= CAST(N''' + @cross_database + N'.' + @cross_schema + N'.' + @cross_entity + N''' AS NVARCHAR(256))
				,	referencer_type		= r.type
				,	referenced_server	= dsre.referenced_server_name
				,	referenced_database	= ISNULL(dsre.referenced_database_name, ''' + @cross_database + N''')
				,	referenced_schema	= ISNULL(dsre.referenced_schema_name, ''dbo'')
				,	referenced_entity	= dsre.referenced_entity_name
				,	referenced_type		= t.type
				,	level				= ' + CAST(@running_level + 1 AS NVARCHAR) + N'
			FROM	' + @cross_database + N'.' + N'sys.dm_sql_referenced_entities(N''' + @cross_schema + N'.' + @cross_entity + N''', ''OBJECT'') AS dsre
			OUTER APPLY (
				SELECT	o.type
				FROM	' + @cross_database + N'.sys.objects AS o
				WHERE	o.name = ''' + @cross_entity + N'''
			) r
			OUTER APPLY (
				SELECT	o.type
				FROM	' + @cross_database + N'.sys.objects AS o
				WHERE	o.name = dsre.referenced_entity_name
			) t
			WHERE	dsre.referenced_minor_id = 0

			UNION ALL

			SELECT	referencer			= CAST(ISNULL(cte.referenced_server + N''.'', '''') + ISNULL(cte.referenced_database + N''.'', '''') + cte.referenced_schema + N''.'' + cte.referenced_entity AS NVARCHAR(256))
				,	referencer_type		= cte.referenced_type
				,	referenced_server	= dsre.referenced_server_name
				,	referenced_database	= ISNULL(dsre.referenced_database_name, ''' + @cross_database + N''')
				,	referenced_schema	= ISNULL(dsre.referenced_schema_name, ''dbo'')
				,	referenced_entity	= dsre.referenced_entity_name
				,	referenced_type		= t.type
				,	level				= cte.level + 1
			FROM	cte
			CROSS APPLY ' + @cross_database + N'.sys.dm_sql_referenced_entities(cte.referenced_schema + N''.'' + cte.referenced_entity, ''OBJECT'') AS dsre
			OUTER APPLY (
				SELECT	o.type
				FROM	' + @cross_database + N'.sys.objects AS o
				WHERE	o.name = dsre.referenced_entity_name
			) t
			WHERE	dsre.referenced_minor_id = 0
				AND	cte.referenced_type <> ''U''
		)
		INSERT INTO	#vnDBA_Objects_Dependencies
				(	    referencer,     referencer_type,     referenced_server,     referenced_database,     referenced_schema,     referenced_entity,     referenced_type,     level)
			SELECT	DISTINCT
					cte.referencer, cte.referencer_type, cte.referenced_server, cte.referenced_database, cte.referenced_schema, cte.referenced_entity, cte.referenced_type, cte.level
		FROM	cte;';
		
		BEGIN TRY
			EXECUTE	sys.sp_executesql @stmt = @query;
		END TRY
		BEGIN CATCH
		
		END CATCH;

		SELECT	@debug_message = N'DONE: ' + @cross_database + N'.' + @cross_schema + N'.' + @cross_entity;
		RAISERROR(@debug_message, 0, 0) WITH NOWAIT;
	END;

	IF	@server_name IS NOT NULL
	BEGIN
	    UPDATE	#vnDBA_Objects_Dependencies
		SET		referencer			= @server_name + N'.' + referencer
			,	referenced_server	= @server_name
		WHERE	referenced_server IS NULL;
	END;

	-- Check cross server dependencies --
	WHILE	0 = 0
	BEGIN
	    UPDATE	TOP(1) cr
		SET		@cross_server	= cr.referenced_server
			,	@cross_database	= cr.referenced_database
			,	@cross_schema	= cr.referenced_schema
			,	@cross_entity	= cr.referenced_entity
			,	@running_level	= cr.level
			,	isDone			= 1
		FROM	#cross_referenced AS cr
		WHERE	referenced_server IS NOT NULL
			AND	isDone = 0;

		IF	@@ROWCOUNT = 0
			BREAK;

		SELECT	@query = N'
		EXECUTE	' + @cross_server + N'.MonDB.dbo.vnDBA_sp_Object_checkDependency
					@session_id		= ''' + CAST(@session_id AS NVARCHAR(36)) + N'''
				,	@server_name	= ''' + @cross_server + N'''
				,	@db_name		= ''' + @cross_database + N'''
				,	@schema_name	= ''' + @cross_schema + N'''
				,	@object_name	= ''' + @cross_entity + N'''
				,	@level			= ' + CAST(@running_level + 1 AS NVARCHAR) + N'
				,	@result			= @query_result OUTPUT
				;'
			,	@query_params = N'@query_result BIT OUTPUT'
			;

		BEGIN TRY
			EXECUTE	sys.sp_executesql @query, @query_params, @query_result = @query_result OUTPUT;

			IF	@query_result = 1
			BEGIN
				SELECT	@query = N'
			    INSERT INTO	#vnDBA_Objects_Dependencies
					(	referencer, referencer_type, referenced_server, referenced_database, referenced_schema, referenced_entity, referenced_type, level)
			    SELECT	referencer, referencer_type, referenced_server, referenced_database, referenced_schema, referenced_entity, referenced_type, level
				FROM	' + @cross_server + N'.MonDB.dbo.vnDBA_Objects_Dependencies WITH (NOLOCK)
				WHERE	session_id = ''' + CAST(@session_id AS NVARCHAR(36)) + N''';';

				EXECUTE	sys.sp_executesql @stmt = @query;

				SELECT	@query = N'
				EXECUTE	' + @cross_server + N'.MonDB.dbo.vnDBA_sp_Object_checkDependency
							@isDelete			= 1
						,	@session_id			= ''' + CAST(@session_id AS NVARCHAR(36)) + N'''
						,	@db_name			= NULL
						,	@object_name		= NULL
						;';
						
				EXECUTE	sys.sp_executesql @stmt = @query;
			END;
		END TRY
		BEGIN CATCH
			SELECT	@debug_message = N'Error ' + CAST(@@ERROR AS NVARCHAR) + N' encountered!
		' + ERROR_MESSAGE();
			RAISERROR(@debug_message, 0, 0) WITH NOWAIT;
		END CATCH;

		SELECT	@debug_message = N'DONE: ' + @cross_server + N'.' + @cross_database + N'.' + @cross_schema + N'.' + @cross_entity;
		RAISERROR(@debug_message, 0, 0) WITH NOWAIT;

	END;
	
	-- Check referencing dependencies --
	IF	@server_name IS NULL
	BEGIN
		SELECT	@query = N'
			DECLARE	@query	NVARCHAR(MAX);
			
			SELECT	@query = ''
				WITH cte AS (
					SELECT	referencer_schema	= dsre.referencing_schema_name
						,	referencer_entity	= dsre.referencing_entity_name
						,	referencer_type		= tr.type
						,	referenced_schema	= CAST(N''''' + @schema_name + N''''' AS NVARCHAR(128))
						,	referenced_entity	= CAST(N''''' + @object_name + N''''' AS NVARCHAR(128))
						,	referenced_type		= td.type
						,	level				= ' + CAST(@level - 1 AS NVARCHAR) + N'
					FROM sys.dm_sql_referencing_entities(''''' + @schema_name + N'.' + @object_name + N''''', ''''OBJECT'''') AS dsre
					OUTER APPLY (
						SELECT	o.type
						FROM	sys.objects AS o
						WHERE	o.name = ''''' + @object_name + N'''''
					) td
					OUTER APPLY (
						SELECT	o.type
						FROM	sys.objects AS o
						WHERE	o.name = dsre.referencing_entity_name
					) tr

					UNION ALL

					SELECT	referencer_schema	= dsre.referencing_schema_name
						,	referencer_entity	= dsre.referencing_entity_name
						,	referencer_type		= tr.type
						,	referenced_schema	= cte.referencer_schema
						,	referenced_entity	= cte.referencer_entity
						,	referenced_type		= td.type
						,	level				= cte.level - 1
					FROM	cte
					CROSS APPLY	sys.dm_sql_referencing_entities(cte.referencer_schema + N''''.'''' + cte.referencer_entity, ''''OBJECT'''') dsre
					OUTER APPLY (
						SELECT	o.type
						FROM	sys.objects AS o
						WHERE	o.name = cte.referencer_entity
					) td
					OUTER APPLY (
						SELECT	o.type
						FROM	sys.objects AS o
						WHERE	o.name = dsre.referencing_entity_name
					) tr
				)
				INSERT INTO	#vnDBA_Objects_Dependencies
					(	referencer, referencer_type, referenced_server, referenced_database, referenced_schema, referenced_entity, referenced_type, level)
				SELECT	referencer			= N''''' + @db_name + N''''' + N''''.'''' + cte.referencer_schema + N''''.'''' + cte.referencer_entity
					,	referencer_type		= cte.referencer_type
					,	referenced_server	= NULL
					,	referenced_datebase	= N''''' + @db_name + N'''''
					,	referenced_schema	= cte.referenced_schema
					,	referenced_entity	= cte.referenced_entity
					,	referenced_type		= cte.referenced_type
					,	level				= cte.level
				FROM	cte;'';
			
			EXECUTE	' + @db_name + N'.sys.sp_executesql @stmt = @query;
		';

		EXECUTE	sys.sp_executesql @stmt = @query;
		
	END;
			
	INSERT INTO	MonDB.dbo.vnDBA_Objects_Dependencies
		(	 session_id, referencer, referencer_type, referenced_server, referenced_database, referenced_schema, referenced_entity, referenced_type, level)
	SELECT	@session_id, referencer, referencer_type, referenced_server, referenced_database, referenced_schema, referenced_entity, referenced_type, level
	FROM	#vnDBA_Objects_Dependencies;

	UPDATE	od
	SET		od.referenced_type = rod.referencer_type
	FROM	MonDB.dbo.vnDBA_Objects_Dependencies AS od
	INNER JOIN	MonDB.dbo.vnDBA_Objects_Dependencies AS rod WITH (NOLOCK)
			ON	rod.referencer = ISNULL(od.referenced_server + '.', '') + od.referenced_database + '.' + od.referenced_schema + '.' + od.referenced_entity
			AND	rod.session_id = @session_id
			AND	od.session_id = @session_id;
		
	UPDATE	od
	SET		od.referenced_type = 'RU'
	FROM	MonDB.dbo.vnDBA_Objects_Dependencies AS od
	WHERE	od.referenced_type IS NULL;
		
	IF	@server_name IS NULL
	BEGIN
		INSERT INTO	#aliases (name)
		SELECT	od.referencer
		FROM	MonDB.dbo.vnDBA_Objects_Dependencies AS od WITH (NOLOCK)
		WHERE	od.session_id = @session_id
		UNION
		SELECT	ISNULL(od.referenced_server + N'.', '') + od.referenced_database + N'.' + od.referenced_schema + N'.' + od.referenced_entity
		FROM	MonDB.dbo.vnDBA_Objects_Dependencies AS od WITH (NOLOCK)
		WHERE	od.session_id = @session_id;

		WITH cte AS (
			SELECT	DISTINCT
					root		= od.referencer
				,	processing	= CAST(od.referencer AS NVARCHAR(256))
				,	path		= CAST(a.alias AS NVARCHAR(MAX))
				,	isValid		= CAST(	CASE	WHEN od.referencer LIKE '%[_]xtest%' OR od.referencer LIKE '%[_]xpre%' OR od.referencer LIKE '%[_]UAT%'
													THEN 3
												ELSE 1
										END AS TINYINT)
			FROM		MonDB.dbo.vnDBA_Objects_Dependencies AS od WITH (NOLOCK)
			INNER JOIN	#aliases AS a
					ON	a.name = od.referencer
			WHERE	od.session_id = @session_id
				AND	od.level = (SELECT TOP 1 od.level FROM MonDB.dbo.vnDBA_Objects_Dependencies WITH (NOLOCK) ORDER BY od.level ASC)
			
			UNION ALL	
			
			SELECT	root		= cte.root
				,	processing	= CAST(rd.name AS NVARCHAR(256))
				,	path		= CAST(cte.path + N' -> ' + a.alias AS NVARCHAR(MAX))
				,	isValid		= CAST(	CASE	WHEN rd.name LIKE '%[_]xtest%' OR rd.name LIKE '%[_]xpre%' OR rd.name LIKE '%[_]UAT%'
													THEN 2
												ELSE 3
										END
								& cte.isValid AS TINYINT)
			FROM		cte
			INNER JOIN	MonDB.dbo.vnDBA_Objects_Dependencies AS od WITH (NOLOCK)
					ON	od.session_id = @session_id
					AND	cte.processing = od.referencer
			CROSS APPLY	(
				SELECT	ISNULL(od.referenced_server + N'.', '') + od.referenced_database + N'.' + od.referenced_schema + N'.' + od.referenced_entity
			) rd(name)
			INNER JOIN	#aliases AS a
					ON	a.name = rd.name
		)
		SELECT	DISTINCT
				cte.root
			,	cte.path
			,	cte.isValid
		FROM		cte
		CROSS APPLY	(
			SELECT	MIN(LEN(i.path))
			FROM	cte AS i
			WHERE	i.root = cte.root
				AND i.isValid = 0
		) mx(ln)
		WHERE	isValid = 0
			AND	LEN(cte.path) = mx.ln;
	
		SELECT	referencer		= od.referencer
			,	referencer_type	= od.referencer_type
			,	referenced		= rd.name
			,	referenced_type	= od.referenced_type
			,	[http://yuml.me/diagram/nofunky/class/draw]
			=	'[' + arr.alias
			+	CASE	WHEN od.referencer LIKE '%f[_]%'
							THEN	CASE	WHEN od.referencer LIKE '%[_]xtest%' OR od.referencer LIKE '%[_]xpre%' OR od.referencer LIKE '%[_]UAT%'
												THEN	'{bg:lightsalmon}'
											ELSE	'{bg:lightseagreen}'
									END
						ELSE	CASE	WHEN od.referencer LIKE '%[_]xtest%' OR od.referencer LIKE '%[_]xpre%' OR od.referencer LIKE '%[_]UAT%'
											THEN	'{bg:lightcoral}'
										ELSE	CASE	WHEN	od.referencer_type IN ('U', 'RU', 'V')
															THEN	'{bg:thistle}'
														ELSE	'{bg:lightskyblue}'
												END
								END
				END	+ ']'
			+	CASE	WHEN MAX(od.level) < 0
							THEN	'++-^'
						ELSE	CASE	WHEN od.referencer_type NOT IN ('U', 'RU', 'V') AND od.referenced_type NOT IN ('U', 'RU', 'V')
											THEN	CASE	WHEN od.referenced_server IS NULL
																THEN	'<>-^'
															ELSE	'<>-.-^'
													END
										WHEN od.referencer_type NOT IN ('U', 'RU', 'V') AND od.referenced_type IN ('U', 'RU', 'V')
											THEN	CASE	WHEN od.referenced_server IS NULL
																THEN	'<>->'
															ELSE	'<>-.->'
													END
										WHEN od.referencer_type IN ('U', 'RU', 'V') AND od.referenced_type IN ('U', 'RU', 'V')
											THEN	CASE	WHEN od.referenced_server IS NULL
																THEN	'->'
															ELSE	'-.->'
													END
										ELSE	CASE	WHEN od.referenced_server IS NULL
															THEN	'-^'
														ELSE	'-.-^'
												END
								END
				END
			+	'[' + ard.alias
			+	CASE	WHEN rd.name LIKE '%f[_]%'
							THEN	CASE	WHEN rd.name LIKE '%[_]xtest%' OR rd.name LIKE '%[_]xpre%' OR rd.name LIKE '%[_]UAT%'
												THEN	'{bg:lightsalmon}'
											ELSE	'{bg:lightseagreen}'
									END
						ELSE	CASE	WHEN rd.name LIKE '%[_]xtest%' OR rd.name LIKE '%[_]xpre%' OR rd.name LIKE '%[_]UAT%'
											THEN	'{bg:lightcoral}'
										ELSE	CASE	WHEN	od.referenced_type IN ('U', 'RU', 'V')
															THEN	'{bg:thistle}'
														ELSE	'{bg:lightskyblue}'
												END
								END
				END	+ ']'
		FROM	MonDB.dbo.vnDBA_Objects_Dependencies AS od
		CROSS APPLY	(
			SELECT	ISNULL(od.referenced_server + '.', '') + od.referenced_database + '.' + od.referenced_schema + '.' + od.referenced_entity
		) rd(name)
		INNER JOIN	#aliases AS arr
				ON	arr.name = od.referencer
		INNER JOIN	#aliases AS ard
				ON	ard.name = rd.name
		WHERE	session_id = @session_id
		GROUP BY od.referencer, od.referencer_type, od.referenced_server, rd.name, od.referenced_type, arr.alias, ard.alias
		ORDER BY MAX(od.level) ASC;

		SELECT	a.alias, a.name
		FROM	#aliases AS a;
	
	END;
	
	SELECT	@result = 1;
	
	IF	@server_name IS NULL
	BEGIN
		DELETE FROM	MonDB.dbo.vnDBA_Objects_Dependencies
		WHERE	session_id = @session_id;
	END;

	DROP TABLE	#cross_referenced;
	DROP TABLE	#vnDBA_Objects_Dependencies;
	DROP TABLE	#aliases;
END;
GO

GRANT EXECUTE ON dbo.vnDBA_sp_Object_checkDependency TO vnteam AS dbo;
GO
