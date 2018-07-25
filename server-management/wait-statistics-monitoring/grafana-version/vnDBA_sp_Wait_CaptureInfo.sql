USE MonDB;
GO

ALTER PROCEDURE	dbo.vnDBA_sp_Wait_CaptureInfo
AS
/*
	Creator:	20171103@Billy
	Task:		Capture Wait Statistics information - Target side - [Redmine: #83670]
	Database:	[ALL SERVERS].MonDB
	
	Revisions:
		- 20171103@Billy:	Initial - [Redmine: #83670]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@basetime	DATETIME;

	SELECT	@basetime	= '2010-01-01';

	SELECT	[ServerName]			= @@SERVERNAME
		,	[CaptureDate]			= DATEADD(SECOND, DATEDIFF(SECOND, @basetime, GETDATE()), @basetime)
		,	[msTicks]				= ms_ticks
		,	[WaitType]				= wait_type
		,	[WaitingTasksCount]		= waiting_tasks_count
		,	[WaitTime_ms]			= wait_time_ms
		,	[SignalWaitTime_ms]		= signal_wait_time_ms
	FROM		sys.dm_os_wait_stats WITH (NOLOCK)
	CROSS JOIN	sys.dm_os_sys_info WITH (NOLOCK);
END;
GO


GRANT EXECUTE ON dbo.vnDBA_sp_Wait_CaptureInfo TO sqlLink AS dbo;
GO


ADD SIGNATURE TO OBJECT::dbo.vnDBA_sp_Wait_CaptureInfo
BY CERTIFICATE serverlevel_cert
WITH PASSWORD = '************';
GO