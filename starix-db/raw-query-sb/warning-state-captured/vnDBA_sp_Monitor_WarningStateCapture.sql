USE	StarixDB;
GO

ALTER PROCEDURE	dbo.vnDBA_sp_Monitor_WarningStateCapture
AS
/*
	Creator:	20180704@Billy
	Task:		Description - [Redmine: #00000]
	Database:	DSTARIX.StarixDB
	
	Revisions:
		- 20180704@Billy:	Initial - [Redmine: #00000]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;
	
	DECLARE	@ServerName			NVARCHAR(128)
		,	@StartTime			DATETIME
		,	@EndTime			DATETIME
		,	@RequestStartTime	DATETIME
		,	@RequestEndTime		DATETIME
		,	@Message			NVARCHAR(MAX)
		,	@dialog				UNIQUEIDENTIFIER
		;

	DECLARE	@capturing AS TABLE (
				ObjectName		VARCHAR(1024)
			,	CounterName		VARCHAR(1024)
			,	Threshold		DECIMAL(19,9)
			,	Samples			SMALLINT
			);

	DECLARE	@included AS TABLE (
				MachineName		VARCHAR(1024)
			,	LogicalName		NVARCHAR(128)
			);

	DECLARE	@result AS TABLE (
				LogicalName		NVARCHAR(128)
			,	Done			BIT
			);

	
	INSERT INTO @capturing (ObjectName, CounterName, Threshold, Samples)
	VALUES	('Processor', '% Processor Time', 40, 1)
		,	('SQLServer:General Statistics', 'Processes blocked', 0, 3)
		,	('SQLServer:General Statistics', 'Processes blocked', 20, 1)
		,	('SQLServer:Memory Manager', 'Granted Workspace Memory (KB)', 5242880, 3)
		;

	INSERT INTO	@included (MachineName, LogicalName)
	VALUES	('\\DBTRANS1', N'DBTRANS')
		,	('\\DBTRANS2', N'DBTRANS')
		,	('\\DBCUST1', N'DBCUST')
		,	('\\DBCUST2', N'DBCUST')
		,	('\\DB021', N'DB02')
		,	('\\DB022', N'DB02')
		,	('\\DB042', N'DB042')
		,	('\\DB052', N'DB052')
		,	('\\DB053', N'DB053')
		,	('\\DB054', N'DB054')
		,	('\\DB06', N'DB06')
		,	('\\DB05', N'DB05')
		;
		
	WHILE	0 = 0
	BEGIN;
		INSERT INTO	@result (LogicalName, Done)
		SELECT	DISTINCT
				inc.LogicalName, 0
		FROM		@capturing AS input
		INNER JOIN	dbo.CounterDetails AS c WITH (NOLOCK)
				ON	input.ObjectName = c.ObjectName
				AND	input.CounterName = c.CounterName
		INNER JOIN	@included AS inc
				ON	c.MachineName = inc.MachineName
		CROSS APPLY	(
			SELECT	[CounterTime]		= MIN(_ad.CounterTime)
				,	[ViolatedCnt]		= SUM(_ad.Violated)
				,	[MaxCounterValue]	= MAX(_ad.CounterValue)
			FROM	(
				SELECT	TOP(input.Samples)
						_d.CounterTime, _d.CounterValue
					,	[Violated]	= CASE WHEN _d.CounterValue > input.Threshold THEN 1 ELSE 0 END
				FROM	dbo.vnDBA_Perf_CounterData AS _d WITH (NOLOCK)
				WHERE	_d.CounterID = c.CounterID
				ORDER BY _d.CounterTime DESC
			) AS _ad
		) AS d
		WHERE	d.ViolatedCnt >= input.Samples
			AND	d.CounterTime > DATEADD(SECOND, -30, GETDATE());

		IF	EXISTS (SELECT 1 FROM @result)
		BEGIN;
			WHILE	0 = 0
			BEGIN;
				UPDATE	TOP(1)
						r
				SET		@ServerName	= r.LogicalName
					,	Done		= 1
				FROM	@result AS r
				WHERE	Done = 0;

				IF	@@ROWCOUNT = 0
					BREAK;

				SELECT	@RequestStartTime	= GETDATE()
					,	@RequestEndTime		= DATEADD(SECOND, 10, GETDATE())
					;

				SELECT	@StartTime	= css.StartTime
					,	@EndTime	= css.EndTime
				FROM	dbo.vnDBA_Monitor_WarningStateCaptureSession AS css WITH (NOLOCK)
				WHERE	css.ServerName = @ServerName;
				
				IF	@@ROWCOUNT = 0
				BEGIN;
					INSERT INTO	dbo.vnDBA_Monitor_WarningStateCaptureSession (ServerName, StartTime, EndTime)
					VALUES	(@ServerName, @RequestStartTime, @RequestEndTime);
				END;
				ELSE IF	@StartTime IS NULL
				BEGIN;
					UPDATE	css
					SET		StartTime	= @RequestStartTime
						,	EndTime		= @RequestEndTime
					FROM	dbo.vnDBA_Monitor_WarningStateCaptureSession AS css WITH (ROWLOCK)
					WHERE	ServerName = @ServerName;
				END;
				ELSE IF	@StartTime IS NOT NULL AND @EndTime < @RequestEndTime
				BEGIN;
					UPDATE	css
					SET		EndTime		= @RequestEndTime
					FROM	dbo.vnDBA_Monitor_WarningStateCaptureSession AS css WITH (ROWLOCK)
					WHERE	ServerName = @ServerName;

					CONTINUE;
				END;
				ELSE
				BEGIN;
					CONTINUE;
				END;
				

				SELECT	@Message	= N'';
				SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

DECLARE	@EndTime	DATETIME
	,	@ServerName	NVARCHAR(128)	= N''' + @ServerName + N'''
	,	@GetPlan	VARCHAR(MAX)
	;

DECLARE	@Data AS TABLE (
			ServerName			NVARCHAR(128)
		,	CaptureDate			DATETIME
		,	DB					NVARCHAR(128)
		,	ObjectName			NVARCHAR(128)
		,	SessionId			SMALLINT
		,	BlockingSession		SMALLINT
		,	WaitType			VARCHAR(60)
		,	WaitTime			INT
		,	WaitResource		VARCHAR(256)
		,	CPUTime				INT
		,	ElapsedTime			INT
		,	DOP					SMALLINT
		,	GrantedMemoryKB		BIGINT
		,	UsedMemoryKB		BIGINT
		,	RequestId			SMALLINT
		,	Reads				BIGINT
		,	LogicalReads		BIGINT
		,	Writes				BIGINT
		,	PercentComplete		REAL
		,	RunningStartOffset	INT
		,	RequestStart		DATETIME
		,	RequestStatus		VARCHAR(30)
		,	RequestCommand		VARCHAR(16)
		,	SchedulerId			INT
		,	HostName			VARCHAR(128)
		,	Program				VARCHAR(128)
		,	LoginName			VARCHAR(128)
		,	SessionStatus		VARCHAR(30)
		,	BaseText			VARCHAR(MAX)
		,	RunningText			VARCHAR(MAX)
		,	RunningPlan			VARCHAR(MAX)
		);

WHILE	0 = 0
BEGIN;
	DELETE	@Data;

	SELECT	@EndTime	= css.EndTime
	FROM	dbo.vnDBA_Monitor_WarningStateCaptureSession AS css WITH (NOLOCK)
	WHERE	css.ServerName = @ServerName;

	IF	GETDATE() < @EndTime
	BEGIN;
		INSERT INTO	@Data
			(	ServerName, CaptureDate, DB, ObjectName, SessionId, BlockingSession, WaitType, WaitTime, WaitResource, CPUTime, ElapsedTime, DOP, GrantedMemoryKB, UsedMemoryKB, RequestId, Reads, LogicalReads, Writes, PercentComplete, RunningStartOffset, RequestStart, RequestStatus, RequestCommand, SchedulerId, HostName, Program, LoginName, SessionStatus, BaseText, RunningText, RunningPlan)
		SELECT	ServerName, CaptureDate, DB, ObjectName, SessionId, BlockingSession, WaitType, WaitTime, WaitResource, CPUTime, ElapsedTime, DOP, GrantedMemoryKB, UsedMemoryKB, RequestId, Reads, LogicalReads, Writes, PercentComplete, RunningStartOffset, RequestStart, RequestStatus, RequestCommand, SchedulerId, HostName, Program, LoginName, SessionStatus, BaseText, RunningText, RunningPlan
		FROM	OPENQUERY(' + @ServerName + 'KBT, ''
EXECUTE	MonDB.dbo.vnDBA_sp_Monitor_WarningStateCaptureRequestPlans;
'');

		INSERT INTO	dbo.vnDBA_Monitor_WarningStateRequests
			(	ServerName, CaptureDate, DB, ObjectName, SessionId, BlockingSession, WaitType, WaitTime, WaitResource, CPUTime, ElapsedTime, DOP, GrantedMemoryKB, UsedMemoryKB, RequestId, Reads, LogicalReads, Writes, PercentComplete, RunningStartOffset, RequestStart, RequestStatus, RequestCommand, SchedulerId, HostName, Program, LoginName, SessionStatus)
		SELECT	ServerName, CaptureDate, DB, ObjectName, SessionId, BlockingSession, WaitType, WaitTime, WaitResource, CPUTime, ElapsedTime, DOP, GrantedMemoryKB, UsedMemoryKB, RequestId, Reads, LogicalReads, Writes, PercentComplete, RunningStartOffset, RequestStart, RequestStatus, RequestCommand, SchedulerId, HostName, Program, LoginName, SessionStatus
		FROM	@Data;
		
		INSERT INTO	dbo.vnDBA_Monitor_WarningStatePlans
			(	ServerName, SessionId, RequestStart, RunningStartOffset, BaseText, RunningText, RunningPlan)
		SELECT	ServerName, SessionId, RequestStart, RunningStartOffset, BaseText, RunningText, RunningPlan
		FROM	@Data;

		INSERT INTO	dbo.vnDBA_Monitor_WarningStateSchedulers
			(	ServerName, CaptureDate, SchedulerId, CPUId, CurrentTasks, RunnableTasks, PendingTasks, ActiveWorkers, TotalWorkers)
		SELECT	ServerName, CaptureDate, SchedulerId, CPUId, CurrentTasks, RunnableTasks, PendingTasks, ActiveWorkers, TotalWorkers
		FROM	OPENQUERY(' + @ServerName + 'KBT, ''
EXECUTE	MonDB.dbo.vnDBA_sp_Monitor_WarningStateCaptureSchedulers;
'');
	END;
	ELSE
	BEGIN;
		UPDATE	css
		SET		StartTime	= NULL
			,	EndTime		= NULL
		FROM	dbo.vnDBA_Monitor_WarningStateCaptureSession AS css WITH (ROWLOCK)
		WHERE	ServerName = @ServerName;

		RETURN;
	END;

	WAITFOR DELAY ''00:00:01.000'';

	SELECT	@EndTime	= NULL;
END;
';
				
				BEGIN DIALOG CONVERSATION	@dialog
				FROM SERVICE	RawQueryInitiator
				TO SERVICE		'RawQueryTarget'
				ON CONTRACT		RawQueryContract
				WITH	ENCRYPTION	= OFF
					,	LIFETIME	= 172800
					;

				SEND ON CONVERSATION @dialog MESSAGE TYPE RawQueryMessage (@Message);

				END CONVERSATION @dialog;
			END;

			DELETE @result;
		END;

		WAITFOR DELAY '00:00:05.000';
	END;
END;
GO
/*<info serverAlias="DBSTARIX-StarixDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/