
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OAS_Users_GetAll    Script Date: 1/21/2019 4:30:10 AM ******/
/****** Object:  Stored Procedure dbo.OAS_Users_GetAll    Script Date: 3/22/2012 5:16:57 PM ******/

   
CREATE PROCEDURE [dbo].[OAS_Users_GetAll]   
AS  
  
/*  
 * Created by : [20111512@Kos]  
 * Task  : Get all users  
 * DB   : DB052.bodb_Licensee  
 * Revisions :  
 */  
  
SET NOCOUNT ON  
  
SELECT  
	 u.UserID,
	 u.Username,
	 u.DisplayName,
	 u.Role,
	 u.IsActive,
	 u.IsTest,
	 u.CreatedDate,
	 u.ModifiedDate,
	 u.Creator,
	 ISNULL(p.Username, '') AS CreatorName  
FROM  
	 dbo.OAS_Users AS u WITH (NOLOCK)  
	 LEFT JOIN   
	 dbo.OAS_Users AS p WITH (NOLOCK)   
	 ON u.Creator = p.UserID
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OAS_Users_GetAll] TO [bodbAdminNet]
GO 
