
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_UsersGetByUserID    Script Date: 1/21/2019 4:30:10 AM ******/
/****** Object:  Stored Procedure dbo.OA_UsersGetByUserID    Script Date: 10/21/2011 7:48:20 PM ******/
CREATE PROCEDURE [dbo].[OA_UsersGetByUserID]	
	@UserID int	
AS

/*
	Created by: [20110919@Elly]
	Task: Get user information
	DB: DB052.bodb_Licensee
	Revisions:
*/

SET NOCOUNT ON

	SELECT u.UserID
		,u.GroupID
		,u.Username
		,u.DisplayName
		,u.IsActive
		,u.Creator
		,u.CreatedDate
		,u.ModifiedDate
		,g.GroupName
		,pu.Username as CreatorName
	FROM dbo.OA_Users u WITH(NOLOCK)
	INNER JOIN dbo.OA_Groups g WITH (NOLOCK) ON u.GroupID = g.GroupID
	INNER JOIN dbo.OA_Users pu WITH (NOLOCK) ON u.Creator = pu.UserID
	WHERE u.UserID=@UserID
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_UsersGetByUserID] TO [bodbAdminNet]
GO 
