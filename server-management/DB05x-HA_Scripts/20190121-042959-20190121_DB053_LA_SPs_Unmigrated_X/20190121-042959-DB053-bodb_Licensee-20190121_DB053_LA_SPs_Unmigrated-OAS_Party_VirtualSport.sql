
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OAS_Party_VirtualSport    Script Date: 1/21/2019 4:30:10 AM ******/
/****** Object:  Stored Procedure dbo.OAS_Party_VirtualSport    Script Date: 11/18/2014 5:02:35 AM ******/
/****** Object:  Stored Procedure dbo.OAS_Party_VirtualSport    Script Date: 14/11/2014 14:52:26 PM ******/

CREATE PROCEDURE [dbo].[OAS_Party_VirtualSport]
AS  
  
/*  
 * Created by : 20140328@Florent 
 * Task  : Get all licensees (compatible with the new structure) for VirtualSport Winloss report 
 * DB   : DB052.bodb_Licensee  
 * Revisions :  
    - 20141105@Florent: fix get brand name of licensee
    - 20141031@Florent: Apply new Structure Using SystemMapping 	
 * Param's Explanation:    
 * 
 */  
 
BEGIN
	SET NOCOUNT ON  
	SELECT DISTINCT CASE WHEN p1.PartyName = 'Boping' THEN p1.PartyID ELSE ci.FromParty END AS PartyID,
				CASE 
					WHEN p.PartyName = 'IBC' THEN r.ResellerName
					WHEN p.PartyName = '18bb' THEN r.ResellerName
					WHEN p1.PartyName = 'Boping' THEN p1.PartyName
					ELSE p.PartyName + CASE WHEN ISNULL(pd.BrandName,'') = '' OR p.PartyName = pd.BrandName THEN ''
									    ELSE ' ('+CAST(pd.BrandName AS VARCHAR(20) )+')'
								    END
				END AS PartyName
		FROM dbo.OAS_ChargeInfo ci (NOLOCK) 
			INNER JOIN dbo.OAS_Party p (NOLOCK) ON ci.FromParty = p.PartyID
			INNER JOIN dbo.OAS_Party p1 (NOLOCK) ON ci.toParty = p1.PartyID
			INNER JOIN dbo.LA_ChargeInfo_SystemMapping (NOLOCK) cs ON ci.ChargeID = cs.ChargeID
			LEFT JOIN dbo.OAS_PartyDetail pd (NOLOCK) ON p.PartyID = pd.PartyID
			LEFT JOIN dbo.LicenseeReseller lr WITH (NOLOCK) ON p.OldRefID = lr.LicenseeID
			LEFT JOIN dbo.Resellers r WITH (NOLOCK) ON lr.ResellerID = r.ResellerID
		WHERE ci.ProductID = 5
				AND p.PartyType = 1
				--AND p1.PartyName !='Boping'
				AND cs.SystemID = 4 --OWS
		ORDER BY PartyName ASC
END

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OAS_Party_VirtualSport] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[OAS_Party_VirtualSport] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[OAS_Party_VirtualSport] TO [bodbLicenseeNet]
GO 
