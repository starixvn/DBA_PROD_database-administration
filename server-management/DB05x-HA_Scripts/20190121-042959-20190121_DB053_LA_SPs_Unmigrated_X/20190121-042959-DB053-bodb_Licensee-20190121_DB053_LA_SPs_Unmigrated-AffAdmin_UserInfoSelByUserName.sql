
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.AffAdmin_UserInfoSelByUserName    Script Date: 1/21/2019 4:30:01 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_UserInfoSelByUserName    Script Date: 12/7/2016 2:04:54 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_UserInfoSelByUserName    Script Date: 12/6/2016 5:13:35 PM ******/
CREATE PROCEDURE [dbo].[AffAdmin_UserInfoSelByUserName] 
  @UserName NVARCHAR(50)  
 ,@LicenseeId INT = 0  
 ,@isInternal BIT = 0  
AS  
/*  
 Created by: 20151204@Francis  
 Task: Get Affiliate Admin User Detail for SSO  
 DB: DB052.bodb_Licensee  
 Revisions:
 20161206Alex: Add param @isInternal
*/  
SET NOCOUNT ON  
  
SELECT DISTINCT  u.UserID  
   ,u.UserName  
   ,u.FirstName  
   ,u.LastName  
   ,u.UserPwd AS password  
   ,u.STATUS  
   ,u.isInternal AS IsInternal  
   ,u.UserSalt  
FROM dbo.Users u(NOLOCK)  
     INNER JOIN dbo.Aff_LicenseeUser l(NOLOCK) ON u.UserID = l.UserID  
WHERE u.Username = @UserName  
 AND (  
  @LicenseeId = 0  
  OR (  
   @LicenseeId <> 0  
   AND l.LicenseeID = @LicenseeId  
   )  
  )  
 AND u.isInternal = @isInternal
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[AffAdmin_UserInfoSelByUserName] TO [bodbLicenseeNet]
GO 
