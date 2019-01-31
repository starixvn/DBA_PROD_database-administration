
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_FunctionSelByUser    Script Date: 1/21/2019 4:30:03 AM ******/
/****** Object:  Stored Procedure dbo.LA_FunctionSelByUser    Script Date: 15/10/2014 16:43:22 PM ******/

CREATE PROCEDURE [dbo].[LA_FunctionSelByUser]
	@UserID	 INT
AS

/*  
	 Created: 20140814@Florent
	 Task : Select Function list by User
	 DB: DB052.bodb_Licensee  
   
	 Revisions:     
	 Params :	 @getAll : 0 : get only Function active
				    : 1 : get all function both active and not
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
    FROM dbo.LA_Function f WITH(NOLOCK) 
		 INNER JOIN dbo.LA_UserFunction uf WITH(NOLOCK) ON f.FunctionID = uf.FunctionID
    WHERE uf.UserID = @UserID AND f.StatusID != 0
		  --AND (@getAll = 1 or f.StatusID != @getAll)
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_FunctionSelByUser] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_FunctionSelByUser] TO [vnteam]
GO 
