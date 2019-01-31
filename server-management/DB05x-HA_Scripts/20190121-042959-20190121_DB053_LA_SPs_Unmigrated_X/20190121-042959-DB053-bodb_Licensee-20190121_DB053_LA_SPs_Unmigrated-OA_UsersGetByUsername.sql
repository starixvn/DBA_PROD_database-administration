
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_UsersGetByUsername    Script Date: 1/21/2019 4:30:10 AM ******/
/****** Object:  Stored Procedure dbo.OA_UsersGetByUsername    Script Date: 11/26/2013 2:53:51 AM ******/
/****** Object:  Stored Procedure dbo.OA_UsersGetByUsername    Script Date: 11/25/2013 12:44:49 PM ******/
CREATE PROCEDURE [dbo].[OA_UsersGetByUsername]	
	@Username varchar(50)
AS

/*
	Created by: [20111004@Henry]
	Task: Get user information
	DB: DBLIC.bodb_Licensee
	Revisions:
		20131122@Jim: add more creatorname,GroupName column in result 
*/

SET NOCOUNT ON

	SELECT u.UserID
		,u.GroupID
		,u.Username
		,u.UserPwd
		,u.DisplayName
		,u.UserSalt
		,u.IsActive
		,u.Creator
		,u.CreatedDate
		,u.ModifiedDate
		,g.GroupName
		,pu.Username as CreatorName
	FROM dbo.OA_Users u WITH(NOLOCK)
	INNER JOIN dbo.OA_Groups g WITH (NOLOCK) ON u.GroupID = g.GroupID
	INNER JOIN dbo.OA_Users pu WITH (NOLOCK) ON u.Creator = pu.UserID
	WHERE u.Username=@Username
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_UsersGetByUsername] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[OA_UsersGetByUsername] TO [vnteam]
GO 
