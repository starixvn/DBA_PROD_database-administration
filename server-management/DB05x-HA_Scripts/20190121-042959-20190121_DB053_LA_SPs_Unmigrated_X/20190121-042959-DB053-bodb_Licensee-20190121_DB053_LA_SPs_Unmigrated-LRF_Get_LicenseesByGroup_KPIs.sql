
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LRF_Get_LicenseesByGroup_KPIs    Script Date: 1/21/2019 4:30:08 AM ******/
/****** Object:  Stored Procedure dbo.LRF_Get_LicenseesByGroup_KPIs    Script Date: 7/19/2012 9:28:40 AM ******/

CREATE PROCEDURE [dbo].[LRF_Get_LicenseesByGroup_KPIs]
    @GroupID int
AS
/*
    Created: 20111012@Don
    Task: 
    DB: DB052.bodb_Licensee

    Revisions:
        - 20120305@Don: Adapt for restructuring Licensees and Labels/Sites
        - 20120518@Don: Include SunGame licensee to result
		- 20180518@Jim: add more IsKPIActive=1 condition 
		- 20120709@Don: use object view_kpi_labels instead of view_all_labels
        
    Param's Explanation:

*/
SET NOCOUNT ON

SELECT LabelID SiteID, LabelName SiteName 
FROM dbo.view_kpi_labels (NOLOCK)
WHERE ResellerID = @GroupID AND IsKPIActive = 1
ORDER BY SiteID 

SET NOCOUNT OFF
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LRF_Get_LicenseesByGroup_KPIs] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[LRF_Get_LicenseesByGroup_KPIs] TO [bodbLicenseeNet]
GO 
