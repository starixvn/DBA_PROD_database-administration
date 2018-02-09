/*
	Creator:	20180208@Billy
	Task:		Table type for Terminal Session structure - [Redmine: #90722]
	Server:		SITDB06.MonDB
*/


CREATE TYPE	dbo.TSSession AS TABLE (
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


GRANT EXECUTE ON TYPE::dbo.TSSession TO vnTask AS dbo;

