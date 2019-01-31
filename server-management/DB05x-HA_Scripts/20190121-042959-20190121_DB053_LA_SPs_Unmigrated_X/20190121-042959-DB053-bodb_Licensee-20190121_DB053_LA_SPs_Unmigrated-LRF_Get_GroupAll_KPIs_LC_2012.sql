
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LRF_Get_GroupAll_KPIs_LC_2012    Script Date: 1/21/2019 4:30:08 AM ******/
/****** Object:  Stored Procedure dbo.LRF_Get_GroupAll_KPIs_LC_2012    Script Date: 1/29/2013 4:03:49 PM ******/

CREATE PROCEDURE [dbo].[LRF_Get_GroupAll_KPIs_LC_2012]
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

SELECT 1 AS GroupId, 'Deposit Licensees' AS GroupName, 2 AS GroupType

UNION  
SELECT 2, 'Credit Licensees', 1

SET NOCOUNT OFF
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LRF_Get_GroupAll_KPIs_LC_2012] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[LRF_Get_GroupAll_KPIs_LC_2012] TO [bodbLicenseeNet]
GO 
