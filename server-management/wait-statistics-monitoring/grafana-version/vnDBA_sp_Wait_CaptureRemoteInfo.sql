USE	StarixDB;
GO

ALTER PROCEDURE	dbo.vnDBA_sp_Wait_CaptureRemoteInfo
					@Debug				BIT				= 0
AS
/*
	Creator:	20171103@Billy
	Task:		Capture Remote Wait Statistics Information - Host side - [Redmine: #83670]
	Database:	DBDWCSS.StarixDB
	
	Revisions:
		- 20171103@Billy:	Initial - [Redmine: #83670]
		
	Developer's Notes:
		- @Debug:			0		- Debug mode is OFF [DEFAULT]
							1		- Debug mode is ON

*/
BEGIN
	SET NOCOUNT ON;
	
	-- Debug variables --
	DECLARE	@DebugMsg		NVARCHAR(MAX)
		;

	-- Procedure variables --
	DECLARE	@ServerName		NVARCHAR(128)
		,	@Query			NVARCHAR(MAX)
		,	@WaitType		NVARCHAR(60)
		;

	-- Temporary tables --
	IF	OBJECT_ID('tempdb..#CaptureServers') IS NOT NULL
		DROP TABLE	#CaptureServers;

	CREATE TABLE	#CaptureServers (
						ServerName				NVARCHAR(128)
					,	isDone					BIT
					,	PRIMARY KEY CLUSTERED (
							isDone			ASC
						,	ServerName		ASC
						)
					);
					
	IF	OBJECT_ID('tempdb..##CaptureInfo_WaitStat') IS NOT NULL
		DROP TABLE	##CaptureInfo_WaitStat;

	CREATE TABLE	##CaptureInfo_WaitStat (
						ServerName				NVARCHAR(128)	NOT NULL
					,	CaptureDate				DATETIME		NOT NULL
					,	msTicks					BIGINT			NOT NULL
					,	WaitType				NVARCHAR(60)	NOT NULL
					,	WaitingTasksCount		BIGINT			NOT NULL
					,	WaitTime_ms				BIGINT			NOT NULL
					,	SignalWaitTime_ms		BIGINT			NOT NULL
					,	PRIMARY KEY CLUSTERED (
							ServerName		ASC
						,	WaitType		ASC
						)
					);

	
	-- Get monitored server list --
	INSERT INTO	#CaptureServers (ServerName, isDone)
	SELECT	ServerName, 0
	FROM	dbo.vnDBA_Wait_Servers AS s WITH (NOLOCK)
	WHERE	s.isMonitored = 1;


	-- Get wait statistics info from target servers --
	WHILE	0 = 0
	BEGIN
		-- Initialize variable --
		SELECT	@ServerName			= NULL;

		-- Get unprocessed server --
		SELECT	TOP(1)
				@ServerName			= ServerName
		FROM	#CaptureServers AS s WITH (NOLOCK)
		WHERE	s.isDone = 0;

		-- Loop termination --
		IF	@@ROWCOUNT = 0
			BREAK;

		-- Generate get info script --
		SELECT	@Query = N'';
		SELECT	@Query = @Query + N'
