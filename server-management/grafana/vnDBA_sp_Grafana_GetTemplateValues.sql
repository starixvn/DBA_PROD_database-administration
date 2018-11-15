SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.vnDBA_sp_Grafana_GetTemplateValues
						@templatetype		SMALLINT
					,	@getAll				BIT				= 1
AS
/*
	Creator:	20170920@Billy
	Task:		Get template values for Grafana Dashboard - [Redmine: #83352]
	Database:	DBSTARIX.StarixDB
	
	Revisions:
		- 20170920@Billy:	Initial - [Redmine: #83352]
		- 20170930@Billy:	Add excluded servers template - [Redmine: #00000]
		- 20171106@Billy:	Add wait statistics servers template - [Redmine: #86054]
		- 20180104@Billy:	Change performance servers template to metadata table - [Redmine: #00000]
		- 20180105@Billy:	Add @getAll parameter for showing unmonitor servers - [Redmine: #00000]
		- 20180507@Billy:	Grafana 5.1 integration - [Redmine: #94602]
		- 20180615@Billy:	Enhancement - [Redmine: #96988]
		- 20181019@Billy:	Support Partition Server List - [Redmine: #103503]
		- 20181115@Billy:	Support Counter List - [Redmine: #104489]

	Developer's Notes:
		- @templatetype:	Specify the type of template that need to be selected
								0				All performance counter and wait statistics servers

								1				All performance counter servers
								2				All performance counter servers for exclusion

								11				All wait statistics servers
								12				All wait statistics servers for exclusion


*/
BEGIN
	SET NOCOUNT ON;
	
	IF	@templatetype = 0
	-- All list --
	BEGIN;
		SELECT	DISTINCT
				[value]		= s.ServerName
		FROM	dbo.vnDBA_Perf_Servers AS s WITH (NOLOCK)
		WHERE	s.isMonitored | @getAll <> 0
		UNION ALL
		SELECT	[value]		= s.ServerName
		FROM	dbo.vnDBA_Wait_Servers AS s WITH (NOLOCK)
		WHERE	s.isMonitored | @getAll <> 0;
	END;
	IF	@templatetype = 1
	-- Server list -- Performance Counter --
	BEGIN;
		SELECT	[value]		= s.ServerName
		FROM	dbo.vnDBA_Perf_Servers AS s WITH (NOLOCK)
		WHERE	s.isMonitored | @getAll <> 0;
	END;
	ELSE IF	@templatetype = 2
	-- Excluded server list -- Performance Counter --
	BEGIN;
		SELECT	[value]		= ' None '
		UNION ALL
		SELECT	[value]		= s.ServerName
		FROM	dbo.vnDBA_Perf_Servers AS s WITH (NOLOCK)
		WHERE	s.isMonitored | @getAll <> 0;
	END;
	ELSE IF	@templatetype = 11
	-- Server list -- Wait Statistics --
	BEGIN;
		SELECT	[value]		= s.ServerName
		FROM	dbo.vnDBA_Wait_Servers AS s WITH (NOLOCK)
		WHERE	s.isMonitored | @getAll <> 0;
	END;
	ELSE IF	@templatetype = 12
	-- Excluded server list -- Wait Statistics --
	BEGIN;
		SELECT	[value]		= ' None '
		UNION ALL
		SELECT	[value]		= s.ServerName
		FROM	dbo.vnDBA_Wait_Servers AS s WITH (NOLOCK)
		WHERE	s.isMonitored | @getAll <> 0;
	END;
	ELSE IF	@templatetype = 20
	-- Server list -- Partitions --
	BEGIN;
		SELECT	DISTINCT
				ServerName
		FROM	dbo.vnDBA_Partition_Status WITH (NOLOCK);
	END;
	ELSE IF	@templatetype = 30
	-- Counter list --
	BEGIN;
		SELECT	DISTINCT
				CounterName
		FROM	dbo.vnDBA_Perf_Counters WITH (NOLOCK);
	END;
END;
GO
GRANT EXECUTE ON dbo.vnDBA_sp_Grafana_GetTemplateValues TO vnGrafana AS dbo;
GO
/*<info serverAlias="DBSTARIX-StarixDB" executers="vnGrafana" viewers="" isFunction="0" isNested="0"></info>*/