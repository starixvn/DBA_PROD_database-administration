
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.IMS_LicenseeSel    Script Date: 1/21/2019 4:30:02 AM ******/
CREATE PROCEDURE [dbo].[IMS_LicenseeSel]
AS
	/*  Created: Kevin
		Date: 20130423
		Task : Report - Licensee Settlement Report
		DB: DBLIC.bodb_Licensee
		Revisions:  
		Param's Explanation:  
		
	*/  
	SET NOCOUNT ON

	SELECT   
		l.LicenseeID, 
		(CASE WHEN ISNULL(l.BrandName, '') = '' THEN l.LicenseeName ELSE l.BrandName END) AS BrandName, 
		l.LicenseeName,
		ISNULL(ba.EnableBA,0) as EnableBA
	FROM 
		dbo.Licensees l WITH (NOLOCK)  
		INNER JOIN dbo.SystemLicensee sl (NOLOCK) ON l.LicenseeID=sl.LicenseeID 
		INNER JOIN dbo.Systems s (NOLOCK) ON sl.SystemID=s.ID 
		LEFT JOIN dbo.LicenseeBAConfig ba WITH (NOLOCK) ON l.LicenseeID = ba.LicenseeID
	WHERE 
		LicenseeName <> 'IBC' AND
		IsDeposit = 1
		AND sl.IsActive = 1
		AND s.SystemName='Accounting'
	ORDER BY l.LicenseeName ASC
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[IMS_LicenseeSel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[IMS_LicenseeSel] TO [vnteam]
GO 
