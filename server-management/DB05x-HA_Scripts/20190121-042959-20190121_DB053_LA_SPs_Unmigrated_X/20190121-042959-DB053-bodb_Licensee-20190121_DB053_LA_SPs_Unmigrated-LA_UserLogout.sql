
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_UserLogout    Script Date: 1/21/2019 4:30:07 AM ******/
/****** Object:  Stored Procedure dbo.LA_UserLogout    Script Date: 15/10/2014 16:43:23 PM ******/
/****** Object:  Stored Procedure dbo.OA_UserLogout    Script Date: 10/21/2011 7:48:20 PM ******/
CREATE PROCEDURE [dbo].[LA_UserLogout]
	@On_UserID INT
AS
/*
	Creator:  20140820@Florent
	Task: OA User Logout
	DB: DB052.bodb_Licensee

*/

SET NOCOUNT ON
BEGIN
    DELETE FROM dbo.LA_OnUser WHERE on_userid = @On_UserID
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_UserLogout] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_UserLogout] TO [vnteam]
GO 
