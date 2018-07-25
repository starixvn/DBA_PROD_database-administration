USE	StarixDB;
GO
ALTER PROCEDURE	[dbo].[vnDBA_sp_Grafana_GetDataDashboard_TC]
						@paneltype		SMALLINT
					,	@timefrom		DATETIME
					,	@timeto			DATETIME
					,	@combine		SMALLINT		= 1
					,	@details		BIT				= 0
					,	@weekdiff		SMALLINT		= 0
AS
/*
	Creator:	20180619@Billy
	Task:		Get transcount data for Grafana Dashboard - [Redmine: #00000]
	Database:	DBDWCSS.StarixDB
	
	Revisions:
		- 20180619@Billy:	Initial - [Redmine: #00000]

	Developer's Notes:
		- @paneltype:		Specify the way to select data based on panel type
								000 ~ 099		Graph chart panel
								100 ~ 199		Single stat panel

		- @timefrom:		The UTC time to get data from
		- @timeto:			The UTC time to get data to
*/
BEGIN
	SET NOCOUNT ON;

	-- Define variables --
	DECLARE	@server_zone	SMALLINT
		,	@base_time		DATETIME	= '2010-01-01'
		;

	DECLARE	@result AS TABLE (
				time		DATETIME
			,	metric		NVARCHAR(MAX)
			,	value		DECIMAL(38,10)
			);

	
	-- Validate parameters --
	IF	ISNULL(@combine, 0) < 1
	BEGIN;
		RAISERROR('Please specify correct number of combined seconds!', 16, 1) WITH NOWAIT;
		RETURN;
	END;


	IF	@timefrom > @timeto
	BEGIN;
		RAISERROR('Please specify the correct range of time!', 16, 1) WITH NOWAIT;
		RETURN;
	END;


	-- Initialize variables --
	SELECT	@server_zone = -4


	-- Convert UTC time to Server time --
	SELECT	@timefrom	= DATEADD(WEEK, -@weekdiff, DATEADD(HOUR, @server_zone, @timefrom))
		,	@timeto		= DATEADD(WEEK, -@weekdiff, DATEADD(HOUR, @server_zone, @timeto))
		;


	-- Get data --

	IF	@paneltype = 000
	-- Graph chart panel -- Metric machine --
	BEGIN;
		IF	@combine = 1
		BEGIN;
			INSERT INTO	@result(time, metric, value)
			SELECT	[time]		= DATEADD(HOUR, -@server_zone, t.transdate)
				,	[metric]	= CASE WHEN @details = 0 AND t.matchid >= 0 THEN 'Bet Tickets' ELSE m.matchname END
				,	[value]		= t.transcnt
			FROM		dbo.transcount AS t WITH (NOLOCK)
			LEFT JOIN	dbo.match AS m WITH (NOLOCK)
					ON	t.matchid = m.matchid
			WHERE	t.transdate BETWEEN @timefrom AND @timeto;
		END;
		ELSE
		BEGIN;
			INSERT INTO	@result(time, metric, value)
			SELECT	[time]		= DATEADD(HOUR, -@server_zone, g.transdate)
				,	[metric]	= CASE WHEN @details = 0 AND t.matchid >= 0 THEN 'Bet Tickets' ELSE m.matchname END
				,	[value]		= AVG(t.transcnt)
			FROM		dbo.transcount AS t WITH (NOLOCK)
			CROSS APPLY	(
				SELECT	[transdate]	= DATEADD(SECOND, FLOOR(DATEDIFF(SECOND, @base_time, t.transdate) / @combine) * @combine, @base_time)
			) AS g
			LEFT JOIN	dbo.match AS m WITH (NOLOCK)
					ON	t.matchid = m.matchid
			WHERE	t.transdate BETWEEN @timefrom AND @timeto
			GROUP BY t.matchid, m.matchname, g.transdate;
		END;

		SELECT	time, metric, value = SUM(value)
		FROM	@result
		GROUP BY time, metric
		ORDER BY time, metric;
	END;
END;
GO

GRANT EXECUTE ON dbo.vnDBA_sp_Grafana_GetDataDashboard_TC TO vnGrafana AS dbo;
GO