
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Lrf_UserLogout_mnl    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.Lrf_UserLogout_mnl    Script Date: 4/3/2017 12:52:40 PM ******/

CREATE PROCEDURE dbo.Lrf_UserLogout_mnl
	@On_UserID int
AS
SET NOCOUNT ON

/*
	Task: User Logout
	DB: DB052.bodb_Licensee
	Original 
	
	Revisions:
		- 20101208@Johnny

*/

--Delete from On_User where on_userid = @On_UserID
RETURN
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[Lrf_UserLogout_mnl] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[Lrf_UserLogout_mnl] TO [bodbLicenseeNet]
GO 
