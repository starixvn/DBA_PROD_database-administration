USE	MonDB;
GO
ALTER PROCEDURE	dbo.vnDBA_sp_RDP_CollectSessionInfo
						@TSSession		dbo.TSSession		READONLY
					,	@Interval		SMALLINT			= 10
AS
/*
	Creator:	20180207@Billy
	Task:		SIT RDP Session Management - Collect Info - [Redmine: #90722]
	Database:	SITDB06.MonDB
	
	Revisions:
		- 20180207@Billy:	Initial - [Redmine: #90722]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;
	
	DECLARE	@CurrentTime	DATETIME
		,	@LastTime		DATETIME
		;

	CREATE TABLE	#Sessions (
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
					);	
	
	
	SELECT	TOP(1)
			@CurrentTime = CurrentTime
	FROM	@TSSession;
	
	INSERT INTO	#Sessions
		(	ServerName, SessionId, SessionState, IPAddress, ClientName, WindowStationName, UserName, ConnectTime, DisconnectTime, LastInputTime, CurrentTime)
	SELECT	ServerName, SessionId, SessionState, IPAddress, ClientName, WindowStationName, UserName, ConnectTime, DisconnectTime, LastInputTime, @CurrentTime
	FROM	@TSSession AS tbl
	WHERE	SessionState IN ('Active', 'Disconnected');
	
	SELECT	TOP(1)
			@LastTime = CurrentTime
	FROM	dbo.vnDBA_RDP_Sessions WITH (NOLOCK)
	ORDER BY CurrentTime DESC;
	
	INSERT INTO	dbo.vnDBA_RDP_Sessions (ServerName, SessionId, SessionState, IPAddress, ClientName, WindowStationName, UserName, ConnectTime, DisconnectTime, LastInputTime, CurrentTime, SessionStatusId, SessionStatus)
	SELECT	[ServerName]		= src.ServerName
		,	[SessionId]			= src.SessionId
		,	[SessionState]		= src.SessionState
		,	[IPAddress]			= src.IPAddress
		,	[ClientName]		= src.ClientName
		,	[WindowStationName]	= src.WindowStationName
		,	[UserName]			= src.UserName
		,	[ConnectTime]		= src.ConnectTime
		,	[DisconnectTime]	= src.DisconnectTime
		,	[LastInputTime]		= src.LastInputTime
		,	[CurrentTime]		= @CurrentTime
		,	[SessionStatusId]	= ssid.SessionStatusId
		,	[SessionStatus]		= sss.SessionStatus
	FROM			#Sessions AS src
	OUTER APPLY	(
		SELECT	TOP(1)
				ServerName, SessionId, SessionState, IPAddress, ClientName, WindowStationName, UserName, ConnectTime, DisconnectTime, LastInputTime, CurrentTime, SessionStatusId, SessionStatus
		FROM	dbo.vnDBA_RDP_Sessions AS _tbl WITH (NOLOCK)
		WHERE	_tbl.CurrentTime < @CurrentTime
			AND	src.ServerName = _tbl.ServerName
			AND	src.SessionId = _tbl.SessionId
	) AS lt
	CROSS APPLY	(
		SELECT	[SessionStatusId]	= CASE	WHEN src.WindowStationName =lt.WindowStationName AND src.SessionState = 'Active'
												THEN -10	-- Unchanged Active
											WHEN src.SessionState = 'Disconnected' AND lt.SessionState = 'Disconnected' AND FLOOR(DATEDIFF(MINUTE, lt.DisconnectTime, lt.CurrentTime) / @Interval) = FLOOR(DATEDIFF(MINUTE, src.DisconnectTime, src.CurrentTime) / @Interval)
												THEN -1000	-- Unchanged Disconnected
											WHEN src.SessionState = 'Disconnected' AND lt.SessionStatusId BETWEEN 1001 AND 1999
												THEN -1001	-- Not Notified

											WHEN src.SessionState = 'Disconnected' AND ISNULL(lt.SessionState, '') <> 'Disconnected'
												THEN 1001	-- New Disconnected
											WHEN src.SessionState = 'Disconnected' AND lt.SessionState = 'Disconnected' AND FLOOR(DATEDIFF(MINUTE, lt.DisconnectTime, lt.CurrentTime) / @Interval) <> FLOOR(DATEDIFF(MINUTE, src.DisconnectTime, src.CurrentTime) / @Interval)
												THEN 1002	-- Repeative Disconnected

											WHEN src.SessionState = 'Active' AND lt.SessionId IS NULL
												THEN 10		-- New Session
											WHEN src.SessionState = 'Active' AND src.DisconnectTime IS NULL AND src.WindowStationName = lt.WindowStationName
												THEN 11		-- New Session within Interval
											WHEN src.SessionState = 'Active' AND src.DisconnectTime IS NULL AND lt.SessionId IS NOT NULL AND lt.SessionState IS NULL
												THEN 12		-- New Session reusing SessionId

											WHEN src.SessionState = 'Active' AND src.DisconnectTime = lt.DisconnectTime AND src.ConnectTime > lt.ConnectTime AND src.UserName = lt.UserName
												THEN 21		-- Reconnected
											WHEN src.SessionState = 'Active' AND src.DisconnectTime = lt.DisconnectTime AND src.ConnectTime > lt.ConnectTime AND src.UserName <> lt.UserName
												THEN 22		-- Taken Over

											ELSE NULL
									  END
	) AS ssid
	CROSS APPLY	(
		SELECT	[SessionStatus]		= CASE ssid.SessionStatusId
											WHEN 10		THEN 'NewSession'
											WHEN 11		THEN 'NewSession'
											WHEN 12		THEN 'NewSession'

											WHEN 21		THEN 'Reconnected'
											WHEN 22		THEN 'TakenOver'

											WHEN 1001	THEN 'Notification'
											WHEN 1002	THEN 'RepeativeNotification'

											WHEN -10	THEN 'StillActive'
											WHEN -1000	THEN 'StillDisconnected'
											ELSE NULL
									  END
	) sss
	WHERE	ssid.SessionStatusId > 0;

	INSERT INTO	dbo.vnDBA_RDP_Sessions (ServerName, SessionId, SessionState, IPAddress, ClientName, WindowStationName, UserName, ConnectTime, DisconnectTime, LastInputTime, CurrentTime, SessionStatusId, SessionStatus)
	SELECT	[ServerName]		= tbl.ServerName
		,	[SessionId]			= tbl.SessionId
		,	[SessionState]		= NULL
		,	[IPAddress]			= tbl.IPAddress
		,	[ClientName]		= tbl.ClientName
		,	[WindowStationName]	= tbl.WindowStationName
		,	[UserName]			= tbl.UserName
		,	[ConnectTime]		= tbl.ConnectTime
		,	[DisconnectTime]	= CASE WHEN tbl.SessionState = 'Disconnected' THEN tbl.DisconnectTime ELSE @CurrentTime END
		,	[LastInputTime]		= NULL
		,	[CurrentTime]		= @CurrentTime
		,	[SessionStatusId]	= 0
		,	[SessionStatus]		= 'LoggedOff'
	FROM		dbo.vnDBA_RDP_Sessions AS tbl WITH (NOLOCK)
	LEFT JOIN	#Sessions AS src WITH (NOLOCK)
			ON	tbl.ServerName = src.ServerName
			AND	tbl.SessionId = src.SessionId
	WHERE	tbl.CurrentTime = @LastTime
		AND	tbl.SessionState IS NOT NULL
		AND	src.SessionId IS NULL;
END;
GO
GRANT EXECUTE ON dbo.vnDBA_sp_RDP_CollectSessionInfo TO vnTask AS dbo;
GO