
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_UsersGetAll    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_UsersGetAll    Script Date: 10/21/2011 7:48:20 PM ******/
CREATE PROCEDURE [dbo].[OA_UsersGetAll]
	@UserID int	,
	@Username varchar(50) = '',
	@GroupID int = 0
AS
/*  
 * Created: 20110915@Elly
 * Task : get all active users for admin role
 * DB: DB052.bodb_Licensee  
 *  
 * Revisions:   
	- 20111004@Henry: add @username and @GroupID for more filter
 Param's Explanation:
	
*/
SET NOCOUNT ON

SET @Username = LTRIM(RTRIM(ISNULL(@Username,'')))

IF EXISTS(SELECT 1 
		FROM dbo.OA_Functions AS f WITH(NOLOCK) 
			INNER JOIN (SELECT FunctionID
					FROM dbo.OA_UserFunctions WITH(NOLOCK)
					WHERE UserID=@UserID
					
					UNION ALL
					
					SELECT FunctionID
					FROM dbo.OA_GroupFunctions AS g WITH(NOLOCK)
						INNER JOIN dbo.OA_Users AS u WITH(NOLOCK) ON g.GroupID=u.GroupID AND u.UserID=@UserID					
				) AS t ON t.FunctionID=f.FunctionID AND FunctionName='Manage User')
BEGIN
	SELECT
		u.UserID,
		u.UserName,
		u.DisplayName,		
		u.IsActive,
		u.CreatedDate,
		u.ModifiedDate,
		u.Creator,
		isnull(p.username,'') AS CreatorName,
		g.GroupID,
		g.GroupName
	FROM
		dbo.OA_Users AS u WITH(NOLOCK)
		INNER JOIN dbo.OA_Groups AS g WITH(NOLOCK) ON u.GroupID=g.GroupID
		LEFT JOIN dbo.OA_Users AS p WITH (NOLOCK) ON u.creator = p.userID
	WHERE	
		((@GroupID=0) OR (@GroupID<>0 AND g.GroupID = @GroupID))
		AND ((@Username='') OR (@Username<>'' AND u.Username LIKE '%' + @Username +'%' ))
	ORDER BY g.GroupName
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_UsersGetAll] TO [bodbAdminNet]
GO 
