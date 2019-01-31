
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.AffAdmin_GroupInfo_Delete    Script Date: 1/21/2019 4:30:00 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_GroupInfo_Delete    Script Date: 12/22/2015 4:36:37 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_GroupInfo_Delete    Script Date: 12/8/2015 09:52:32 ******/
CREATE PROCEDURE [dbo].[AffAdmin_GroupInfo_Delete]
(
	@GroupID	INT
)
/*
	Created: 20151111@Victor
	DB: DBLIC/bodb_licensee
	Remark: Delete GroupInfo by GroupID
	Revision:
*/
AS
BEGIN
	DELETE FROM dbo.Aff_GroupInfo WHERE GroupID = @GroupID
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[AffAdmin_GroupInfo_Delete] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[AffAdmin_GroupInfo_Delete] TO [vnteam]
GO 
