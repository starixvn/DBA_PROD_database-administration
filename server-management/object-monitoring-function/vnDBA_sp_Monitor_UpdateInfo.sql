ALTER PROCEDURE	dbo.vnDBA_sp_Monitor_UpdateInfo
						@mode			INT		= 0
					,	@object_type	VARCHAR(64)	= NULL
AS
/*
	Creator:	20160805@Billy
	Task:		Objects monitoring function - Update objects information - [Redmine: #58941]
	Database:	DBTP.MonDB
	
	Revisions:
		- 20160805@Billy:	v2.01	*start tracking*

	Parameters Explaination:
		@mode:			Update mode
							0 - Update all information
							1 - Resolve ENABLED - Update information of enabled objects
							2 - Resolve DISABLED - Update information of disabled objects
							3 - Resolve CREATED - Insert new objects information
							4 - Resolve DELETED - Delete old objects information

		@object_type:	Object type
							NULL		- All object types
							'DATABASE'
							'PRINCIPAL'
							'JOB'
							'TABLE'
							'VIEW'
							'PROCEDURE'
							'FUNCTION'
							'TRIGGER'
*/
BEGIN
    SET NOCOUNT ON;
	
	DECLARE	@xml_data			XML
		,	@xml_doc			INT
		;

	SELECT	@xml_data = (
				SELECT	'node()'		= CONVERT(XML, ms.xml_data)
				FROM	dbo.vnDBA_Monitor_Staging AS ms
				FOR XML PATH ('')
				,	ROOT ('STAGING')
			);

	EXECUTE	sys.sp_xml_preparedocument @xml_doc OUTPUT, @xml_data;
	

	--	BEGIN STEP 1:
	--		Parse data
	----------------------------------------------------------------------------------------------------
	
	CREATE TABLE	#databases (
						server_name					NVARCHAR(128)
					,	report_date					DATETIME
					,	database_name				NVARCHAR(128)
					,	database_id					VARCHAR(40)
					,	status						INT
					,	created_date				DATETIME
					,	category					INT
					,	compatibility_level			TINYINT
					,	filename					NVARCHAR(260)
					,	xml_data					XML
					);

	INSERT INTO	#databases
		(	server_name, report_date, database_name, database_id, status, created_date, category, compatibility_level, filename, xml_data)
	SELECT	server_name, report_date, database_name, database_id, status, created_date, category, compatibility_level, filename, xml_data
	FROM	OPENXML(@xml_doc, '/STAGING/ROOT/DATABASES/*', 1)
			WITH (
				server_name					NVARCHAR(128)		'../../@ServerName'
			,	report_date					DATETIME			'../@ReportDate'
			,	database_name				NVARCHAR(128)		'@DBName'
			,	database_id					VARCHAR(40)			'@DBID'
			,	status						INT					'@Status'
			,	created_date				DATETIME			'@CreatedDate'
			,	category					INT					'@Category'
			,	compatibility_level			TINYINT				'@CompatibilityLevel'
			,	filename					NVARCHAR(260)		'@Filename'
			,	xml_data					XML					'.'
			);
	

	CREATE TABLE	#principals (
						server_name					NVARCHAR(128)
					,	report_date					DATETIME
					,	prinicpal_name				NVARCHAR(128)
					,	principal_id				VARCHAR(40)
					,	principal_type				CHAR(1)
					,	is_disabled					BIT
					,	created_date				DATETIME
					,	modified_date				DATETIME
					,	xml_data					XML
					);

	INSERT INTO	#principals
		(	server_name, report_date, prinicpal_name, principal_id, principal_type, is_disabled, created_date, modified_date, xml_data)
	SELECT	server_name, report_date, prinicpal_name, principal_id, principal_type, is_disabled, created_date, modified_date, xml_data
	FROM	OPENXML(@xml_doc, '/STAGING/ROOT/PRINCIPALS/*', 1)
			WITH (
				server_name					NVARCHAR(128)		'../../@ServerName'
			,	report_date					DATETIME			'../@ReportDate'
			,	prinicpal_name				NVARCHAR(128)		'@PrincipalName'
			,	principal_id				VARCHAR(40)			'@PrincipalID'
			,	principal_type				CHAR(1)				'@PrincipalType'
			,	is_disabled					BIT					'@IsDisable'
			,	created_date				DATETIME			'@CreatedDate'
			,	modified_date				DATETIME			'@ModifiedDate'
			,	xml_data					XML					'.'
			);

			
	CREATE TABLE	#jobs (
						server_name					NVARCHAR(128)
					,	report_date					DATETIME
					,	job_id						VARCHAR(40)
					,	job_name					NVARCHAR(128)
					,	owner_name					NVARCHAR(256)
					,	category					NVARCHAR(128)
					,	is_enabled					TINYINT
					,	start_execution_date		DATETIME
					,	run_requested_source		NVARCHAR(128)
					,	run_status					INT
					,	next_scheduled_run_date		DATETIME
					,	run_duration				INT
					,	xml_data					XML
					);

	INSERT INTO	#jobs
		(	server_name, report_date, job_id, job_name, owner_name, category, is_enabled, start_execution_date, run_requested_source, run_status, next_scheduled_run_date, run_duration, xml_data)
	SELECT	server_name, report_date, job_id, job_name, owner_name, category, is_enabled, start_execution_date, run_requested_source, run_status, next_scheduled_run_date, run_duration, xml_data
	FROM	OPENXML(@xml_doc, '/STAGING/ROOT/JOBS/*', 1)
			WITH (
				server_name					NVARCHAR(128)		'../../@ServerName'
			,	report_date					DATETIME			'../@ReportDate'
			,	job_id						VARCHAR(40)			'@JobID'
			,	job_name					NVARCHAR(128)		'@JobName'
			,	owner_name					NVARCHAR(256)		'@OwnerName'
			,	category					NVARCHAR(128)		'@Category'
			,	is_enabled					TINYINT				'@IsEnabled'
			,	start_execution_date		DATETIME			'@StartExecutionDate'
			,	run_requested_source		NVARCHAR(128)		'@RunRequestSource'
			,	run_status					INT					'@RunStatus'
			,	next_scheduled_run_date		DATETIME			'@NextScheduledRunDate'
			,	run_duration				INT					'@RunDuration'
			,	xml_data					XML					'.'
			);


	CREATE TABLE	#tables (
						server_name					NVARCHAR(128)
					,	database_name				NVARCHAR(128)
					,	report_date					DATETIME
					,	table_name					NVARCHAR(128)
					,	table_id					VARCHAR(40)
					,	schema_name					NVARCHAR(128)
					,	object_type					CHAR(2)
					,	created_date				DATETIME
					,	modified_date				DATETIME
					,	is_replicated				BIT
					,	no_of_col					INT
					,	has_identity				INT
					,	last_identity				BIGINT
					,	no_of_trig					INT
					,	row_count					BIGINT
					,	total_space_mb				DECIMAL
					,	data_space_mb				DECIMAL
					,	index_space_mb				DECIMAL
					,	is_data_partitioned			BIT
					,	data_fg_ps					NVARCHAR(128)
					,	is_index_partitioned		BIT
					,	index_fg_ps					NVARCHAR(128)
					,	xml_data					XML
					,	full_name					AS schema_name + '.' + table_name
					);

	INSERT INTO	#tables
		(	server_name, database_name, report_date, table_name, table_id, schema_name, object_type, created_date, modified_date, is_replicated, no_of_col, has_identity, last_identity, no_of_trig, row_count, total_space_mb, data_space_mb, index_space_mb, is_data_partitioned, data_fg_ps, is_index_partitioned, index_fg_ps, xml_data)
	SELECT	server_name, database_name, report_date, table_name, table_id, schema_name, object_type, created_date, modified_date, is_replicated, no_of_col, has_identity, last_identity, no_of_trig, row_count, total_space_mb, data_space_mb, index_space_mb, is_data_partitioned, data_fg_ps, is_index_partitioned, index_fg_ps, xml_data
	FROM	OPENXML(@xml_doc, '/STAGING/ROOT/TABLES/*', 1)
			WITH (
				server_name					NVARCHAR(128)		'../../@ServerName'
			,	database_name				NVARCHAR(128)		'../@DatabaseName'
			,	report_date					DATETIME			'../@ReportDate'
			,	table_name					NVARCHAR(128)		'@TableName'
			,	table_id					VARCHAR(40)			'@TableID'
			,	schema_name					NVARCHAR(128)		'@SchemaName'
			,	object_type					CHAR(2)				'@ObjectType'
			,	created_date				DATETIME			'@CreatedDate'
			,	modified_date				DATETIME			'@ModifiedDate'
			,	is_replicated				BIT					'@IsReplicated'
			,	no_of_col					INT					'@NoOfColumns'
			,	has_identity				INT					'@HasIdentityColumn'
			,	last_identity				BIGINT				'@LastIdentityValue'
			,	no_of_trig					INT					'@HasTriggers'
			,	row_count					BIGINT				'@Rowcounts'
			,	total_space_mb				DECIMAL(18,6)		'@TotalSpace_MB'
			,	data_space_mb				DECIMAL(18,6)		'@DataSpace_MB'
			,	index_space_mb				DECIMAL(18,6)		'@IndexSpace_MB'
			,	is_data_partitioned			BIT					'@IsDataPartitioned'
			,	data_fg_ps					NVARCHAR(128)		'@Data_FG_PS'
			,	is_index_partitioned		BIT					'@IsIndexPartitioned'
			,	index_fg_ps					NVARCHAR(128)		'@Index_FG_PS'
			,	xml_data					XML					'.'
			);

			
	CREATE TABLE	#views (
						server_name					NVARCHAR(128)
					,	database_name				NVARCHAR(128)
					,	report_date					DATETIME
					,	view_name					NVARCHAR(128)
					,	view_id						VARCHAR(40)
					,	schema_name					NVARCHAR(128)
					,	object_type					CHAR(2)
					,	created_date				DATETIME
					,	modified_date				DATETIME
					,	is_replicated				BIT
					,	no_of_col					INT
					,	no_of_trig					INT
					,	xml_data					XML
					,	full_name					AS schema_name + '.' + view_name
					);

	INSERT INTO	#views
		(	server_name, database_name, report_date, view_name, view_id, schema_name, object_type, created_date, modified_date, is_replicated, no_of_col, no_of_trig, xml_data)	
	SELECT	server_name, database_name, report_date, view_name, view_id, schema_name, object_type, created_date, modified_date, is_replicated, no_of_col, no_of_trig, xml_data
	FROM	OPENXML(@xml_doc, '/STAGING/ROOT/VIEWS/*', 1)
			WITH (
				server_name					NVARCHAR(128)		'../../@ServerName'
			,	database_name				NVARCHAR(128)		'../@DatabaseName'
			,	report_date					DATETIME			'../@ReportDate'
			,	view_name					NVARCHAR(128)		'@ViewName'
			,	view_id						VARCHAR(40)			'@ViewID'
			,	schema_name					NVARCHAR(128)		'@SchemaName'
			,	object_type					CHAR(2)				'@ObjectType'
			,	created_date				DATETIME			'@CreatedDate'
			,	modified_date				DATETIME			'@ModifiedDate'
			,	is_replicated				BIT					'@IsReplicated'
			,	no_of_col					INT					'@NoOfColumns'
			,	no_of_trig					INT					'@HasTriggers'
			,	xml_data					XML					'.'
			);

	
	CREATE TABLE	#procedures (
						server_name					NVARCHAR(128)
					,	database_name				NVARCHAR(128)
					,	report_date					DATETIME
					,	proc_name					NVARCHAR(128)
					,	proc_id						VARCHAR(40)
					,	schema_name					NVARCHAR(128)
					,	object_type					CHAR(2)
					,	created_date				DATETIME
					,	modified_date				DATETIME
					,	is_replicated				BIT
					,	no_of_param					INT
					,	no_of_planguide				INT
					,	xml_data					XML
					,	full_name					AS schema_name + '.' + proc_name
					);

	INSERT INTO	#procedures
		(	server_name, database_name, report_date, proc_name, proc_id, schema_name, object_type, created_date, modified_date, is_replicated, no_of_param, no_of_planguide, xml_data)
	SELECT	server_name, database_name, report_date, proc_name, proc_id, schema_name, object_type, created_date, modified_date, is_replicated, no_of_param, no_of_planguide, xml_data
	FROM	OPENXML(@xml_doc, '/STAGING/ROOT/PROCEDURES/*', 1)
			WITH (
				server_name					NVARCHAR(128)		'../../@ServerName'
			,	database_name				NVARCHAR(128)		'../@DatabaseName'
			,	report_date					DATETIME			'../@ReportDate'
			,	proc_name					NVARCHAR(128)		'@ProcName'
			,	proc_id						VARCHAR(40)			'@ProcID'
			,	schema_name					NVARCHAR(128)		'@SchemaName'
			,	object_type					CHAR(2)				'@ObjectType'
			,	created_date				DATETIME			'@CreatedDate'
			,	modified_date				DATETIME			'@ModifiedDate'
			,	is_replicated				BIT					'@IsReplicated'
			,	no_of_param					INT					'@NoOfParameters'
			,	no_of_planguide				INT					'@NoOfPlanGuides'
			,	xml_data					XML					'.'
			);

	
	CREATE TABLE	#functions (
						server_name					NVARCHAR(128)
					,	database_name				NVARCHAR(128)
					,	report_date					DATETIME
					,	func_name					NVARCHAR(128)
					,	func_id						VARCHAR(40)
					,	schema_name					NVARCHAR(128)
					,	object_type					CHAR(2)
					,	created_date				DATETIME
					,	modified_date				DATETIME
					,	no_of_param					INT
					,	xml_data					XML
					,	full_name					AS schema_name + '.' + func_name
					);

	INSERT INTO	#functions
		(	server_name, database_name, report_date, func_name, func_id, schema_name, object_type, created_date, modified_date, no_of_param, xml_data)
	SELECT	server_name, database_name, report_date, func_name, func_id, schema_name, object_type, created_date, modified_date, no_of_param, xml_data
	FROM	OPENXML(@xml_doc, '/STAGING/ROOT/FUNCTIONS/*', 1)
			WITH (
				server_name					NVARCHAR(128)		'../../@ServerName'
			,	database_name				NVARCHAR(128)		'../@DatabaseName'
			,	report_date					DATETIME			'../@ReportDate'
			,	func_name					NVARCHAR(128)		'@FuncName'
			,	func_id						VARCHAR(40)			'@FuncID'
			,	schema_name					NVARCHAR(128)		'@SchemaName'
			,	object_type					CHAR(2)				'@ObjectType'
			,	created_date				DATETIME			'@CreatedDate'
			,	modified_date				DATETIME			'@ModifiedDate'
			,	no_of_param					INT					'@NoOfParameters'
			,	xml_data					XML					'.'
			);

	
	CREATE TABLE	#triggers (
						server_name					NVARCHAR(128)
					,	database_name				NVARCHAR(128)
					,	report_date					DATETIME
					,	trig_name					NVARCHAR(128)
					,	trig_id						VARCHAR(40)
					,	parent_schema_name			NVARCHAR(128)
					,	parent_name					NVARCHAR(128)
					,	object_type					CHAR(2)
					,	created_date				DATETIME
					,	modified_date				DATETIME
					,	is_disabled					BIT
					,	is_instead_of_trigger		BIT
					,	xml_data					XML
					);

	INSERT INTO	#triggers
		(	server_name, database_name, report_date, trig_name, trig_id, parent_schema_name, parent_name, object_type, created_date, modified_date, is_disabled, is_instead_of_trigger, xml_data)
	SELECT	server_name, database_name, report_date, trig_name, trig_id, parent_schema_name, parent_name, object_type, created_date, modified_date, is_disabled, is_instead_of_trigger, xml_data
	FROM	OPENXML(@xml_doc, '/STAGING/ROOT/TRIGGERS/*', 1)
			WITH (
				server_name					NVARCHAR(128)		'../../@ServerName'
			,	database_name				NVARCHAR(128)		'../@DatabaseName'
			,	report_date					DATETIME			'../@ReportDate'
			,	trig_name					NVARCHAR(128)		'@TrigName'
			,	trig_id						VARCHAR(40)			'@TrigID'
			,	parent_schema_name			NVARCHAR(128)		'@ParentSchema'
			,	parent_name					NVARCHAR(128)		'@ParentName'
			,	object_type					CHAR(2)				'@ObjectType'
			,	created_date				DATETIME			'@CreatedDate'
			,	modified_date				DATETIME			'@ModifiedDate'
			,	is_disabled					BIT					'@IsDisabled'
			,	is_instead_of_trigger		BIT					'@IsInsteadOf'
			,	xml_data					XML					'.'
			);
			

	--	BEGIN STEP 2:	MODE 0
	--		Update all information
	----------------------------------------------------------------------------------------------------
	IF	@mode = 0
	BEGIN
		IF	ISNULL(@object_type, 'DATABASE') = 'DATABASE'
		BEGIN
			UPDATE	mi
			SET		mi.xml_data = d.xml_data
			FROM		#databases AS d
			INNER JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = d.server_name
					AND	mi.object_id = d.database_id
					AND	mi.object_type = 'DATABASE'
			WHERE	mi.object_type = 'DATABASE';
		END;

		IF	ISNULL(@object_type, 'PRINCIPAL') = 'PRINCIPAL'
		BEGIN
			UPDATE	mi
			SET		mi.update_date = p.modified_date
				,	mi.xml_data = p.xml_data
			FROM		#principals AS p
			INNER JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = p.server_name
					AND	mi.object_id = p.principal_id
					AND	mi.object_type = 'PRINCIPAL'
			WHERE	mi.update_date < p.modified_date
				AND	mi.object_type = 'PRINCIPAL';
		END;

		IF	ISNULL(@object_type, 'JOB') = 'JOB'
		BEGIN
			UPDATE	mi
			SET		mi.xml_data = j.xml_data
			FROM		#jobs AS j
			INNER JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = j.server_name
					AND	mi.object_id = j.job_id
					AND	mi.object_type = 'JOB'
			CROSS APPLY	mi.xml_data.nodes('*') nodes(node)
			WHERE	node.value('@IsEnabled', 'BIT') = j.is_enabled
				AND	mi.object_type = 'JOB';
		END;

		IF	ISNULL(@object_type, 'TABLE') = 'TABLE'
		BEGIN
			UPDATE	mi
			SET		mi.update_date = t.modified_date
				,	mi.xml_data = t.xml_data
			FROM		#tables AS t
			INNER JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = t.server_name
					AND	mi.database_name = t.database_name
					AND	mi.object_id = t.table_id
					AND	mi.object_type = 'TABLE'
			WHERE	mi.update_date < t.modified_date
				AND	mi.object_type = 'TABLE';
		END;

		IF	ISNULL(@object_type, 'VIEW') = 'VIEW'
		BEGIN
			UPDATE	mi
			SET		mi.update_date = v.modified_date
				,	mi.xml_data = v.xml_data
			FROM		#views AS v
			INNER JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = v.server_name
					AND	mi.database_name = v.database_name
					AND	mi.object_id = v.view_id
					AND	mi.object_type = 'VIEW'
			WHERE	mi.update_date < v.modified_date
				AND	mi.object_type = 'VIEW';
		END;

		IF	ISNULL(@object_type, 'PROCEDURE') = 'PROCEDURE'
		BEGIN
			UPDATE	mi
			SET		mi.update_date = p.modified_date
				,	mi.xml_data = p.xml_data
			FROM		#procedures AS p
			INNER JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = p.server_name
					AND	mi.database_name = p.database_name
					AND	mi.object_id = p.proc_id
					AND	mi.object_type = 'PROCEDURE'
			WHERE	mi.update_date < p.modified_date
				AND	mi.object_type = 'PROCEDURE';
		END;

		IF	ISNULL(@object_type, 'FUNCTION') = 'FUNCTION'
		BEGIN
			UPDATE	mi
			SET		mi.update_date = f.modified_date
				,	mi.xml_data = f.xml_data
			FROM		#functions AS f
			INNER JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = f.server_name
					AND	mi.database_name = f.database_name
					AND	mi.object_id = f.func_id
					AND	mi.object_type = 'FUNCTION'
			WHERE	mi.update_date < f.modified_date
				AND	mi.object_type = 'FUNCTION';
		END;

		IF	ISNULL(@object_type, 'TRIGGER') = 'TRIGGER'
		BEGIN
			UPDATE	mi
			SET		mi.update_date = t.modified_date
				,	mi.xml_data = t.xml_data
			FROM		#triggers AS t
			INNER JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = t.server_name
					AND	mi.database_name = t.database_name
					AND	mi.object_id = t.trig_id
					AND	mi.object_type = 'TRIGGER'
			WHERE	mi.update_date < t.modified_date
				AND	mi.object_type = 'TRIGGER';
		END;
	END;
			

	--	BEGIN STEP 3:	MODE 1 - ENABLED
	--		Update enable information
	----------------------------------------------------------------------------------------------------
	IF	@mode = 1
	BEGIN
		IF	ISNULL(@object_type, 'JOB') = 'JOB'
		BEGIN
			UPDATE	mr
			SET		mr.resolve_date = GETDATE()
			FROM		dbo.vnDBA_Monitor_Report AS mr
			INNER JOIN	#jobs AS j
					ON	j.server_name = mr.server_name
					AND	j.job_id = mr.object_id
					AND	mr.object_type = 'JOB'
			INNER JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = j.server_name
					AND	mi.object_id = j.job_id
					AND	mi.object_type = mr.object_type
			CROSS APPLY	mi.xml_data.nodes('*') nodes(node)
			WHERE	j.is_enabled = 1
				AND	mr.report_type = 'ENABLED'
				AND	mr.object_type = 'JOB';

			UPDATE	mi
			SET		mi.xml_data = j.xml_data
			FROM		#jobs AS j
			INNER JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = j.server_name
					AND	mi.object_id = j.job_id
					AND	mi.object_type = 'JOB'
			CROSS APPLY	mi.xml_data.nodes('*') nodes(node)
			WHERE	node.value('@IsEnabled', 'BIT') = 0
				AND	j.is_enabled = 1
				AND	mi.object_type = 'JOB';
		END;
	END;
			

	--	BEGIN STEP 4:	MODE 2 - DISABLED
	--		Update disable information
	----------------------------------------------------------------------------------------------------
	IF	@mode = 2
	BEGIN
		IF	ISNULL(@object_type, 'JOB') = 'JOB'
		BEGIN
			UPDATE	mr
			SET		mr.resolve_date = GETDATE()
			FROM		dbo.vnDBA_Monitor_Report AS mr
			INNER JOIN	#jobs AS j
					ON	j.server_name = mr.server_name
					AND	j.job_id = mr.object_id
					AND	mr.object_type = 'JOB'
			INNER JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = j.server_name
					AND	mi.object_id = j.job_id
					AND	mi.object_type = mr.object_type
			CROSS APPLY	mi.xml_data.nodes('*') nodes(node)
			WHERE	j.is_enabled = 0
				AND	mr.report_type = 'DISABLED'
				AND	mr.object_type = 'JOB';

			UPDATE	mi
			SET		mi.xml_data = j.xml_data
			FROM		#jobs AS j
			INNER JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = j.server_name
					AND	mi.object_id = j.job_id
					AND	mi.object_type = 'JOB'
			CROSS APPLY	mi.xml_data.nodes('*') nodes(node)
			WHERE	node.value('@IsEnabled', 'BIT') = 1
				AND	j.is_enabled = 0
				AND	mi.object_type = 'JOB';
		END;
	END;
			

	--	BEGIN STEP 5:	MODE 3 - CREATED
	--		Insert new objects information
	----------------------------------------------------------------------------------------------------
	IF	@mode = 3
	BEGIN
		IF	ISNULL(@object_type, 'DATABASE') = 'DATABASE'
		BEGIN
			INSERT INTO	dbo.vnDBA_Monitor_Information
				(	  server_name, database_name,   object_id  ,   object_name  , object_type,   created_date,   update_date ,   xml_data)
			SELECT	d.server_name, ''           , d.database_id, d.database_name, 'DATABASE' , d.created_date, d.created_date, d.xml_data
			FROM		#databases AS d
			LEFT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = d.server_name
					AND	mi.object_id = d.database_id
					AND	mi.object_type = 'DATABASE'
			WHERE	mi.object_id IS NULL;

			UPDATE	mr
			SET		mr.resolve_date = GETDATE()
			FROM		dbo.vnDBA_Monitor_Report AS mr
			INNER JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = mr.server_name
					AND	mi.object_id = mr.object_id
			WHERE	mr.object_type = 'DATABASE'
				AND	mr.report_type = 'CREATED';
		END;

		IF	ISNULL(@object_type, 'PRINCIPAL') = 'PRINCIPAL'
		BEGIN
			INSERT INTO	dbo.vnDBA_Monitor_Information
				(	  server_name, database_name,   object_id   ,   object_name   , object_type,   created_date,   update_date  ,   xml_data)
			SELECT	p.server_name, ''           , p.principal_id, p.prinicpal_name, 'PRINCIPAL', p.created_date, p.modified_date, p.xml_data
			FROM		#principals AS p
			LEFT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = p.server_name
					AND	mi.object_id = p.principal_id
					AND	mi.object_type = 'PRINCIPAL'
			WHERE	mi.object_id IS NULL;

			UPDATE	mr
			SET		mr.resolve_date = GETDATE()
			FROM		dbo.vnDBA_Monitor_Report AS mr
			INNER JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = mr.server_name
					AND	mi.object_id = mr.object_id
			WHERE	mr.object_type = 'PRINCIPAL'
				AND	mr.report_type = 'CREATED';
		END;

		IF	ISNULL(@object_type, 'JOB') = 'JOB'
		BEGIN
			INSERT INTO	dbo.vnDBA_Monitor_Information
				(	  server_name, database_name,   object_id,   object_name, object_type,   created_date,   update_date,   xml_data)
			SELECT	j.server_name, ''           , j.job_id   , j.job_name   , 'JOB'      , j.report_date , j.report_date, j.xml_data
			FROM		#jobs AS j
			LEFT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = j.server_name
					AND	mi.object_id = j.job_id
					AND	mi.object_type = 'JOB'
			WHERE	mi.object_id IS NULL;

			UPDATE	mr
			SET		mr.resolve_date = GETDATE()
			FROM		dbo.vnDBA_Monitor_Report AS mr
			INNER JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = mr.server_name
					AND	mi.object_id = mr.object_id
			WHERE	mr.object_type = 'JOB'
				AND	mr.report_type = 'CREATED';
		END;

		IF	ISNULL(@object_type, 'TABLE') = 'TABLE'
		BEGIN
			INSERT INTO	dbo.vnDBA_Monitor_Information
				(	  server_name,   database_name,   object_id,   object_name, object_type,   created_date,   update_date  ,   xml_data)
			SELECT	t.server_name, t.database_name, t.table_id , t.full_name  , 'TABLE'    , t.created_date, t.modified_date, t.xml_data
			FROM		#tables AS t
			LEFT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = t.server_name
					AND	mi.database_name = t.database_name
					AND	mi.object_id = t.table_id
					AND	mi.object_type = 'TABLE'
			WHERE	mi.object_id IS NULL;

			UPDATE	mr
			SET		mr.resolve_date = GETDATE()
			FROM		dbo.vnDBA_Monitor_Report AS mr
			INNER JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = mr.server_name
					AND	mi.database_name = mr.database_name
					AND	mi.object_id = mr.object_id
			WHERE	mr.object_type = 'TABLE'
				AND	mr.report_type = 'CREATED';
		END;

		IF	ISNULL(@object_type, 'VIEW') = 'VIEW'
		BEGIN
			INSERT INTO	dbo.vnDBA_Monitor_Information
				(	  server_name,   database_name,   object_id,   object_name, object_type,   created_date,   update_date  ,   xml_data)
			SELECT	v.server_name, v.database_name, v.view_id  , v.full_name  , 'VIEW'     , v.created_date, v.modified_date, v.xml_data
			FROM		#views AS v
			LEFT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = v.server_name
					AND	mi.database_name = v.database_name
					AND	mi.object_id = v.view_id
					AND	mi.object_type = 'VIEW'
			WHERE	mi.object_id IS NULL;

			UPDATE	mr
			SET		mr.resolve_date = GETDATE()
			FROM		dbo.vnDBA_Monitor_Report AS mr
			INNER JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = mr.server_name
					AND	mi.database_name = mr.database_name
					AND	mi.object_id = mr.object_id
			WHERE	mr.object_type = 'VIEW'
				AND	mr.report_type = 'CREATED';
		END;

		IF	ISNULL(@object_type, 'PROCEDURE') = 'PROCEDURE'
		BEGIN
			INSERT INTO	dbo.vnDBA_Monitor_Information
				(	  server_name,   database_name,   object_id,   object_name, object_type,   created_date,   update_date  ,   xml_data)
			SELECT	p.server_name, p.database_name, p.proc_id  , p.full_name  , 'PROCEDURE', p.created_date, p.modified_date, p.xml_data
			FROM		#procedures AS p
			LEFT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = p.server_name
					AND	mi.database_name = p.database_name
					AND	mi.object_id = p.proc_id
					AND	mi.object_type = 'PROCEDURE'
			WHERE	mi.object_id IS NULL;

			UPDATE	mr
			SET		mr.resolve_date = GETDATE()
			FROM		dbo.vnDBA_Monitor_Report AS mr
			INNER JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = mr.server_name
					AND	mi.database_name = mr.database_name
					AND	mi.object_id = mr.object_id
			WHERE	mr.object_type = 'PROCEDURE'
				AND	mr.report_type = 'CREATED';
		END;

		IF	ISNULL(@object_type, 'FUNCTION') = 'FUNCTION'
		BEGIN
			INSERT INTO	dbo.vnDBA_Monitor_Information
				(	  server_name,   database_name,   object_id,   object_name, object_type,   created_date,   update_date  ,   xml_data)
			SELECT	f.server_name, f.database_name, f.func_id  , f.full_name  , 'FUNCTION' , f.created_date, f.modified_date, f.xml_data
			FROM		#functions AS f
			LEFT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = f.server_name
					AND	mi.database_name = f.database_name
					AND	mi.object_id = f.func_id
					AND	mi.object_type = 'FUNCTION'
			WHERE	mi.object_id IS NULL;

			UPDATE	mr
			SET		mr.resolve_date = GETDATE()
			FROM		dbo.vnDBA_Monitor_Report AS mr
			INNER JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = mr.server_name
					AND	mi.database_name = mr.database_name
					AND	mi.object_id = mr.object_id
			WHERE	mr.object_type = 'FUNCTION'
				AND	mr.report_type = 'CREATED';
		END;

		IF	ISNULL(@object_type, 'TRIGGER') = 'TRIGGER'
		BEGIN
			INSERT INTO	dbo.vnDBA_Monitor_Information
				(	  server_name,   database_name,   object_id,   object_name, object_type,   created_date,   update_date  ,   xml_data)
			SELECT	t.server_name, t.database_name, t.trig_id  , t.trig_name  , 'TRIGGER'  , t.created_date, t.modified_date, t.xml_data
			FROM		#triggers AS t
			LEFT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = t.server_name
					AND	mi.database_name = t.database_name
					AND	mi.object_id = t.trig_id
					AND	mi.object_type = 'TRIGGER'
			WHERE	mi.object_id IS NULL;

			UPDATE	mr
			SET		mr.resolve_date = GETDATE()
			FROM		dbo.vnDBA_Monitor_Report AS mr
			INNER JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = mr.server_name
					AND	mi.database_name = mr.database_name
					AND	mi.object_id = mr.object_id
			WHERE	mr.object_type = 'TRIGGER'
				AND	mr.report_type = 'CREATED';
		END;
	END;
			

	--	BEGIN STEP 6:	MODE 4 - DELETED
	--		Delete old objects information
	----------------------------------------------------------------------------------------------------
	IF	@mode = 4
	BEGIN
		IF	ISNULL(@object_type, 'DATABASE') = 'DATABASE'
		BEGIN
			DELETE	mi
			FROM		#databases AS d
			RIGHT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = d.server_name
					AND	mi.object_id = d.database_id
					AND	mi.object_type = 'DATABASE'
			WHERE	d.database_id IS NULL
				AND	mi.object_type = 'DATABASE';

			UPDATE	mr
			SET		mr.resolve_date = GETDATE()
			FROM		dbo.vnDBA_Monitor_Report AS mr
			LEFT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mr.server_name = mi.server_name
					AND	mr.object_id = mi.object_id
					AND	mr.object_type = mi.object_type
			LEFT JOIN	#databases AS d
					ON	d.server_name = mr.server_name
					AND	d.database_id = mr.object_id
			WHERE	d.database_id IS NULL
				AND	mi.object_id IS NULL
				AND	mr.object_type = 'DATABASE'
				AND	mr.report_type = 'DELETED';
		END;

		IF	ISNULL(@object_type, 'PRINCIPAL') = 'PRINCIPAL'
		BEGIN
			DELETE	mi
			FROM		#principals AS p
			RIGHT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = p.server_name
					AND	mi.object_id = p.principal_id
					AND	mi.object_type = 'PRINCIPAL'
			WHERE	p.principal_id IS NULL
				AND	mi.object_type = 'PRINCIPAL';

			UPDATE	mr
			SET		mr.resolve_date = GETDATE()
			FROM		dbo.vnDBA_Monitor_Report AS mr
			LEFT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mr.server_name = mi.server_name
					AND	mr.object_id = mi.object_id
					AND	mr.object_type = mi.object_type
			LEFT JOIN	#principals AS p
					ON	p.server_name = mr.server_name
					AND	p.principal_id = mr.object_id
			WHERE	p.principal_id IS NULL
				AND	mi.object_id IS NULL
				AND	mr.object_type = 'PRINCIPAL'
				AND	mr.report_type = 'DELETED';
		END;

		IF	ISNULL(@object_type, 'JOB') = 'JOB'
		BEGIN
			DELETE	mi
			FROM		#jobs AS j
			RIGHT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = j.server_name
					AND	mi.object_id = j.job_id
					AND	mi.object_type = 'JOB'
			WHERE	j.job_id IS NULL
				AND	mi.object_type = 'JOB';

			UPDATE	mr
			SET		mr.resolve_date = GETDATE()
			FROM		dbo.vnDBA_Monitor_Report AS mr
			LEFT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mr.server_name = mi.server_name
					AND	mr.object_id = mi.object_id
					AND	mr.object_type = mi.object_type
			LEFT JOIN	#jobs AS j
					ON	j.server_name = mr.server_name
					AND	j.job_id = mr.object_id
			WHERE	j.job_id IS NULL
				AND	mi.object_id IS NULL
				AND	mr.object_type = 'JOB'
				AND	mr.report_type = 'DELETED';
		END;

		IF	ISNULL(@object_type, 'TABLE') = 'TABLE'
		BEGIN
			DELETE	mi
			FROM		#tables AS t
			RIGHT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = t.server_name
					AND	mi.database_name = t.database_name
					AND	mi.object_id = t.table_id
					AND	mi.object_type = 'TABLE'
			WHERE	t.table_id IS NULL
				AND	mi.object_type = 'TABLE';

			UPDATE	mr
			SET		mr.resolve_date = GETDATE()
			FROM		dbo.vnDBA_Monitor_Report AS mr
			LEFT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mr.server_name = mi.server_name
					AND	mr.database_name = mi.database_name
					AND	mr.object_id = mi.object_id
					AND	mr.object_type = mi.object_type
			LEFT JOIN	#tables AS t
					ON	t.server_name = mr.server_name
					AND	t.database_name = mr.database_name
					AND	t.table_id = mr.object_id
			WHERE	t.table_id IS NULL
				AND	mi.object_id IS NULL
				AND	mr.object_type = 'TABLE'
				AND	mr.report_type = 'DELETED';
		END;

		IF	ISNULL(@object_type, 'VIEW') = 'VIEW'
		BEGIN
			DELETE	mi
			FROM		#views AS v
			RIGHT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = v.server_name
					AND	mi.database_name = v.database_name
					AND	mi.object_id = v.view_id
					AND	mi.object_type = 'VIEW'
			WHERE	v.view_id IS NULL
				AND	mi.object_type = 'VIEW';

			UPDATE	mr
			SET		mr.resolve_date = GETDATE()
			FROM		dbo.vnDBA_Monitor_Report AS mr
			LEFT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mr.server_name = mi.server_name
					AND	mr.database_name = mi.database_name
					AND	mr.object_id = mi.object_id
					AND	mr.object_type = mi.object_type
			LEFT JOIN	#views AS v
					ON	v.server_name = mr.server_name
					AND	v.database_name = mr.database_name
					AND	v.view_id = mr.object_id
			WHERE	v.view_id IS NULL
				AND	mi.object_id IS NULL
				AND	mr.object_type = 'VIEW'
				AND	mr.report_type = 'DELETED';
		END;

		IF	ISNULL(@object_type, 'PROCEDURE') = 'PROCEDURE'
		BEGIN
			DELETE	mi
			FROM		#procedures AS p
			RIGHT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = p.server_name
					AND	mi.database_name = p.database_name
					AND	mi.object_id = p.proc_id
					AND	mi.object_type = 'PROCEDURE'
			WHERE	p.proc_id IS NULL
				AND	mi.object_type = 'PROCEDURE';

			UPDATE	mr
			SET		mr.resolve_date = GETDATE()
			FROM		dbo.vnDBA_Monitor_Report AS mr
			LEFT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mr.server_name = mi.server_name
					AND	mr.database_name = mi.database_name
					AND	mr.object_id = mi.object_id
					AND	mr.object_type = mi.object_type
			LEFT JOIN	#procedures AS p
					ON	p.server_name = mr.server_name
					AND	p.database_name = mr.database_name
					AND	p.proc_id = mr.object_id
			WHERE	p.proc_id IS NULL
				AND	mi.object_id IS NULL
				AND	mr.object_type = 'PROCEDURE'
				AND	mr.report_type = 'DELETED';
		END;

		IF	ISNULL(@object_type, 'FUNCTION') = 'FUNCTION'
		BEGIN
			DELETE	mi
			FROM		#functions AS f
			RIGHT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = f.server_name
					AND	mi.database_name = f.database_name
					AND	mi.object_id = f.func_id
					AND	mi.object_type = 'FUNCTION'
			WHERE	f.func_id IS NULL
				AND	mi.object_type = 'FUNCTION';

			UPDATE	mr
			SET		mr.resolve_date = GETDATE()
			FROM		dbo.vnDBA_Monitor_Report AS mr
			LEFT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mr.server_name = mi.server_name
					AND	mr.database_name = mi.database_name
					AND	mr.object_id = mi.object_id
					AND	mr.object_type = mi.object_type
			LEFT JOIN	#functions AS f
					ON	f.server_name = mr.server_name
					AND	f.database_name = mr.database_name
					AND	f.func_id = mr.object_id
			WHERE	f.func_id IS NULL
				AND	mi.object_id IS NULL
				AND	mr.object_type = 'FUNCTION'
				AND	mr.report_type = 'DELETED';
		END;

		IF	ISNULL(@object_type, 'TRIGGER') = 'TRIGGER'
		BEGIN
			DELETE	mi
			FROM		#triggers AS t
			RIGHT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mi.server_name = t.server_name
					AND	mi.database_name = t.database_name
					AND	mi.object_id = t.trig_id
					AND	mi.object_type = 'TRIGGER'
			WHERE	t.trig_id IS NULL
				AND	mi.object_type = 'TRIGGER';

			UPDATE	mr
			SET		mr.resolve_date = GETDATE()
			FROM		dbo.vnDBA_Monitor_Report AS mr
			LEFT JOIN	dbo.vnDBA_Monitor_Information AS mi
					ON	mr.server_name = mi.server_name
					AND	mr.database_name = mi.database_name
					AND	mr.object_id = mi.object_id
					AND	mr.object_type = mi.object_type
			LEFT JOIN	#triggers AS t
					ON	t.server_name = mr.server_name
					AND	t.database_name = mr.database_name
					AND	t.trig_id = mr.object_id
			WHERE	t.trig_id IS NULL
				AND	mi.object_id IS NULL
				AND	mr.object_type = 'TRIGGER'
				AND	mr.report_type = 'DELETED';
		END;
	END;


	--	BEGIN STEP 7:
	--		Reset notification everyday
	----------------------------------------------------------------------------------------------------

	IF	@mode = -1
	BEGIN
	    UPDATE	dbo.vnDBA_Monitor_Report
		SET		is_notified = 0
		WHERE	is_notified = 1
			AND	DATEDIFF(DAY, verify_date, GETDATE()) <> 0
	END;	


	--	BEGIN STEP 8:
	--		Clean up
	----------------------------------------------------------------------------------------------------

	EXECUTE	sys.sp_xml_removedocument @xml_doc;
	
	DROP TABLE	#databases
			,	#jobs
			,	#tables
			,	#views
			,	#procedures
			,	#functions
			,	#triggers
			;

END;
GO