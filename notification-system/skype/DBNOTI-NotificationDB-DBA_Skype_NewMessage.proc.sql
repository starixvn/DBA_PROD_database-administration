SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE	dbo.DBA_Skype_NewMessage
						@ServerName			NVARCHAR(128)
					,	@JobId				CHAR(36)		= NULL
					,	@JobName			NVARCHAR(128)	= NULL
					,	@Message			NVARCHAR(4000)
					,	@CaseId				TINYINT			= 1
					,	@isSimple			BIT				= 0
AS
/*
	Creator:	20180906@Billy
	Task:		Letstalk Notification - Insert new message to notify in Letstalk - Type: JOB - [Redmine: #101021]
	Database:	DBNOTI.NotificationDB
	
	Revisions:
		- 20180906@Billy:	Initialization - [Redmine: #101021]
		- 20190523@Billy:	Move system to DBSPARE - [Redmine: #113125]
		- 20191111@Billy:	Support MNL & Remove check on JobId - [Redmine: #123657]

	Parameters:
		@ServerName			: The name of server where job's message comes from
		@JobId				: The job's id
		@JobName			: The job's name - will be ignored if @JobId is not NULL
		@Message			: The content of the message
*/
BEGIN
	SET NOCOUNT ON;

	-- Declare variables & temporary schemas --
	DECLARE	@JobRoom	AS TABLE (
							JobName			NVARCHAR(128)
						,	SkypeGroupId	VARCHAR(256)
						);

	IF	DB_ID(N'_This_MNL_DR_site') IS NOT NULL
	-- MNL environment --
	BEGIN;
		DECLARE	@Msg			NVARCHAR(4000);

		SELECT	@Msg = N'\
▚▚▚▚▚▚▚▚▚▚▚▚▚▚  🅼 🅽 🅻  ▞▞▞▞▞▞▞▞▞▞▞▞▞▞

' + @Message;

		EXECUTE	DBNOTI.NotificationDB.dbo.DBA_Skype_NewMessage
					@ServerName = @ServerName
				,	@JobId		= @JobId
				,	@JobName	= @JobName
				,	@Message	= @Msg
				,	@CaseId		= @CaseId
				,	@isSimple	= @isSimple
				;
		RETURN;
	END;

	-- If @JobId and @JobName are both NULL, we cannot identify the job, RETURN --
	IF	@JobId IS NULL AND @JobName IS NULL
		RETURN	0;

	-- If @CaseId is invalid, set default 1 --
	IF	ISNULL(@CaseId, 0) = 0
	BEGIN;
		SELECT	@CaseId = 1;
	END;

	-- Get JobName and TargetName --
	IF	@JobId IS NOT NULL
	BEGIN
		INSERT INTO	@JobRoom
			(	   JobName,    SkypeGroupId)
		SELECT	lj.JobName, sg.SkypeGroupId
		FROM		dbo.DBA_LetstalkJobs	AS lj WITH (NOLOCK)
		INNER JOIN	dbo.DBA_SkypeGroup		AS sg WITH (NOLOCK)
				ON	lj.SkypeGroupId = sg.GroupId
		WHERE	lj.ServerName = @ServerName
			AND	lj.JobId = @JobId		-- Find by @JobId
			AND	lj.Level >= 3			-- Important Level >= 3
			AND	lj.CaseId = @CaseId		-- Find by @CaseId
		;
	END;
	ELSE
	BEGIN
		INSERT INTO	@JobRoom
			(	   JobName,    SkypeGroupId)
		SELECT	lj.JobName, sg.SkypeGroupId
		FROM		dbo.DBA_LetstalkJobs	AS lj WITH (NOLOCK)
		INNER JOIN	dbo.DBA_SkypeGroup		AS sg WITH (NOLOCK)
				ON	lj.SkypeGroupId = sg.GroupId
		WHERE	lj.ServerName = @ServerName
			AND	lj.JobName = @JobName	-- Find by @JobName
			AND	lj.Level >= 3			-- Important Level >= 3
			AND	lj.CaseId = @CaseId		-- Find by @CaseId
		;
	END;

	-- Insert new message to notify --
	INSERT INTO	dbo.DBA_SkypeNotifications
		(	ServerName,     Title  , MsgInfo , LogDate  ,    SkypeGroupId,         isSimple    , isNoticed)
	SELECT	@ServerName, jr.JobName, @Message, GETDATE(), jr.SkypeGroupId, ISNULL(@isSimple, 0), 0
	FROM	@JobRoom AS jr;
END;
GO
/*<info serverAlias="DBNOTI-NotificationDB" executers="sqlLink" viewers="" isFunction="0" isNested="0"></info>*/