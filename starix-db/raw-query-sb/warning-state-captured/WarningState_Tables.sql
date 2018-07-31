/*
	Creator:	20180704@Billy
	Task:		Tables for warning state monitoring - [Redmine: #00000]
	Server:		DBSTARIX-StarixDB
*/


USE	StarixDB;
GO

IF	OBJECT_ID('dbo.vnDBA_Monitor_WarningStateRequests') IS NOT NULL
	--RETURN;
	DROP TABLE	dbo.vnDBA_Monitor_WarningStateRequests;

CREATE TABLE	dbo.vnDBA_Monitor_WarningStateRequests (
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
				);

CREATE CLUSTERED INDEX	CIX_Monitor_WarningStateRequests ON dbo.vnDBA_Monitor_WarningStateRequests (
							ServerName	ASC
						,	CaptureDate	ASC
						,	SessionId	ASC
						) WITH (DATA_COMPRESSION = PAGE) ON Monitor;

CREATE NONCLUSTERED INDEX	IX_Monitor_WarningStateRequests ON dbo.vnDBA_Monitor_WarningStateRequests (
								CaptureDate	ASC
							,	ServerName	ASC
							) 
							INCLUDE (
								RequestStart
							,	RunningStartOffset
							) WITH (DATA_COMPRESSION = PAGE) ON Monitor;


IF	OBJECT_ID('dbo.vnDBA_Monitor_WarningStateSchedulers') IS NOT NULL
	--RETURN;
	DROP TABLE	dbo.vnDBA_Monitor_WarningStateSchedulers;

CREATE TABLE	dbo.vnDBA_Monitor_WarningStateSchedulers (
					ServerName			NVARCHAR(128)
				,	CaptureDate			DATETIME
				,	SchedulerId			INT
				,	CPUId				INT
				,	CurrentTasks		INT
				,	RunnableTasks		INT
				,	PendingTasks		BIGINT
				,	ActiveWorkers		INT
				,	TotalWorkers		INT
				);

CREATE CLUSTERED INDEX	CIX_Monitor_WarningStateSchedulers ON dbo.vnDBA_Monitor_WarningStateSchedulers (
							ServerName	ASC
						,	CaptureDate	ASC
						,	SchedulerId	ASC
						) WITH (DATA_COMPRESSION = PAGE) ON Monitor;
						
CREATE NONCLUSTERED INDEX	IX_Monitor_WarningStateSchedulers ON dbo.vnDBA_Monitor_WarningStateSchedulers (
							CaptureDate	ASC
						,	ServerName	ASC
						) WITH (DATA_COMPRESSION = PAGE) ON Monitor;


IF	OBJECT_ID('dbo.vnDBA_Monitor_WarningStateCaptureSession') IS NOT NULL
	--RETURN;
	DROP TABLE	dbo.vnDBA_Monitor_WarningStateCaptureSession;

CREATE TABLE	dbo.vnDBA_Monitor_WarningStateCaptureSession (
					ServerName			NVARCHAR(128)		NOT NULL
				,	StartTime			DATETIME			NULL
				,	EndTime				DATETIME			NULL
				,	CONSTRAINT	PK_Monitor_WarningStateCaptureSession PRIMARY KEY CLUSTERED (
									ServerName	ASC
								) WITH (DATA_COMPRESSION = PAGE) ON Monitor
				) ON DATA;
				
	

IF	OBJECT_ID('dbo.vnDBA_Monitor_WarningStatePlans') IS NOT NULL
	--RETURN;
	DROP TABLE	dbo.vnDBA_Monitor_WarningStatePlans;

CREATE TABLE	dbo.vnDBA_Monitor_WarningStatePlans (
					ServerName			NVARCHAR(128)
				,	SessionId			SMALLINT
				,	RequestStart		DATETIME
				,	RunningStartOffset	INT
				,	BaseText			VARCHAR(MAX)
				,	RunningText			VARCHAR(MAX)
				,	RunningPlan			VARCHAR(MAX)
				);

CREATE CLUSTERED INDEX	CIX_Monitor_WarningStatePlans ON dbo.vnDBA_Monitor_WarningStatePlans (
							ServerName			ASC
						,	SessionId			ASC
						,	RequestStart		ASC
						,	RunningStartOffset	ASC
						) WITH (DATA_COMPRESSION = PAGE) ON Monitor;

CREATE NONCLUSTERED INDEX	IX_Monitor_WarningStatePlans ON dbo.vnDBA_Monitor_WarningStatePlans (
								RunningStartOffset	ASC
							,	RequestStart		ASC
							) WITH (DATA_COMPRESSION = PAGE) ON Monitor;
GO

CREATE TRIGGER	dbo.Trig_Monitor_WarningStatePlans_IOI ON dbo.vnDBA_Monitor_WarningStatePlans
INSTEAD OF INSERT
AS
/*
	Creator:	20180705@Billy
	Task:		Trigger for insert plan data - [Redmine: #00000]
	Database:	StarixDB
	
	Revisions:
		- 20180705@Billy:	Initial - [Redmine: #00000]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	INSERT INTO	dbo.vnDBA_Monitor_WarningStatePlans
		(	  ServerName,   SessionId,   RequestStart,   RunningStartOffset,   BaseText,   RunningText,   RunningPlan)
	SELECT	i.ServerName, i.SessionId, i.RequestStart, i.RunningStartOffset, i.BaseText, i.RunningText, i.RunningPlan
	FROM	inserted AS i
	OUTER APPLY	(
		SELECT	TOP(1)
				[OK]	= 0
		FROM	dbo.vnDBA_Monitor_WarningStatePlans AS _pln WITH (NOLOCK)
		WHERE	i.ServerName = _pln.ServerName
			AND	i.SessionId = _pln.SessionId
			AND	i.RequestStart = _pln.RequestStart
			AND	i.RunningStartOffSet = _pln.RunningStartOffSet
	) AS stt
	WHERE	stt.OK IS NULL;
END;
GO