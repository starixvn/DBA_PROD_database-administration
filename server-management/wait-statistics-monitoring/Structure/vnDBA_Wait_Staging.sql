/*
	Creator:	20171009@Billy
	Task:		New Wait Statistics Capturing - [Redmine: #84605]
	Server:		DBDWCSS.StarixDB
*/

USE	StarixDB;
GO

CREATE TABLE	dbo.vnDBA_Wait_Staging (
					ServerName					NVARCHAR(128)	NOT NULL
				,	CaptureDate					DATETIME		NOT NULL
				,	msTicks						BIGINT			NOT NULL
				,	WaitType					NVARCHAR(60)	NOT NULL
				,	WaitingTasksCount			BIGINT			NOT NULL
				,	WaitTime_ms					BIGINT			NOT NULL
				,	SignalWaitTime_ms			BIGINT			NOT NULL
				,	CONSTRAINT PK_vnDBA_Wait_Staging PRIMARY KEY CLUSTERED (ServerName ASC, CaptureDate ASC, WaitType ASC) ON WaitStat
				) ON WaitStat;
GO