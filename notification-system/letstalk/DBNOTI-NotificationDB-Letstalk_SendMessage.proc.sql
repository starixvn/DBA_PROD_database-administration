SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.Letstalk_SendMessage
						@To		VARCHAR(128)
					,	@Msg	NVARCHAR(MAX)
AS
/*
	Creator:	20200107@Billy
	Task:		Send message directly to Letstalk - [Redmine: #126684]
	Database:	DBNOTI.NotificationDB

	Revisions:
		- 20200107@Billy:	Initial - [Redmine: #126684]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@TargetName		VARCHAR(128)
		;

	IF	DB_ID(N'_This_MNL_DR_site') IS NOT NULL
	-- MNL environment --
	BEGIN;
		SELECT	@Msg = N'\
▚▚▚▚▚▚▚▚▚▚▚▚▚▚  🅼 🅽 🅻  ▞▞▞▞▞▞▞▞▞▞▞▞▞▞

' + @Msg;

		EXECUTE	DBNOTI.NotificationDB.dbo.Letstalk_SendMessage @To, @Msg;
	END;
	ELSE
	-- KBT environment --
	BEGIN;
		SELECT	@TargetName = lr.RoomName + '.' + CAST(lr.RoomId AS VARCHAR)
		FROM	dbo.DBA_LetstalkRooms AS lr WITH (NOLOCK)
		WHERE	lr.RoomName = @To
			AND	lr.SendDirectly = 1
			AND	lr.isActive = 1;

		IF	@@ROWCOUNT = 0
		BEGIN;
			RAISERROR(N'This recipient is not authorized to receive this message.', 16, 1) WITH NOWAIT;
			RETURN;
		END;

		INSERT INTO	dbo.DBA_LetstalkNotifications
				(ServerName, Title, MsgInfo , LogDate  , MessageType,  TargetName, isNoticed, SkypeGroupId)
		VALUES	(N''       , N''  , @Msg    , GETDATE(), 'JOB'      , @TargetName, 0        , NULL        );
	END;
END;
GO
/*<info serverAlias="DBNOTI-NotificationDB" executers="sqlLink" viewers="" isFunction="0" isNested="0"></info>*/