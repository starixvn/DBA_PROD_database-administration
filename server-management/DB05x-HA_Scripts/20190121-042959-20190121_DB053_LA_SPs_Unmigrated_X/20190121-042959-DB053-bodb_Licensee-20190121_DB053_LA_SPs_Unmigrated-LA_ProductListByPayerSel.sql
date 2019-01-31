
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_ProductListByPayerSel    Script Date: 1/21/2019 4:30:06 AM ******/
/****** Object:  Stored Procedure dbo.LA_ProductListByPayerSel    Script Date: 15/06/2015 13:57:54 PM ******/
/****** Object:  Stored Procedure dbo.LA_ProductListByPayerSel    Script Date: 18/05/2015 09:15:07 AM ******/

CREATE PROCEDURE [dbo].[LA_ProductListByPayerSel]
	 @PayerId	INT	= 0	
AS
/*  
	 Created: 20150413@Florent
	 Task : get List Products by Payerid or get all
	 DB: DB052.bodb_Licensee  
   
	 Revisions:     		  
	 Params:
		+ 0 get all products
		+ <> 0 all product by PayerID
	 Example:
								EXEC dbo.LA_ProductListByPayerSel 0
*/
BEGIN
	SET NOCOUNT ON	
	SELECT c.ProductID, pd.ProductPrefix, pd.ProductName
	FROM dbo.OAS_Party p WITH (NOLOCK)
		INNER JOIN dbo.OAS_ChargeInfo c WITH (NOLOCK) ON p.PartyID = c.FromParty
		INNER JOIN dbo.LA_ChargeInfo_SystemMapping cs WITH (NOLOCK) ON c.ChargeID = cs.ChargeID AND cs.SystemID = 2
		LEFT JOIN dbo.LA_f_Products3rd('') pd ON c.ProductID = pd.ProductID	
	WHERE (@PayerId = 0 OR p.PartyID = @PayerId)
	GROUP BY c.ProductID, pd.ProductPrefix, pd.ProductName
	
	
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_ProductListByPayerSel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_ProductListByPayerSel] TO [vnteam]
GO 
