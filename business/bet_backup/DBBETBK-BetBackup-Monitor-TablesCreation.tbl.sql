/*
	Creator:	20190724@Billy
	Task:		BetBackup monitoring tables - [Redmine: #116270]
	Server:		DBBETBK.BetBackup
*/


--	BEGIN STEP 1:
--		Job task execution log
----------------------------------------------------------------------------------------------------

USE	BetBackup;
GO

CREATE TABLE	dbo.Monitor_JobTaskExecution (
					TaskName			NVARCHAR(128)	NOT NULL
				,	ExecTime			DATETIME		NOT NULL
				,	ExecDuration		BIGINT			NOT NULL
				,	isAbnormal			BIT				NOT NULL
						CONSTRAINT	DF_JobTaskExecution_Abnormal DEFAULT (0)
				) ON DATA;

CREATE CLUSTERED INDEX	CIX_JobTaskExecution ON dbo.Monitor_JobTaskExecution (
							TaskName	ASC
						,	ExecTime	ASC
						) WITH (DATA_COMPRESSION = PAGE) ON DATA;
GO