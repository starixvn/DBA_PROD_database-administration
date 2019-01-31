
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_Inv_InvoiceMetadataSel    Script Date: 1/21/2019 4:30:04 AM ******/
/****** Object:  Stored Procedure dbo.LA_Inv_InvoiceMetadataSel    Script Date: 4/26/2017 1:14:56 PM ******/

CREATE PROCEDURE [dbo].LA_Inv_InvoiceMetadataSel
	@InvoiceIdString VARCHAR(8000)
AS
/*	Header:
	Created: 2017.04.26 - Bruce
	Task : Get invoice header by id
	DB: DB052.bodb_Licensee
*/
BEGIN
	SET NOCOUNT ON
	
	SELECT InvoiceHeaderId, InvoiceData, InvoicePath, Environment
	FROM dbo.LA_InvoiceHeader
	WHERE InvoiceHeaderId IN(SELECT val FROM dbo.strSplit(@InvoiceIdString, ','))
	
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_Inv_InvoiceMetadataSel] TO [bodbAdminNet]
GO 
