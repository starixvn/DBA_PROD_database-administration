
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.AffAdmin_GroupInfo_Update    Script Date: 1/21/2019 4:30:00 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_GroupInfo_Update    Script Date: 12/22/2015 4:36:39 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_GroupInfo_Update    Script Date: 12/8/2015 09:52:32 ******/
CREATE PROCEDURE [dbo].[AffAdmin_GroupInfo_Update]
(
	@GroupID	INT,
	@GroupName	NVARCHAR(50) = NULL,
	@GroupDesc	NVARCHAR(50) = NULL,
	@ModifyDate	DATETIME = NULL,
	@DisplayOrder	TINYINT = NULL,
	@Creator	INT = NULL
)
/*
	Created: 20151112@Victor
	DB: DBLIC/bodb_licensee
	Remark: Update GroupInfo
	Revision:
*/
AS
BEGIN
	SELECT @ModifyDate = ISNULL(@ModifyDate, GETDATE())

	UPDATE Aff_GroupInfo WITH (ROWLOCK, UPDLOCK)
	SET GroupName = ISNULL(@GroupName,GroupName),
		GroupDesc = ISNULL(@GroupDesc, GroupDesc),
		ModifyDate = @ModifyDate,
		DisplayOrder = ISNULL(@DisplayOrder, DisplayOrder),
		Creator = ISNULL(@Creator, Creator)
	WHERE GroupID = @GroupID
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[AffAdmin_GroupInfo_Update] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[AffAdmin_GroupInfo_Update] TO [vnteam]
GO 
