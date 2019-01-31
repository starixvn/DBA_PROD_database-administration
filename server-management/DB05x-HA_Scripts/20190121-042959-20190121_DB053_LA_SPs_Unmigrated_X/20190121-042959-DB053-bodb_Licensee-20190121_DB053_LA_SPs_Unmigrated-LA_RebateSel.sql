
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_RebateSel    Script Date: 1/21/2019 4:30:07 AM ******/
CREATE PROCEDURE [dbo].[LA_RebateSel]
AS
/*  
	 Created: 20180525@Parsons [#94282]
	 Task : Enhance Manage Discount group function to support more discount schemes
	 DB: DB052.bodb_licensee   

	 Revisions:  
		- 20180525@Parsons: Get rebate groups info [#94282]

	 Params:

	 Explannation: EXEC LA_RebateSel
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @RebateGroupType INT = 2
	
	SELECT h.DiscountGroupId as GroupId, 
			h.DiscountGroupName as GroupName,
			h.FromDate,
			h.ToDate, 
			d.Rate, 
			COUNT(DISTINCT p.ProductId) AS NumberOfProduct,
			COUNT(DISTINCT a.PartyID) AS NumberOfPayer, 
			STUFF((
				SELECT ', ' + ISNULL(CAST(ppp.ProductName AS VARCHAR), '')
				FROM dbo.LA_DiscountGroupProduct pp WITH (NOLOCK)
					LEFT JOIN dbo.LA_f_Products3rd('') ppp ON pp.ProductId = ppp.Productid
				WHERE pp.DiscountGroupId = h.DiscountGroupId
				FOR XML PATH (''))
			  , 1, 2, '') AS ProductList, 
			 STUFF((
				SELECT ', ' + CASE WHEN ISNULL(d.BrandName, '') = '' THEN ISNULL(CAST(pp.PartyName AS VARCHAR), '') ELSE ISNULL(CAST(d.BrandName AS VARCHAR), '') END
				FROM dbo.LA_DiscountGroupAssignment aa WITH (NOLOCK)
					LEFT JOIN dbo.OAS_Party pp WITH(NOLOCK) ON aa.PartyID = pp.PartyID
					LEFT JOIN dbo.OAS_PartyDetail d ON aa.PartyID = d.PartyID
				WHERE aa.DiscountGroupId = h.DiscountGroupId
				FOR XML PATH (''), ROOT('str'), TYPE 
					).value('/str[1]','VARCHAR(MAX)') 
			  , 1, 2, '') AS PartyList
	FROM dbo.LA_DiscountGroupHeader h WITH(NOLOCK)
		LEFT JOIN dbo.LA_DiscountGroupDetail d WITH(NOLOCK) ON h.DiscountGroupId = d.DiscountGroupId
		LEFT JOIN dbo.LA_DiscountGroupProduct p WITH(NOLOCK) ON h.DiscountGroupId = p.DiscountGroupId
		LEFT JOIN dbo.LA_DiscountGroupAssignment a WITH(NOLOCK) ON h.DiscountGroupId = a.DiscountGroupId
	WHERE DiscountGroupType = @RebateGroupType
	GROUP BY h.DiscountGroupId, h.DiscountGroupName, h.FromDate, h.ToDate, d.Rate
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_RebateSel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_RebateSel] TO [vnteam]
GO 
