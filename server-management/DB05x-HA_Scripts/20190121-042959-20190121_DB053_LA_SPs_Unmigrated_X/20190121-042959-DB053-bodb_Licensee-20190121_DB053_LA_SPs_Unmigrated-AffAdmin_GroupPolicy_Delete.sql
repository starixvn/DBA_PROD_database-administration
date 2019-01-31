
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.AffAdmin_GroupPolicy_Delete    Script Date: 1/21/2019 4:30:01 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_GroupPolicy_Delete    Script Date: 12/22/2015 4:36:40 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_GroupPolicy_Delete    Script Date: 12/8/2015 09:52:32 ******/
CREATE PROCEDURE [dbo].[AffAdmin_GroupPolicy_Delete]
(
	@GroupID	INT
)
/*
	Created: 20151111@Victor
	DB: DBLIC/bodb_licensee
	Remark: Delete GroupPolicy by GroupID
	Revision:
*/
AS
BEGIN
	DELETE FROM dbo.Aff_GroupPolicy WHERE GroupID = @GroupID
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[AffAdmin_GroupPolicy_Delete] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[AffAdmin_GroupPolicy_Delete] TO [vnteam]
GO 
