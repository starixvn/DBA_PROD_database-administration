USE	StarixDB;
GO

ALTER PROCEDURE	dbo.vnDBA_sp_Monitor_TicketLatencyCapture
AS
/*
	Creator:	20180702@Billy
	Task:		Capture bettrans latency via Service Broker execution - [Redmine: #00000]
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
		;

	-- Variables --
	DECLARE	@message			NVARCHAR(MAX)
		,	@server				NVARCHAR(128)
		;

	-- Table variables --
	DECLARE	@servers AS TABLE (
				ServerName			NVARCHAR(128)
			,	Done				BIT
			);

	-- Initial server list --
	INSERT INTO	@servers (ServerName, Done)
	VALUES	('DBTRANS', 0)
		,	('DB042', 0)
		,	('DB043', 0)
		,	('DB044', 0)
		,	('DB05', 0)
		,	('DB052', 0)
		,	('DB053', 0)
		,	('DB054', 0)
		,	('DB06', 0)
		,	('DBTP', 0)
		,	('DBLICAPI', 0)
		,	('DBLICAPI02', 0)
		;

	WHILE	0 = 0
	BEGIN;
		WHILE	0 = 0
		BEGIN;
			UPDATE	TOP(1)
					tbl
			SET		@server	= tbl.ServerName
				,	Done = 1
			FROM	@servers AS tbl
			WHERE	Done = 0;

			IF	@@ROWCOUNT = 0
				BREAK;

			SELECT	@message = N'';
			SELECT	@message = @message + N'
INSERT INTO	dbo.vnDBA_Monitor_TicketLatency (ServerName, CaptureTime, LastTicketId)
SELECT	ServerName, CaptureTime, LastTicketId
FROM	OPENQUERY(' + @server + N'KBT, ''
SELECT	TOP(1)
		[ServerName]	= @@SERVERNAME
	,	[CaptureTime]	= GETDATE()
	,	[LastTicketId]	= b.transid
FROM	bodb02.dbo.bettrans AS b WITH (NOLOCK)
ORDER BY b.transid DESC;
'');
';

			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	RawQueryInitiator
			TO SERVICE		'RawQueryTarget'
			ON CONTRACT		RawQueryContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE RawQueryMessage (@message);

			END CONVERSATION @dialog;
		END;

		-- Reset server state --
		UPDATE	tbl
		SET		Done = 0
		FROM	@servers AS tbl;

		WAITFOR DELAY '00:00:04.000';
	END;
END;
GO
/*<info serverAlias="DBSTARIX-StarixDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/