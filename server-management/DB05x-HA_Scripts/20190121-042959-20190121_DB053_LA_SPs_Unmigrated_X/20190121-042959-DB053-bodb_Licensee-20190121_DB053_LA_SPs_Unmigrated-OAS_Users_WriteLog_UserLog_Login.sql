
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OAS_Users_WriteLog_UserLog_Login    Script Date: 1/21/2019 4:30:10 AM ******/
/****** Object:  Stored Procedure dbo.OAS_Users_WriteLog_UserLog_Login    Script Date: 3/13/2012 4:06:05 PM ******/
   

CREATE PROCEDURE [dbo].[OAS_Users_WriteLog_UserLog_Login]  
 @UserID   INT,    
 @LoginIP  VARCHAR(50)  = '',   
 @DomainName  NVARCHAR(253) = NULL,  
 @Doing   VARCHAR(300),  
 @BrowserName NVARCHAR(255) = NULL,  
 @Platform  NVARCHAR(255) = NULL,  
 @CountryCode VARCHAR(64)  = NULL,  
 @Duration  INT    = NULL     
AS    
  
/*  
 * Created by : [20111512@Kos]  
 * Task  : Insert login count statistic    
 * DB   : DB052.bodb_Licensee  
 * Revisions :  
 *  
 * Param's Explanation:    
 *  - @UserID  : Main account login   
 *  - @LoginIP  : IP user login  
 *  - @DomainName : Domain user login    
 *  - @Doing  :   
 *  - @BrowserName : Browser name user using  
 *  - @Platform  : Platform user login  
 *  - @CountryCode : Country code user login  
 *  - @Duration  : Time process login  
 */  
    
SET NOCOUNT ON    
   
INSERT INTO OAS_UserLog_Login   
(  
 UserID,   
 IP,   
 LogDate,   
 Doing,  
 DomainName,  
 BrowserName,  
 Platform,  
 CountryCode,  
 Duration  
)  
VALUES  
(  
 @UserID,    
 @LoginIP,   
 GETDATE(),    
 @Doing,  
 @DomainName,  
 @BrowserName,  
 @Platform,  
 @CountryCode,  
 @Duration  
)
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OAS_Users_WriteLog_UserLog_Login] TO [bodbAdminNet]
GO 
