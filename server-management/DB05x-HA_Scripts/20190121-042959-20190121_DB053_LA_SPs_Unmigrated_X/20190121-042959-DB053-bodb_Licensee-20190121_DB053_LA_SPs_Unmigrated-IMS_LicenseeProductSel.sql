
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.IMS_LicenseeProductSel    Script Date: 1/21/2019 4:30:02 AM ******/

CREATE PROCEDURE [dbo].[IMS_LicenseeProductSel]
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

	DECLARE @products AS TABLE (productid INT PRIMARY KEY, productname VARCHAR(50))

	INSERT INTO @products(productid, productname)  VALUES(0, 'Sportsbook')
	INSERT INTO @products(productid, productname)  
		SELECT ld.Productid, p.ProductName FROM dbo.LicenseeProduct3rd ld WITH (NOLOCK)
		LEFT JOIN dbo.Product3rd p  WITH (NOLOCK)
		ON  ld.ProductID = p.Productid
		WHERE	ld.LicenseeID = @licenseeId
				AND ld.ProductID IN(2, 3)				
	SELECT * FROM @products p ORDER BY p.productid




GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[IMS_LicenseeProductSel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[IMS_LicenseeProductSel] TO [vnteam]
GO 
