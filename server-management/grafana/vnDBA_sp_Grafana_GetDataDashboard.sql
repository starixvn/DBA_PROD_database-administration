USE StarixDB;
GO
ALTER PROCEDURE	dbo.vnDBA_sp_Grafana_GetDataDashboard
						@paneltype		SMALLINT
					,	@timefrom		DATETIME
					,	@timeto			DATETIME
					,	@servers		NVARCHAR(MAX)
					,	@ex_servers		NVARCHAR(MAX)	= NULL
					,	@object			NVARCHAR(128)	= NULL
					,	@counters		NVARCHAR(MAX)	= NULL
					,	@weekdiff		SMALLINT		= 0
AS
/*
	Creator:	20170918@Billy
	Task:		Get data for Grafana Dashboard - [Redmine: #83352]
	Database:	DBDWCSS.StarixDB
	
	Revisions:
		- 20170918@Billy:	Initial - [Redmine: #83352]
		- 20180105@Billy:	Add @weekdiff for comparision dashboard - [Redmine: #89141]
		- 20180403@Billy:	Add panel type 111 - [Redmine: #91078]
		- 20180503@Billy:	Grafana 5.1 integration - [Redmine: #94602]

	Developer's Notes:
		- @paneltype:		Specify the way to select data based on panel type
								000 ~ 099		Graph chart panel
								100 ~ 199		Single stat panel

		- @timefrom:		The UTC time to get data from
		- @timeto:			The UTC time to get data to

		- @servers:			List of servers to select data from, seperated by comma  ,  and can be enclosed with curly brackets {}
								NULL			All available servers

		- @object:			The object (group) of counter need to be selected

		- @counters:		List of counters need to be selected, seperated by comma  ,  and can be enclosed with curly brackets  {} 
								At least one of these 2 parameters (@object, @counters) have to be not null
*/
BEGIN
	SET NOCOUNT ON;

	-- Define variables --
	DECLARE	@server_zone	SMALLINT;


	-- Validate parameters --
	IF	ISNULL(@object, @counters) IS NULL
	BEGIN;
		RAISERROR('Please specify at least one of Object or Counter to be selected!', 16, 1) WITH NOWAIT;
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

	IF	OBJECT_ID('tempdb..#counters') IS NOT NULL
		DROP TABLE	#counters;

	CREATE TABLE	#counters (
						NumberId		INT					IDENTITY(1,1)
					,	CounterName	VARCHAR(128)
							PRIMARY KEY CLUSTERED (CounterName)
					);

	IF	OBJECT_ID('tempdb..#CounterDetails') IS NOT NULL
		DROP TABLE	#CounterDetails;

	CREATE TABLE	#CounterDetails (
						NumberId		INT
					,	CounterId		INT
							PRIMARY KEY CLUSTERED (CounterId)
					,	MachineName		VARCHAR(128)
					,	ObjectName		VARCHAR(128)
					,	CounterName		VARCHAR(128)
					,	InstanceName	VARCHAR(128)
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
		SELECT	DISTINCT
				c.MachineName
		FROM	dbo.CounterDetails AS c WITH (NOLOCK);
	END;
	ELSE
	BEGIN;
		SELECT	@servers = CASE WHEN LEFT(@servers, 1) = '{' THEN SUBSTRING(@servers, 2, LEN(@servers)) ELSE @servers END;
		SELECT	@servers = CASE WHEN RIGHT(@servers, 1) = '}' THEN SUBSTRING(@servers, 1, LEN(@servers) - 1) ELSE @servers END;
	
		WITH cte AS (
			SELECT	[start]		= CAST(1 AS INT)
				,	[finish]	= CASE WHEN CHARINDEX(',', @servers, 1) = 0 THEN LEN(@servers) + 1 ELSE CHARINDEX(',', @servers, 1) END
			UNION ALL
			SELECT	[start]		= CAST(cte.finish + 1 AS INT)
				,	[finish]	= CASE WHEN CHARINDEX(',', @servers, cte.finish + 1) = 0 THEN LEN(@servers) + 1 ELSE CHARINDEX(',', @servers, cte.finish + 1) END
			FROM	cte
			WHERE	cte.finish < LEN(@servers)
		)
		INSERT INTO	#servers (ServerName)
		SELECT	'\\' + LTRIM(RTRIM(SUBSTRING(@servers, cte.start, cte.finish - cte.start)))
		FROM	cte
		WHERE	LTRIM(RTRIM(SUBSTRING(@servers, cte.start, cte.finish - cte.start))) <> '';
	END;

	IF	@ex_servers IS NOT NULL
	BEGIN;
		SELECT	@ex_servers = CASE WHEN LEFT(@ex_servers, 1) = '{' THEN SUBSTRING(@ex_servers, 2, LEN(@ex_servers)) ELSE @ex_servers END;
		SELECT	@ex_servers = CASE WHEN RIGHT(@ex_servers, 1) = '}' THEN SUBSTRING(@ex_servers, 1, LEN(@ex_servers) - 1) ELSE @ex_servers END;
			
		WITH cte AS (
			SELECT	[start]		= CAST(1 AS INT)
				,	[finish]	= CASE WHEN CHARINDEX(',', @ex_servers, 1) = 0 THEN LEN(@ex_servers) + 1 ELSE CHARINDEX(',', @ex_servers, 1) END
			UNION ALL
			SELECT	[start]		= CAST(cte.finish + 1 AS INT)
				,	[finish]	= CASE WHEN CHARINDEX(',', @ex_servers, cte.finish + 1) = 0 THEN LEN(@ex_servers) + 1 ELSE CHARINDEX(',', @ex_servers, cte.finish + 1) END
			FROM	cte
			WHERE	cte.finish < LEN(@ex_servers)
		)
		DELETE	s
		FROM	#servers AS s
		INNER JOIN	cte
				ON	s.ServerName = '\\' + LTRIM(RTRIM(SUBSTRING(@ex_servers, cte.start, cte.finish - cte.start)));
	END;


	-- Parse counters name --
	IF	@counters IS NOT NULL
	BEGIN;
		SELECT	@counters = CASE WHEN LEFT(@counters, 1) = '{' THEN SUBSTRING(@counters, 2, LEN(@counters)) ELSE @counters END;
		SELECT	@counters = CASE WHEN RIGHT(@counters, 1) = '}' THEN SUBSTRING(@counters, 1, LEN(@counters) - 1) ELSE @counters END;
	
		WITH cte AS (
			SELECT	[start]		= CAST(1 AS INT)
				,	[finish]	= CASE WHEN CHARINDEX(',', @counters, 1) = 0 THEN LEN(@counters) + 1 ELSE CHARINDEX(',', @counters, 1) END
			UNION ALL
			SELECT	[start]		= CAST(cte.finish + 1 AS INT)
				,	[finish]	= CASE WHEN CHARINDEX(',', @counters, cte.finish + 1) = 0 THEN LEN(@counters) + 1 ELSE CHARINDEX(',', @counters, cte.finish + 1) END
			FROM	cte
			WHERE	cte.finish < LEN(@counters)
		)
		INSERT INTO	#counters (CounterName)
		SELECT	LTRIM(RTRIM(SUBSTRING(@counters, cte.start, cte.finish - cte.start)))
		FROM	cte
		WHERE	LTRIM(RTRIM(SUBSTRING(@counters, cte.start, cte.finish - cte.start))) <> '';
	END;
	

	-- Select counters --
	INSERT INTO	#CounterDetails (NumberId, CounterId, MachineName, ObjectName, CounterName, InstanceName)
	SELECT	cf.NumberId, c.CounterID, c.MachineName, c.ObjectName, c.CounterName, c.InstanceName
	FROM		dbo.CounterDetails AS c WITH (NOLOCK)
	INNER JOIN	#servers AS s WITH (NOLOCK)
			ON	s.ServerName = c.MachineName
	LEFT JOIN	#counters AS cf WITH (NOLOCK)
			ON	c.CounterName = cf.CounterName
	WHERE	c.ObjectName = ISNULL(@object, c.ObjectName)
		AND	CASE WHEN @counters IS NULL THEN c.CounterName ELSE cf.CounterName END IS NOT NULL;

	-- Get data --

	IF	@paneltype = 000
	-- Graph chart panel -- Metric machine --
	BEGIN;
		SELECT	[time]		= DATEADD(HOUR, -@server_zone, d.CounterTime)
			,	[metric]	= CASE LEFT(c.MachineName, 2) WHEN '\\' THEN SUBSTRING(c.MachineName, 3, LEN(c.MachineName)) ELSE c.MachineName END
			,	[value]		= SUM(d.CounterValue)
		FROM		#CounterDetails AS c WITH (NOLOCK)
		CROSS APPLY	(
			SELECT	_d.CounterTime, _d.CounterValue
			FROM	dbo.vnDBA_Perf_CounterData AS _d WITH (NOLOCK)
			WHERE	_d.CounterID = c.CounterID
				AND	_d.CounterTime BETWEEN @timefrom AND @timeto
		) AS d
		GROUP BY	d.CounterTime, c.MachineName
		ORDER BY	[time], [metric];
	END;
	
	IF	@paneltype = 001
	-- Graph chart panel -- Metric counter --
	BEGIN;
		SELECT	[time]		= DATEADD(HOUR, -@server_zone, d.CounterTime)
			,	[metric]	= c.CounterName
			,	[value]		= SUM(d.CounterValue)
		FROM		#CounterDetails AS c WITH (NOLOCK)
		CROSS APPLY	(
			SELECT	_d.CounterTime, _d.CounterValue
			FROM	dbo.vnDBA_Perf_CounterData AS _d WITH (NOLOCK)
			WHERE	_d.CounterID = c.CounterID
				AND	_d.CounterTime BETWEEN @timefrom AND @timeto
		) AS d
		GROUP BY	d.CounterTime, c.CounterName
		ORDER BY	[time], [metric];
	END;
	
	IF	@paneltype = 002
	-- Graph chart panel -- Metric instance --
	BEGIN;
		SELECT	[time]		= DATEADD(HOUR, -@server_zone, d.CounterTime)
			,	[metric]	= c.InstanceName
			,	[value]		= SUM(d.CounterValue)
		FROM		#CounterDetails AS c WITH (NOLOCK)
		CROSS APPLY	(
			SELECT	_d.CounterTime, _d.CounterValue
			FROM	dbo.vnDBA_Perf_CounterData AS _d WITH (NOLOCK)
			WHERE	_d.CounterID = c.CounterID
				AND	_d.CounterTime BETWEEN @timefrom AND @timeto
		) AS d
		GROUP BY	d.CounterTime, c.InstanceName
		ORDER BY	[time], [metric];
	END;
	
	IF	@paneltype = 003
	-- Graph chart panel -- Metric object - counter - instance --
	BEGIN;
		SELECT	[time]		= DATEADD(HOUR, -@server_zone, d.CounterTime)
			,	[metric]	= c.ObjectName + N'(' + c.InstanceName + N'): ' + c.CounterName
			,	[value]		= SUM(d.CounterValue)
		FROM		#CounterDetails AS c WITH (NOLOCK)
		CROSS APPLY	(
			SELECT	_d.CounterTime, _d.CounterValue
			FROM	dbo.vnDBA_Perf_CounterData AS _d WITH (NOLOCK)
			WHERE	_d.CounterID = c.CounterID
				AND	_d.CounterTime BETWEEN @timefrom AND @timeto
		) AS d
		GROUP BY	d.CounterTime, c.ObjectName, c.InstanceName, c.CounterName
		ORDER BY	[time], [metric];
	END;

	IF	@paneltype = 010
	-- Graph chart panel -- Metric machine - counter --
	BEGIN;
		SELECT	[time]		= DATEADD(HOUR, -@server_zone, d.CounterTime)
			,	[metric]	= CASE LEFT(c.MachineName, 2) WHEN '\\' THEN SUBSTRING(c.MachineName, 3, LEN(c.MachineName)) ELSE c.MachineName END + '[' + CAST(c.NumberId AS VARCHAR) + ']'
			,	[value]		= SUM(d.CounterValue)
		FROM		#CounterDetails AS c WITH (NOLOCK)
		CROSS APPLY	(
			SELECT	_d.CounterTime, _d.CounterValue
			FROM	dbo.vnDBA_Perf_CounterData AS _d WITH (NOLOCK)
			WHERE	_d.CounterID = c.CounterID
				AND	_d.CounterTime BETWEEN @timefrom AND @timeto
		) AS d
		GROUP BY	d.CounterTime, c.NumberId, c.MachineName, c.CounterName
		ORDER BY	d.CounterTime, c.NumberId, c.MachineName;
	END;

	IF	@paneltype = 101
	-- Single stat panel -- Latest value --
	BEGIN;
		SELECT	[value]		= d.CounterValue
		FROM		#CounterDetails AS c WITH (NOLOCK)
		CROSS APPLY	(
			SELECT	TOP(1)
					_d.CounterValue
			FROM	dbo.vnDBA_Perf_CounterData AS _d WITH (NOLOCK)
			WHERE	_d.CounterID = c.CounterID
			ORDER BY	_d.CounterTime DESC
		) AS d;

		IF	@@ROWCOUNT <> 1
			RAISERROR('There are only 1 counter accepted!', 16, 1);
	END;

	IF	@paneltype = 102
	-- Single stat panel -- Sum latest value --
	BEGIN;
		SELECT	[value]		= SUM(d.CounterValue)
		FROM		#CounterDetails AS c WITH (NOLOCK)
		CROSS APPLY	(
			SELECT	TOP(1)
					_d.CounterValue
			FROM	dbo.vnDBA_Perf_CounterData AS _d WITH (NOLOCK)
			WHERE	_d.CounterID = c.CounterID
			ORDER BY	_d.CounterTime DESC
		) AS d;

		IF	@@ROWCOUNT <> 1
			RAISERROR('There are only 1 counter accepted!', 16, 1);
	END;

	IF	@paneltype = 111
	-- Single stat panel -- Last 10 seconds value --
	BEGIN;
		SELECT	[value]		= ISNULL(d.CounterValue, 0)
		FROM		#CounterDetails AS c WITH (NOLOCK)
		OUTER APPLY	(
			SELECT	TOP(1)
					_d.CounterValue
			FROM	dbo.vnDBA_Perf_CounterData AS _d WITH (NOLOCK)
			WHERE	_d.CounterID = c.CounterID
				AND	_d.CounterTime BETWEEN DATEADD(SECOND, -10, @timeto) AND @timeto
			ORDER BY	_d.CounterTime DESC
		) AS d;

		IF	@@ROWCOUNT <> 1
			RAISERROR('There are only 1 counter accepted!', 16, 1);
	END;

	-- Cleanup temporary tables --
	DROP TABLE	#servers;
	DROP TABLE	#counters;
END;
GO
GRANT EXECUTE ON dbo.vnDBA_sp_Grafana_GetDataDashboard TO vnGrafana AS dbo;
GO
