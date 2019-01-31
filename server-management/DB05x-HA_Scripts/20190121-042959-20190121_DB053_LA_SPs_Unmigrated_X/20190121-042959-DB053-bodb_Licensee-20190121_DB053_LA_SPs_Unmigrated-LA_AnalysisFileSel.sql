
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_AnalysisFileSel    Script Date: 1/21/2019 4:30:02 AM ******/
/****** Object:  Stored Procedure dbo.LA_AnalysisFileSel    Script Date: 12/14/2017 10:55:28 PM ******/
CREATE PROCEDURE dbo.[LA_AnalysisFileSel] (
	@FileName VARCHAR(200) = '',
	@Fromdate DATETIME = NULL,  
	@ToDate DATETIME = NULL
)
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

	IF @Fromdate IS NULL SET @Fromdate = '20000101'
	IF @ToDate IS NULL SET @ToDate = '20500101'

	SELECT FileId, PartyIds, ProductCodes, Filename, FromDate, ToDate, [Status], IsSkinView
	FROM dbo.LA_AnalysisFile f WITH(NOLOCK)
	WHERE f.FromDate >= @Fromdate AND f.ToDate <= @ToDate AND (
		ISNULL(@FileName,'') = '' OR f.[Filename] LIKE @FileName ESCAPE '\'
	)

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_AnalysisFileSel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_AnalysisFileSel] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[LA_AnalysisFileSel] TO [bodbLicenseeNet]
GO 
