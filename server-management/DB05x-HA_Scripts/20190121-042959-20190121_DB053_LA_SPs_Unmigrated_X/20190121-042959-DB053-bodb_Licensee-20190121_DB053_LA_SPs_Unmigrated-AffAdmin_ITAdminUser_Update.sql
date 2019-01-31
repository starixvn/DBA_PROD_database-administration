
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.AffAdmin_ITAdminUser_Update    Script Date: 1/21/2019 4:30:01 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_ITAdminUser_Update    Script Date: 12/22/2015 4:36:45 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_ITAdminUser_Update    Script Date: 12/8/2015 09:52:32 ******/
CREATE PROCEDURE [dbo].[AffAdmin_ITAdminUser_Update]
(
	@UserID		INT,
	@UserPwd	VARCHAR(50) = NULL,
	@UserSalt	VARCHAR(50) = NULL,
	@FirstName	NVARCHAR(50) = NULL,
	@LastName	NVARCHAR(50) = NULL,
	@Status		VARCHAR(30) = NULL
)
/*
	Created: 20151125@Victor
	DB: DBLIC/bodb_licensee
	Remark: Update IT Admin user
	Revision:
*/
AS
BEGIN
	UPDATE Users WITH (ROWLOCK, UPDLOCK) 
	SET UserPwd = ISNULL(@UserPwd, UserPwd),
		UserSalt = ISNULL(@UserSalt, UserSalt),
		FirstName = ISNULL(@FirstName, FirstName),
		LastName = ISNULL(@LastName, LastName),
		[Status] = ISNULL(@Status, [Status])
	WHERE UserID = @UserID

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[AffAdmin_ITAdminUser_Update] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[AffAdmin_ITAdminUser_Update] TO [vnteam]
GO 
