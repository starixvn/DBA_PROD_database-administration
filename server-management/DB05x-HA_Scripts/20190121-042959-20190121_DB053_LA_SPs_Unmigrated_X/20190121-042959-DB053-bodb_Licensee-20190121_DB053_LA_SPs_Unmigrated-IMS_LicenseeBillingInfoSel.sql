
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.IMS_LicenseeBillingInfoSel    Script Date: 1/21/2019 4:30:02 AM ******/

CREATE PROCEDURE [dbo].[IMS_LicenseeBillingInfoSel]
	@partyId TINYINT = 0,
	@licenseeId INT = 0,
	@productId INT = 0
AS
	/*  Created: Kevin
		Date: 20130418
		Task : Report - Licensee Settlement Report
		DB: DBLIC.bodb_Licensee
		Revisions:  
		Param's Explanation:  
		  + @product:	0 -> Sportsbook			1 -> Racing
						2 -> Number Game		3 -> BA
						4 -> Live Casino		5 -> Virtual Sports
						6 -> RNG Casino			7 -> Bingo
	*/  
	SET NOCOUNT ON

	SELECT 
		GETDATE() AS FirstBilling, 
		'15% of Net Win' AS BasisOfBilling, 
		'EUR15000 (minimum fees waived 3 months from date of launch)' AS MinimumFees,  
		REPLACE(CONVERT(VARCHAR(11),GETDATE(),6), ' ', '-') AS HeadOfTerms




GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[IMS_LicenseeBillingInfoSel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[IMS_LicenseeBillingInfoSel] TO [vnteam]
GO 
