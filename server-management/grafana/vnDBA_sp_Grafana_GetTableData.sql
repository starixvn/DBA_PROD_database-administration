SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.vnDBA_sp_Grafana_GetTableData
						@tableName		NVARCHAR(128)
					,	@top			INT				= 10
					,	@columnList		NVARCHAR(MAX)	= NULL
					,	@filter			NVARCHAR(MAX)	= NULL
					,	@groupBy		NVARCHAR(MAX)	= NULL
					,	@orderList		NVARCHAR(MAX)	= NULL
WITH EXECUTE AS OWNER
AS
/*
	Creator:	20180621@Billy
	Task:		Get data for Grafana Dashboard - Table data - [Redmine: #00000]
	Database:	DBSTARIX.StarixDB
	
	Revisions:
		- 20180621@Billy:	Initial - [Redmine: #00000]

	Developer's Notes:
		- @paneltype:		Specify the way to select data based on panel type
								000 ~ 099		Graph chart panel
								100 ~ 199		Single stat panel

*/
BEGIN;
	DECLARE	@message	NVARCHAR(MAX);

	SELECT	@columnList	= N'
SELECT	' + ISNULL(N'TOP(' + CAST(@top AS NVARCHAR) + N')
		', N'') + ISNULL(@columnList, N'*')
		,	@tableName	= N'
FROM	' + @tableName + N' AS tbl WITH (NOLOCK)'
		,	@filter		= ISNULL(N'
WHERE	' + @filter, N'')
		,	@groupBy	= ISNULL(N'
GROUP BY ' + @groupBy, N'')
		,	@orderList	= ISNULL(N'
ORDER BY ' + @orderList, N'')
		;

	SELECT	@message	= @columnList + @tableName + @filter + @groupBy + @orderList + N';';

	EXECUTE	sys.sp_executesql @message;
END;
GO
GRANT EXECUTE ON dbo.vnDBA_sp_Grafana_GetTableData TO vnGrafana AS dbo;
GO
/*<info serverAlias="DBSTARIX-StarixDB" executers="vnGrafana" viewers="" isFunction="0" isNested="0"></info>*/