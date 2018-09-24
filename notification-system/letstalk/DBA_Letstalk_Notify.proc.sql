SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
ALTER PROCEDURE	dbo.DBA_Letstalk_Notify
						@minute			INT			= 5
					,	@type			VARCHAR(16)	= NULL
AS
/*
	Creator:	20170207@Billy
	Task:		Letstalk Notification - Get messages to notify via Letstalk - [Redmine: #70016]
	Database:	DBMON.MonDBDW
	
	Revisions:
		- 20170207@Billy:	Initialization - [Redmine: #70016]
		- 20180202@Billy:	Support Skype notification - [Redmine: #90474]

	Parameters:
		@minute			: We will get the message from this amount of minutes in the past to the current time
		@type			: The message type that we will get (NULL values means get all of the types)
*/
BEGIN
	SET NOCOUNT ON;
	
	-- Declare variables & temporary schemas --
	CREATE TABLE	#messages (
						ServerName		VARCHAR(100)
					,	Title			VARCHAR(100)
					,	MsgInfo			NVARCHAR(4000)
					,	LogDate			DATETIME
					,	TargetName		VARCHAR(128)
					,	SkypeGroupId	INT
					);

	DECLARE	@Log_Date	DATETIME
		;

	-- Get the time of @minute ago --
	SELECT	@Log_Date = DATEADD(MINUTE, -@minute, GETDATE())
		;

	-- Get all unnotified messages from @minute ago filtered by @type --
	UPDATE	ln
	SET		ln.isNoticed = 1
	OUTPUT	Deleted.ServerName, Deleted.Title, Deleted.MsgInfo, Deleted.LogDate, Deleted.TargetName, Deleted.SkypeGroupId
	INTO	#messages (ServerName, Title, MsgInfo, LogDate, TargetName, SkypeGroupId)
	FROM	dbo.DBA_LetstalkNotifications AS ln WITH (ROWLOCK, UPDLOCK)
	WHERE	ln.MessageType = ISNULL(@type, ln.MessageType)		-- @type = NULL means get all types
		AND	ln.LogDate >= @Log_Date								-- Get message from @minute ago
		AND	ln.isNoticed = 0									-- Get only unnotified messages
	;

	-- Return the result --
	SELECT	m.ServerName, m.Title, m.MsgInfo, m.LogDate, m.TargetName, m.SkypeGroupId
	FROM	#messages AS m
	;

	-- Cleanup temporary tables --
	DROP TABLE	#messages;
END;
GO
/*<info serverAlias="DBMON-MonDBDW" executers="DBA_Letstalk,MonDB_User" viewers="" isFunction="0" isNested="0"></info>*/