/*
	Creator:	20180905@Billy
	Task:		Tables for Letstalk Notification - [Redmine: #00000]
	Server:		DBNOTI.NotificationDB
*/
USE	NotificationDB;
GO

CREATE TABLE	dbo.DBA_LetstalkJobs (
					ServerName		NVARCHAR(128)	NOT NULL
				,	JobId			CHAR(36)		NOT NULL
				,	JobName			NVARCHAR(128)	NOT NULL
				,	Level			TINYINT			NOT NULL
						CONSTRAINT	DF_LetstalkJobs_Level DEFAULT (3)
				,	RoomId			INT				NOT NULL
				,	CaseId			TINYINT			NOT NULL
				,	SkypeGroupId	INT				NULL
				,	CONSTRAINT PK_DBA_LetstalkJobs PRIMARY KEY CLUSTERED (ServerName ASC, JobId ASC, CaseId ASC) ON DATA
				) ON DATA;

CREATE TABLE	dbo.DBA_LetstalkRooms (
					RoomId			INT				NOT NULL
				,	RoomName		VARCHAR(100)	NOT NULL
				,	isActive		BIT				NOT NULL
						CONSTRAINT	DF_LetstalkRooms_isActive DEFAULT (1)
				,	SendDirectly	BIT				NOT NULL
						CONSTRAINT	DF_LetstalkRooms_SendDirectly DEFAULT (0)
				,	CONSTRAINT PK_DBA_LetstalkRooms PRIMARY KEY CLUSTERED (RoomId ASC) ON DATA
				) ON DATA;

CREATE TABLE	dbo.DBA_LetstalkNotifications (
					Id				INT				NOT NULL	IDENTITY(1, 1)
				,	ServerName		NVARCHAR(128)	NULL
				,	Title			NVARCHAR(128)	NULL
				,	MsgInfo			NVARCHAR(4000)	NULL
				,	LogDate			DATETIME		NOT NULL
				,	MessageType		VARCHAR(16)		NULL
				,	TargetName		VARCHAR(128)	NOT NULL
				,	isNoticed		BIT				NOT NULL
						CONSTRAINT	DF_LetstalkNotifications_isNoticed DEFAULT (0)
				,	SkypeGroupId	INT				NULL
				,	CONSTRAINT PK_DBA_LetstalkNotifications PRIMARY KEY CLUSTERED (Id ASC) WITH (DATA_COMPRESSION = PAGE) ON DATA
				) ON DATA;