
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OAS_Users_Logout    Script Date: 1/21/2019 4:30:10 AM ******/
/****** Object:  Stored Procedure dbo.OAS_Users_Logout    Script Date: 3/13/2012 4:06:03 PM ******/
CREATE PROCEDURE [dbo].[OAS_Users_Logout]
	@On_UserID INT
AS

/*
 *	Created by	: [20111512@Kos]
 *	Task		: OAS user logout
 *	DB			: DB052.bodb_Licensee
 *	Revisions	:
 *
 *	Param's Explanation:  
 *		- @On_UserID		: User ID
 */

SET NOCOUNT ON

DELETE 
FROM OAS_OnUser 
WHERE on_userid = @On_UserID
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OAS_Users_Logout] TO [bodbAdminNet]
GO 
