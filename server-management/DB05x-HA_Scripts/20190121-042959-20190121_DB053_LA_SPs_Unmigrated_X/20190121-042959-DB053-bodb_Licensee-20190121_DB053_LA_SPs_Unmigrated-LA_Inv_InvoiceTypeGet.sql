
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_Inv_InvoiceTypeGet    Script Date: 1/21/2019 4:30:05 AM ******/
/****** Object:  Stored Procedure dbo.LA_Inv_InvoiceTypeGet    Script Date: 8/31/2015 9:35:04 AM ******/

CREATE PROCEDURE [dbo].[LA_Inv_InvoiceTypeGet] 	
	  
AS
/*	Header:
	Created:2015.08.21 - Bravo.Tran
	Task :	Create Invoice 
	DB:		DB052.bodb_Licensee
   
	Revisions: 
		+ 2015.08.07: Invoice Type List - Get
*/
/*	Example:
	USE bodb_licensee
		EXEC [LA_Inv_InvoiceTypeGet]
*/
BEGIN
	SET NOCOUNT ON
	
	SELECT i.InvTypeId, i.InvTypeName
	FROM dbo.LA_InvoiceType i
	
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_Inv_InvoiceTypeGet] TO [bodbAdminNet]
GO 
