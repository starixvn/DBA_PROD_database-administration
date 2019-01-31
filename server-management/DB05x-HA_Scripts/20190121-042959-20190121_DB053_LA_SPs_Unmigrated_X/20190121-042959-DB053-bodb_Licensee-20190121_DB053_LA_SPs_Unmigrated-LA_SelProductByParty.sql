
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_SelProductByParty    Script Date: 1/21/2019 4:30:07 AM ******/
/****** Object:  Stored Procedure dbo.LA_SelProductByParty    Script Date: 30/03/2015 11:03:21 AM ******/
/****** Object:  Stored Procedure dbo.LA_SelProductByParty    Script Date: 19/03/2015 14:00:57 PM ******/
CREATE PROCEDURE [dbo].[LA_SelProductByParty] 
	 @PartyID		INT		= 0
	, @excludeTest	BIT		= 0	
AS
/*
Created: 20150312@Florent
Task : Get all product by a party
DB: DB052.bodb_licensee
Revison:

Revisions:
Param's Explanation:
*/
SET NOCOUNT ON

BEGIN
	--DECLARE @temp AS TABLE (ProductID INT)

	BEGIN
		--INSERT INTO @temp(ProductID)
		SELECT CASE WHEN c.ProductID = 0 THEN 'SB'
					 ELSE pr.ProductPrefix
				END AS ProductCode 
			, CASE WHEN c.ProductID = 0 THEN 'Sportsbook'
					 ELSE pr.ProductName
				END AS ProductName
		FROM dbo.OAS_ChargeInfo AS c
			INNER JOIN dbo.LA_ChargeInfo_SystemMapping cs WITH (NOLOCK) ON c.ChargeID = cs.ChargeID AND cs.SystemID = 2
			INNER JOIN dbo.OAS_Party p WITH (NOLOCK) ON c.FromParty = p.PartyID
			LEFT JOIN dbo.Product3rd pr WITH (NOLOCK) ON c.ProductID = pr.Productid	
		WHERE (@PartyID = 0 OR p.PartyID = @PartyID)
		GROUP BY pr.Productid
			, CASE WHEN c.ProductID = 0 THEN 'SB'
					 ELSE pr.ProductPrefix
				END 
			, CASE WHEN c.ProductID = 0 THEN 'Sportsbook'
					 ELSE pr.ProductName
				END
		ORDER BY pr.Productid
	END
	
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_SelProductByParty] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_SelProductByParty] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[LA_SelProductByParty] TO [bodbLicenseeNet]
GO 
