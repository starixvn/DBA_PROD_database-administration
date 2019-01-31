
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_UserLogout    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_UserLogout    Script Date: 10/21/2011 7:48:20 PM ******/
CREATE PROCEDURE [dbo].[OA_UserLogout]
	@On_UserID INT
AS
SET NOCOUNT ON

/*
	Creator:  20111020@Henry
	Task: OA User Logout
	DB: DB052.bodb_Licensee

*/

Delete from OA_OnUser WHERE on_userid = @On_UserID
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_UserLogout] TO [bodbAdminNet]
GO 
