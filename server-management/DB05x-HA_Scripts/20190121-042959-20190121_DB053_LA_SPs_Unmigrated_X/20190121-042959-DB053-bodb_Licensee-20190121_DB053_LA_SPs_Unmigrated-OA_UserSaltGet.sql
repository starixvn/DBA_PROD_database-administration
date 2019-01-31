
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_UserSaltGet    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_UserSaltGet    Script Date: 10/21/2011 7:48:20 PM ******/
CREATE PROCEDURE [dbo].[OA_UserSaltGet]  
 @UserName varchar(50)
AS  
/*  
 * Created: 201110914@Elly
 * Task : Sel Pwd Salt
 * DB: DB052.bodb_Licensee  
 *  
 * Revisions:     
*/  
BEGIN  
SET NOCOUNT ON;  

	SELECT UserSalt  
	FROM dbo.OA_Users WITH(NOLOCK)  
	WHERE Username = @UserName  

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_UserSaltGet] TO [bodbAdminNet]
GO 
