
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_UsersGetbyGroupID    Script Date: 1/21/2019 4:30:10 AM ******/
/****** Object:  Stored Procedure dbo.OA_UsersGetbyGroupID    Script Date: 10/21/2011 7:48:20 PM ******/
CREATE PROCEDURE [dbo].[OA_UsersGetbyGroupID]
	@GroupID int	
AS
/*  
 * Created: 20110915@Elly
 * Task : get all users of a group
 * DB: DB052.bodb_Licensee  
 *  
 * Revisions:   
 Param's Explanation:
	
*/
BEGIN
SET NOCOUNT ON

	SELECT
		u.UserID
		,u.UserName
		,u.DisplayName
		,u.IsActive
		,u.Creator
		,u1.Username as CreatorName
		,u.CreatedDate
	FROM dbo.OA_Users AS u WITH(NOLOCK) 	
	INNER JOIN dbo.OA_Users AS u1 WITH (NOLOCK) ON u.Creator = u1.UserID			
	WHERE u.GroupID=@GroupID
		--AND IsActive=1	
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_UsersGetbyGroupID] TO [bodbAdminNet]
GO 
