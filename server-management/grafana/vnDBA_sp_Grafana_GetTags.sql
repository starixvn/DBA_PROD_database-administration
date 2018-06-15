USE	StarixDB;
GO
ALTER PROCEDURE	dbo.vnDBA_sp_Grafana_GetTags
						@tagtype			TINYINT
AS
/*
	Creator:	20170920@Billy
	Task:		Get variable tags for Grafana Dashboard - [Redmine: #94602]
	Database:	DB233.StarixDB
	
	Revisions:
		- 20170515@Billy:	Initial - [Redmine: #94602]
		
	Developer's Notes:
		
*/
BEGIN
	SET NOCOUNT ON;
	
	IF	@tagtype = 0
	-- All list --
	BEGIN;
		SELECT	DISTINCT
				[tag]		= st.Tag
		FROM	dbo.vnDBA_Perf_ServerTags AS st WITH (NOLOCK)
	END;
END;
GO
GRANT EXECUTE ON dbo.vnDBA_sp_Grafana_GetTags TO vnGrafana AS dbo;
GO
