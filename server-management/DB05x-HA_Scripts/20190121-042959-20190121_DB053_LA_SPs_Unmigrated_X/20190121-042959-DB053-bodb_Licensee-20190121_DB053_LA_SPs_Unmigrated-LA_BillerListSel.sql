
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_BillerListSel    Script Date: 1/21/2019 4:30:02 AM ******/
/****** Object:  Stored Procedure dbo.LA_BillerListSel    Script Date: 15/06/2015 13:57:50 PM ******/
/****** Object:  Stored Procedure dbo.LA_BillerListSel    Script Date: 18/05/2015 09:15:07 AM ******/

CREATE PROCEDURE [dbo].[LA_BillerListSel]
	 @BillerId	INT	= 0	
AS
/*  
	 Created: 20150408@Florent
	 Task : get List Biller by all or biller name
	 DB: DB052.bodb_Licensee  
   
	 Revisions:     		  
	 Params:
		+ 0 get all biller
		+ <> 0 specify a biller 
	 Example:
								EXEC dbo.LA_BillerListSel 0
*/
BEGIN	
	SET NOCOUNT ON
	;WITH cte_BillerPayer(FromPartyId, ToPartyID)
	AS 
	(
		SELECT FromPartyId, ToPartyID 
		FROM dbo.LA_InvoiceSetting WITH (NOLOCK)
		GROUP BY FromPartyId, ToPartyID 	
	)
	SELECT b.PartyID AS BillerID, b.BillerName, b.BillerFullName, b.CompanyName, COUNT(i.FromPartyId) AS NumberOfPayers	
		,STUFF((
				SELECT ', ' + CAST(CASE WHEN ISNULL(pd.BrandName, '') != '' THEN pd.BrandName ELSE pp.PartyName END AS VARCHAR)
				FROM cte_BillerPayer ii
					LEFT JOIN dbo.OAS_Party pp WITH (NOLOCK) ON ii.FromPartyId = pp.PartyID
					LEFT JOIN dbo.OAS_PartyDetail pd WITH (NOLOCK) ON pp.PartyID = pd.PartyID
				WHERE i.ToPartyID = ii.ToPartyID
				FOR XML PATH (''), ROOT('str'), TYPE 
					).value('/str[1]','VARCHAR(MAX)') 
			  , 1, 2, '') AS PayerList
		, b.StatusId
	FROM dbo.OAS_Party p WITH (NOLOCK)
		INNER JOIN dbo.LA_BillerInfo b WITH (NOLOCK) ON p.PartyID = b.PartyID		
		LEFT JOIN cte_BillerPayer i ON i.ToPartyId = p.PartyID
	WHERE p.PartyType = 4
		AND (@BillerId = 0 OR p.PartyID = @BillerId)
	GROUP BY b.PartyID, b.BillerName, b.CompanyName, ToPartyID, b.BillerFullName, b.StatusId
	ORDER BY b.BillerName ASC
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_BillerListSel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_BillerListSel] TO [vnteam]
GO 
