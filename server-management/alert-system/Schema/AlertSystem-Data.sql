/*
	Creator:	20190124@Billy
	Task:		Data for Alert System - [Redmine: #107814]
	Server:		DBSTARIX.StarixDB
*/


--	BEGIN STEP 1:
--		Regular Jobs
----------------------------------------------------------------------------------------------------

INSERT INTO	dbo.vnDBA_Alert_RegularJobSchedules
		(ServerName, JobName, StartWeekDay, StartTime, AvgDuration, MaxDuration, IsActive)
VALUES	(N'DBTRANS', N'DBA : DBA_ReIndex', 127, '11:00:00 PM', 1 * 3600 + 20 * 60, 1 * 3600 + 45 * 60 + 16, 1)
	,	(N'DBTRANS', N'DBA : DBA_ReIndex', 127, '04:30:00 AM', 25 * 60, 1 * 3600 + 37, 1)
	,	(N'DBTRANS', N'DBTRANS : DailySummary (Move Bet)', 34, '05:30:00 PM', 2 * 3600 + 10 * 60, 3 * 3600 + 12 * 60 + 11, 1)
	,	(N'DBTRANS', N'DBTRANS : DailySummary (Move Bet)', 76, '05:30:00 PM', 1 * 3600 + 10 * 60, 1 * 3600 + 27 * 60 + 47, 1)
	,	(N'DBTRANS', N'DBTRANS : Balance Up (Background)', 16, '04:35:00 PM', 3 * 3600 + 17 * 60, 3 * 3600 + 22 * 60 + 59, 1)
	;


--	BEGIN STEP 2:
--		Alert Thresholds
----------------------------------------------------------------------------------------------------

INSERT INTO	dbo.vnDBA_Alert_Thresholds
		(AlertType, Samples, Threshold, RegularThreshold, Method, Pattern)
VALUES	(N'Replication Latency', 3, 60000, 90000, NULL, NULL)
	,	(N'Ticket Latency', 3, 6000, 9000, NULL, NULL)
	;