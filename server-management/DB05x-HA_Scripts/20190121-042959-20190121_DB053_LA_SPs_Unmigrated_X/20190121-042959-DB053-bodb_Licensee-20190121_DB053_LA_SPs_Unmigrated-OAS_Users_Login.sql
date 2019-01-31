
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OAS_Users_Login    Script Date: 1/21/2019 4:30:10 AM ******/
/****** Object:  Stored Procedure dbo.OAS_Users_Login    Script Date: 3/22/2012 5:16:58 PM ******/

CREATE PROCEDURE [dbo].[OAS_Users_Login]	
	@Username VARCHAR(50)
AS

/*
 *	Created by	: [20111512@Kos]
 *	Task		: Get user and password for the login user
 *	DB			: DB052.bodb_Licensee
 *	Revisions	:
 *
 *	Param's Explanation:  
 *		- @Username		: Username
 */

SET NOCOUNT ON

SELECT UserID,
	Username,
	UserPwd,
	UserSalt,
	DisplayName,
	Role,
	IsActive,
	IsTest
FROM dbo.OAS_Users WITH (NOLOCK)
WHERE Username = @Username
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OAS_Users_Login] TO [bodbAdminNet]
GO 
