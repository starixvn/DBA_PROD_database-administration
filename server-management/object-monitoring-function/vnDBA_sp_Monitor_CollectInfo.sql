ALTER PROCEDURE	dbo.vnDBA_sp_Monitor_CollectInfo
AS
/*
	Creator:	20160803@Billy
	Task:		Objects monitoring function - Collect information - [Redmine: #58941]
	Database:	*ALL_SERVER*.MonDB
	
	Revisions:
		- 20160803@Billy:	v2.01	*start tracking*
*/
BEGIN
	SET NOCOUNT ON;
		
	DECLARE	@query				NVARCHAR(MAX)
		,	@parameter			NVARCHAR(128)
		,	@database			NVARCHAR(128)
		;
	
	DECLARE	@xml_data			NVARCHAR(MAX)
		,	@tmp_xml_data		XML
		;

	CREATE TABLE	#databases (
						database_name	SYSNAME
					,	xml_data		XML
					,	is_done			BIT
					);

	INSERT INTO	#databases
		(	database_name, is_done)
	SELECT	d.name       , 0
	FROM	sys.databases AS d WITH (NOLOCK)
	WHERE	d.name NOT IN (N'master', N'model', N'msdb', N'tempdb')
		AND	d.is_distributor = 0
		AND	d.state = 0
		AND	d.collation_name IS NOT NULL;

	WHILE	0 = 0
	BEGIN
		UPDATE	TOP(1) #databases
		SET		@database = database_name
			,	is_done = 1
		WHERE	is_done = 0;

		IF	@@ROWCOUNT = 0
			BREAK;

		SELECT	@query = N''

	    SELECT	@query = @query + N'
