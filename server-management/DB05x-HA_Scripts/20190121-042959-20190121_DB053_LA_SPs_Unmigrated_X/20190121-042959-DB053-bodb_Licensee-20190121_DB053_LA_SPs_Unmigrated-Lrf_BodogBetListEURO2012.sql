
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Lrf_BodogBetListEURO2012    Script Date: 1/21/2019 4:30:08 AM ******/

CREATE PROCEDURE Lrf_BodogBetListEURO2012
AS
BEGIN

	SET NOCOUNT ON;
	select * from DB06.bodb02.dbo.[_bodogBetlist]
END



GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[Lrf_BodogBetListEURO2012] TO [bodbLicenseeNet]
GO 
