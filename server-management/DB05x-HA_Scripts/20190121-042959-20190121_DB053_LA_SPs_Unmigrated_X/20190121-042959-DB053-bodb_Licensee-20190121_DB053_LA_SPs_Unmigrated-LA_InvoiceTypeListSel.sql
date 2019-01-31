
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_InvoiceTypeListSel    Script Date: 1/21/2019 4:30:05 AM ******/
/****** Object:  Stored Procedure dbo.LA_InvoiceTypeListSel    Script Date: 3/26/2018 10:18:29 PM ******/
/****** Object:  Stored Procedure dbo.LA_InvoiceTypeListSel    Script Date: 3/20/2018 9:49:00 AM ******/

CREATE PROCEDURE [dbo].[LA_InvoiceTypeListSel]
	 @InvoiceTypeId	INT	= 0	
AS
/*  
	 Created: 20150413@Florent
	 Task : get List Invoice type by all or id
	 DB: DB052.bodb_Licensee  
   
	 Revisions:     		  
		+ 20180109@bruce: filter invoice type by IsVisible=1 [#87039]
	 Params:
		+ 0 get all Invoice type
		+ <> 0 specify a Invoice type
	 Example:
				EXEC dbo.LA_InvoiceTypeListSel 0
*/
SET NOCOUNT ON
BEGIN
	SELECT InvTypeId, InvTypeName
	FROM dbo.LA_InvoiceType WITH (NOLOCK)
	WHERE (@InvoiceTypeId = 0 OR InvTypeId = @InvoiceTypeId) AND IsVisible=1
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_InvoiceTypeListSel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_InvoiceTypeListSel] TO [vnteam]
GO 