INSERT INTO	##CaptureInfo_WaitStat (ServerName, CaptureDate, msTicks, WaitType, WaitingTasksCount, WaitTime_ms, SignalWaitTime_ms)
SELECT	ServerName, CaptureDate, msTicks, WaitType, WaitingTasksCount, WaitTime_ms, SignalWaitTime_ms
FROM	OPENQUERY(' + @ServerName + N'KBT, ''EXECUTE	MonDB.dbo.vnDBA_sp_Wait_CaptureInfo;'');
';
		
		-- Debug info --
		IF	@Debug = 1
		BEGIN;
			RAISERROR(@Query, 0, 0) WITH NOWAIT;
		END;

		-- Execute dynamic query --
		EXECUTE	sys.sp_executesql @Query;

		-- Mark server as processed --
		UPDATE	#CaptureServers
		SET		isDone = 1
		WHERE	isDone = 0
			AND	ServerName = @ServerName;
	END;


	-- Cleanup ignorable wait types --
	DELETE	ws
	FROM		##CaptureInfo_WaitStat AS ws WITH (TABLOCK)
	LEFT JOIN	dbo.vnDBA_Wait_Metadata AS meta WITH (NOLOCK)
			ON	meta.WaitType = ws.WaitType
	WHERE	ISNULL(meta.Ignorable, 1) = 1


	-- Debug mode: Select result then return --
	IF	@Debug = 1
	BEGIN;
		SELECT	ServerName, CaptureDate, msTicks, WaitType, WaitingTasksCount, WaitTime_ms, SignalWaitTime_ms
		FROM	##CaptureInfo_WaitStat WITH (NOLOCK);

		RETURN;
	END;


	-- Processing infomation --
	BEGIN;
		-- Mark server as not resetted --
		UPDATE	#CaptureServers
		SET		isDone = 0;

		-- Check if the information is resetted or not --
		SELECT	@WaitType = N'CXPACKET';

		UPDATE	srv
		SET		isDone = 1
		FROM	#CaptureServers AS srv WITH (TABLOCK)
		CROSS APPLY	(
			SELECT	_ws.WaitingTasksCount
			FROM	##CaptureInfo_WaitStat AS _ws WITH (NOLOCK)
			WHERE	_ws.ServerName = srv.ServerName
				AND	_ws.WaitType = @WaitType
		) AS new
		CROSS APPLY	(
			SELECT	_ws.WaitingTasksCount
			FROM	dbo.vnDBA_Wait_Staging AS _ws WITH (NOLOCK)
			WHERE	_ws.ServerName = srv.ServerName
				AND	_ws.WaitType = @WaitType
		) AS old
		WHERE	old.WaitingTasksCount > new.WaitingTasksCount;

		-- Calculate wait statistics --
		INSERT INTO	dbo.vnDBA_Wait_Captured (ServerName, CalculateDate, Calc_msTicks, WaitType, CalcWaitingTasksCount, CalcWaitTime_ms, CalcSignalWaitTime_ms)
		SELECT	srv.ServerName, calc.CalculateDate, calc.Calc_msTicks, calc.WaitType, calc.CalcWaitingTasksCount, calc.CalcWaitTime_ms, calc.CalcSignalWaitTime_ms
		FROM		#CaptureServers AS srv WITH (NOLOCK)
		CROSS APPLY	(
			SELECT	'CalculateDate'				= _new.CaptureDate
				,	'Calc_msTicks'				= _new.msTicks - _old.msTicks
				,	'WaitType'					= _new.WaitType
				,	'CalcWaitingTasksCount'		= _new.WaitingTasksCount - _old.WaitingTasksCount
				,	'CalcWaitTime_ms'			= _new.WaitTime_ms - _old.WaitTime_ms
				,	'CalcSignalWaitTime_ms'		= _new.SignalWaitTime_ms - _old.SignalWaitTime_ms
			FROM		##CaptureInfo_WaitStat AS _new WITH (NOLOCK)
			INNER JOIN	dbo.vnDBA_Wait_Staging AS _old WITH (NOLOCK)
					ON	_new.ServerName = _old.ServerName
					AND	_new.WaitType = _old.WaitType
			WHERE	_new.ServerName = srv.ServerName
		) calc
		WHERE	srv.isDone = 0;

		-- Insert resetted data --
		INSERT INTO	dbo.vnDBA_Wait_Captured (ServerName, CalculateDate, Calc_msTicks, WaitType, CalcWaitingTasksCount, CalcWaitTime_ms, CalcSignalWaitTime_ms)
		SELECT	srv.ServerName, ws.CaptureDate, ws.msTicks, ws.WaitType, ws.WaitingTasksCount, ws.WaitTime_ms, ws.SignalWaitTime_ms
		FROM		#CaptureServers AS srv WITH (NOLOCK)
		INNER JOIN	##CaptureInfo_WaitStat AS ws WITH (NOLOCK)
				ON	ws.ServerName = srv.ServerName
		WHERE	srv.isDone = 1;

		-- Remove calculated data --
		DELETE	ws
		FROM		dbo.vnDBA_Wait_Staging AS ws WITH (TABLOCK)
		INNER JOIN	#CaptureServers AS srv WITH (NOLOCK)
				ON	srv.ServerName = ws.ServerName
		WHERE	srv.isDone = 1;

		DELETE	old
		FROM		dbo.vnDBA_Wait_Staging AS old WITH (TABLOCK)
		INNER JOIN	##CaptureInfo_WaitStat AS new WITH (NOLOCK)
				ON	new.ServerName = old.ServerName
				AND	new.WaitType = old.WaitType;

		-- Insert new staging data --
		INSERT INTO	dbo.vnDBA_Wait_Staging (ServerName, CaptureDate, msTicks, WaitType, WaitingTasksCount, WaitTime_ms, SignalWaitTime_ms)
		SELECT	ws.ServerName, ws.CaptureDate, ws.msTicks, ws.WaitType, ws.WaitingTasksCount, ws.WaitTime_ms, ws.SignalWaitTime_ms
		FROM	##CaptureInfo_WaitStat AS ws WITH (NOLOCK);
	END;

	DROP TABLE	##CaptureInfo_WaitStat
			,	#CaptureServers
			;
END;
GO