SELECT	@tmp_xml_data = (
			SELECT	''node()''		= (		
						SELECT	''@ReportDate''			= GETDATE()
							,	''@DatabaseName''			= N''' + @database + N'''
							,	(	SELECT	''@TableName''				= t.name
										,	''@TableID''				= t.object_id
										,	''@SchemaName''				= s.name
										,	''@ObjectType''				= t.type
										,	''@CreatedDate''			= t.create_date
										,	''@ModifiedDate''			= t.modify_date
										,	''@IsReplicated''			= t.is_replicated
										,	''@NoOfColumns''			= col.no_of_col
										,	''@HasIdentityColumn''		= col.has_identity
										,	''@LastIdentityValue''		= col.last_value
										,	''@HasTriggers''			= trg.no_of_trig
										,	''@Rowcounts''				= rc.rows
										,	''@TotalSpace_MB''			= CAST((ci.total_pages + nci.total_pages) * 8 / 1024.0 AS DECIMAL(18,6))
										,	''@DataSpace_MB''			= CAST(ci.data_pages * 8 / 1024.0 AS DECIMAL(18,6))
										,	''@IndexSpace_MB''			= CAST((ci.used_pages - ci.data_pages + nci.used_pages) * 8 / 1024.0 AS DECIMAL(18,6))
										,	''@IsDataPartitioned''		= CASE WHEN ci.partition_scheme IS NULL THEN 0 ELSE 1 END
										,	''@Data_FG_PS''				= ISNULL(ci.partition_scheme, ci.file_group)
										,	''@IsIndexPartitioned''		= CASE WHEN nci.partition_scheme IS NULL THEN 0 ELSE 1 END
										,	''@Index_FG_PS''			= ISNULL(nci.partition_scheme, nci.file_group)
									FROM		[' + @database + N'].sys.tables				AS t
									INNER JOIN	[' + @database + N'].sys.schemas				AS s
											ON	s.schema_id = t.schema_id
									CROSS APPLY (
										SELECT	no_of_col				= COUNT(c.column_id)
											,	has_identity			= SUM(CAST(c.is_identity AS TINYINT))
											,	last_value				= MAX(ic.last_value)
										FROM		[' + @database + N'].sys.columns				AS c
										LEFT JOIN	[' + @database + N'].sys.identity_columns	AS ic
												ON	ic.object_id = c.object_id
										WHERE	c.object_id = t.object_id
									) col
									CROSS APPLY	(
										SELECT	no_of_trig				= COUNT(tr.object_id)
										FROM	[' + @database + N'].sys.triggers				AS tr
										WHERE	tr.parent_id = t.object_id
									) trg
									CROSS APPLY	(
										SELECT	rows					= SUM(p.rows)
										FROM		[' + @database + N'].sys.indexes				AS i
										INNER JOIN	[' + @database + N'].sys.partitions			AS p
												ON	p.object_id = i.object_id
												AND	p.index_id = i.index_id
										WHERE	i.object_id = t.object_id
											AND	i.type_desc IN (''HEAP'', ''CLUSTERED'')
									) rc
									CROSS APPLY	(
										SELECT	total_pages				= ISNULL(SUM(au.total_pages), 0)
											,	used_pages				= ISNULL(SUM(au.used_pages), 0)
											,	data_pages				= ISNULL(SUM(CASE au.type WHEN 2 THEN au.used_pages ELSE au.data_pages END), 0)
											,	file_group				= MAX(fg.name)
											,	partition_scheme		= MAX(ps.name)
										FROM		[' + @database + N'].sys.indexes				AS i
										INNER JOIN	[' + @database + N'].sys.partitions			AS p
												ON	p.object_id = i.object_id
												AND	p.index_id = i.index_id
										INNER JOIN	[' + @database + N'].sys.allocation_units	AS au
												ON	au.container_id = p.hobt_id
										INNER JOIN	[' + @database + N'].sys.filegroups			AS fg
												ON	fg.data_space_id = au.data_space_id
										LEFT JOIN	[' + @database + N'].sys.destination_data_spaces AS dds
												ON	dds.data_space_id = fg.data_space_id
										LEFT JOIN	[' + @database + N'].sys.partition_schemes	AS ps
												ON	ps.data_space_id = dds.partition_scheme_id
										WHERE	i.object_id = t.object_id
											AND	i.type_desc IN (''HEAP'', ''CLUSTERED'')
									) ci
									CROSS APPLY	(
										SELECT	total_pages				= ISNULL(SUM(au.total_pages), 0)
											,	used_pages				= ISNULL(SUM(au.used_pages), 0)
											,	data_pages				= ISNULL(SUM(CASE au.type WHEN 2 THEN au.used_pages ELSE au.data_pages END), 0)
											,	file_group				= MAX(fg.name)
											,	partition_scheme		= MAX(ps.name)
										FROM		[' + @database + N'].sys.indexes				AS i
										INNER JOIN	[' + @database + N'].sys.partitions			AS p
												ON	p.object_id = i.object_id
												AND	p.index_id = i.index_id
										INNER JOIN	[' + @database + N'].sys.allocation_units	AS au
												ON	au.container_id = p.hobt_id
										INNER JOIN	[' + @database + N'].sys.filegroups			AS fg
												ON	fg.data_space_id = au.data_space_id
										LEFT JOIN	[' + @database + N'].sys.destination_data_spaces AS dds
												ON	dds.data_space_id = fg.data_space_id
										LEFT JOIN	[' + @database + N'].sys.partition_schemes	AS ps
												ON	ps.data_space_id = dds.partition_scheme_id
										WHERE	i.object_id = t.object_id
											AND	i.type_desc NOT IN (''HEAP'', ''CLUSTERED'')
									) nci
									ORDER BY s.name, t.name
									FOR XML PATH (''TBL'')
								,	TYPE
								)
						FOR XML PATH (''TABLES'')
						,	TYPE
					)
				,	''node()''		= (	
						SELECT	''@ReportDate''			= GETDATE()
							,	''@DatabaseName''			= N''' + @database + N'''
							,	(	SELECT	''@ViewName''				= v.name
										,	''@ViewID''					= v.object_id
										,	''@SchemaName''				= s.name
										,	''@ObjectType''				= v.type
										,	''@CreatedDate''			= v.create_date
										,	''@ModifiedDate''			= v.modify_date
										,	''@IsReplicated''			= v.is_replicated
										,	''@NoOfColumns''			= col.no_of_col
										,	''@HasTriggers''			= trg.no_of_trig
									FROM		[' + @database + N'].sys.views				AS v
									INNER JOIN	[' + @database + N'].sys.schemas				AS s
											ON	s.schema_id = v.schema_id
									CROSS APPLY (
										SELECT	no_of_col				= COUNT(c.column_id)
										FROM	[' + @database + N'].sys.columns				AS c
										WHERE	c.object_id = v.object_id
									) col
									CROSS APPLY	(
										SELECT	no_of_trig				= COUNT(tr.object_id)
										FROM	[' + @database + N'].sys.triggers				AS tr
										WHERE	tr.parent_id = v.object_id
									) trg
									WHERE	v.name NOT LIKE ''syncobj[_]0x%''
									FOR XML PATH (''VIEW'')
								,	TYPE
								)
						FOR XML PATH (''VIEWS'')
						,	TYPE
					)
				,	''node()''		= (	
						SELECT	''@ReportDate''			= GETDATE()
							,	''@DatabaseName''			= N''' + @database + N'''
							,	(	SELECT	''@ProcName''				= p.name
										,	''@ProcID''					= p.object_id
										,	''@SchemaName''				= s.name
										,	''@ObjectType''				= p.type
										,	''@CreatedDate''			= p.create_date
										,	''@ModifiedDate''			= p.modify_date
										,	''@IsReplicated''			= p.is_execution_replicated
										,	''@NoOfParameters''			= pr.no_of_param
										,	''@NoOfPlanGuides''			= pg.no_of_planguide
									FROM		[' + @database + N'].sys.procedures			AS p
									INNER JOIN	[' + @database + N'].sys.schemas				AS s
											ON	s.schema_id = p.schema_id
									CROSS APPLY	(
										SELECT	no_of_param				= COUNT(pr.parameter_id)
										FROM	[' + @database + N'].sys.parameters AS pr
										WHERE	pr.object_id = p.object_id
									) pr
									CROSS APPLY	(
										SELECT	no_of_planguide			= COUNT(pg.plan_guide_id)
										FROM	[' + @database + N'].sys.plan_guides AS pg
										WHERE	pg.scope_object_id = p.object_id
									) pg
									WHERE	p.type = ''P''
									FOR XML PATH (''PROC'')
								,	TYPE
								)
							,	(	SELECT	''@ProcName''				= o.name
										,	''@ProcID''					= o.object_id
										,	''@SchemaName''				= s.name
										,	''@ObjectType''				= o.type
										,	''@CreatedDate''			= o.create_date
										,	''@ModifiedDate''			= o.modify_date
										,	''@NoOfParameters''			= pr.no_of_param
										,	''@NoOfPlanGuides''			= pg.no_of_planguide
									FROM		[' + @database + N'].sys.objects				AS o
									INNER JOIN	[' + @database + N'].sys.schemas				AS s
											ON	s.schema_id = o.schema_id
									CROSS APPLY	(
										SELECT	no_of_param				= COUNT(pr.parameter_id)
										FROM	[' + @database + N'].sys.parameters AS pr
										WHERE	pr.object_id = o.object_id
									) pr
									CROSS APPLY	(
										SELECT	no_of_planguide			= COUNT(pg.plan_guide_id)
										FROM	[' + @database + N'].sys.plan_guides AS pg
										WHERE	pg.scope_object_id = o.object_id
									) pg
									WHERE	o.type = ''PC''
									FOR XML PATH (''PROC_CLR'')
								,	TYPE
								)
							,	(	SELECT	''@ProcName''				= o.name
										,	''@ProcID''					= o.object_id
										,	''@SchemaName''				= s.name
										,	''@ObjectType''				= o.type
										,	''@CreatedDate''			= o.create_date
										,	''@ModifiedDate''			= o.modify_date
										,	''@NoOfParameters''			= pr.no_of_param
										,	''@NoOfPlanGuides''			= pg.no_of_planguide
									FROM		[' + @database + N'].sys.objects				AS o
									INNER JOIN	[' + @database + N'].sys.schemas				AS s
											ON	s.schema_id = o.schema_id
									CROSS APPLY	(
										SELECT	no_of_param				= COUNT(pr.parameter_id)
										FROM	[' + @database + N'].sys.parameters AS pr
										WHERE	pr.object_id = o.object_id
									) pr
									CROSS APPLY	(
										SELECT	no_of_planguide			= COUNT(pg.plan_guide_id)
										FROM	[' + @database + N'].sys.plan_guides AS pg
										WHERE	pg.scope_object_id = o.object_id
									) pg
									WHERE	o.type = ''X''
									FOR XML PATH (''EXTENDED_PROC'')
								,	TYPE
								)
						FOR XML PATH (''PROCEDURES'')
						,	TYPE
					)
				,	''node()''		= (	
						SELECT	''@ReportDate''			= GETDATE()
							,	''@DatabaseName''			= N''' + @database + N'''
							,	(	SELECT	''@FuncName''				= o.name
										,	''@FuncID''					= o.object_id
										,	''@SchemaName''				= s.name
										,	''@ObjectType''				= o.type
										,	''@CreatedDate''			= o.create_date
										,	''@ModifiedDate''			= o.modify_date
										,	''@NoOfParameters''			= pr.no_of_param
									FROM		[' + @database + N'].sys.objects				AS o
									INNER JOIN	[' + @database + N'].sys.schemas				AS s
											ON	s.schema_id = o.schema_id
									CROSS APPLY	(
										SELECT	no_of_param				= COUNT(pr.parameter_id)
										FROM	[' + @database + N'].sys.parameters AS pr
										WHERE	pr.object_id = o.object_id
									) pr
									WHERE	o.type = ''AF''
									FOR XML PATH (''AGGREGATE_CLR'')
								,	TYPE
								)
							,	(	SELECT	''@FuncName''				= o.name
										,	''@FuncID''					= o.object_id
										,	''@SchemaName''				= s.name
										,	''@ObjectType''				= o.type
										,	''@CreatedDate''			= o.create_date
										,	''@ModifiedDate''			= o.modify_date
										,	''@NoOfParameters''			= pr.no_of_param
									FROM		[' + @database + N'].sys.objects				AS o
									INNER JOIN	[' + @database + N'].sys.schemas				AS s
											ON	s.schema_id = o.schema_id
									CROSS APPLY	(
										SELECT	no_of_param				= COUNT(pr.parameter_id)
										FROM	[' + @database + N'].sys.parameters AS pr
										WHERE	pr.object_id = o.object_id
									) pr
									WHERE	o.type = ''FN''
									FOR XML PATH (''SCALAR'')
								,	TYPE
								)
							,	(	SELECT	''@FuncName''				= o.name
										,	''@FuncID''					= o.object_id
										,	''@SchemaName''				= s.name
										,	''@ObjectType''				= o.type
										,	''@CreatedDate''			= o.create_date
										,	''@ModifiedDate''			= o.modify_date
										,	''@NoOfParameters''			= pr.no_of_param
									FROM		[' + @database + N'].sys.objects				AS o
									INNER JOIN	[' + @database + N'].sys.schemas				AS s
											ON	s.schema_id = o.schema_id
									CROSS APPLY	(
										SELECT	no_of_param				= COUNT(pr.parameter_id)
										FROM	[' + @database + N'].sys.parameters AS pr
										WHERE	pr.object_id = o.object_id
									) pr
									WHERE	o.type = ''FS''
									FOR XML PATH (''SCALAR_CLR'')
								,	TYPE
								)
							,	(	SELECT	''@FuncName''				= o.name
										,	''@FuncID''					= o.object_id
										,	''@SchemaName''				= s.name
										,	''@ObjectType''				= o.type
										,	''@CreatedDate''			= o.create_date
										,	''@ModifiedDate''			= o.modify_date
										,	''@NoOfParameters''			= pr.no_of_param
									FROM		[' + @database + N'].sys.objects				AS o
									INNER JOIN	[' + @database + N'].sys.schemas				AS s
											ON	s.schema_id = o.schema_id
									CROSS APPLY	(
										SELECT	no_of_param				= COUNT(pr.parameter_id)
										FROM	[' + @database + N'].sys.parameters AS pr
										WHERE	pr.object_id = o.object_id
									) pr
									WHERE	o.type = ''FT''
									FOR XML PATH (''TABLE_VALUED_CLR'')
								,	TYPE
								)
							,	(	SELECT	''@FuncName''				= o.name
										,	''@FuncID''					= o.object_id
										,	''@SchemaName''				= s.name
										,	''@ObjectType''				= o.type
										,	''@CreatedDate''			= o.create_date
										,	''@ModifiedDate''			= o.modify_date
										,	''@NoOfParameters''			= pr.no_of_param
									FROM		[' + @database + N'].sys.objects				AS o
									INNER JOIN	[' + @database + N'].sys.schemas				AS s
											ON	s.schema_id = o.schema_id
									CROSS APPLY	(
										SELECT	no_of_param				= COUNT(pr.parameter_id)
										FROM	[' + @database + N'].sys.parameters AS pr
										WHERE	pr.object_id = o.object_id
									) pr
									WHERE	o.type = ''IF''
									FOR XML PATH (''INLINE_TABLE_VALUED'')
								,	TYPE
								)
							,	(	SELECT	''@FuncName''				= o.name
										,	''@FuncID''					= o.object_id
										,	''@SchemaName''				= s.name
										,	''@ObjectType''				= o.type
										,	''@CreatedDate''			= o.create_date
										,	''@ModifiedDate''			= o.modify_date
										,	''@NoOfParameters''			= pr.no_of_param
									FROM		[' + @database + N'].sys.objects				AS o
									INNER JOIN	[' + @database + N'].sys.schemas				AS s
											ON	s.schema_id = o.schema_id
									CROSS APPLY	(
										SELECT	no_of_param				= COUNT(pr.parameter_id)
										FROM	[' + @database + N'].sys.parameters AS pr
										WHERE	pr.object_id = o.object_id
									) pr
									WHERE	o.type = ''TF''
									FOR XML PATH (''TABLE_VALUED'')
								,	TYPE
								)
						FOR XML PATH (''FUNCTIONS'')
						,	TYPE
					)
				,	''node()''		= (	
						SELECT	''@ReportDate''			= GETDATE()
							,	''@DatabaseName''			= N''' + @database + N'''
							,	(	SELECT	''@TrigName''				= tr.name
										,	''@TrigID''					= tr.object_id
										,	''@ParentSchema''			= s.name
										,	''@ParentName''				= o.name
										,	''@ObjectType''				= tr.type
										,	''@CreatedDate''			= tr.create_date
										,	''@ModifiedDate''			= tr.modify_date
										,	''@IsDisabled''				= tr.is_disabled
										,	''@IsInsteadOf''			= tr.is_instead_of_trigger
									FROM		[' + @database + N'].sys.triggers			AS tr
									INNER JOIN	[' + @database + N'].sys.objects				AS o
											ON	o.object_id = tr.parent_id
									INNER JOIN	[' + @database + N'].sys.schemas				AS s
											ON	s.schema_id = o.schema_id
									WHERE	tr.parent_class <> 0
									FOR XML PATH (''TRIG_DML'')
								,	TYPE
								)
							,	(	SELECT	''@TrigName''				= tr.name
										,	''@TrigID''					= tr.object_id
										,	''@ObjectType''				= tr.type
										,	''@CreatedDate''			= tr.create_date
										,	''@ModifiedDate''			= tr.modify_date
										,	''@IsDisabled''				= tr.is_disabled
										,	''@IsInsteadOf''			= tr.is_instead_of_trigger
									FROM	[' + @database + N'].sys.triggers				AS tr
									WHERE	tr.parent_class = 0
									FOR XML PATH (''TRIG_DDL'')
								,	TYPE
								)
						FOR XML PATH (''TRIGGERS'')
						,	TYPE
					)
			FOR XML PATH ('''')
			,	TYPE
		);'
		,	@parameter = N'@tmp_xml_data XML OUTPUT'
		;

		EXECUTE	sys.sp_executesql @query, @parameter, @tmp_xml_data = @tmp_xml_data OUTPUT;
		
		UPDATE	#databases
		SET		xml_data = @tmp_xml_data
		WHERE	database_name = @database;

	END;
	
	SELECT	@query = N'
SELECT	@xml_data = (
			SELECT	''@ServerName''	= @@SERVERNAME
				,	''node()''		= (
						SELECT	''@ReportDate''			= GETDATE()
							,	(	SELECT	''@DBName''					= d.name
										,	''@DBID''					= d.dbid
										,	''@Status''					= d.status
										,	''@CreatedDate''			= d.crdate
										,	''@Category''				= d.category
										,	''@CompatibilityLevel''		= d.cmptlevel
										,	''@Filename''				= d.filename
									FROM sys.sysdatabases				AS d
									FOR XML PATH (''DB'')
									,	TYPE
								)
						FOR XML PATH (''DATABASES'')
						,	TYPE
					)
				,	''node()''		= (
						SELECT	''@ReportDate''			= GETDATE()
							,	(	SELECT	''@PrincipalName''			= sp.name
										,	''@PrincipalID''			= sp.principal_id
										,	''@PrincipalType''			= sp.type
										,	''@IsDisable''				= sp.is_disabled
										,	''@CreatedDate''			= sp.create_date
										,	''@ModifiedDate''			= sp.modify_date
									FROM	sys.server_principals		AS sp
									WHERE	sp.type = ''S''
									FOR XML PATH (''SQL_LOGIN'')
								,	TYPE
								)
							,	(	SELECT	''@PrincipalName''			= sp.name
										,	''@PrincipalID''			= sp.principal_id
										,	''@PrincipalType''			= sp.type
										,	''@IsDisable''				= sp.is_disabled
										,	''@CreatedDate''			= sp.create_date
										,	''@ModifiedDate''			= sp.modify_date
									FROM	sys.server_principals		AS sp
									WHERE	sp.type = ''U''
									FOR XML PATH (''WINDOWS_LOGIN'')
								,	TYPE
								)
							,	(	SELECT	''@PrincipalName''			= sp.name
										,	''@PrincipalID''			= sp.principal_id
										,	''@PrincipalType''			= sp.type
										,	''@IsDisable''				= sp.is_disabled
										,	''@CreatedDate''			= sp.create_date
										,	''@ModifiedDate''			= sp.modify_date
									FROM	sys.server_principals		AS sp
									WHERE	sp.type = ''G''
									FOR XML PATH (''WINDOWS_GROUP'')
								,	TYPE
								)
							,	(	SELECT	''@PrincipalName''			= sp.name
										,	''@PrincipalID''			= sp.principal_id
										,	''@PrincipalType''			= sp.type
										,	''@IsDisable''				= sp.is_disabled
										,	''@CreatedDate''			= sp.create_date
										,	''@ModifiedDate''			= sp.modify_date
									FROM	sys.server_principals		AS sp
									WHERE	sp.type = ''R''
									FOR XML PATH (''SERVER_ROLE'')
								,	TYPE
								)
							,	(	SELECT	''@PrincipalName''			= sp.name
										,	''@PrincipalID''			= sp.principal_id
										,	''@PrincipalType''			= sp.type
										,	''@IsDisable''				= sp.is_disabled
										,	''@CreatedDate''			= sp.create_date
										,	''@ModifiedDate''			= sp.modify_date
									FROM	sys.server_principals		AS sp
									WHERE	sp.type = ''C''
									FOR XML PATH (''CERTIFICATE_LOGIN'')
								,	TYPE
								)
							,	(	SELECT	''@PrincipalName''			= sp.name
										,	''@PrincipalID''			= sp.principal_id
										,	''@PrincipalType''			= sp.type
										,	''@IsDisable''				= sp.is_disabled
										,	''@CreatedDate''			= sp.create_date
										,	''@ModifiedDate''			= sp.modify_date
									FROM	sys.server_principals		AS sp
									WHERE	sp.type = ''K''
									FOR XML PATH (''ASYMMETRIC_KEY_LOGIN'')
								,	TYPE
								)
						FOR XML PATH (''PRINCIPALS'')
						,	TYPE
					)
				,	''node()''		= (
						SELECT	''@ReportDate''			= GETDATE()
							,	(	SELECT	''@Server''					= @@SERVERNAME
										,	''@JobID''					= sj.job_id
										,	''@JobName''				= sj.name
										,	''@OwnerName''				= SUSER_SNAME(sj.owner_sid)
										,	''@Category''				= sc.name
										,	''@IsEnabled''				= sj.enabled
										,	''@StartExecutionDate''		= sja.start_execution_date
										,	''@RunRequestSource''		= sja.run_requested_source
										,	''@RunStatus''				= sjh.run_status
										,	''@NextScheduledRunDate''	= sja.next_scheduled_run_date
										,	''@RunDuration''			= (sjh.run_duration / 10000) * 3600 + ((sjh.run_duration % 10000) / 100) * 60 + (sjh.run_duration % 100)
									FROM			msdb.dbo.sysjobs		AS sj WITH (NOLOCK)
									LEFT OUTER JOIN	msdb.dbo.syscategories	AS sc WITH (NOLOCK)
												ON	sj.category_id = sc.category_id
									OUTER APPLY		(	SELECT	TOP 1 isja.run_requested_source, isja.start_execution_date, isja.job_history_id, isja.next_scheduled_run_date
														FROM	msdb.dbo.sysjobactivity AS isja WITH (NOLOCK)
														WHERE	isja.job_id = sj.job_id
															AND	isja.start_execution_date IS NOT NULL
														ORDER BY isja.start_execution_date
													) AS sja
									LEFT OUTER JOIN	msdb.dbo.sysjobhistory	AS sjh WITH (NOLOCK)
												ON	sjh.instance_id = sja.job_history_id
									FOR XML PATH (''JOB'')
								,	TYPE
								)
						FOR XML PATH (''JOBS'')
						,	TYPE
					)
				,	''node()''		= (
						SELECT	''node()'' = xml_data
						FROM	#databases
						FOR XML PATH ('''')
						,	TYPE
					)
			FOR XML PATH (''ROOT'')
		);'
		,	@parameter = N'@xml_data NVARCHAR(MAX) OUTPUT'
		;

	EXECUTE	sys.sp_executesql @query, @parameter, @xml_data = @xml_data OUTPUT;

	DELETE FROM	dbo.vnDBA_Monitor_Staging
	WHERE	server_name = @@SERVERNAME;

	INSERT INTO	dbo.vnDBA_Monitor_Staging
		(	info_date
		,	server_name
		,	xml_data
		)
	SELECT	info_date			= GETDATE()
		,	server_name			= @@SERVERNAME
		,	xml_data			= @xml_data
		;

	DROP TABLE	#databases;

END;
GO

