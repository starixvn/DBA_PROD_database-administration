USE StarixDB;
GO
ALTER PROCEDURE	dbo.vnDBA_sp_Grafana_GetDataDashboard_WS
						@paneltype		SMALLINT
					,	@timefrom		DATETIME
					,	@timeto			DATETIME
					,	@servers		NVARCHAR(MAX)
					,	@ex_servers		NVARCHAR(MAX)	= NULL
					,	@waitgroup		NVARCHAR(128)	= NULL
					,	@waittypes		NVARCHAR(MAX)	= NULL
					,	@weekdiff		SMALLINT		= 0
AS
/*
	Creator:	20171106@Billy
	Task:		Get data for Wait Statistics Grafana Dashboard - [Redmine: #86054]
	Database:	DBDWCSS.StarixDB
	
	Revisions:
		- 20170918@Billy:	Initial - [Redmine: #86054]
		- 20180103@Billy:	Change value scale to milliseconds per second - [Redmine: #89022]
		- 20180108@Billy:	Support Performance Counter list - [Redmine: #89141]

	Developer's Notes:
		- @paneltype:		Specify the way to select data based on panel type
								000 ~ 099		Graph chart panel
								100 ~ 199		Single stat panel

		- @timefrom:		The UTC time to get data from
		- @timeto:			The UTC time to get data to

		- @servers:			List of servers to select data from, seperated by comma  ,  and can be enclosed with curly brackets  {} 
								NULL			All available servers

		- @waitgroup:		The group of wait type need to be selected

		- @waittypes:		List of counters need to be selected, seperated by comma  ,  and can be enclosed with curly brackets  {} 
								At least one of these 2 parameters (@waitgroup, @waittypes) have to be not null
*/
BEGIN
	SET NOCOUNT ON;

	-- Define variables --
	DECLARE	@server_zone	SMALLINT;


	-- Validate parameters --
	IF	ISNULL(@waitgroup, @waittypes) IS NULL
	BEGIN;
		RAISERROR('Please specify at least one of Wait Group or Wait Type to be selected!', 16, 1) WITH NOWAIT;
		RETURN;
	END;

	IF	@timefrom > @timeto
	BEGIN;
		RAISERROR('Please specify the correct range of time!', 16, 1) WITH NOWAIT;
		RETURN;
	END;


	-- Define temporary tables --
	IF	OBJECT_ID('tempdb..#servers') IS NOT NULL
		DROP TABLE	#servers;

	CREATE TABLE	#servers (
						ServerName		VARCHAR(128)
							PRIMARY KEY CLUSTERED (ServerName)
					);

	IF	OBJECT_ID('tempdb..#waittypes') IS NOT NULL
		DROP TABLE	#waittypes;

	CREATE TABLE	#waittypes (
						NumberId		INT					IDENTITY(1,1)
					,	WaitType		VARCHAR(128)
							PRIMARY KEY CLUSTERED (WaitType)
					);


	-- Initialize variables --
	SELECT	@server_zone = -4


	-- Convert UTC time to Server time --
	SELECT	@timefrom	= DATEADD(WEEK, -@weekdiff, DATEADD(HOUR, @server_zone, @timefrom))
		,	@timeto		= DATEADD(WEEK, -@weekdiff, DATEADD(HOUR, @server_zone, @timeto))
		;


	-- Parse servers name --
	IF	@servers IS NULL
	BEGIN;
		INSERT INTO	#servers (ServerName)
		SELECT	s.ServerName
		FROM	dbo.vnDBA_Wait_Servers AS s WITH (NOLOCK)
		WHERE	s.isMonitored = 1;
	END;
	ELSE
	BEGIN;
		SELECT	@servers = CASE WHEN LEFT(@servers, 1) = '{' THEN SUBSTRING(@servers, 2, LEN(@servers)) ELSE @servers END;
		SELECT	@servers = CASE WHEN RIGHT(@servers, 1) = '}' THEN SUBSTRING(@servers, 1, LEN(@servers) - 1) ELSE @servers END;
	
		WITH cte AS (
			SELECT	'start'		= CAST(1 AS INT)
				,	'finish'	= CASE WHEN CHARINDEX(',', @servers, 1) = 0 THEN LEN(@servers) + 1 ELSE CHARINDEX(',', @servers, 1) END
			UNION ALL
			SELECT	'start'		= CAST(cte.finish + 1 AS INT)
				,	'finish'	= CASE WHEN CHARINDEX(',', @servers, cte.finish + 1) = 0 THEN LEN(@servers) + 1 ELSE CHARINDEX(',', @servers, cte.finish + 1) END
			FROM	cte
			WHERE	cte.finish < LEN(@servers)
		)
		INSERT INTO	#servers (ServerName)
		SELECT	LTRIM(RTRIM(SUBSTRING(@servers, cte.start, cte.finish - cte.start)))
		FROM	cte
		WHERE	LTRIM(RTRIM(SUBSTRING(@servers, cte.start, cte.finish - cte.start))) <> '';
	END;

	IF	@ex_servers IS NOT NULL
	BEGIN;
		SELECT	@ex_servers = CASE WHEN LEFT(@ex_servers, 1) = '{' THEN SUBSTRING(@ex_servers, 2, LEN(@ex_servers)) ELSE @ex_servers END;
		SELECT	@ex_servers = CASE WHEN RIGHT(@ex_servers, 1) = '}' THEN SUBSTRING(@ex_servers, 1, LEN(@ex_servers) - 1) ELSE @ex_servers END;
			
		WITH cte AS (
			SELECT	'start'		= CAST(1 AS INT)
				,	'finish'	= CASE WHEN CHARINDEX(',', @ex_servers, 1) = 0 THEN LEN(@ex_servers) + 1 ELSE CHARINDEX(',', @ex_servers, 1) END
			UNION ALL
			SELECT	'start'		= CAST(cte.finish + 1 AS INT)
				,	'finish'	= CASE WHEN CHARINDEX(',', @ex_servers, cte.finish + 1) = 0 THEN LEN(@ex_servers) + 1 ELSE CHARINDEX(',', @ex_servers, cte.finish + 1) END
			FROM	cte
			WHERE	cte.finish < LEN(@ex_servers)
		)
		DELETE	s
		FROM	#servers AS s
		INNER JOIN	cte
				ON	s.ServerName = LTRIM(RTRIM(SUBSTRING(@ex_servers, cte.start, cte.finish - cte.start)));
	END;


	-- Update if match clustered physical machine --
	UPDATE	#servers
	SET		ServerName =	CASE ServerName	WHEN N'DBTRANS1'	THEN N'DBTRANS'
											WHEN N'DBTRANS2'	THEN N'DBTRANS'
											WHEN N'DBCUST1'		THEN N'DBCUST'
											WHEN N'DBCUST2'		THEN N'DBCUST'
											WHEN N'DB021'		THEN N'DB02'
											WHEN N'DB022'		THEN N'DB02'
											WHEN N'DBTP1'		THEN N'DBTP'
											WHEN N'DBTP2'		THEN N'DBTP'
																ELSE ServerName
							END;

	-- Delete unmatch Wait Statistics server list --
	DELETE	tmp
	FROM		#servers AS tmp WITH (TABLOCK)
	LEFT JOIN	dbo.vnDBA_Wait_Servers AS ws WITH (NOLOCK)
			ON	tmp.ServerName = ws.ServerName
	WHERE	ws.ServerName IS NULL;


	-- Parse wait types --
	IF	@waittypes IS NOT NULL
	BEGIN;
		SELECT	@waittypes = CASE WHEN LEFT(@waittypes, 1) = '{' THEN SUBSTRING(@waittypes, 2, LEN(@waittypes)) ELSE @waittypes END;
		SELECT	@waittypes = CASE WHEN RIGHT(@waittypes, 1) = '}' THEN SUBSTRING(@waittypes, 1, LEN(@waittypes) - 1) ELSE @waittypes END;
	
		WITH cte AS (
			SELECT	'start'		= CAST(1 AS INT)
				,	'finish'	= CASE WHEN CHARINDEX(',', @waittypes, 1) = 0 THEN LEN(@waittypes) + 1 ELSE CHARINDEX(',', @waittypes, 1) END
			UNION ALL
			SELECT	'start'		= CAST(cte.finish + 1 AS INT)
				,	'finish'	= CASE WHEN CHARINDEX(',', @waittypes, cte.finish + 1) = 0 THEN LEN(@waittypes) + 1 ELSE CHARINDEX(',', @waittypes, cte.finish + 1) END
			FROM	cte
			WHERE	cte.finish < LEN(@waittypes)
		)
		INSERT INTO	#waittypes (WaitType)
		SELECT	LTRIM(RTRIM(SUBSTRING(@waittypes, cte.start, cte.finish - cte.start)))
		FROM	cte
		WHERE	LTRIM(RTRIM(SUBSTRING(@waittypes, cte.start, cte.finish - cte.start))) <> '';
	END;
	

	-- Filter wait type group --
	IF	@waittypes IS NULL AND @waitgroup IS NOT NULL
	BEGIN;
		INSERT INTO	#waittypes (WaitType)
		SELECT	m.WaitType
		FROM	dbo.vnDBA_Wait_Metadata AS m WITH (NOLOCK)
		WHERE	m.Report = @waitgroup;
	END;
	ELSE IF	@waittypes IS NOT NULL AND @waitgroup IS NOT NULL
	BEGIN;
		DELETE	w
		FROM		#waittypes AS w
		INNER JOIN	dbo.vnDBA_Wait_Metadata AS m WITH (NOLOCK)
				ON	m.WaitType = w.WaitType
		WHERE	m.Report <> @waitgroup;
	END;


	-- Get data --

	IF	@paneltype = 001
	-- Graph chart panel -- Wait Time --
	BEGIN;
		SELECT	'Time'		= DATEADD(HOUR, -@server_zone, wc.CalculateDate)
			,	'Metric'	= w.WaitType
			,	'Value'		= SUM(wc.CalcWaitTime_ms_p_s)
		FROM		#waittypes AS w WITH (NOLOCK)
		CROSS JOIN	#servers AS s WITH (NOLOCK)
		CROSS APPLY	(
			SELECT	_w.CalculateDate, 'CalcWaitTime_ms_p_s' = CAST(_w.CalcWaitTime_ms * 1000.0 / _w.Calc_msTicks AS DECIMAL(19, 1))
			FROM	dbo.vnDBA_Wait_Captured AS _w WITH (NOLOCK)
			WHERE	_w.ServerName = s.ServerName
				AND	_w.WaitType = w.WaitType
				AND	_w.CalculateDate BETWEEN @timefrom AND @timeto
		) AS wc
		GROUP BY	wc.CalculateDate, w.WaitType
		ORDER BY	'Time', 'Metric'
		OPTION (FORCE ORDER);
	END;
	

	-- Cleanup temporary tables --
	DROP TABLE	#servers;
	DROP TABLE	#waittypes;
END;
GO
GRANT EXECUTE ON dbo.vnDBA_sp_Grafana_GetDataDashboard_WS TO vnGrafana AS dbo;
GO
