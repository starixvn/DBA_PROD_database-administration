ALTER PROCEDURE	dbo.vnDBA_sp_UpdateSchedules
					@delete_data		NVARCHAR(MAX)	= NULL
				,	@insert_data		NVARCHAR(MAX)	= NULL
AS
/*
	Creator:	20160630@Billy
	Task:		Dynamic Schedules Function - Update schedules on remote servers - [Redmine: #00000]
	Database:	*ALL_SERVERS*.MonDB
	
	Revisions:
		- 20160630@Billy:	v1.00	*start tracking*

	Params Explaination:
		- @delete_data:	XML string contains id of deleted schedules on host
							<root><schedules schedule_id="1"/><schedules schedule_id="2"/></root>
		- @insert_data:	XML string contains information of inserted schedules on host
							<root><schedules schedule_id="1" schedule_type="JOBS_COLLECTDATA" enabled="1" freq_type="0" freq_interval="0" freq_subday_type="0" freq_subday_interval="0" freq_relative_interval="0" freq_recurrence_factor="0" active_start_date="0" active_end_date="0" active_start_time="0" active_end_time="0"/></root>
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE	@idoc		INT;

	--  Delete schedules  --
	EXECUTE	sys.sp_xml_preparedocument @idoc OUTPUT, @delete_data;

	DELETE	js
	FROM		dbo.vnDBA_Jobs_schedules AS js
	INNER JOIN	OPENXML(@idoc, '/root/schedules', 1)
				WITH (
					schedule_id				INT
				) AS ox
			ON	ox.schedule_id = js.schedule_id;
	
	EXECUTE	sys.sp_xml_removedocument @idoc;


	--  Insert schedules  --
	EXECUTE	sys.sp_xml_preparedocument @idoc OUTPUT, @insert_data;

	IF	EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id WHERE t.name = 'vnDBA_Jobs_schedules' AND c.is_identity = 1)
		SET IDENTITY_INSERT dbo.vnDBA_Jobs_schedules ON;

	INSERT INTO	vnDBA_Jobs_schedules
		(	schedule_id
		,	schedule_type
		,	enabled
		,	freq_type
		,	freq_interval
		,	freq_subday_type
		,	freq_subday_interval
		,	freq_relative_interval
		,	freq_recurrence_factor
		,	active_start_date
		,	active_end_date
		,	active_start_time
		,	active_end_time
		)
	SELECT	ox.schedule_id
		,	ox.schedule_type
		,	ox.enabled
		,	ox.freq_type
		,	ox.freq_interval
		,	ox.freq_subday_type
		,	ox.freq_subday_interval
		,	ox.freq_relative_interval
		,	ox.freq_recurrence_factor
		,	ox.active_start_date
		,	ox.active_end_date
		,	ox.active_start_time
		,	ox.active_end_time
	FROM	OPENXML(@idoc, '/root/schedules', 1)
			WITH (
				schedule_id					INT
			,	schedule_type				VARCHAR(50)
			,	enabled						TINYINT
			,	freq_type					INT
			,	freq_interval				INT
			,	freq_subday_type			INT
			,	freq_subday_interval		INT
			,	freq_relative_interval		INT
			,	freq_recurrence_factor		INT
			,	active_start_date			INT
			,	active_end_date				INT
			,	active_start_time			INT
			,	active_end_time				INT
			) AS ox;
	
	IF	EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id WHERE t.name = 'vnDBA_Jobs_schedules' AND c.is_identity = 1)
		SET IDENTITY_INSERT dbo.vnDBA_Jobs_schedules OFF;

	EXECUTE	sys.sp_xml_removedocument @idoc;

END;

