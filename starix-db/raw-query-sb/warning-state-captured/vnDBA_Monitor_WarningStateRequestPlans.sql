/*
	Creator:	20180704@Billy
	Task:		View for warning state monitoring - [Redmine: #00000]
	Server:		DBSTARIX-StarixDB
*/


USE	StarixDB;
GO

IF	OBJECT_ID('dbo.vnDBA_Monitor_WarningStateRequestPlans') IS NOT NULL
	DROP VIEW	dbo.vnDBA_Monitor_WarningStateRequestPlans;
GO
CREATE VIEW	dbo.vnDBA_Monitor_WarningStateRequestPlans
AS
SELECT	rqs.ServerName
	,	rqs.CaptureDate
	,	rqs.SessionId
	,	rqs.RequestId
	,	rqs.BlockingSession
	,	rqs.DB
	,	rqs.LoginName
	,	rqs.RequestCommand
	,	rqs.RequestStatus
	,	rqs.WaitType
	,	rqs.WaitTime
	,	rqs.WaitResource
	,	pln.RunningText
	,	pln.BaseText
	,	rqs.Reads
	,	rqs.LogicalReads
	,	rqs.CPUTime
	,	rqs.ElapsedTime
	,	rqs.Program
	,	pln.RunningPlan
FROM		dbo.vnDBA_Monitor_WarningStateRequests AS rqs WITH (NOLOCK)
LEFT JOIN	dbo.vnDBA_Monitor_WarningStatePlans AS pln WITH (NOLOCK)
		ON	rqs.ServerName = pln.ServerName
		AND	rqs.RequestStart = pln.RequestStart
		AND	rqs.SessionId = pln.SessionId
		AND	rqs.RunningStartOffset = pln.RunningStartOffset;
GO