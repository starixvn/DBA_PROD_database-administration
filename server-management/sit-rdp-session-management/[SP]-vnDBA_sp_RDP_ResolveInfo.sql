USE	MonDB;
GO
ALTER PROCEDURE	dbo.vnDBA_sp_RDP_ResolveInfo
						@ResolveTime		DATETIME
AS
/*
	Creator:	20180207@Billy
	Task:		SIT RDP Session Management - Resolve Info - [Redmine: #90722]
	Database:	SITDB06.MonDB
	
	Revisions:
		- 20180207@Billy:	Initial - [Redmine: #90722]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;
	
	CREATE TABLE	#deleted (
						ServerName		VARCHAR(128)
					,	SessionId		INT
					,	UserName		VARCHAR(128)
					,	ClientName		VARCHAR(128)
					,	ConnectTime		DATETIME
					,	DisconnectTime	DATETIME
					,	CurrentTime		DATETIME
					);

	UPDATE	dbo.vnDBA_RDP_Sessions WITH (ROWLOCK)
	SET		SessionStatusId = 1000
		,	SessionStatus = 'Disconnected'
	OUTPUT	deleted.ServerName, deleted.SessionId, deleted.UserName, deleted.ClientName, deleted.ConnectTime, deleted.DisconnectTime, deleted.CurrentTime
	INTO	#deleted (ServerName, SessionId, UserName, ClientName, ConnectTime, DisconnectTime, CurrentTime)
	WHERE	CurrentTime <= @ResolveTime
		AND	SessionStatusId BETWEEN 1001 AND 1999;
		
	DELETE	tbl
	FROM		dbo.vnDBA_RDP_Sessions AS tbl WITH (ROWLOCK)
	INNER JOIN	#deleted AS del WITH (NOLOCK)
			ON	tbl.ServerName = del.ServerName
			AND	tbl.SessionId = del.SessionId
			AND	tbl.UserName = del.UserName
			AND	tbl.ClientName = del.ClientName
			AND	tbl.ConnectTime = del.ConnectTime
			AND	tbl.DisconnectTime = del.DisconnectTime
			AND	tbl.CurrentTime < del.CurrentTime;
END;
GO
GRANT EXECUTE ON dbo.vnDBA_sp_RDP_ResolveInfo TO sqlLink AS dbo;
GO