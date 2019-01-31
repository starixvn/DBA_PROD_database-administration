
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Aff_UserLogout    Script Date: 1/21/2019 4:30:00 AM ******/
/****** Object:  Stored Procedure dbo.Aff_UserLogout    Script Date: 12/22/2015 4:36:57 AM ******/
/****** Object:  Stored Procedure dbo.Aff_UserLogout    Script Date: 12/8/2015 09:52:32 ******/
CREATE PROCEDURE [dbo].[Aff_UserLogout]
	@On_UserID INT
AS
SET NOCOUNT ON

/*
	Created: 20151013@Victor
	Task: User Logout
	DB: DBLIC/bodb_Licensee
	Original 
	
	Revisions:

*/

DELETE FROM Aff_On_User WHERE on_userid = @On_UserID
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[Aff_UserLogout] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[Aff_UserLogout] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Aff_UserLogout] TO [bodbLicenseeNet]
GO 
