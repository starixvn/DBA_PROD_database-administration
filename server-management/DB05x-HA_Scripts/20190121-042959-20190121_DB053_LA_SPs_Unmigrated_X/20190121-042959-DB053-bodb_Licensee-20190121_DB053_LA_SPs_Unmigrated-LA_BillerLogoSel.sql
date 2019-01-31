
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_BillerLogoSel    Script Date: 1/21/2019 4:30:02 AM ******/
/****** Object:  Stored Procedure dbo.LA_BillerLogoSel    Script Date: 3/1/2017 3:46:48 PM ******/

CREATE PROCEDURE [dbo].[LA_BillerLogoSel]
	@billerId INT
AS
/*
	 Created: 20170227@bruce
	 Task : select biller logo [RedmineID: #72187]
	 DB: DB052.bodb_Licensee
*/
BEGIN
	SET NOCOUNT ON

	SELECT TOP 1 LogoPath	AS [Filename],
		LogoHeight			AS Height,
		LogoWidth			AS Width,
		Logo				AS Data
	FROM dbo.LA_BillerInfo WITH(NOLOCK)
	WHERE PartyId = @billerId
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_BillerLogoSel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_BillerLogoSel] TO [vnteam]
GO 
