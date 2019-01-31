
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_FunctionsGetByFunctionID    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_FunctionsGetByFunctionID    Script Date: 12/2/2011 10:33:03 AM ******/

CREATE PROCEDURE [dbo].[OA_FunctionsGetByFunctionID]	
	@FunctionID int
AS
/*  
 * Created: 20111125@Kos
 * Task : Get function information by function ID
 * DB: DB052.bodb_Licensee  
 *  
 * Revisions:     
*/  

SET NOCOUNT ON

SELECT	
	FunctionID
	,FunctionName
	,FunctionDesc
	,ParentID
	,ParentName
	,URL
	,CreatedDate
	,ModifiedDate
	,DisplayOrder
	,Creator
	,IsActive
	,FunctionKey	
FROM
	dbo.OA_Functions AS f WITH(NOLOCK)
WHERE f.FunctionID=@FunctionID
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_FunctionsGetByFunctionID] TO [bodbAdminNet]
GO 
