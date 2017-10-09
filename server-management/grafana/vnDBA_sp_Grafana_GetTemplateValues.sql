USE	StarixDB;
GO
ALTER PROCEDURE	dbo.vnDBA_sp_Grafana_GetTemplateValues
						@templatetype		TINYINT
AS
/*
	Creator:	20170920@Billy
	Task:		Get template values for Grafana Dashboard - [Redmine: #83352]
	Database:	DB233.StarixDB
	
	Revisions:
		- 20170920@Billy:	Initial - [Redmine: #83352]
		- 20170930@Billy:	Add excluded servers template - [Redmine: #00000]
		
	Developer's Notes:
		
*/
BEGIN
	SET NOCOUNT ON;
	
	IF	@templatetype = 1
	-- Server list --
	BEGIN;
		SELECT	DISTINCT
				'Value'		= CASE LEFT(c.MachineName, 2) WHEN '\\' THEN SUBSTRING(c.MachineName, 3, LEN(c.MachineName)) ELSE c.MachineName END
		FROM	dbo.CounterDetails AS c WITH (NOLOCK);
	END;
	ELSE IF	@templatetype = 2
	-- Excluded server list --
	BEGIN;
		SELECT	'Value'		= ' None '
		UNION ALL
		SELECT	DISTINCT
				'Value'		= CASE LEFT(c.MachineName, 2) WHEN '\\' THEN SUBSTRING(c.MachineName, 3, LEN(c.MachineName)) ELSE c.MachineName END
		FROM	dbo.CounterDetails AS c WITH (NOLOCK);
	END;
END;
GO