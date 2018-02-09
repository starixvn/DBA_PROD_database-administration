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

	UPDATE	dbo.vnDBA_RDP_Sessions WITH (ROWLOCK)
	SET		SessionStatusId = 1000
		,	SessionStatus = 'Disconnected'
	WHERE	CurrentTime <= @ResolveTime
		AND	SessionStatusId BETWEEN 1001 AND 1999;
END;
GO
GRANT EXECUTE ON dbo.vnDBA_sp_RDP_ResolveInfo TO sqlLink AS dbo;
GO