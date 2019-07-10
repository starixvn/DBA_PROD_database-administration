/*
	Creator:	20180905@Billy
	Task:		Tables for Skype Notification - [Redmine: #101021]
	Server:		DBNOTI.NotificationDB
*/
USE	NotificationDB;
GO

CREATE TABLE	dbo.DBA_SkypeGroup (
					GroupId				INT				NOT NULL	IDENTITY(1, 1)
				,	SkypeGroupId		VARCHAR(256)	NOT NULL
				,	CodeName			VARCHAR(128)	NULL
				,	SkypeName			NVARCHAR(128)	NULL
				,	CONSTRAINT	PK_SkypeGroup PRIMARY KEY CLUSTERED (GroupId ASC) ON DATA
				);

CREATE UNIQUE NONCLUSTERED INDEX	UIX_SkypeGroup_SkypeGroupId ON dbo.DBA_SkypeGroup (
										SkypeGroupId	ASC
									) ON IDX;

CREATE UNIQUE NONCLUSTERED INDEX	UIX_SkypeGroup_CodeName ON dbo.DBA_SkypeGroup (
										CodeName	ASC
									) ON IDX;

CREATE TABLE	dbo.DBA_SkypeNotifications (
					NotificationId		INT				NOT NULL	IDENTITY(1, 1)
				,	ServerName			NVARCHAR(128)	NULL
				,	Title				NVARCHAR(128)	NULL
				,	MsgInfo				NVARCHAR(4000)	NULL
				,	LogDate				DATETIME		NOT NULL
				,	SkypeGroupId		VARCHAR(256)	NOT NULL
				,	isSimple			BIT				NOT NULL
						CONSTRAINT	DF_SkypeNotifications_isSimple	DEFAULT (0)
				,	isNoticed			BIT				NOT NULL
						CONSTRAINT	DF_SkypeNotifications_isNoticed	DEFAULT (0)
				,	CONSTRAINT	PK_SkypeNotifications PRIMARY KEY NONCLUSTERED (NotificationId ASC) ON IDX
				);

CREATE CLUSTERED INDEX	CIX_SkypeNotifications_isNoticed ON dbo.DBA_SkypeNotifications (
								isNoticed	ASC
							,	LogDate		ASC
							) WITH (DATA_COMPRESSION = PAGE) ON DATA;
