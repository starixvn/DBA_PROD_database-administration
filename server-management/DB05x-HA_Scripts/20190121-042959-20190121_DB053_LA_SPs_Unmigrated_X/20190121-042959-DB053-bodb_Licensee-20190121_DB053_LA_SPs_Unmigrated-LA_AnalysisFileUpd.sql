
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_AnalysisFileUpd    Script Date: 1/21/2019 4:30:02 AM ******/
/****** Object:  Stored Procedure dbo.LA_AnalysisFileUpd    Script Date: 12/14/2017 10:55:30 PM ******/
CREATE PROCEDURE dbo.[LA_AnalysisFileUpd]
	@FileName	VARCHAR(200),
	@Status		TINYINT
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

	UPDATE dbo.LA_AnalysisFile WITH(ROWLOCK, UPDLOCK)
	SET [Status] = @Status
	WHERE [Filename] = @FileName
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_AnalysisFileUpd] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_AnalysisFileUpd] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[LA_AnalysisFileUpd] TO [bodbLicenseeNet]
GO 
