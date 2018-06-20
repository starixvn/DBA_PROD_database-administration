ALTER PROCEDURE	dbo.Task_CaptureMatch
AS
/*
	Creator:	20180619@Billy
	Task:		Description - [Redmine: #00000]
	Database:	DBTP.bodb02
	
	Revisions:
		- 20180619@Billy:	Initial - [Redmine: #00000]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;
	
	DECLARE	@worldcup AS TABLE (
				leagueid		INT
			);

	INSERT INTO	@worldcup (leagueid)
	VALUES	(69686)
		;

	SELECT	[MatchId]		= m.matchid
		,	[MatchName]		= home.teamname + N' - ' + away.teamname
	FROM		@worldcup AS l
	INNER JOIN	dbo.match AS m WITH (NOLOCK)
			ON	l.leagueid = m.leagueid
	INNER JOIN	dbo.Team AS home WITH (NOLOCK)
			ON	m.homeid = home.teamid
	INNER JOIN	dbo.Team AS away WITH (NOLOCK)
			ON	m.awayid = away.teamid
	WHERE	m.matchcode NOT LIKE 'hedge%';
END;