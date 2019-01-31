
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LRF_Get_LicenseesByGroup_KPIs_LC_2012    Script Date: 1/21/2019 4:30:08 AM ******/
/****** Object:  Stored Procedure dbo.LRF_Get_LicenseesByGroup_KPIs_LC_2012    Script Date: 1/29/2013 4:03:49 PM ******/

CREATE PROCEDURE [dbo].[LRF_Get_LicenseesByGroup_KPIs_LC_2012]
    @GroupID int
AS
/*
    Created: 20130129@Don
    Task: 
    DB: DB052.bodb_Licensee
	Original:

    Revisions:
        
    Param's Explanation:

*/
SET NOCOUNT ON

-- Deposit Licensees
IF @GroupID = 1
    SELECT LabelID SiteID, LabelName SiteName 
    FROM dbo.view_kpi_labels_LC (NOLOCK)
    WHERE ResellerID = 1 AND IsKPIActive = 1
    ORDER BY SiteID 
    
-- Credit Licensees
ELSE IF @GroupID = 2
    SELECT LabelID SiteID, LabelName SiteName 
    FROM dbo.view_kpi_labels_LC (NOLOCK)
    WHERE ResellerID IN (4,8) AND IsKPIActive = 1
    ORDER BY SiteID

SET NOCOUNT OFF



GRANT EXECUTE ON [dbo].[LRF_Get_LicenseesByGroup_KPIs_LC_2012] TO [bodbAdminNet]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LRF_Get_LicenseesByGroup_KPIs_LC_2012] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[LRF_Get_LicenseesByGroup_KPIs_LC_2012] TO [bodbLicenseeNet]
GO 
