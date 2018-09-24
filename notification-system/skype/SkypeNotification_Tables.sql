/*
	Creator:	20180905@Billy
	Task:		Tables for Skype Notification - [Redmine: #101021]
	Server:		DBMON.MonDBDW
*/

USE	MonDBDW;
GO

CREATE TABLE	dbo.DBA_SkypeNotifications (
					NotificationId		INT				NOT NULL	IDENTITY(1, 1)
				,	ServerName			VARCHAR(100)	NULL
				,	Title				VARCHAR(100)	NULL
				,	MsgInfo				NVARCHAR(4000)	NULL
				,	LogDate				DATETIME		NOT NULL
				,	SkypeGroupId		VARCHAR(256)	NOT NULL
				,	isSimple			BIT				NOT NULL
						CONSTRAINT	DF_SkypeNotifications_isSimple	DEFAULT (0)
				,	isNoticed			BIT				NOT NULL
						CONSTRAINT	DF_SkypeNotifications_isNoticed	DEFAULT (0)
				,	CONSTRAINT	PK_SkypeNotifications PRIMARY KEY CLUSTERED (NotificationId ASC)
				);

CREATE NONCLUSTERED INDEX	IX_SkypeNotifications_isNoticed ON dbo.DBA_SkypeNotifications (
								isNoticed	ASC
							)
							WHERE	isNoticed = 0;

CREATE TABLE	dbo.DBA_SkypeGroup (
					GroupId				INT				NOT NULL	IDENTITY(1, 1)
				,	SkypeGroupId		VARCHAR(256)	NOT NULL
				,	CodeName			VARCHAR(128)	NULL
				,	SkypeName			VARCHAR(128)	NULL
				,	CONSTRAINT	PK_SkypeGroup PRIMARY KEY CLUSTERED (GroupId ASC)
				);

CREATE UNIQUE NONCLUSTERED INDEX	UIX_SkypeGroup_SkypeGroupId ON dbo.DBA_SkypeGroup (SkypeGroupId);
