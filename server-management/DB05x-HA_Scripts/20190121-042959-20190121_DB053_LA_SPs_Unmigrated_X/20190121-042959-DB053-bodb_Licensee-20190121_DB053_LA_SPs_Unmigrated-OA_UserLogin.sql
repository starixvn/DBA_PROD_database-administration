
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_UserLogin    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_UserLogin    Script Date: 10/21/2011 7:48:20 PM ******/
CREATE PROCEDURE [dbo].[OA_UserLogin]	
	@UserName varchar(50)
AS

/*
	Created by: [20110919@Elly]
	Task: Get user and password for the login user
	DB: DB052.bodb_Licensee
	Revisions:
*/

SET NOCOUNT ON

	SELECT UserID
		,UserName
		,UserPwd
		,UserSalt
		,DisplayName
		,GroupID
		,IsActive
	FROM dbo.OA_Users WITH(NOLOCK)
	WHERE UserName=@UserName
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_UserLogin] TO [bodbAdminNet]
GO 
