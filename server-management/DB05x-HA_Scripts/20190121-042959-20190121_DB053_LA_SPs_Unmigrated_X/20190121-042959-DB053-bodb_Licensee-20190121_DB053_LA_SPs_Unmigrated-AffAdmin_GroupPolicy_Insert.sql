
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.AffAdmin_GroupPolicy_Insert    Script Date: 1/21/2019 4:30:01 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_GroupPolicy_Insert    Script Date: 12/22/2015 4:36:42 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_GroupPolicy_Insert    Script Date: 12/8/2015 09:52:32 ******/
CREATE PROCEDURE [dbo].[AffAdmin_GroupPolicy_Insert]
(
	@GroupID		INT,
	@FunctionIDs	VARCHAR(1000),
	@Policy			TINYINT,
	@CreateDate		DATETIME = NULL,
	@ModifyDate		DATETIME = NULL,
	@Creator		INT = NULL
)
/*
	Created: 20151112@Victor
	DB: DBLIC/bodb_licensee
	Remark: Insert GroupPolicy
	Revision:
*/
AS
BEGIN
	DECLARE @FunctionList TABLE (FunctionID INT)
	INSERT INTO @FunctionList (FunctionID)
	SELECT CAST(val AS INT) FROM bodb02.dbo.Lrf_f_StringSplit(@FunctionIDs, ',')

	SELECT @CreateDate = ISNULL(@CreateDate, GETDATE()),
		@ModifyDate = ISNULL(@ModifyDate, GETDATE())
	
	INSERT INTO Aff_GroupPolicy (GroupID, FunctionID, Policy, CreateDate, ModifyDate, Creator)
	SELECT @GroupID, FunctionID, @Policy, @CreateDate, @ModifyDate, @Creator
	FROM @FunctionList

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[AffAdmin_GroupPolicy_Insert] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[AffAdmin_GroupPolicy_Insert] TO [vnteam]
GO 
