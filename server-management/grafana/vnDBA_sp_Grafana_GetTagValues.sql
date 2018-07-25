USE	StarixDB;
GO
ALTER PROCEDURE	dbo.vnDBA_sp_Grafana_GetTagValues
						@tag				NVARCHAR(60)
AS
/*
	Creator:	20170920@Billy
	Task:		Get tag's values for Grafana Dashboard - [Redmine: #94602]
	Database:	StarixDB
	
	Revisions:
		- 20170515@Billy:	Initial - [Redmine: #94602]
		
	Developer's Notes:
		
*/
BEGIN
	SET NOCOUNT ON;
	
	SELECT	DISTINCT
			[server]		= st.ServerName
	FROM	dbo.vnDBA_Perf_ServerTags AS st WITH (NOLOCK)
	WHERE	st.Tag = @tag;
END;
GO
GRANT EXECUTE ON dbo.vnDBA_sp_Grafana_GetTagValues TO vnGrafana AS dbo;
GO
