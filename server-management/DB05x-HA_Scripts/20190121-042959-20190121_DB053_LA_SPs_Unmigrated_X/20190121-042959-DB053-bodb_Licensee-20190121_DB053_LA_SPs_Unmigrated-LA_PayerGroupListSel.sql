
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_PayerGroupListSel    Script Date: 1/21/2019 4:30:06 AM ******/
/****** Object:  Stored Procedure dbo.LA_PayerGroupListSel    Script Date: 15/06/2015 13:57:53 PM ******/

CREATE PROCEDURE [dbo].[LA_PayerGroupListSel]
	 @PayerGroupId	INT	= 0	
	 , @PayerID		INT = 0
AS
/*  
	 Created: 20150422@Florent
	 Task : get List Payer Group by all or by Id
	 DB: DB052.bodb_Licensee  
   
	 Revisions:     		  
	 Params:
		+ 0 get all payer
		+ <> 0 specify a payer
	 Example:
				EXEC dbo.LA_PayerGroupListSel 1
*/
BEGIN	
SET NOCOUNT ON

	SELECT pg.PartyGroupId AS PayerGroupID, pg.PartyGroupName AS PayerGroupName, COUNT(pga.PartyId) AS NumberOfPayers	
		, STUFF((
				SELECT ', ' + CAST(CASE WHEN ISNULL(pd.BrandName, '') != '' THEN pd.BrandName ELSE p1.PartyName END AS VARCHAR)
				FROM dbo.LA_PartyGroupAssignment p WITH (NOLOCK)
					LEFT JOIN dbo.OAS_Party p1 WITH (NOLOCK) ON p.PartyId = p1.PartyID
					LEFT JOIN dbo.OAS_PartyDetail pd WITH (NOLOCK) ON p1.PartyID = pd.PartyID
				WHERE pg.PartyGroupId = p.PartyGroupId					
				FOR XML PATH (''), ROOT('str'), TYPE 
					).value('/str[1]','VARCHAR(MAX)') 
			  , 1, 2, '') AS PayerList				
	FROM dbo.LA_PartyGroup pg WITH (NOLOCK)		
		LEFT JOIN dbo.LA_PartyGroupAssignment pga WITH (NOLOCK) ON pg.PartyGroupId = pga.PartyGroupId		
	WHERE (@PayerGroupId = 0 OR pg.PartyGroupId = @PayerGroupId)
		AND (@PayerID = 0 OR pga.PartyId = @PayerID)
	GROUP BY pg.PartyGroupId, pg.PartyGroupName

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_PayerGroupListSel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_PayerGroupListSel] TO [vnteam]
GO 
