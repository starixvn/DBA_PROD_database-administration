
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_InvoiceTemplateListSel    Script Date: 1/21/2019 4:30:05 AM ******/
/****** Object:  Stored Procedure dbo.LA_InvoiceTemplateListSel    Script Date: 15/06/2015 13:57:52 PM ******/
/****** Object:  Stored Procedure dbo.LA_InvoiceTemplateListSel    Script Date: 18/05/2015 09:15:07 AM ******/

CREATE PROCEDURE [dbo].[LA_InvoiceTemplateListSel]
	 @InvoiceTemplateId	INT	= 0	
AS
/*  
	 Created: 20150413@Florent
	 Task : get List template by all or id
	 DB: DB052.bodb_Licensee  
   
	 Revisions:     		  
	 Params:
		+ 0 get all Invoice template
		+ <> 0 specify a Invoice template
	 Example:
								EXEC dbo.LA_InvoiceTemplateListSel 0
*/
SET NOCOUNT ON
BEGIN
	SELECT InvTemplateId, InvTemplateName, TemplatePath
	FROM dbo.LA_InvoiceTemplate WITH (NOLOCK)
	WHERE (@InvoiceTemplateId = 0 OR InvTemplateId = @InvoiceTemplateId)
		
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_InvoiceTemplateListSel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_InvoiceTemplateListSel] TO [vnteam]
GO 
