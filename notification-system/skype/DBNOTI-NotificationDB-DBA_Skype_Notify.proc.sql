SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE	dbo.DBA_Skype_Notify
						@minute			INT			= 5
AS
/*
	Creator:	20180906@Billy
	Task:		Skype Notification - Get messages to notify via Skype - [Redmine: #101021]
	Database:	DBNOTI.NotificationDB
	
	Revisions:
		- 20170207@Billy:	Initialization - [Redmine: #101021]
		- 20190523@Billy:	Move system to DBSPARE - [Redmine: #113125]

	Parameters:
		@minute			: We will get the message from this amount of minutes in the past to the current time
*/
BEGIN
	SET NOCOUNT ON;
	
	-- Declare variables & temporary schemas --
	DECLARE	@Log_Date	DATETIME
		;

	-- Get the time of @minute ago --
	SELECT	@Log_Date = DATEADD(MINUTE, -@minute, GETDATE())
		;

	-- Return the result --
	SELECT	sn.NotificationId, sn.ServerName, sn.Title, sn.MsgInfo, sn.LogDate, sn.SkypeGroupId, sn.isSimple
	FROM	dbo.DBA_SkypeNotifications AS sn WITH (NOLOCK)
	WHERE	sn.LogDate >= @Log_Date								-- Get message from @minute ago
		AND	sn.isNoticed = 0									-- Get only unnotified messages
	ORDER BY sn.LogDate ASC;
END;
GO
/*<info serverAlias="DBNOTI-NotificationDB" executers="DBA_Skype" viewers="" isFunction="0" isNested="0"></info>*/