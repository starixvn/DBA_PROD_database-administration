
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.AffAdmin_UserPolicy_Insert    Script Date: 1/21/2019 4:30:01 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_UserPolicy_Insert    Script Date: 12/22/2015 4:36:49 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_UserPolicy_Insert    Script Date: 12/8/2015 09:52:32 ******/
CREATE PROCEDURE [dbo].[AffAdmin_UserPolicy_Insert]
(
	@UserID			INT,
	@LicenseeID		INT,
	@FunctionID		INT,
	@Policy			TINYINT,
	@CreateDate		DATETIME = NULL,
	@ModifyDate		DATETIME = NULL,
	@Creator		INT = NULL
)
/*
	Created: 20151118@Victor
	DB: DBLIC/bodb_licensee
	Remark: Insert UserPolicy
	Revision:
*/
AS
BEGIN
	SELECT @CreateDate = ISNULL(@CreateDate, GETDATE()),
		@ModifyDate = ISNULL(@ModifyDate, GETDATE())
	
	INSERT INTO Aff_UserPolicy (UserID, LicenseeID, FunctionID, Policy, CreateDate, ModifyDate, Creator)
	SELECT @UserID, @LicenseeID, @FunctionID, @Policy, @CreateDate, @ModifyDate, @Creator

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[AffAdmin_UserPolicy_Insert] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[AffAdmin_UserPolicy_Insert] TO [vnteam]
GO 
