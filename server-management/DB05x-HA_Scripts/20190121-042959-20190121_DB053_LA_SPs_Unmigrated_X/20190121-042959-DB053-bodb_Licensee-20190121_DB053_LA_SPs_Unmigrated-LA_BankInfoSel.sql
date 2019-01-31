
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_BankInfoSel    Script Date: 1/21/2019 4:30:02 AM ******/
/****** Object:  Stored Procedure dbo.LA_BankInfoSel    Script Date: 15/06/2015 13:57:50 PM ******/

CREATE PROCEDURE [dbo].[LA_BankInfoSel]
	 @BillerId	INT	= 0	
AS
/*  
	 Created: 20150604@Florent
	 Task : get list bank info 
	 DB: DB052.bodb_Licensee  
   
	 Revisions:     		  
	 Params:		
	 Example:
				EXEC dbo.LA_BankInfoSel 1
*/
BEGIN

	SET NOCOUNT ON
	SELECT
		p.PartyID	AS BillerID
		, b.BankId
		, b.BeneficiaryName
		, b.AccountNumber
		, b.BankName
		, b.BankAddress
		, b.IBAN
		, b.SwiftCode
		, b.CorrespondentBank
		, b.CorrespondentAccountNumber
		, b.CorrespondentAddress
		, b.CorrespondentSwiftCode
	FROM dbo.OAS_Party p WITH (NOLOCK)
		INNER JOIN dbo.LA_BankInfo b WITH (NOLOCK) ON p.PartyID = b.PartyID
	WHERE p.PartyType = 4
		AND (@BillerId = 0 OR p.PartyID = @BillerId)
		
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_BankInfoSel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_BankInfoSel] TO [vnteam]
GO 
