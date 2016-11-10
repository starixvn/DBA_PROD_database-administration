/*
	Creator:	20160630@Billy
	Task:		Dynamic Schedules Function - Create Schedules Table - [Redmine: #60126]
	Server:		KBT		- DBTP
				SIT		- SITDB06
*/


--	BEGIN STEP 1:	*SERVER*.MonDB
--		Create Schedules Table
----------------------------------------------------------------------------------------------------

CREATE TABLE	dbo.vnDBA_Jobs_schedules (
					schedule_id					INT				NOT NULL
				,	schedule_type				VARCHAR(50)
				,	enabled						TINYINT
				,	freq_type					INT
						CONSTRAINT DF_vnDBA_Jobs_schedules_freq_type				DEFAULT 0
				,	freq_interval				INT
						CONSTRAINT DF_vnDBA_Jobs_schedules_freq_interval			DEFAULT 1
				,	freq_subday_type			INT
						CONSTRAINT DF_vnDBA_Jobs_schedules_freq_subday_type			DEFAULT 0
				,	freq_subday_interval		INT
						CONSTRAINT DF_vnDBA_Jobs_schedules_freq_subday_interval		DEFAULT 0
				,	freq_relative_interval		INT
						CONSTRAINT DF_vnDBA_Jobs_schedules_freq_relative_interval	DEFAULT 0
				,	freq_recurrence_factor		INT
						CONSTRAINT DF_vnDBA_Jobs_schedules_freq_recurrence_factor	DEFAULT 0
				,	active_start_date			INT
						CONSTRAINT DF_vnDBA_Jobs_schedules_active_start_date		DEFAULT NULL
				,	active_end_date				INT
						CONSTRAINT DF_vnDBA_Jobs_schedules_active_end_date			DEFAULT 99991231
				,	active_start_time			INT
						CONSTRAINT DF_vnDBA_Jobs_schedules_active_start_time		DEFAULT 000000
				,	active_end_time				INT
						CONSTRAINT DF_vnDBA_Jobs_schedules_active_end_time			DEFAULT 235959
				);

CREATE CLUSTERED INDEX	IX_vnDBA_Jobs_schedules_type ON dbo.vnDBA_Jobs_schedules (
							enabled			DESC
						,	schedule_type	ASC
						) ON [PRIMARY];

ALTER TABLE	dbo.vnDBA_Jobs_schedules
	ADD CONSTRAINT	PK_vnDBA_Jobs_schedules PRIMARY KEY NONCLUSTERED (
						schedule_id	ASC
					) ON [PRIMARY];
GO

CREATE TABLE	dbo.vnDBA_Jobs_schedules_logs (
					changed_date				DATETIME		NOT NULL
				,	delete_data					NVARCHAR(MAX)
				,	insert_data					NVARCHAR(MAX)
				);

CREATE CLUSTERED INDEX	CIX_vnDBA_Jobs_schedules_logs ON dbo.vnDBA_Jobs_schedules_logs (
							changed_date	ASC
						) ON [PRIMARY];
GO


--	BEGIN STEP 2:	*SERVER*.MonDB
--		Create trigger for update remote servers schedules
----------------------------------------------------------------------------------------------------

SET XACT_ABORT OFF;
GO

CREATE TRIGGER	dbo.vnDBA_Jobs_schedules_RemoteUpdate ON dbo.vnDBA_Jobs_schedules
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE	@delete_data	NVARCHAR(MAX)
		,	@insert_data	NVARCHAR(MAX)
		;

	SELECT	@delete_data = (
		SELECT	'@schedule_id'					= d.schedule_id
		FROM	Deleted d
		FOR XML PATH ('schedules')
	,	ROOT
	);

	SELECT	@insert_data = (
		SELECT	'@schedule_id'					= i.schedule_id
			,	'@schedule_type'				= i.schedule_type
			,	'@enabled'						= i.enabled
			,	'@freq_type'					= i.freq_type
			,	'@freq_interval'				= i.freq_interval
			,	'@freq_subday_type'				= i.freq_subday_type
			,	'@freq_subday_interval'			= i.freq_subday_interval
			,	'@freq_relative_interval'		= i.freq_relative_interval		
			,	'@freq_recurrence_factor'		= i.freq_recurrence_factor
			,	'@active_start_date'			= i.active_start_date
			,	'@active_end_date'				= i.active_end_date
			,	'@active_start_time'			= i.active_start_time
			,	'@active_end_time'				= i.active_end_time
		FROM	Inserted i
		FOR XML PATH ('schedules')
	,	ROOT
	);

	INSERT INTO	dbo.vnDBA_Jobs_schedules_logs
			(	changed_date,  delete_data,  insert_data)
	VALUES	(	GETDATE()   , @delete_data, @insert_data);
	
END;
