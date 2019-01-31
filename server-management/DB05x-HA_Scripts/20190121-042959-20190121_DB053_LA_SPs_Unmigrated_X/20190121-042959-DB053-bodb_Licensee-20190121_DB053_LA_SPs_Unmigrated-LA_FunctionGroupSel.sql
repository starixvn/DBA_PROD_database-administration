
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_FunctionGroupSel    Script Date: 1/21/2019 4:30:03 AM ******/
/****** Object:  Stored Procedure dbo.LA_FunctionGroupSel    Script Date: 9/9/2015 2:59:48 PM ******/

CREATE PROCEDURE [dbo].[LA_FunctionGroupSel]
	@FunctionId INT
AS
/*	Header:
	Created:2015.09.04 - Bravo.Tran
	Task :	Enhance Manage Function 
	DB:		DB052.bodb_Licensee
   
	Revisions: 
		+ 20150904@Bravo: get function groups
*/
/*	Example:
	USE bodb_licensee
		EXEC [LA_FunctionGroupSel] 1
*/
BEGIN
	SET NOCOUNT ON
	
	SELECT f.GroupID
	FROM dbo.LA_GroupFunction f		
	WHERE f.FunctionID = @FunctionId 		
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_FunctionGroupSel] TO [bodbAdminNet]
GO 
