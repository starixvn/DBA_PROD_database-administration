
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.IMS_LicenseeCurrencySel    Script Date: 1/21/2019 4:30:02 AM ******/
/****** Object:  Stored Procedure dbo.IMS_LicenseeCurrencySel    Script Date: 5/8/2013 4:59:14 PM ******/
CREATE PROCEDURE [dbo].[IMS_LicenseeCurrencySel]
	@licenseeId INT = 0
AS
	/*  Created: Kevin
		Date: 20130423
		Task : Report - Licensee Settlement Report
		DB: DBLIC.bodb_Licensee
		Revisions:  
		Param's Explanation:  
		
	*/  
	SET NOCOUNT ON

	BEGIN
	declare @tempLicenseeCurr as table (currency int)
	insert into @tempLicenseeCurr
		SELECT distinct lc.Currency 
		FROM dbo.LicenseeCust lc (nolock)
		WHERE	(@LicenseeID = 0 OR LicenseeID = @LicenseeID)
				AND Currency <> 20
	SELECT 
		t.currency, 
		e.Code AS CurrencyName
	FROM 
		@tempLicenseeCurr t
	INNER JOIN bodb02.dbo.exchange e WITH (NOLOCK) ON t.currency = e.exchangeid
	ORDER BY 
		e.Code
	END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[IMS_LicenseeCurrencySel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[IMS_LicenseeCurrencySel] TO [vnteam]
GO 
