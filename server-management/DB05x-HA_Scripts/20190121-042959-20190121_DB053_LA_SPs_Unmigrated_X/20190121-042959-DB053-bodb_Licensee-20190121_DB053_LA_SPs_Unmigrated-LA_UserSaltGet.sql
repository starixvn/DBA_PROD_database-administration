
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_UserSaltGet    Script Date: 1/21/2019 4:30:08 AM ******/
/****** Object:  Stored Procedure dbo.LA_UserSaltGet    Script Date: 15/10/2014 16:43:23 PM ******/
/****** Object:  Stored Procedure dbo.OA_UserSaltGet    Script Date: 10/21/2011 7:48:20 PM ******/
CREATE PROCEDURE [dbo].[LA_UserSaltGet]  
 @UserName varchar(50)
AS  
/*  
 * Created: 20140822@Florent
 * Task : Sel Pwd Salt
 * DB: DB052.bodb_Licensee  
 *  
 * Revisions:     
*/  
BEGIN  
SET NOCOUNT ON;  

	SELECT UserSalt  
	FROM dbo.LA_User WITH(NOLOCK)  
	WHERE Username = @UserName  

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_UserSaltGet] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_UserSaltGet] TO [vnteam]
GO 
