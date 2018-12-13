SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.vnDBA_sp_Grafana_GetDataDashboard
						@paneltype			SMALLINT
					,	@timefrom			DATETIME
					,	@timeto				DATETIME
					,	@servers			NVARCHAR(MAX)
					,	@ex_servers			NVARCHAR(MAX)	= NULL
					,	@object				NVARCHAR(128)	= NULL
					,	@counters			NVARCHAR(MAX)	= NULL
					,	@weekdiff			SMALLINT		= 0
					,	@limittime			DATETIME		= '2018-06-01'
					,	@ex_legends			NVARCHAR(MAX)	= NULL
					,	@use_logicalname	BIT				= 0
					,	@postfix			NVARCHAR(10)	= N''
					,	@filter				NVARCHAR(MAX)	= N''
AS
/*
	Creator:	20170918@Billy
	Task:		Get data for Grafana Dashboard - [Redmine: #83352]
	Database:	DBSTARIX.StarixDB
	
	Revisions:
		- 20170918@Billy:	Initial - [Redmine: #83352]
		- 20180105@Billy:	Add @weekdiff for comparision dashboard - [Redmine: #89141]
		- 20180403@Billy:	Add panel type 111 - [Redmine: #91078]
		- 20180503@Billy:	Grafana 5.1 integration - [Redmine: #94602]
		- 20180615@Billy:	Enhancement - [Redmine: #96988]
		- 20180619@Billy:	Special handling for distribution panel - [Redmine: #00000]
		- 20180629@Billy:	Add options for filtering legends, time limit and use logical name - [Redmine: #00000]
		- 20180702@Billy:	Special handling for ticket latency - [Redmine: #00000]
		- 20180703@Billy:	Add filter for metric - [Redmine: #00000]
							Change panel type for Replication Panel - [Redmine: #00000]
		- 20180709@Billy:	Add MAXRECURSION option - [Redmine: #00000]
		- 20181115@Billy:	Fix weekdiff point out of range - [Redmine: #104489]

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
	IF	ISNULL(@object, @counters) IS NULL AND @paneltype >= 0
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
	DECLARE	@tservers AS TABLE (
				ServerName		VARCHAR(128)
			,	LogicalName		VARCHAR(128)
					PRIMARY KEY CLUSTERED (ServerName)
			);
					
	DECLARE	@xlegends AS TABLE (
				Legend			VARCHAR(128)
					PRIMARY KEY CLUSTERED (Legend)
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
		,	@limittime = ISNULL(@limittime, '2000-01-01')
		;


	-- Convert UTC time to Server time --
	SELECT	@timefrom	= DATEADD(WEEK, -@weekdiff, DATEADD(HOUR, @server_zone, @timefrom))
		,	@timeto		= DATEADD(WEEK, -@weekdiff, DATEADD(HOUR, @server_zone, @timeto))
		;


	-- Parse servers name --
	IF	@servers IS NULL
	BEGIN;
		INSERT INTO	@tservers (ServerName, LogicalName)
		SELECT	DISTINCT
				c.MachineName, s.LogicalName
		FROM		dbo.CounterDetails AS c WITH (NOLOCK)
		INNER JOIN	dbo.vnDBA_Perf_Servers AS s WITH (NOLOCK)
				ON	c.MachineName = '\\' + CAST(s.ServerName AS VARCHAR)
				AND	s.DatabaseName = N''
				AND	s.isMonitored = 1;
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
		INSERT INTO	@tservers (ServerName, LogicalName)
		SELECT	c.MachineName, s.LogicalName
		FROM		cte
		CROSS APPLY	(
			SELECT	[MachineName]	= '\\' + LTRIM(RTRIM(SUBSTRING(@servers, cte.start, cte.finish - cte.start)))
		) AS c
		INNER JOIN	dbo.vnDBA_Perf_Servers AS s WITH (NOLOCK)
				ON	c.MachineName = '\\' + CAST(s.ServerName AS VARCHAR)
				AND	s.DatabaseName = N''
				AND	s.isMonitored = 1
		WHERE	c.MachineName <> '\\'
		OPTION (MAXRECURSION 0);
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
		FROM	@tservers AS s
		INNER JOIN	cte
				ON	s.ServerName = '\\' + LTRIM(RTRIM(SUBSTRING(@ex_servers, cte.start, cte.finish - cte.start)))
		OPTION (MAXRECURSION 0);
	END;

	BEGIN;
		SELECT	@ex_legends = CASE WHEN LEFT(@ex_legends, 1) = '{' THEN SUBSTRING(@ex_legends, 2, LEN(@ex_legends)) ELSE @ex_legends END;
		SELECT	@ex_legends = CASE WHEN RIGHT(@ex_legends, 1) = '}' THEN SUBSTRING(@ex_legends, 1, LEN(@ex_legends) - 1) ELSE @ex_legends END;
	
		WITH cte AS (
			SELECT	[start]		= CAST(1 AS INT)
				,	[finish]	= CASE WHEN CHARINDEX(',', @ex_legends, 1) = 0 THEN LEN(@ex_legends) + 1 ELSE CHARINDEX(',', @ex_legends, 1) END
			UNION ALL
			SELECT	[start]		= CAST(cte.finish + 1 AS INT)
				,	[finish]	= CASE WHEN CHARINDEX(',', @ex_legends, cte.finish + 1) = 0 THEN LEN(@ex_legends) + 1 ELSE CHARINDEX(',', @ex_legends, cte.finish + 1) END
			FROM	cte
			WHERE	cte.finish < LEN(@ex_legends)
		)
		INSERT INTO	@xlegends (Legend)
		SELECT	LTRIM(RTRIM(SUBSTRING(@ex_legends, cte.start, cte.finish - cte.start)))
		FROM	cte
		WHERE	LTRIM(RTRIM(SUBSTRING(@ex_legends, cte.start, cte.finish - cte.start))) <> ''
		OPTION (MAXRECURSION 0);
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
		WHERE	LTRIM(RTRIM(SUBSTRING(@counters, cte.start, cte.finish - cte.start))) <> ''
		OPTION (MAXRECURSION 0);
	END;
	

	-- Select counters --
	INSERT INTO	#CounterDetails (NumberId, CounterId, MachineName, ObjectName, CounterName, InstanceName)
	SELECT	cf.NumberId, c.CounterID, CASE WHEN @use_logicalname = 1 THEN s.LogicalName ELSE c.MachineName END, c.ObjectName, c.CounterName, c.InstanceName
	FROM		dbo.CounterDetails AS c WITH (NOLOCK)
	INNER JOIN	@tservers AS s
			ON	s.ServerName = c.MachineName
	LEFT JOIN	#counters AS cf WITH (NOLOCK)
			ON	c.CounterName = cf.CounterName
	WHERE	c.ObjectName = ISNULL(@object, c.ObjectName)
		AND	CASE WHEN @counters IS NULL THEN c.CounterName ELSE cf.CounterName END IS NOT NULL;

	-- Get data --

	IF	@paneltype = 000
	-- Graph chart panel -- Metric machine --
	BEGIN;
		SELECT	[time]		= DATEADD(WEEK, @weekdiff, DATEADD(HOUR, -@server_zone, d.CounterTime))
			,	[metric]	= m.metric + @postfix
			,	[value]		= SUM(d.CounterValue)
		FROM		#CounterDetails AS c WITH (NOLOCK)
		CROSS APPLY	(
			SELECT	_d.CounterTime, _d.CounterValue
			FROM	dbo.vnDBA_Perf_CounterData AS _d WITH (NOLOCK)
			WHERE	_d.CounterID = c.CounterID
				AND	_d.CounterTime BETWEEN @timefrom AND @timeto
				AND	_d.CounterTime >= @limittime
		) AS d
		CROSS APPLY	(
			SELECT	[metric]	= CASE LEFT(c.MachineName, 2) WHEN '\\' THEN SUBSTRING(c.MachineName, 3, LEN(c.MachineName)) ELSE c.MachineName END
			WHERE	c.MachineName LIKE N'%' + @filter + N'%'
		) AS m
		LEFT JOIN	@xlegends AS l
				ON	m.metric = l.Legend
		WHERE	l.Legend IS NULL
		GROUP BY	d.CounterTime, m.metric
		ORDER BY	[time], [metric];
	END;
	
	IF	@paneltype = 001
	-- Graph chart panel -- Metric counter --
	BEGIN;
		SELECT	[time]		= DATEADD(WEEK, @weekdiff, DATEADD(HOUR, -@server_zone, d.CounterTime))
			,	[metric]	= m.metric + @postfix
			,	[value]		= SUM(d.CounterValue)
		FROM		#CounterDetails AS c WITH (NOLOCK)
		CROSS APPLY	(
			SELECT	_d.CounterTime, _d.CounterValue
			FROM	dbo.vnDBA_Perf_CounterData AS _d WITH (NOLOCK)
			WHERE	_d.CounterID = c.CounterID
				AND	_d.CounterTime BETWEEN @timefrom AND @timeto
				AND	_d.CounterTime >= @limittime
		) AS d
		CROSS APPLY	(
			SELECT	[metric]	= c.CounterName
			WHERE	c.CounterName LIKE N'%' + @filter + N'%'
		) AS m
		LEFT JOIN	@xlegends AS l
				ON	m.metric = l.Legend
		WHERE	l.Legend IS NULL
		GROUP BY	d.CounterTime, m.metric
		ORDER BY	[time], [metric];
	END;
	
	IF	@paneltype = 002
	-- Graph chart panel -- Metric instance --
	BEGIN;
		SELECT	[time]		= DATEADD(WEEK, @weekdiff, DATEADD(HOUR, -@server_zone, d.CounterTime))
			,	[metric]	= m.metric + @postfix
			,	[value]		= SUM(d.CounterValue)
		FROM		#CounterDetails AS c WITH (NOLOCK)
		CROSS APPLY	(
			SELECT	_d.CounterTime, _d.CounterValue
			FROM	dbo.vnDBA_Perf_CounterData AS _d WITH (NOLOCK)
			WHERE	_d.CounterID = c.CounterID
				AND	_d.CounterTime BETWEEN @timefrom AND @timeto
				AND	_d.CounterTime >= @limittime
		) AS d
		CROSS APPLY	(
			SELECT	[metric]	= c.InstanceName
			WHERE	c.InstanceName LIKE N'%' + @filter + N'%'
		) AS m
		LEFT JOIN	@xlegends AS l
				ON	m.metric = l.Legend
		WHERE	l.Legend IS NULL
		GROUP BY	d.CounterTime, m.metric
		ORDER BY	[time], [metric];
	END;
	
	IF	@paneltype = 003
	-- Graph chart panel -- Metric object - counter - instance --
	BEGIN;
		SELECT	[time]		= DATEADD(WEEK, @weekdiff, DATEADD(HOUR, -@server_zone, d.CounterTime))
			,	[metric]	= m.metric + @postfix
			,	[value]		= SUM(d.CounterValue)
		FROM		#CounterDetails AS c WITH (NOLOCK)
		CROSS APPLY	(
			SELECT	_d.CounterTime, _d.CounterValue
			FROM	dbo.vnDBA_Perf_CounterData AS _d WITH (NOLOCK)
			WHERE	_d.CounterID = c.CounterID
				AND	_d.CounterTime BETWEEN @timefrom AND @timeto
				AND	_d.CounterTime >= @limittime
		) AS d
		CROSS APPLY	(
			SELECT	[metric]	= c.ObjectName + N'(' + c.InstanceName + N'): ' + c.CounterName
			WHERE	c.ObjectName LIKE N'%' + @filter + N'%'
				OR	c.InstanceName LIKE N'%' + @filter + N'%'
		) AS m
		LEFT JOIN	@xlegends AS l
				ON	m.metric = l.Legend
		WHERE	l.Legend IS NULL
		GROUP BY	d.CounterTime, m.metric
		ORDER BY	[time], [metric];
	END;
	
	IF	@paneltype = 10001
	-- Graph chart panel -- Metric instance -- For DISTRIBUTION
	BEGIN;
		SELECT	[time]		= DATEADD(WEEK, @weekdiff, DATEADD(HOUR, -@server_zone, d.CounterTime))
			,	[metric]	= m.metric + @postfix
			,	[value]		= SUM(d.CounterValue)
		FROM		#CounterDetails AS c WITH (NOLOCK)
		CROSS APPLY	(
			SELECT	_d.CounterTime, _d.CounterValue
			FROM	dbo.vnDBA_Perf_CounterData AS _d WITH (NOLOCK)
			WHERE	_d.CounterID = c.CounterID
				AND	_d.CounterTime BETWEEN @timefrom AND @timeto
				AND	_d.CounterTime >= @limittime
		) AS d
		CROSS APPLY	(
			SELECT	[SubscriberName]	= REVERSE(LEFT(REVERSE(_ss.SubscriberName), CHARINDEX('-', REVERSE(_ss.SubscriberName)) - 1))
			FROM	(
				SELECT	[SubscriberName]	= LEFT(c.InstanceName, LEN(c.InstanceName) - CHARINDEX('-', REVERSE(c.InstanceName)))
				WHERE	c.InstanceName LIKE N'%' + @filter + N'%'
			) _ss
		) AS ss
		CROSS APPLY	(
			SELECT	[metric]	= ss.SubscriberName
		) AS m
		LEFT JOIN	@xlegends AS l
				ON	m.metric = l.Legend
		WHERE	l.Legend IS NULL
		GROUP BY	d.CounterTime, m.metric
		ORDER BY	[time], [metric];
	END;
	
	IF	@paneltype = 10002
	-- Graph chart panel -- For Ticket Latency
	BEGIN;
		SELECT	[time]		= DATEADD(WEEK, @weekdiff, DATEADD(HOUR, -@server_zone, txn.CaptureTime))
			,	[metric]	= m.metric + @postfix
			,	[value]		= txn.LastTicketId - d.LastTicketId
		FROM	(
			SELECT	_txn.CaptureTime, _txn.LastTicketId
			FROM	dbo.vnDBA_Monitor_TicketLatency AS _txn WITH (NOLOCK)
			WHERE	_txn.CaptureTime BETWEEN @timefrom AND @timeto
				AND	_txn.ServerName = 'DBTRANS'
		) AS txn
		CROSS APPLY	(
			SELECT	_d.ServerName, _d.LastTicketId
			FROM	dbo.vnDBA_Monitor_TicketLatency AS _d WITH (NOLOCK)
			WHERE	_d.CaptureTime BETWEEN txn.CaptureTime AND DATEADD(SECOND, 2, txn.CaptureTime)
				AND	_d.ServerName <> 'DBTRANS'
		) AS d
		CROSS APPLY	(
			SELECT	[metric]	= d.ServerName
		) AS m
		LEFT JOIN	@xlegends AS l
				ON	m.metric = l.Legend
		ORDER BY	[time], [metric];
	END;
	
	IF	@paneltype = 010
	-- Graph chart panel -- Metric machine - counter --
	BEGIN;
		SELECT	[time]		= DATEADD(WEEK, @weekdiff, DATEADD(HOUR, -@server_zone, d.CounterTime))
			,	[metric]	= m.metric + @postfix
			,	[value]		= SUM(d.CounterValue)
		FROM		#CounterDetails AS c WITH (NOLOCK)
		CROSS APPLY	(
			SELECT	_d.CounterTime, _d.CounterValue
			FROM	dbo.vnDBA_Perf_CounterData AS _d WITH (NOLOCK)
			WHERE	_d.CounterID = c.CounterID
				AND	_d.CounterTime BETWEEN @timefrom AND @timeto
				AND	_d.CounterTime >= @limittime
		) AS d
		CROSS APPLY	(
			SELECT	[metric]	= CASE LEFT(c.MachineName, 2) WHEN '\\' THEN SUBSTRING(c.MachineName, 3, LEN(c.MachineName)) ELSE c.MachineName END + '[' + CAST(c.NumberId AS VARCHAR) + ']'
			WHERE	c.MachineName LIKE N'%' + @filter + N'%'
		) AS m
		LEFT JOIN	@xlegends AS l
				ON	m.metric = l.Legend
		WHERE	l.Legend IS NULL
		GROUP BY	d.CounterTime, m.metric
		ORDER BY	[time], [metric];
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
				AND	_d.CounterTime <= @timeto
				AND	_d.CounterTime >= @limittime
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
				AND	_d.CounterTime <= @timeto
				AND	_d.CounterTime >= @limittime
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
				AND	_d.CounterTime >= @limittime
			ORDER BY	_d.CounterTime DESC
		) AS d;

		IF	@@ROWCOUNT <> 1
			RAISERROR('There are only 1 counter accepted!', 16, 1);
	END;


	-- Static value --

	IF	@paneltype = -1
	-- Static value -- Total CPUs capacity --
	BEGIN;
		SELECT	[time]		= DATEADD(WEEK, @weekdiff, DATEADD(HOUR, -@server_zone, t.time))
			,	[metric]	= N'%CPU Capacity' + @postfix
			,	[value]		= ps.CPUs * 100
		FROM		@tservers AS s
		INNER JOIN	dbo.vnDBA_Perf_Servers AS ps WITH (NOLOCK)
				ON	N'\\' + ps.ServerName = s.ServerName
		CROSS APPLY	(
			SELECT	[time]		= @timefrom
			UNION ALL
			SELECT	[time]		= @timeto
		) AS t
		ORDER BY	[time], [metric];
	END;

	-- Cleanup temporary tables --
	DROP TABLE	#counters;
END;
GO
GRANT EXECUTE ON dbo.vnDBA_sp_Grafana_GetDataDashboard TO vnGrafana AS dbo;
GO
/*<info serverAlias="DBSTARIX-StarixDB" executers="vnGrafana" viewers="" isFunction="0" isNested="0"></info>*/