
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_PayerListSel    Script Date: 1/21/2019 4:30:06 AM ******/
/****** Object:  Stored Procedure dbo.LA_PayerListSel    Script Date: 12/13/2016 11:26:32 PM ******/
/****** Object:  Stored Procedure dbo.LA_PayerListSel    Script Date: 12/9/2016 2:18:08 PM ******/

CREATE PROCEDURE [dbo].[LA_PayerListSel]
	@PayerId INT = 0
AS
/*
	Created: 20150414@Florent
	Task : get List Payer by all or by Id
	DB: DB052.bodb_Licensee  

	Revisions:
		- 20150917@Victor: support Chinese on settings
		- 20161109@bruce.bui: include non-official payers

	Params:
		+ 0 get all payer
		+ <> 0 specify a payer

	Example:
				EXEC dbo.LA_PayerListSel 0
*/
BEGIN
	SET NOCOUNT ON

	;WITH cte_BillerPayer(FromPartyId, ToPartyID) AS
	(
		SELECT FromPartyId, ToPartyID 
		FROM dbo.LA_InvoiceSetting WITH (NOLOCK)
		GROUP BY FromPartyId, ToPartyID
	)
	SELECT p.PartyID AS PayerID
		 , p.PartyName AS PayerName
		 , pd.BrandName
		 , pd.CompanyName
		 , COUNT(i.ToPartyId) AS NumberOfBillers
		 , STUFF((
				SELECT ', ' + CAST(b.BillerName AS NVARCHAR)
				FROM cte_BillerPayer ii
					LEFT JOIN dbo.LA_BillerInfo b ON ii.ToPartyId = b.PartyId
				WHERE b.PartyID = ii.ToPartyID AND ii.FromPartyId = p.PartyID
				FOR XML PATH ('')
			), 1, 2, '') AS BillerList
		 , ISNULL(pd.StatusId,0) AS StatusId
		 , p.PartyType
	FROM dbo.OAS_Party p WITH (NOLOCK)
		INNER JOIN dbo.OAS_PartyDetail pd WITH (NOLOCK) ON p.PartyID = pd.PartyID
		LEFT JOIN cte_BillerPayer i ON i.FromPartyId = p.PartyID
	WHERE p.PartyType IN (1,5)
		AND (@PayerId = 0 OR p.PartyID = @PayerId)
	GROUP BY p.PartyID, p.PartyName, pd.BrandName, pd.CompanyName, pd.StatusId, p.PartyType

	-- PartyType
	--
	-- 1: official licensee (unmapped)
	-- 5: non-offcial licensee
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_PayerListSel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_PayerListSel] TO [vnteam]
GO 
