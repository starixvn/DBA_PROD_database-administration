ALTER PROCEDURE	dbo.vnDBA_sp_CheckSchedules
					@schedule_type		VARCHAR(50)
				,	@isRun				BIT				OUTPUT
AS
/*
	Creator:	20160630@Billy
	Task:		Dynamic Schedules Function - Check current time with schedules for running - [Redmine: #60126]
	Database:	*ALL_SERVERS*.MonDB
	
	Revisions:
		- 20160630@Billy:	v1.00	*start tracking*
		- 20160708@Billy:	v1.01	Extend time check to delay for maximum 5 seconds instead of exactly time - [Redmine: #60126]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE	@schedule_id				INT
		,	@freq_type					INT
		,	@freq_interval				INT
		,	@freq_subday_type			INT
		,	@freq_subday_interval		INT
		,	@freq_relative_interval		INT
		,	@freq_recurrence_factor		INT
		,	@active_start_date			INT
		,	@active_end_date			INT
		,	@active_start_time			INT
		,	@active_end_time			INT
		;
	
	DECLARE	@current_datetime			DATETIME
		,	@current_date				INT
		,	@current_time				INT
		;

	DECLARE	@valued_start_time			INT
		,	@valued_current_time		INT
		;

	SELECT	@isRun = 0;

	SELECT	@current_datetime		= GETDATE();

	SELECT	@current_date			= CAST(CONVERT(VARCHAR, @current_datetime, 112) AS INT)
		,	@current_time			= CAST(REPLACE(CONVERT(VARCHAR, @current_datetime, 108), ':', '') AS INT)
		;

	SELECT	@schedule_id			= js.schedule_id
		,	@freq_type				= js.freq_type
		,	@freq_interval			= js.freq_interval
		,	@freq_subday_type		= js.freq_subday_type
		,	@freq_subday_interval	= js.freq_subday_interval
		,	@freq_relative_interval	= js.freq_relative_interval
		,	@freq_recurrence_factor	= js.freq_recurrence_factor
		,	@active_start_date		= js.active_start_date
		,	@active_end_date		= js.active_end_date
		,	@active_start_time		= js.active_start_time
		,	@active_end_time		= js.active_end_time
	FROM	dbo.vnDBA_Jobs_schedules AS js
	WHERE	js.schedule_type = @schedule_type
		AND	js.enabled = 1;

	SELECT	@valued_start_time = (@active_start_time / 10000) * 3600 + ((@active_start_time % 10000) / 100) * 60 + (@active_start_time % 100)
		,	@valued_current_time = (@current_time / 10000) * 3600 + ((@current_time % 10000) / 100) * 60 + (@current_time % 100);

	IF	@valued_start_time > @valued_current_time
		SELECT	@valued_current_time = @valued_current_time + 24 * 3600;


	--  Schedule is disabled  --
	IF	@schedule_id IS NULL
		RETURN;

	--  Check start date  --
	IF	@current_date < @active_start_date
		RETURN;

	--  Check start time  --
	IF	@current_date = @active_start_date AND @current_time < @active_start_time
		RETURN;

	--  Check end date  --
	IF	@current_date > @active_end_date
		RETURN;

	--  Check end time  --
	IF	@current_date = @active_end_date AND @current_time > @active_end_time
		RETURN;

	--  Run once  --
	IF	@freq_type = 1
	BEGIN
	    IF	@current_date <> @active_start_date
			RETURN;
	END;

	--	Run daily  --
	ELSE IF	@freq_type = 4
	BEGIN
	    IF	DATEDIFF(DAY, CAST(CAST(@active_start_date AS VARCHAR) AS DATETIME), @current_datetime) % @freq_interval <> 0
			RETURN;
	END;

	--  Run weekly  --
	ELSE IF	@freq_type = 8
	BEGIN
	    IF	@freq_interval &
				CASE DATENAME(WEEKDAY, @current_datetime)	WHEN N'Sunday'		THEN 1
															WHEN N'Monday'		THEN 2
															WHEN N'Tuesday'		THEN 4
															WHEN N'Wednesday'	THEN 8
															WHEN N'Thursday'	THEN 16
															WHEN N'Friday'		THEN 32
															WHEN N'Saturday'	THEN 64
															ELSE 0
				END = 0
			RETURN;
		
		IF	@freq_recurrence_factor <= 0
			RETURN;
		ELSE IF	DATEDIFF(WEEK, CAST(CAST(@active_start_date AS VARCHAR) AS DATETIME), @current_datetime) % @freq_recurrence_factor <> 0
			RETURN;
	END;

	--  Run monthly  --
	ELSE IF	@freq_type = 16
	BEGIN
	    IF	@current_date % 100 <> @freq_interval
			RETURN;

		IF	@freq_recurrence_factor <= 0
			RETURN;
		ELSE IF	DATEDIFF(MONTH, CAST(CAST(@active_start_date AS VARCHAR) AS DATETIME), @current_datetime) % @freq_recurrence_factor <> 0
			RETURN;
	END;

	--  Run monthly relative  --
	ELSE IF	@freq_type = 32
	BEGIN
	    IF	CASE @freq_interval	WHEN 1	THEN 1
								WHEN 2	THEN 2
								WHEN 3	THEN 4
								WHEN 4	THEN 8
								WHEN 5	THEN 16
								WHEN 6	THEN 32
								WHEN 7	THEN 64
								WHEN 8	THEN 1 + 2 + 4 + 8 + 16 + 32 + 64
								WHEN 9	THEN 2 + 4 + 8 + 16 + 32
								WHEN 10	THEN 64 + 1
								ELSE 0
			END
			&	CASE DATENAME(WEEKDAY, @current_datetime)	WHEN N'Sunday'		THEN 1
															WHEN N'Monday'		THEN 2
															WHEN N'Tuesday'		THEN 4
															WHEN N'Wednesday'	THEN 8
															WHEN N'Thursday'	THEN 16
															WHEN N'Friday'		THEN 32
															WHEN N'Saturday'	THEN 64
															ELSE 0
				END = 0
			RETURN;

		IF	@freq_relative_interval IN (1, 2, 4, 16)
		BEGIN
		    IF	DATEDIFF(MONTH, DATEADD(WEEK, - CAST(LOG(@freq_relative_interval)/LOG(2) AS INT), @current_datetime), @current_datetime) <> 0
			OR	DATEDIFF(MONTH, DATEADD(WEEK, - CAST(LOG(@freq_relative_interval)/LOG(2) + 1 AS INT), @current_datetime), @current_datetime) <> 1
				RETURN;
		END;
		ELSE IF	@freq_relative_interval = 32
		BEGIN
		    IF	DATEDIFF(MONTH, @current_datetime, DATEADD(WEEK, 1, @current_datetime)) <> 1
				RETURN;
		END;
		ELSE
			RETURN;

		IF	@freq_recurrence_factor <= 0
			RETURN;
		ELSE IF	DATEDIFF(MONTH, CAST(CAST(@active_start_date AS VARCHAR) AS DATETIME), @current_datetime) % @freq_recurrence_factor <> 0
			RETURN;
	END;

	--  Invalid date recurrence setting  --
	ELSE
		RETURN;


	--  Run at specified time  --
	IF	@freq_subday_type = 1
	BEGIN
	    IF	@current_time < @active_start_time OR @current_time > @active_start_time + 5
			RETURN;
	END;

	--  Run by the number of seconds periods  --
	ELSE IF	@freq_subday_type = 2
	BEGIN
		IF	@freq_subday_interval <= 0
			RETURN;
	    ELSE IF	(@valued_current_time - @valued_start_time) % @freq_subday_interval > 5
			RETURN;
	END;

	--  Run by the number of minutes periods  --
	ELSE IF	@freq_subday_type = 4
	BEGIN
	    IF	@freq_subday_interval <= 0
			RETURN;
	    ELSE IF	(@valued_current_time - @valued_start_time) % (@freq_subday_interval * 60) > 5
			RETURN;
	END;

	--  Run by the number of hours periods  --
	ELSE IF	@freq_subday_type = 8
	BEGIN
	    IF	@freq_subday_interval <= 0
			RETURN;
	    ELSE IF	(@valued_current_time - @valued_start_time) % (@freq_subday_interval * 3600) > 5
			RETURN;
	END;
	
	--  Invalid time recurrence setting  --
	ELSE
		RETURN;


	SELECT	@isRun = 1;

END;
GO
