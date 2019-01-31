
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Licensee_UserSaltSel    Script Date: 1/21/2019 4:30:08 AM ******/
CREATE PROCEDURE [dbo].[Licensee_UserSaltSel]  
 @UserName varchar(50)
AS  
/*  
 * Created: 20101203@Anders 
 * Task : Sel Pwd Salt
 * DB: DB052.bodb_Licensee  
 *  
 * Revisions:     
*/  
BEGIN  
SET NOCOUNT ON;  

	SELECT TOP 1 UserSalt  
	FROM dbo.Users WITH(NOLOCK)  
	WHERE Username = @UserName  

END

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[Licensee_UserSaltSel] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[Licensee_UserSaltSel] TO [bodbLicenseeNet]
GO 
