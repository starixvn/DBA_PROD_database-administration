SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.GetSPsExecutionCounts
						@From				DATETIME
					,	@To					DATETIME
					,	@Server				NVARCHAR(128)
					,	@Database			VARCHAR(128)	= NULL
AS
/*
	Creator:	20191209@Billy
	Task:		Get SP Execution Counts - [Redmine: #124921]
	Database:	DBMON.MonDBDW

	Revisions:
		- 20191209@Billy:	Initial - [Redmine: #124921]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	SELECT	svr.ServerName
		,	sp.DBName
		,	sp.SPName
		,	[ExecutionCount] = SUM(ValSum)
	FROM		dbo.vnDBA_SPPF_HourlySummary_ExecutionCount AS ec WITH (NOLOCK)
	INNER JOIN	dbo.vnDBA_SPPF_ServerList_Filtered AS svr WITH (NOLOCK)
			ON	ec.ServerId = svr.ServerId
	INNER JOIN	dbo.Mon_SPPF_List AS sp WITH (NOLOCK)
			ON	ec.ServerId = sp.ServerID
			AND	ec.SPId = sp.SPID
	WHERE	svr.isEnabled = 1
		AND	svr.ServerName = ISNULL(@Server, svr.ServerName)
		AND	sp.DBName = ISNULL(@Database, sp.DBName)
		AND	ec.EventTime >= @From
		AND	ec.EventTime < @To
		AND	sp.SPName NOT LIKE '%[_]xtest'
		AND	sp.SPName NOT LIKE '%[_]xpre'
		AND	sp.SPName NOT LIKE '%[_]UAT[1234]'
		AND	sp.SPName NOT LIKE '%[_]test'
	GROUP BY svr.ServerName, sp.DBName, sp.SPName
	ORDER BY svr.ServerName, sp.DBName, sp.SPName;
END;
GO
/*<info serverAlias="DBMON-MonDBDW" executers="bodbMonitorNet" viewers="" isFunction="0" isNested="0"></info>*/