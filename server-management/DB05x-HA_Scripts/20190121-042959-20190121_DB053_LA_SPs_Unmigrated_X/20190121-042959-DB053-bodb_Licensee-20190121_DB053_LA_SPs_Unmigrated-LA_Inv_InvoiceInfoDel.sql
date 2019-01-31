
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_Inv_InvoiceInfoDel    Script Date: 1/21/2019 4:30:04 AM ******/
/****** Object:  Stored Procedure dbo.LA_Inv_InvoiceInfoDel    Script Date: 9/28/2017 10:07:32 PM ******/
/****** Object:  Stored Procedure dbo.LA_Inv_InvoiceInfoDel    Script Date: 9/27/2017 3:05:14 PM ******/

CREATE PROCEDURE [dbo].[LA_Inv_InvoiceInfoDel]
	@InvoiceHeaderId INT
AS

/*  Header:
	Created: 2017.08.24@Bruce
	Task : Delete invalid invoice
	DB: DB052.bodb_Licensee

	Revisions:
*/

BEGIN
	SET NOCOUNT ON
	
	DELETE dbo.LA_InvoiceHeader WHERE InvoiceHeaderId = @InvoiceHeaderId
	DELETE dbo.LA_InvoiceStatement WHERE InvoiceHeaderId = @InvoiceHeaderId
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_Inv_InvoiceInfoDel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_Inv_InvoiceInfoDel] TO [vnteam]
GO 
