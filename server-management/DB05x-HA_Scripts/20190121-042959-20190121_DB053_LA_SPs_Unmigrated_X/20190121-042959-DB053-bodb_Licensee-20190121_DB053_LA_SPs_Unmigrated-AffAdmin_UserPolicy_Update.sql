
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.AffAdmin_UserPolicy_Update    Script Date: 1/21/2019 4:30:01 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_UserPolicy_Update    Script Date: 12/22/2015 4:36:50 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_UserPolicy_Update    Script Date: 12/8/2015 09:52:32 ******/
CREATE PROCEDURE [dbo].[AffAdmin_UserPolicy_Update]
(
	@UserID		INT,
	@LicenseeID INT,
	@FunctionID	INT,
	@Policy		TINYINT,
	@ModifyDate	DATETIME = NULL,
	@Creator	INT = NULL
)
/*
	Created: 20151117@Victor
	DB: DBLIC/bodb_licensee
	Remark: Update UserPolicy
	Revision:
*/
AS
BEGIN
	SELECT @ModifyDate = ISNULL(@ModifyDate, GETDATE())

	UPDATE Aff_UserPolicy WITH (ROWLOCK, UPDLOCK)
	SET Policy = @Policy,
		ModifyDate = @ModifyDate,
		Creator = ISNULL(@Creator, Creator)
	WHERE UserID = @UserID
		AND FunctionID = @FunctionID
		AND LicenseeID = @LicenseeID
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[AffAdmin_UserPolicy_Update] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[AffAdmin_UserPolicy_Update] TO [vnteam]
GO 
