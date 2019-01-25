/*
	Creator:	20190124@Billy
	Task:		Tables for Alert System - [Redmine: #107814]
	Server:		DBSTARIX.StarixDB
*/


--	BEGIN STEP 1:
--		Regular Jobs Metadata
----------------------------------------------------------------------------------------------------

CREATE TABLE	dbo.vnDBA_Alert_RegularJobSchedules (
					ScheduleId		INT				NOT NULL		IDENTITY(1,1)
				,	ServerName		NVARCHAR(128)	NOT NULL
				,	JobName			NVARCHAR(128)	NOT NULL
				,	StartWeekDay	TINYINT
				,	StartTime		TIME(2)
				,	AvgDuration		INT
				,	MaxDuration		INT
				,	IsActive		BIT				NOT NULL
						CONSTRAINT	DF_Alert_RegularJobSchedules_Active DEFAULT (1)
				,	CONSTRAINT PK_Alert_RegularJobSchedules_Id PRIMARY KEY NONCLUSTERED (ScheduleID) ON DATA
				);

CREATE CLUSTERED INDEX	CIX_Alert_RegularJobSchedules ON dbo.vnDBA_Alert_RegularJobSchedules (
							ServerName	ASC
						,	JobName		ASC
						) ON DATA;


--	BEGIN STEP 2:
--		Alert Threshold Definition
----------------------------------------------------------------------------------------------------

CREATE TABLE	dbo.vnDBA_Alert_Thresholds (
					AlertType			NVARCHAR(128)	NOT NULL
				,	Samples				INT				NOT NULL
				,	Threshold			DECIMAL(19, 8)	NOT NULL
				,	RegularThreshold	DECIMAL(19, 8)	NOT NULL
				,	Method				NVARCHAR(128)
				,	Pattern				VARCHAR(MAX)
				,	CONSTRAINT	PK_Alert_Thresholds_Type PRIMARY KEY CLUSTERED (AlertType) ON DATA
				);
