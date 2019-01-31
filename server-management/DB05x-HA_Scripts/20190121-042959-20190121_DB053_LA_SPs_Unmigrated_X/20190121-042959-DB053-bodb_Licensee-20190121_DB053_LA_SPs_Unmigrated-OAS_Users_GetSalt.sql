
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OAS_Users_GetSalt    Script Date: 1/21/2019 4:30:10 AM ******/
/****** Object:  Stored Procedure dbo.OAS_Users_GetSalt    Script Date: 3/13/2012 4:06:03 PM ******/
   
  
CREATE PROCEDURE [dbo].[OAS_Users_GetSalt]    
 @Username VARCHAR(50)  
AS    
  
/*  
 * Created by : [20111512@Kos]  
 * Task  : Get user salt  
 * DB   : DB052.bodb_Licensee  
 * Revisions :  
 *  
 * Param's Explanation:    
 *  - @Username  : Username  
 */  
  
SET NOCOUNT ON  
  
SELECT UserSalt    
FROM dbo.OAS_Users WITH (NOLOCK)    
WHERE Username = @Username
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OAS_Users_GetSalt] TO [bodbAdminNet]
GO 
