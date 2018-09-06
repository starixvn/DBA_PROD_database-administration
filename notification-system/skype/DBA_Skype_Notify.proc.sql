SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
ALTER PROCEDURE	dbo.DBA_Skype_Notify
						@minute			INT			= 5
AS
/*
	Creator:	20180906@Billy
	Task:		Letstalk Notification - Get messages to notify via Letstalk - [Redmine: #101021]
	Database:	DBMON.MonDBDW
	
	Revisions:
		- 20170207@Billy:	Initialization - [Redmine: #101021]

	Parameters:
		@minute			: We will get the message from this amount of minutes in the past to the current time
		@type			: The message type that we will get (NULL values means get all of the types)
*/
BEGIN
	SET NOCOUNT ON;
	
	-- Declare variables & temporary schemas --
	DECLARE	@messages	AS TABLE (
							ServerName		VARCHAR(100)
						,	Title			VARCHAR(100)
						,	MsgInfo			NVARCHAR(4000)
						,	LogDate			DATETIME
						,	SkypeGroupId	VARCHAR(256)
						,	isSimple		BIT
						);

	DECLARE	@Log_Date	DATETIME
		;

	-- Get the time of @minute ago --
	SELECT	@Log_Date = DATEADD(MINUTE, -@minute, GETDATE())
		;

	-- Get all unnotified messages from @minute ago filtered by @type --
	UPDATE	sn
	SET		sn.isNoticed = 1
	OUTPUT	Deleted.ServerName, Deleted.Title, Deleted.MsgInfo, Deleted.LogDate, Deleted.SkypeGroupId, Deleted.isSimple
	INTO	@messages (ServerName, Title, MsgInfo, LogDate, SkypeGroupId, isSimple)
	FROM	dbo.DBA_SkypeNotifications AS sn WITH (ROWLOCK, UPDLOCK)
	WHERE	sn.LogDate >= @Log_Date								-- Get message from @minute ago
		AND	sn.isNoticed = 0									-- Get only unnotified messages
	;

	-- Return the result --
	SELECT	m.ServerName, m.Title, m.MsgInfo, m.LogDate, m.SkypeGroupId, m.isSimple
	FROM	@messages AS m;
END;
GO
/*<info serverAlias="DBMON-MonDBDW" executers="DBA_Letstalk,MonDB_User" viewers="" isFunction="0" isNested="0"></info>*/