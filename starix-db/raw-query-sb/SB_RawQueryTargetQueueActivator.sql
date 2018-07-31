USE	StarixDB;
GO

ALTER PROCEDURE	dbo.SB_RawQueryTargetQueueActivator
WITH EXECUTE AS OWNER
AS
/*
	Creator:	20180702@Billy
	Task:		Activator for Raw Query Target Service Queue - [Redmine: #00000]
	Database:	DBSTARIX.StarixDB
	
	Revisions:
		- 20180702@Billy:	Initial - [Redmine: #00000]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	
	-- Service Broker variables --
	DECLARE	@dialog				UNIQUEIDENTIFIER
		,	@type				NVARCHAR(256)
		,	@message			NVARCHAR(MAX)
		;

	-- Get message from queue --
	RECEIVE	TOP(1)
			@dialog		= conversation_handle
		,	@type		= message_type_name
		,	@message	= CAST(message_body AS NVARCHAR(MAX))
	FROM	dbo.RawQueryTargetQueue;
	
	-- Execute new monitoring task --
	IF	@type = N'RawQueryMessage'
	BEGIN;
		BEGIN TRY
			EXECUTE	sys.sp_executesql @message;
		END TRY
		BEGIN CATCH
			INSERT INTO	dbo.vnDBA_ServiceBroker_RawQueryFailedLog (LogDate, Msg, ErrorMsg)
			SELECT	GETDATE(), @message, ERROR_MESSAGE();

			UPDATE	dbo.vnDBA_Monitor_WarningStateCaptureSession
			SET		StartTime = NULL
				,	EndTime = NULL
				;
		END CATCH;
	END;
	
	IF	@type = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
	BEGIN;
		END CONVERSATION @dialog WITH CLEANUP;
	END;
END;
GO

ADD SIGNATURE TO OBJECT::dbo.SB_RawQueryTargetQueueActivator
BY CERTIFICATE StarixServerAuthenticationCertificate
WITH PASSWORD = '~`St@r1xS3rv3r1e6e1`~';
GO
/*<info serverAlias="DBSTARIX-StarixDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/