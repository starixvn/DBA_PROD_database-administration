/*
	Creator:	20171009@Billy
	Task:		New Wait Statistics Capturing - [Redmine: #84605]
	Server:		DBDWCSS.StarixDB
*/

USE	StarixDB;
GO

CREATE TABLE	dbo.vnDBA_Wait_Captured (
					ServerName					NVARCHAR(128)	NOT NULL
				,	CalculateDate				DATETIME		NOT NULL
				,	Calc_msTicks				BIGINT			NOT NULL
				,	WaitType					NVARCHAR(60)	NOT NULL
				,	CalcWaitingTasksCount		BIGINT			NOT NULL
				,	CalcWaitTime_ms				BIGINT			NOT NULL
				,	CalcSignalWaitTime_ms		BIGINT			NOT NULL
				,	CONSTRAINT PK_vnDBA_Wait_Captured PRIMARY KEY CLUSTERED (ServerName ASC, CalculateDate ASC, WaitType ASC) WITH (DATA_COMPRESSION = PAGE) ON WaitStat
				) ON WaitStat;
GO