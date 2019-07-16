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
		- 20190711@Billy:	Control directly sent message using flag - [Redmine: #110664]
		- 20190716@Billy:	Support MNL side - [Redmine: #110664]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@SkypeGroupId	VARCHAR(256)
		;

	IF	DB_ID(N'_This_MNL_DR_site') IS NOT NULL
	-- MNL environment --
	BEGIN;
		SELECT	@Msg = N'\
▚▚▚▚▚▚▚▚▚▚▚▚▚▚  🅼 🅽 🅻  ▞▞▞▞▞▞▞▞▞▞▞▞▞▞

' + @Msg;

		EXECUTE	DBNOTI.NotificationDB.dbo.Skype_SendMessage @To, @Msg;
	END;
	ELSE
	-- KBT environment --
	BEGIN;
		SELECT	@SkypeGroupId = SkypeGroupId
		FROM	dbo.DBA_SkypeGroup WITH (NOLOCK)
		WHERE	CodeName = @To
			AND	SendDirectly = 1;

		IF	@@ROWCOUNT = 0
		BEGIN;
			RAISERROR(N'This recipient is not authorized to receive this message.', 16, 1) WITH NOWAIT;
			RETURN;
		END;

		INSERT INTO	dbo.DBA_SkypeNotifications
				(ServerName, Title, MsgInfo, LogDate  ,  SkypeGroupId, isSimple, isNoticed)
		VALUES	(N''       , N''  , @Msg   , GETDATE(), @SkypeGroupId, 1       , 0        );
	END;
END;
GO
/*<info serverAlias="DBNOTI-NotificationDB" executers="sqlLink" viewers="" isFunction="0" isNested="0"></info>*/