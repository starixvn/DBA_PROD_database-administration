SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.InsRptStats
AS
/*
	Created:	20130802@Bobby.Nguyen
	Task:		Collect stats data of FPS_SUB
	Database:	FPSDEV.FPS_DEV

	Revisions:
		- 20181214@Billy:	Refactoring SP - [Redmine: #106061]

	Param's Explanation:
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE	@DateNow		DATE			= GETDATE()
		,	@StatsDbName	VARCHAR(50)	= DB_NAME()
		;

	CREATE TABLE	#tblSpaceUsed (
						name			NVARCHAR(128)
					,	type			CHAR(2)
					,	type_desc		NVARCHAR(60)
					,	rows			BIGINT
					,	reserved_kb		BIGINT
					,	data_kb			BIGINT
					,	index_kb		BIGINT
					,	unused_kb		BIGINT
					);

	INSERT INTO	#tblSpaceUsed (name, type, type_desc, rows, reserved_kb, data_kb, index_kb, unused_kb)
	EXECUTE	dbo.sp_starix_tblspaceused;

	EXECUTE	FPSRPT.FPS_RPT.sys.sp_executesql
				@stmt = N'
DELETE	dbo.rptDBStats WITH (ROWLOCK)
WHERE	ReportDate >= @DateNow
	AND	StatsDbName = @StatsDbName;
'
			,	@params = N'
	@DateNow		DATE
,	@StatsDbName	VARCHAR(50)
'
			,	@DateNow = @DateNow
			,	@StatsDbName = @StatsDbName
			;

	INSERT INTO	FPSRPT.FPS_RPT.dbo.rptDBStats (StatsDbName, TableName, RowInCount, SpaceInUse, RowIncrement, SpaceIncrement, ReportDate, SubscriberID)
	SELECT	[StatsDbName]		= @StatsDbName
		,	[TableName]			= tbl.name
		,	[RowInCount]		= tbl.rows
		,	[SpaceInUse]		= tbl.data_kb + tbl.index_kb
		,	[RowIncrement]		= tbl.rows - ISNULL(rpt.SpaceInUse, 0)
		,	[SpaceIncrement]	= tbl.data_kb + tbl.index_kb - ISNULL(rpt.SpaceInUse, 0)
		,	[ReportDate]		= @DateNow
		,	[SubscriberID]		= NULL
	FROM		#tblSpaceUsed AS tbl WITH (NOLOCK)
	OUTER APPLY	(
		SELECT	TOP(1)
				lst.RowInCount, lst.SpaceInUse
		FROM	FPSRPT.FPS_RPT.dbo.rptDBStats AS lst
		WHERE	lst.StatsDbName = CAST(DB_NAME() AS VARCHAR(50))
			AND	lst.TableName = CAST(tbl.name AS VARCHAR(50))
			AND	lst.SubscriberID IS NULL
			AND	lst.ReportDate < @DateNow
		ORDER BY lst.ReportDate DESC
	) AS rpt;
END;
GO
/*<info serverAlias="FPSDEV-FPS_DEV" executers="" viewers="" isFunction="0" isNested="0"></info>*/