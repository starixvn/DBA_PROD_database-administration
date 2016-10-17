/*
	Creator:	20160630@Billy
	Task:		Dynamic Schedules Function - Create Schedules Table - [Redmine: #60126]
	Server:		*ALL_SERVERS*
*/


--	BEGIN STEP :	*ALL_SERVERS*.MonDB
--		Create Schedules Table
----------------------------------------------------------------------------------------------------

CREATE TABLE	dbo.vnDBA_Jobs_schedules (
					schedule_id					INT			NOT NULL
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