
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OAS_Party_TotalTrans    Script Date: 1/21/2019 4:30:10 AM ******/
/****** Object:  Stored Procedure dbo.OAS_Party_TotalTrans    Script Date: 6/15/2015 4:35:17 AM ******/
/****** Object:  Stored Procedure dbo.OAS_Party_TotalTrans    Script Date: 12/06/2015 10:59:19 AM ******/
/****** Object:  Stored Procedure dbo.OAS_Party_TotalTrans    Script Date: 4/13/2015 5:44:48 PM ******/

/****** Object:  Stored Procedure dbo.OAS_Party_TotalTrans    Script Date: 12/31/2013 10:38:18  ******/
CREATE PROCEDURE [dbo].[OAS_Party_TotalTrans] 
	 @FromDate 	SMALLDATETIME
	,@ToDate 		SMALLDATETIME
	,@ExcludeTest 	BIT 			= 1
AS
/*  
 * Created by : 20131126@Francis 
 * Task  : Get all licensees (compatible with the new structure) for Total Trans report 
 * DB   : DB052.bodb_Licensee  
 * Revisions :  
 	- 20141031@Florent: Apply new Structure Using SystemMapping
	- 20141105@Florent: fix get brand name of licensee
	- 20150412@Patrick: Add filter by PartyType

 * Param's Explanation:    
 *  - @ExcludeTest: to exclude Spondemo (a test licensee)
  exec [OAS_Party_TotalTrans] '2014-09-01','2014-09-30'
 */
BEGIN
	SET NOCOUNT ON

	SELECT @Fromdate = ltrim(rtrim(@Fromdate))
		,@Todate = ltrim(rtrim(@Todate))

	SELECT DISTINCT ci.ChargeID
		,ci.FromParty AS PartyID
		,p.PartyName + CASE WHEN ISNULL(pd.BrandName,'') = '' OR p.PartyName = pd.BrandName THEN ''
									    ELSE ' ('+CAST(pd.BrandName AS VARCHAR(20) )+')'
								    END AS PartyName
		,ci.ParentChargeID
	FROM dbo.OAS_ChargeInfo ci WITH (NOLOCK)
	     INNER JOIN dbo.OAS_Party p WITH (NOLOCK) ON ci.FromParty = p.PartyID
		INNER JOIN dbo.LA_ChargeInfo_SystemMapping cs WITH (NOLOCK) ON ci.ChargeID = cs.ChargeID AND cs.SystemID = 4
		LEFT JOIN dbo.LA_ChargeInfo_MinFee cm WITH (NOLOCK) ON ci.ChargeID = cm.ChargeID
		LEFT JOIN dbo.OAS_PartyDetail pd (NOLOCK) ON p.PartyID = pd.PartyID
	WHERE (
			@FromDate BETWEEN ci.FromDate AND ci.ToDate
			OR @ToDate BETWEEN ci.FromDate AND ci.ToDate
			)
		AND ci.ChargeType = 2
		AND ci.ProductID = 0
		AND ci.ToParty IN (
			SELECT p1.PartyID
			FROM OAS_Party p1(NOLOCK)
			WHERE p1.PartyName IN ('Oneworks', 'BCH', 'LDL') AND p1.PartyType NOT IN (4)
			)
		AND (
			(@ExcludeTest = 0)
			OR (
				@ExcludeTest = 1
				AND ci.FromParty NOT IN (
					SELECT p2.PartyID
					FROM OAS_Party p2(NOLOCK)
					WHERE p2.PartyName IN ('spondemo', 'Demo') AND p2.PartyType NOT IN (4)
					)
				)
			)
		AND ci.MinAmount = 0
	ORDER BY ci.ParentChargeID ASC
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OAS_Party_TotalTrans] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[OAS_Party_TotalTrans] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[OAS_Party_TotalTrans] TO [bodbLicenseeNet]
GO 
