
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_BillerInfoSel    Script Date: 1/21/2019 4:30:02 AM ******/
/****** Object:  Stored Procedure dbo.LA_BillerInfoSel    Script Date: 3/2/2017 5:29:35 AM ******/
/****** Object:  Stored Procedure dbo.LA_BillerInfoSel    Script Date: 3/1/2017 3:47:05 PM ******/

CREATE PROCEDURE [dbo].[LA_BillerInfoSel]
	 @BillerId	INT	= 0	
AS
/*  
	 Created: 20150413@Florent
	 Task : get Biller Information by Id
	 DB: DB052.bodb_Licensee  
   
	 Revisions:
        - 20170227@bruce: get logo width & height [#72187]
	 Params:
	 Example:
				EXEC dbo.LA_BillerInfoSel 125
*/
BEGIN
	SET NOCOUNT ON
	SELECT b.PartyID AS BillerID
		, b.BillerName
		, b.StatusId
		, b.BillerFullName
		, b.CompanyName
		, b.Address1
		, b.Address2
		, b.LogoPath
		, b.Description
		, b.LogoHeight
		, b.LogoWidth
	FROM dbo.OAS_Party p WITH (NOLOCK)
		INNER JOIN dbo.LA_BillerInfo b WITH (NOLOCK) ON p.PartyID = b.PartyID
	WHERE p.PartyType = 4
		AND (@BillerId = 0 OR p.PartyID = @BillerId)

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
 GRANT EXECUTE ON [dbo].[LA_BillerInfoSel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_BillerInfoSel] TO [vnteam]
GO 
