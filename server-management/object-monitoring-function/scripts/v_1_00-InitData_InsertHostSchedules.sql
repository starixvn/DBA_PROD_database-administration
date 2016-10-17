/*
	Creator:	20160803@Billy
	Task:		Insert schedules information for Objects Monitoring - [Redmine: #58941]
	Server:		KBT		- DBTP
				SIT		- SITDB06
*/


--	BEGIN STEP :	*SERVER*.MonDB
--		Insert data into vnDBA_Jobs_schedules
----------------------------------------------------------------------------------------------------

USE MonDB;
GO

IF	EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id WHERE t.name = 'vnDBA_Jobs_schedules' AND c.is_identity = 1)
	SET IDENTITY_INSERT dbo.vnDBA_Jobs_schedules ON;

MERGE INTO	dbo.vnDBA_Jobs_schedules AS js
USING	(
	VALUES	(	16         , 'MON_STAGING'      , 1      , 4        , 1            , 4               , 5                   , 0                     , 0                     , 20160801         , 99991231       , 000000           , 235959         )
		,	(	17         , 'MON_VERIFY'       , 1      , 4        , 1            , 4               , 5                   , 0                     , 0                     , 20160801         , 99991231       , 000100           , 235959         )
		,	(	18         , 'MON_NOTIFICATION' , 1      , 4        , 1            , 1               , 0                   , 0                     , 0                     , 20160801         , 99991231       , 190000           , 235959         )
		,	(	19         , 'MON_REPORT'       , 1      , 4        , 1            , 1               , 0                   , 0                     , 0                     , 20160901         , 99991231       , 210000           , 235959         )
)	value	(	schedule_id, schedule_type      , enabled, freq_type, freq_interval, freq_subday_type, freq_subday_interval, freq_relative_interval, freq_recurrence_factor, active_start_date, active_end_date, active_start_time, active_end_time)
ON	js.schedule_type = value.schedule_type
WHEN MATCHED THEN
	UPDATE SET	js.enabled					= value.enabled
			,	js.freq_type				= value.freq_type
			,	js.freq_interval			= value.freq_interval
			,	js.freq_subday_type			= value.freq_subday_type
			,	js.freq_subday_interval		= value.freq_subday_interval
			,	js.freq_relative_interval	= value.freq_relative_interval
			,	js.freq_recurrence_factor	= value.freq_recurrence_factor
			,	js.active_start_date		= value.active_start_date
			,	js.active_end_date			= value.active_end_date
			,	js.active_start_time		= value.active_start_time
			,	js.active_end_time			= value.active_end_time
WHEN NOT MATCHED THEN
	INSERT	(	      schedule_id,       schedule_type,       enabled,       freq_type,       freq_interval,       freq_subday_type,       freq_subday_interval,       freq_relative_interval,       freq_recurrence_factor,       active_start_date,       active_end_date,       active_start_time,       active_end_time)
	VALUES	(	value.schedule_id, value.schedule_type, value.enabled, value.freq_type, value.freq_interval, value.freq_subday_type, value.freq_subday_interval, value.freq_relative_interval, value.freq_recurrence_factor, value.active_start_date, value.active_end_date, value.active_start_time, value.active_end_time)
;

IF	EXISTS(SELECT 1 FROM sys.tables t INNER JOIN sys.columns c ON t.object_id = c.object_id WHERE t.name = 'vnDBA_Jobs_schedules' AND c.is_identity = 1)
	SET IDENTITY_INSERT dbo.vnDBA_Jobs_schedules OFF;
