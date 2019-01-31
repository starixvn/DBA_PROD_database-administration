
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_Inv_InvoiceReferenceGet    Script Date: 1/21/2019 4:30:05 AM ******/
/****** Object:  Stored Procedure dbo.LA_Inv_InvoiceReferenceGet    Script Date: 1/31/2018 6:25:27 AM ******/
/****** Object:  Stored Procedure dbo.LA_Inv_InvoiceReferenceGet    Script Date: 1/31/2018 4:45:40 PM ******/

CREATE PROCEDURE [dbo].[LA_Inv_InvoiceReferenceGet]
	@BillerId		INT,
	@PayerId 		INT,
	@Environment	VARCHAR(10)
AS
/*	
	Created: 2017.07.19 - Scofield.Huynh [#79905]
	DB:		DBLIC/bodb_Licensee	

	Revision:
		20180131@Bruce: support credit note for setup fee [#90274]
*/
BEGIN
	SELECT OfficialInvoiceNo	AS InvoiceNo,
		InvoiceHeaderId			AS InvoiceId,
		InvoiceType
	FROM LA_InvoiceHeader WITH(NOLOCK)
	WHERE InvoiceType IN (1, 3, 7) -- Software Fee, Rebate, setupfee
		AND StatusId = 0 -- normal
		AND PartyId = @PayerId 
		AND BillerId = @BillerId
		AND Environment = @Environment
	ORDER BY CreatedDateTime
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_Inv_InvoiceReferenceGet] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_Inv_InvoiceReferenceGet] TO [vnteam]
GO 
