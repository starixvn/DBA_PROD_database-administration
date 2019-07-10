SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.Skype_SendMessage
						@To		VARCHAR(128)
					,	@Msg	NVARCHAR(MAX)
AS
/*
	Creator:	20190710@Billy
	Task:		Send message directly to Skype - [Redmine: #110664]
	Database:	DBNOTI.NotificationDB

	Revisions:
		- 20190710@Billy:	Initial - [Redmine: #110664]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@SkypeGroupId	VARCHAR(256)
		;

	SELECT	@SkypeGroupId = SkypeGroupId
	FROM	dbo.DBA_SkypeGroup WITH (NOLOCK)
	WHERE	CodeName = @To;

	IF	@@ROWCOUNT = 0
	BEGIN;
		RAISERROR(N'This recipient is not authorized to receive this message.', 16, 1) WITH NOWAIT;
		RETURN;
	END;

	INSERT INTO	dbo.DBA_SkypeNotifications
			(ServerName, Title, MsgInfo, LogDate  ,  SkypeGroupId, isSimple, isNoticed)
	VALUES	(N''       , N''  , @Msg   , GETDATE(), @SkypeGroupId, 1       , 0        );
END;
GO
/*<info serverAlias="DBNOTI-NotificationDB" executers="sqlLink" viewers="" isFunction="0" isNested="0"></info>*/