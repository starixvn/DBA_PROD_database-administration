
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_FunctionsGetAll    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_FunctionsGetAll    Script Date: 10/21/2011 7:48:21 PM ******/
CREATE PROCEDURE [dbo].[OA_FunctionsGetAll]	
AS
/*  
 * Created: 20110922@Elly
 * Task : Get all functions 
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
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_FunctionsGetAll] TO [bodbAdminNet]
GO 
