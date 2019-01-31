
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LRF_Get_LicenseesByGroup_KPIs_LC    Script Date: 1/21/2019 4:30:08 AM ******/
/****** Object:  Stored Procedure dbo.LRF_Get_LicenseesByGroup_KPIs_LC    Script Date: 1/3/2013 3:19:01 PM ******/



CREATE  PROCEDURE [dbo].[LRF_Get_LicenseesByGroup_KPIs_LC]
    @GroupID int
AS
/*
    Created: 20121226@Jim
    Task: OWA - Add Live Casino data to KPI report
    DB: DB052.bodb_Licensee
	Original:LRF_Get_LicenseesByGroup_KPIs

    Revisions:
      
        
    Param's Explanation:

*/
SET NOCOUNT ON

SELECT LabelID SiteID, LabelName SiteName 
FROM dbo.view_kpi_labels_LC (NOLOCK)
WHERE ResellerID = @GroupID AND IsKPIActive = 1
ORDER BY SiteID 

SET NOCOUNT OFF
GRANT EXECUTE ON [dbo].[LRF_Get_LicenseesByGroup_KPIs_LC] TO [bodbAdminNet]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LRF_Get_LicenseesByGroup_KPIs_LC] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[LRF_Get_LicenseesByGroup_KPIs_LC] TO [bodbLicenseeNet]
GO 
