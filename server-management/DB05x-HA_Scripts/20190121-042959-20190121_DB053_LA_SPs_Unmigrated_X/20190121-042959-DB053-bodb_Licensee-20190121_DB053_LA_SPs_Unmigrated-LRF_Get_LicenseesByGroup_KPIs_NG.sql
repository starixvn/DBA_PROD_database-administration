
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LRF_Get_LicenseesByGroup_KPIs_NG    Script Date: 1/21/2019 4:30:08 AM ******/

/****** Object:  Stored Procedure dbo.LRF_Get_LicenseesByGroup_KPIs_NG    Script Date: 10/30/2012 10:48:09 AM ******/


CREATE PROCEDURE [dbo].[LRF_Get_LicenseesByGroup_KPIs_NG]
    @GroupID int
AS
/*
    Created: 20121025@Jim
    Task: 
    DB: DB052.bodb_Licensee
	Original:LRF_Get_LicenseesByGroup_KPIs

    Revisions:
      
        
    Param's Explanation:

*/
SET NOCOUNT ON

SELECT LabelID SiteID, LabelName SiteName 
FROM dbo.view_kpi_labels_NG (NOLOCK)
WHERE ResellerID = @GroupID AND IsKPIActive = 1
ORDER BY SiteID 

SET NOCOUNT OFF


GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LRF_Get_LicenseesByGroup_KPIs_NG] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[LRF_Get_LicenseesByGroup_KPIs_NG] TO [bodbLicenseeNet]
GO 
