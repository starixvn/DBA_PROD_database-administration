
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LRF_Get_GroupAll_KPIs_2012    Script Date: 1/21/2019 4:30:08 AM ******/
/****** Object:  Stored Procedure dbo.LRF_Get_GroupAll_KPIs_2012    Script Date: 1/24/2013 11:28:28 AM ******/
 -- a sample testcase : exec LRF_Get_GroupAll_KPIs
CREATE PROCEDURE [dbo].[LRF_Get_GroupAll_KPIs_2012]
AS
/*
    Created: 20130124@Don
    Task: 
    DB: DB052.bodb_Licensee

    Revisions:
        
    Param's Explanation:

*/
SET NOCOUNT ON  
  
SELECT 1 AS GroupId, 'Deposit Licensees'   AS GroupName

UNION  
SELECT 2, 'Credit Licensees'

UNION  
SELECT 3, 'Starlit'



SET NOCOUNT OFF
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LRF_Get_GroupAll_KPIs_2012] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[LRF_Get_GroupAll_KPIs_2012] TO [bodbLicenseeNet]
GO 
