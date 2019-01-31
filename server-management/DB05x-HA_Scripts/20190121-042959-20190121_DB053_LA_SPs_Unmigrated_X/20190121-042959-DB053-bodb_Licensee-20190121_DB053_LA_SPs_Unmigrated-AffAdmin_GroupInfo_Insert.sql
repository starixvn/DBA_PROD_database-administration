
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.AffAdmin_GroupInfo_Insert    Script Date: 1/21/2019 4:30:00 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_GroupInfo_Insert    Script Date: 12/22/2015 4:36:38 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_GroupInfo_Insert    Script Date: 12/8/2015 09:52:32 ******/
CREATE PROCEDURE [dbo].[AffAdmin_GroupInfo_Insert]
(
	@LicenseeID	INT,
	@GroupName	NVARCHAR(50),
	@GroupDesc	NVARCHAR(50),
	@CreateDate	DATETIME = NULL,
	@ModifyDate	DATETIME = NULL,
	@DisplayOrder	TINYINT = 1,
	@Creator	INT = NULL,
	@GroupID	INT = NULL OUTPUT
)
/*
	Created: 20151112@Victor
	DB: DBLIC/bodb_licensee
	Remark: Insert GroupInfo
	Revision:
*/
AS
BEGIN
	SELECT @CreateDate = ISNULL(@CreateDate, GETDATE()),
		@ModifyDate = ISNULL(@ModifyDate, GETDATE())

	INSERT INTO Aff_GroupInfo (LicenseeID, GroupName, GroupDesc, CreateDate, ModifyDate, DisplayOrder, Creator)
	SELECT @LicenseeID, @GroupName, @GroupDesc, @CreateDate, @ModifyDate, @DisplayOrder, @Creator

	SELECT @GroupID = SCOPE_IDENTITY()
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[AffAdmin_GroupInfo_Insert] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[AffAdmin_GroupInfo_Insert] TO [vnteam]
GO 
