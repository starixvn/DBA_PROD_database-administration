
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_WriteLog_UserLog_RunSP    Script Date: 1/21/2019 4:30:10 AM ******/
/****** Object:  Stored Procedure dbo.OA_WriteLog_UserLog_RunSP    Script Date: 10/21/2011 7:48:21 PM ******/
CREATE PROCEDURE [dbo].[OA_WriteLog_UserLog_RunSP]  
  @UserID INT,  
  @CustID INT = 0,  
  @SPName VARCHAR(50)= NULL, -- USE FOR OLD FORMAT AND WILL REMOVE LATER  
  @Doing VARCHAR(4000) = NULL, --  
  @ActionID INT = NULL,   
  @TrackingValue nvarchar(MAX)= NULL,  
  @TrackingValue2 nvarchar(MAX) = NULL,  
  @Duration INT = NULL  
    
/* Created: 20110914@Elly copies SP from CustomerLog
    Task: ViewLog function 331  
    DB: bodb_Licensee 
  
 Revisions:  
   
  
Param's Explaination:       
 - @UserID: UserId perform this action  
 - @CustID:   
 - @ActionID: Log action Id  
 - @TrackingValue: xml string format  
*/  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
SET NOCOUNT ON;      
INSERT INTO dbo.OA_UserLog_RunSP( UserID,   
        CustID,   
        --SPName,  
        Doing,  
        ActionID,   
        TrackingValue,  
        TrackingValue2,  
        Duration  
        )  
SELECT  @UserID,   
        @CustID,   
        --@SPName,  
        @Doing,  
        ActionId,   
        @TrackingValue,  
        @TrackingValue2,  
        @Duration  
FROM dbo.OA_LogAction WITH(NOLOCK) 
WHERE SPName=@SPName
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_WriteLog_UserLog_RunSP] TO [bodbAdminNet]
GO 
