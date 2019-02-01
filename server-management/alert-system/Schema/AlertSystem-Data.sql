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
VALUES	(N'DBTRANS', N'DBA : DBA_ReIndex', 254, '11:00:00 PM', 1 * 3600 + 20 * 60, 1 * 3600 + 45 * 60 + 16, 1)
	,	(N'DBTRANS', N'DBA : DBA_ReIndex', 254, '04:30:00 AM', 25 * 60, 1 * 3600 + 37, 1)
	,	(N'DBTRANS', N'DBTRANS : DailySummary (Move Bet)', 68, '05:30:00 PM', 2 * 3600 + 10 * 60, 3 * 3600 + 12 * 60 + 11, 1)
	,	(N'DBTRANS', N'DBTRANS : DailySummary (Move Bet)', 152, '05:30:00 PM', 1 * 3600 + 10 * 60, 1 * 3600 + 27 * 60 + 47, 1)
	,	(N'DBTRANS', N'DBTRANS : Balance Up (Background)', 32, '04:35:00 PM', 3 * 3600 + 17 * 60, 3 * 3600 + 22 * 60 + 59, 1)
	;


--	BEGIN STEP 2:
--		Alert Thresholds
----------------------------------------------------------------------------------------------------

INSERT INTO	dbo.vnDBA_Alert_Repl_Thresholds
		(AlertLevel, Samples, Violates, AlertInterval, TimeThreshold, RegTimeThreshold, IdThreshold, RegIdThreshold)
VALUES	(         1,       3,        2,            60,         60000,            90000,       12000,          18000)
	,	(         2,       3,        2,           120,        120000,           180000,       24000,          36000)
	,	(         3,       3,        2,           120,        180000,           300000,       36000,          60000)
	,	(         4,       3,        2,           300,        300000,           480000,       60000,          96000)
	,	(         5,       3,        2,           300,        600000,           900000,      120000,         180000)
	,	(         6,       3,        2,           600,       1200000,          1800000,      240000,         360000)
	,	(         7,       3,        2,           600,       2400000,          3600000,      480000,         720000)
	,	(         8,       3,        2,           600,       3600000,          5400000,      720000,        1440000)
	,	(         9,       3,        2,           600,       7200000,         10800000,     1440000,        2880000)
	,	(     32767,       0,        0,             0,             0,                0,           0,              0)
	;


--	BEGIN STEP 3:
--		Alert Repication Tables
----------------------------------------------------------------------------------------------------

INSERT INTO	dbo.vnDBA_Alert_Repl_Publications
		(              Publication, AlertLevel)
VALUES	(           N'DBTrans_Bet',          1)
	,	(       N'DBTrans_ExecRep',      32767)
	,	(  N'CustDB_Customer_Info',          1)
	,	(    N'CustDB_CustSetting',          2)
	,	(N'CustDB_ExecRepAcc_Cust',      32767)
	;

INSERT INTO	dbo.vnDBA_Alert_Repl_Subsribers
		(   Subscriber, AlertLevel, AlertCase)
VALUES	(   N'DBTRANS',          1,         3)
	,	(     N'DB042',          1,         1)
	,	(     N'DB054',          8,         1)
	,	(     N'DB052',          1,         1)
	,	(     N'DB053',          1,         1)
	,	(      N'DB06',          1,         3)
	,	(      N'DBTP',          8,         1)
	,	(     N'DB043',          1,         2)
	,	(     N'DB044',          1,         2)
	,	(      N'DB05',          8,         1)
	,	(   N'DB05BK1',          8,         1)
	,	(  N'DBLICAPI',          9,         2)
	,	(N'DBLICAPI02',          9,         2)
	;