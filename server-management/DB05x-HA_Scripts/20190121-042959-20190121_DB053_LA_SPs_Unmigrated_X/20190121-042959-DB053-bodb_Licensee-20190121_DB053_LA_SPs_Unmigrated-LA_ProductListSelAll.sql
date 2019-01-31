
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_ProductListSelAll    Script Date: 1/21/2019 4:30:06 AM ******/
/****** Object:  Stored Procedure dbo.LA_ProductListSelAll    Script Date: 15/06/2015 13:57:54 PM ******/
CREATE PROCEDURE dbo.LA_ProductListSelAll
AS
/*  
	 Created: 20150422@Patrick
	 Task : Get all products
	 DB: DB052.bodb_Licensee
	 Revisions:     
		
	 Params:
*/
BEGIN
	SET NOCOUNT ON
	SELECT ProductId, ProductName
	FROM dbo.LA_f_Products3rd('')
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_ProductListSelAll] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_ProductListSelAll] TO [vnteam]
GO 
