USE	MonDB;
GO
ALTER PROCEDURE	dbo.vnDBA_sp_RDP_CollectSessionInfo
						@TSSession		dbo.TSSession		READONLY
					,	@Interval		SMALLINT			= 30
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
	
	CREATE TABLE	#Connecting (
						ServerName				VARCHAR(128)
					,	SessionId				INT
					);

	CREATE TABLE	#LoggedOff (
						ServerName				VARCHAR(128)
					,	SessionId				INT
					);
	
	SELECT	TOP(1)
			@CurrentTime = CurrentTime
	FROM	@TSSession;
	
	INSERT INTO	#Sessions
		(	ServerName, SessionId, SessionState, IPAddress, ClientName, WindowStationName, UserName, ConnectTime, DisconnectTime, LastInputTime, CurrentTime)
	SELECT	ServerName, SessionId, SessionState, IPAddress, ClientName, WindowStationName, UserName, ConnectTime, DisconnectTime, LastInputTime, @CurrentTime
	FROM	@TSSession AS tbl
	WHERE	SessionState IN ('Active', 'Disconnected');
	
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
	OUTER APPLY	(
		SELECT	_ex.ForcedExcluded
		FROM	dbo.vnDBA_RDP_Excluded AS _ex WITH (NOLOCK)
		WHERE	src.ServerName = _ex.ServerName
			AND	(	src.ClientName LIKE _ex.ClientName
				OR	src.UserName LIKE _ex.UserName
				)
	) AS ex
	CROSS APPLY	(
		SELECT	[SessionStatusId]	= CASE	WHEN src.WindowStationName =lt.WindowStationName AND src.SessionState = 'Active'
												THEN -10	-- Unchanged Active
											WHEN src.SessionState = 'Disconnected' AND lt.SessionState = 'Disconnected' AND FLOOR(DATEDIFF(MINUTE, lt.DisconnectTime, lt.CurrentTime) / @Interval) = FLOOR(DATEDIFF(MINUTE, src.DisconnectTime, src.CurrentTime) / @Interval)
												THEN -1000	-- Unchanged Disconnected
											WHEN src.SessionState = 'Disconnected' AND lt.SessionStatusId BETWEEN 1001 AND 1999
												THEN -1001	-- Not Notified

											WHEN src.SessionState = 'Disconnected' AND ISNULL(lt.SessionState, '') <> 'Disconnected'
												THEN 1000	-- New Disconnected
											WHEN src.SessionState = 'Disconnected' AND lt.SessionState = 'Disconnected' AND FLOOR(DATEDIFF(MINUTE, lt.DisconnectTime, lt.CurrentTime) / @Interval) <> FLOOR(DATEDIFF(MINUTE, src.DisconnectTime, src.CurrentTime) / @Interval)
												THEN CASE	WHEN ForcedExcluded = 1
																THEN -1999		-- Excluded
															WHEN ForcedExcluded = 0
																THEN 1501		-- Internal Notification
															ELSE 1001			-- Repeative Disconnected
													 END
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

											WHEN 1000	THEN 'Disconnected'
											WHEN 1001	THEN 'Notification'

											WHEN -10	THEN 'StillActive'
											WHEN -1000	THEN 'StillDisconnected'
											ELSE NULL
									  END
	) sss
	WHERE	ssid.SessionStatusId > 0;

	INSERT INTO	#Connecting (ServerName, SessionId)
	SELECT	DISTINCT
			tbl.ServerName, tbl.SessionId
	FROM	dbo.vnDBA_RDP_Sessions AS tbl WITH (NOLOCK);

	INSERT INTO	dbo.vnDBA_RDP_Sessions_bk (ServerName, SessionId, SessionState, IPAddress, ClientName, WindowStationName, UserName, ConnectTime, DisconnectTime, LastInputTime, CurrentTime, SessionStatusId, SessionStatus)
	OUTPUT	Inserted.ServerName
		,	Inserted.SessionId
	INTO	#LoggedOff (ServerName, SessionId)
	SELECT	[ServerName]		= tbl.ServerName
		,	[SessionId]			= tbl.SessionId
		,	[SessionState]		= NULL
		,	[IPAddress]			= ss.IPAddress
		,	[ClientName]		= ss.ClientName
		,	[WindowStationName]	= ss.WindowStationName
		,	[UserName]			= ss.UserName
		,	[ConnectTime]		= ss.ConnectTime
		,	[DisconnectTime]	= CASE WHEN ss.SessionState = 'Disconnected' THEN ss.DisconnectTime ELSE @CurrentTime END
		,	[LastInputTime]		= ss.LastInputTime
		,	[CurrentTime]		= @CurrentTime
		,	[SessionStatusId]	= 0
		,	[SessionStatus]		= 'LoggedOff'
	FROM		#Connecting AS tbl WITH (NOLOCK)
	CROSS APPLY	(
		SELECT	TOP(1)
				_ss.SessionState, _ss.IPAddress, _ss.ClientName, _ss.WindowStationName, _ss.UserName, _ss.ConnectTime, _ss.DisconnectTime, _ss.LastInputTime
		FROM	dbo.vnDBA_RDP_Sessions AS _ss WITH (NOLOCK)
		WHERE	_ss.ServerName = tbl.ServerName
			AND	_ss.SessionId = tbl.SessionId
			AND	_ss.SessionState IN ('Active', 'Disconnected')
		ORDER BY _ss.CurrentTime DESC
	) AS ss
	LEFT JOIN	#Sessions AS src WITH (NOLOCK)
			ON	tbl.ServerName = src.ServerName
			AND	tbl.SessionId = src.SessionId
	WHERE	src.SessionId IS NULL;

	DELETE	tbl
	OUTPUT	Deleted.ServerName, Deleted.SessionId, Deleted.SessionState, Deleted.IPAddress, Deleted.ClientName, Deleted.WindowStationName, Deleted.UserName, Deleted.ConnectTime, Deleted.DisconnectTime, Deleted.LastInputTime, Deleted.CurrentTime, Deleted.SessionStatusId, Deleted.SessionStatus
	INTO	dbo.vnDBA_RDP_Sessions_bk (ServerName, SessionId, SessionState, IPAddress, ClientName, WindowStationName, UserName, ConnectTime, DisconnectTime, LastInputTime, CurrentTime, SessionStatusId, SessionStatus)
	FROM		dbo.vnDBA_RDP_Sessions AS tbl WITH (ROWLOCK)
	INNER JOIN	#LoggedOff AS lo WITH (NOLOCK)
			ON	tbl.ServerName = lo.ServerName
			AND	tbl.SessionId = lo.SessionId;

	UPDATE	tbl
	SET		tbl.LastInputTime = src.LastInputTime
	FROM		dbo.vnDBA_RDP_Sessions AS tbl WITH (ROWLOCK)
	INNER JOIN	#Sessions AS src WITH (NOLOCK)
			ON	tbl.ServerName = src.ServerName
			AND	tbl.SessionId = src.SessionId
			AND	tbl.WindowStationName = src.WindowStationName
	WHERE	src.SessionState = 'Active'
		AND	tbl.SessionState = 'Active';
END;
GO
GRANT EXECUTE ON dbo.vnDBA_sp_RDP_CollectSessionInfo TO vnTask AS dbo;
GO