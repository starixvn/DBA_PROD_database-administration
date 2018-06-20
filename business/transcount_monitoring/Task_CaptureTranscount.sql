USE	bodb02;
GO
ALTER PROCEDURE	[dbo].[Task_CaptureTranscount]
						@fromdate	DATETIME
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
	
	DECLARE	@basetime	DATETIME	= '2010-01-01'
		,	@todate		DATETIME
		;

	DECLARE	@worldcup AS TABLE (
				leagueid		INT
			);

	DECLARE	@match AS TABLE (
				matchid			INT
			,	matchname		NVARCHAR(200)
			);

	DECLARE	@transdate AS TABLE (
				matchid			INT
			,	transdate		DATETIME
			);

	INSERT INTO	@worldcup (leagueid)
	VALUES	(69686)
		;

	INSERT INTO	@match (matchid, matchname)
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

	SELECT	TOP(1)
			@todate		= DATEADD(SECOND, DATEDIFF(SECOND, @basetime, b.transdate), @basetime)
	FROM	dbo.bettrans AS b WITH (NOLOCK)
	ORDER BY b.transdate DESC;

	INSERT INTO	@transdate (matchid, transdate)
	SELECT	[matchid]	= ISNULL(m.matchid, 0)
		,	[transdate]	= DATEADD(SECOND, DATEDIFF(SECOND, @basetime, b.transdate), @basetime)
	FROM		dbo.bettrans AS b WITH (NOLOCK)
	LEFT JOIN	@match AS m
			ON	b.matchid = m.matchid
	WHERE	b.transdate >= @fromdate
		AND	b.transdate < @todate
		AND	b.bettype < 19999;

	INSERT INTO	@transdate (matchid, transdate)
	SELECT	[matchid]	= -1
		,	[transdate]	= DATEADD(SECOND, DATEDIFF(SECOND, @basetime, b.transdate), @basetime)
	FROM		dbo.bettrans AS b WITH (NOLOCK)
	WHERE	b.transdate >= @fromdate
		AND	b.transdate < @todate
		AND	b.bettype > 20000;

	SELECT	transdate, matchid, [transcnt] = COUNT(1)
	FROM	@transdate
	GROUP BY transdate, matchid
	ORDER BY transdate, matchid;
END;