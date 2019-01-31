
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_FunctionSel    Script Date: 1/21/2019 4:30:03 AM ******/
/****** Object:  Stored Procedure dbo.LA_FunctionSel    Script Date: 15/10/2014 16:43:22 PM ******/

CREATE PROCEDURE [dbo].[LA_FunctionSel] 	
AS

/*  
	 Created: 20140814@Florent
	 Task : Select Function list 
	 DB: DB052.bodb_Licensee  
   
	 Revisions:     
	 Params :	 

*/
SET NOCOUNT ON
	
BEGIN	
SELECT	
	   f.FunctionID
	   ,FunctionName
	   ,FunctionDesc
	   ,ParentID
	   ,ParentName
	   ,URL
	   ,CreatedDate
	   ,ModifiedDate
	   ,DisplayOrder
	   ,Creator
	   ,f.StatusID AS IsActive
	   ,FunctionKey	
	   ,Stuff((SELECT ', ' + g.GroupName 
				FROM dbo.LA_GroupFunction gf WITH(NOLOCK) LEFT JOIN dbo.LA_Group g WITH(NOLOCK) ON gf.GroupID = g.GroupID 
				WHERE f.FunctionID = gf.FunctionID
				FOR XML PATH('')),1,1,''
			) GroupName
FROM
	   dbo.LA_Function AS f WITH(NOLOCK)	   

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_FunctionSel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_FunctionSel] TO [vnteam]
GO 
