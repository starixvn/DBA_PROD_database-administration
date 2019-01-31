
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_AnalysisFileIns    Script Date: 1/21/2019 4:30:02 AM ******/
/****** Object:  Stored Procedure dbo.LA_AnalysisFileIns    Script Date: 12/14/2017 10:55:27 PM ******/
CREATE PROCEDURE [dbo].[LA_AnalysisFileIns]
	@Files AS XML
AS
/*
	Created: BRUCE
	Date: 2017-10-18
	Task: Licensee Analysis (support raw data) #redmind: https://nexdev.net/issues/78294
	DB: bodb_licensee

	Revisions:
		- 20170919@Bruce: create SP
*/
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.LA_AnalysisFile(Filename, PartyIds, ProductCodes,FromDate,ToDate,IsSkinView, [Status])
	SELECT 
		t.c.value('@name',		'varchar(200)'), 
		t.c.value('@partyids',	'varchar(4000)'),
		t.c.value('@codes',		'varchar(200)'),
		t.c.value('@from',		'datetime'),
		t.c.value('@to',		'datetime'),
		t.c.value('@skin',		'bit'),
		1 -- pending
	FROM @files.nodes('files/file') t(c)

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_AnalysisFileIns] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_AnalysisFileIns] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[LA_AnalysisFileIns] TO [bodbLicenseeNet]
GO 
