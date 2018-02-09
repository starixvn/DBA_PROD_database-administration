/*
	Creator:	20180208@Billy
	Task:		Table for saving Session info - [Redmine: #90722]
	Server:		SITDB06.MonDB
*/


CREATE TABLE	dbo.vnDBA_RDP_Sessions (
					ServerName				VARCHAR(128)
				,	SessionId				INT
				,	SessionState			VARCHAR(128)
				,	IPAddress				VARCHAR(64)
				,	ClientName				VARCHAR(128)
				,	WindowStationName		VARCHAR(128)
				,	UserName				VARCHAR(128)
				,	ConnectTime				DATETIME
				,	DisconnectTime			DATETIME
				,	LastInputTime			DATETIME
				,	CurrentTime				DATETIME
				,	SessionStatusId			SMALLINT
				,	SessionStatus			VARCHAR(128)
				);
		
CREATE CLUSTERED INDEX	CIX_vnDBA_RDP_Sessions ON dbo.vnDBA_RDP_Sessions (
							ServerName
						,	SessionId
						,	CurrentTime DESC
						);
						
CREATE NONCLUSTERED INDEX	IX_vnDBA_RDP_Sessions_CurrentTime_SessionStatusId ON dbo.vnDBA_RDP_Sessions (
								CurrentTime
							,	SessionStatusId
							);
						
RETURN;
DROP INDEX IX_vnDBA_RDP_Sessions_CurrentTime_SessionStatusId ON dbo.vnDBA_RDP_Sessions;
DROP INDEX CIX_vnDBA_RDP_Sessions ON dbo.vnDBA_RDP_Sessions;
DROP TABLE dbo.vnDBA_RDP_Sessions;