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

CREATE TABLE	dbo.vnDBA_Alert_Repl_Thresholds (
					AlertLevel			SMALLINT		NOT NULL
				,	Samples				INT				NOT NULL
				,	Violates			INT				NOT NULL
				,	AlertInterval		INT				NOT NULL
				,	TimeThreshold		INT				NOT NULL
				,	RegTimeThreshold	INT				NOT NULL
				,	IdThreshold			INT				NOT NULL
				,	RegIdThreshold		INT				NOT NULL
				,	CONSTRAINT	PK_AlertReplThresholds PRIMARY KEY CLUSTERED (AlertLevel) ON DATA
				);


--	BEGIN STEP 3:
--		Alert Replication Tables
----------------------------------------------------------------------------------------------------

CREATE TABLE	dbo.vnDBA_Alert_Repl_Publications (
					Publication			NVARCHAR(128)	NOT NULL
				,	AlertLevel			SMALLINT		NOT NULL
						CONSTRAINT	DF_AlertReplPubs_AlertLevel DEFAULT (0)
				,	CONSTRAINT	PK_AlertReplPubs PRIMARY KEY CLUSTERED (Publication) ON DATA
				);

CREATE TABLE	dbo.vnDBA_Alert_Repl_Subsribers (
					Subscriber			NVARCHAR(128)	NOT NULL
				,	AlertLevel			SMALLINT		NOT NULL
						CONSTRAINT	DF_AlertReplSubs_AlertLevel DEFAULT (0)
				,	AlertCase			TINYINT			NOT NULL
						CONSTRAINT	DF_AlertReplSubs_AlertCase DEFAULT (1)
				,	CONSTRAINT	PK_AlertReplSubs PRIMARY KEY CLUSTERED (Subscriber) ON DATA
				);


--	BEGIN STEP 4:
--		Alert Replication Result
----------------------------------------------------------------------------------------------------

CREATE TABLE	dbo.vnDBA_Alert_Repl_Result (
					Publisher		NVARCHAR(128)		NOT NULL
				,	PublishDB		NVARCHAR(128)		NOT NULL
				,	Publication		NVARCHAR(128)		NOT NULL
				,	Subscriber		NVARCHAR(128)		NOT NULL
				,	CounterTime		DATETIME
				,	AlertCase		TINYINT				NOT NULL
				,	CONSTRAINT	PK_AlertReplResult PRIMARY KEY CLUSTERED (Publisher, PublishDB, Publication, Subscriber) ON DATA
				);