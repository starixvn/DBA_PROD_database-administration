USE n8nDB
GO
CREATE TABLE n8n_CookiesLogin (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    SiteName VARCHAR(50) ,
    Cookie NVARCHAR(MAX) ,
	LoginName VARCHAR(50),
	PassLogin BINARY(64) ,
	Salt UNIQUEIDENTIFIER,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE()
);
GO 

CREATE TABLE n8n_GoogleCalandar_Realtime (
    ID VARCHAR(100), 
    StartTime   DATETIME,
    EndTime     DATETIME,
    Attendees   VARCHAR(500),
    Room        VARCHAR(255),
    Summary     VARCHAR(255),
    RunCount INT ,
	RunTime DATETIME
);
GO
CREATE TABLE n8n_GoogleCalandar (
	MeetingID INT IDENTITY(1,1),
	ID VARCHAR(100),
    StartTime   DATETIME,
    EndTime     DATETIME,
    Attendees   VARCHAR(500),
    Room        VARCHAR(255),
	Summary VARCHAR(255),
	IsDelete	BIT 
);
GO

CREATE TABLE [dbo].[HRM_LeaveLog](
	[LeaveID] [int] IDENTITY(1,1) NOT NULL,
	[Nickname] [varchar](100) NULL,
	[Fullname] [nvarchar](100) NULL,
	[Team] [varchar](50) NULL,
	[Leavedate] [date] NULL,
	[FromTime] [varchar](20) NULL,
	[ToTime] [varchar](20) NULL,
	[IsDelete] [bit] NULL
) ON [DATA]
GO

CREATE TABLE [dbo].[HRM_LeaveLog_Realtime](
	[LeaveID] [int] IDENTITY(1,1) NOT NULL,
	[Nickname] [varchar](100) NULL,
	[Fullname] [nvarchar](100) NULL,
	[Team] [varchar](50) NULL,
	[Leavedate] [date] NULL,
	[FromTime] [varchar](20) NULL,
	[ToTime] [varchar](20) NULL,
    [CreatedDate] DATETIME DEFAULT GETDATE() ,
	[RunTime] DATETIME
) ON [DATA]
GO
CREATE TABLE [dbo].[HRM_AttendanceLog](
	[AttendID] [int] IDENTITY(1,1) NOT NULL,
	[Nickname] [varchar](100) NULL,
	[WorkDate] [date] NULL,
	[CheckInTime] [varchar](20) NULL,
	[CheckOutTime] [varchar](20) NULL,
	[RunTime] DATETIME
) ON [DATA]
GO

CREATE TABLE Rocketor_DeployRequest (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Message NVARCHAR(MAX) NULL,
    Type NVARCHAR(50) NULL,
    RequestTime DATETIME NULL,
    Requester NVARCHAR(100) NULL,
    Repo NVARCHAR(255) NULL,
    PackageName NVARCHAR(500) NULL,
    Environment NVARCHAR(100) NULL,
    Assignee NVARCHAR(100) NULL,
    DeployInUM NVARCHAR(10) NULL,
    DeployIn VARCHAR(50) NULL,
    RunTimeAt DATETIME DEFAULT GETDATE(),
	IsDelete BIT
);


GO 

GO
CREATE TABLE Rocketor_DeployRequestAlert (
    DeployID INT,
	MeetingID INT,
	LeaveID INT,
	AttendID INT,
    Reason VARCHAR(500) NULL,
	ReminderSent TINYINT DEFAULT 0,
	ReminderSentAt DATETIME
);

GO

CREATE TABLE TeamMember (
	Team VARCHAR(50),
	Nickname VARCHAR(100),
	Fullname VARCHAR(200),
	Username VARCHAR(100)
)
GO
INSERT INTO TeamMember ([Team], [Nickname], [Fullname], [Username])
VALUES ('Pontus', 'Dominic', 'Dao Trong Nghia', 'Dominic.Dao'),
       ('Pontus', 'Lukas', 'Luu Hoang Loc', 'Lukas.Luu'),
       ('Pontus', 'Daniel', 'Truong Doan Vu Vinh', 'Daniel.Truong'),
       ('Pontus', 'Patrick', 'Pham Manh Cuong', 'Patrick.Pham'),
       ('Pontus', 'Kean', 'Nguyen Ngoc Thach', 'Kean.Nguyen'),
       ('Pontus', 'Sol', 'Le Ngoc Tai', 'Sol.Le'),
       ('Pontus', 'Malcolm', 'Huynh Van Kiet', 'Malcolm.Huynh'),
       ('Pontus', 'Brice', 'Nguyen Tan Thanh', 'Brice.Nguyen'),
       ('Pontus', 'Roy', 'Du Thanh Danh', 'Roy.Du'),
       ('Pontus', 'Evan', 'Trinh Du Long', 'Evan.Trinh');

GO 
CREATE TABLE n8n_FlowSchedule 
(
ID INT IDENTITY(1,1),
Flow VARCHAR(50),
Interval INT,
LastRuntime DATETIME
)

INSERT INTO n8n_FlowSchedule (Flow, Interval,LastRuntime)
VALUES ('GoogleCalandar', 60, GETDATE());

INSERT INTO n8n_FlowSchedule (Flow, Interval,LastRuntime)
VALUES ('HRM', 5, GETDATE());
GO
DECLARE @salt UNIQUEIDENTIFIER=NEWID()
DECLARE @LoginName VARCHAR(100) = 'evan.trinh'
DECLARE @PassLogin VARCHAR(100) = 'Tranhungdao@0825'
INSERT INTO n8n_CookiesLogin (SiteName, Cookie, LoginName, PassLogin, Salt)
VALUES (N'HRM', N'', @LoginName, HASHBYTES('SHA2_512', @PassLogin+CAST(@salt AS NVARCHAR(36))), @salt);

INSERT INTO n8n_CookiesLogin (SiteName, Cookie, LoginName, PassLogin, Salt)
VALUES (N'Rocketor', N'', @LoginName, HASHBYTES('SHA2_512', @PassLogin+CAST(@salt AS NVARCHAR(36))), @salt);
GO


CREATE CLUSTERED INDEX CIX_n8n_GoogleCalandar_MeetingID ON n8n_GoogleCalandar (MeetingID,ID)
CREATE CLUSTERED INDEX CIX_n8n_GoogleCalandar_Realtime_MeetingID ON n8n_GoogleCalandar_Realtime (ID)
CREATE CLUSTERED INDEX CIX_HRM_LeaveLog_LeaveID ON HRM_LeaveLog (LeaveID)
CREATE CLUSTERED INDEX CIX_HRM_LeaveLog_Realtime_LeaveID ON HRM_LeaveLog_Realtime (LeaveID)

CREATE CLUSTERED INDEX CIX_HRM_AttendanceLog_AttendID ON HRM_AttendanceLog (AttendID)
CREATE CLUSTERED INDEX CIX_Rocketor_DeployRequestAlert ON Rocketor_DeployRequestAlert (DeployID,MeetingID,LeaveID,AttendID)
