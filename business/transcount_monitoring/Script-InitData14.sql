DECLARE	@fromdate	DATETIME	= '2018-06-14'
	,	@todate		DATETIME
	;

DECLARE	@basetime	DATETIME	= '2010-01-01'
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

IF	OBJECT_ID('dbo.transdate_summary_Billy_test') IS NOT NULL
	DROP TABLE	dbo.transdate_summary_Billy_test;
	
IF	OBJECT_ID('dbo.match_Billy_test') IS NOT NULL
	DROP TABLE	dbo.match_Billy_test;

INSERT INTO	@worldcup (leagueid)
VALUES	(69686)
	;

INSERT INTO	@match (matchid, matchname)
SELECT	[MatchId]		= m.matchid
	,	[MatchName]		= home.teamname + N' - ' + away.teamname
FROM		@worldcup AS l
INNER JOIN	dbo.match14 AS m WITH (NOLOCK)
		ON	l.leagueid = m.leagueid
INNER JOIN	dbo.Team AS home WITH (NOLOCK)
		ON	m.homeid = home.teamid
INNER JOIN	dbo.Team AS away WITH (NOLOCK)
		ON	m.awayid = away.teamid
WHERE	m.matchcode NOT LIKE 'hedge%';

SELECT	TOP(1)
		@todate		= DATEADD(SECOND, DATEDIFF(SECOND, @basetime, b.transdate), @basetime)
FROM	dbo.bettrans14 AS b WITH (NOLOCK)
ORDER BY b.transdate DESC;

INSERT INTO	@transdate (matchid, transdate)
SELECT	[matchid]	= ISNULL(m.matchid, 0)
	,	[transdate]	= DATEADD(SECOND, DATEDIFF(SECOND, @basetime, b.transdate), @basetime)
FROM		dbo.bettrans14 AS b WITH (NOLOCK)
LEFT JOIN	@match AS m
		ON	b.matchid = m.matchid
WHERE	b.transdate >= @fromdate
	AND	b.transdate < @todate
	AND	b.bettype < 19999;

INSERT INTO	@transdate (matchid, transdate)
SELECT	[matchid]	= -1
	,	[transdate]	= DATEADD(SECOND, DATEDIFF(SECOND, @basetime, b.transdate), @basetime)
FROM		dbo.bettrans14 AS b WITH (NOLOCK)
WHERE	b.transdate >= @fromdate
	AND	b.transdate < @todate
	AND	b.bettype > 20000;

SELECT	transdate, matchid, [transcnt] = COUNT(1)
INTO	dbo.transdate_summary_Billy_test
FROM		@transdate
GROUP BY transdate, matchid
ORDER BY transdate, matchid

SELECT	matchid, matchname
INTO	dbo.match_Billy_test
FROM	@match
