
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_UserSelByUserName    Script Date: 1/21/2019 4:30:08 AM ******/
/****** Object:  Stored Procedure dbo.LA_UserSelByUserName    Script Date: 22/10/2014 14:51:12 PM ******/

/****** Object:  Stored Procedure dbo.LA_UserSelByUserName    Script Date: 15/10/2014 15:24:29 PM ******/
/****** Object:  Stored Procedure dbo.OA_UsersGetAll    Script Date: 10/21/2011 7:48:20 PM ******/
CREATE PROCEDURE [dbo].[LA_UserSelByUserName]
	@Username	 varchar(50),
	@GroupID	 int = 0
AS
/*  
 * Created: 20140820@Florent
 * Task : get user by User Name
 * DB: DB052.bodb_Licensee  
 *  
 * Revisions:   
    - 20141022@Florent: add column 'UserSalt'
 Param's Explanation:
	
*/
SET NOCOUNT ON

SET @Username = LTRIM(RTRIM(ISNULL(@Username,'')))

BEGIN
	SELECT
		u.UserID,
		u.UserName,
		u.UserSalt,
		u.DisplayName,		
		u.StatusID IsActive,
		u.CreatedDate,
		u.ModifiedDate,
		u.Creator,
		isnull(p.username,'') AS CreatorName,
		g.GroupID,
		g.GroupName
	FROM
		dbo.LA_User AS u WITH(NOLOCK)
		INNER JOIN dbo.LA_Group AS g WITH(NOLOCK) ON u.GroupID=g.GroupID
		LEFT JOIN dbo.LA_User AS p WITH (NOLOCK) ON u.creator = p.userID
	WHERE	
		((@GroupID=0) OR (@GroupID<>0 AND g.GroupID = @GroupID))
		AND ((@Username='') OR (@Username<>'' AND u.Username = @Username))
	ORDER BY g.GroupName
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_UserSelByUserName] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_UserSelByUserName] TO [vnteam]
GO 
