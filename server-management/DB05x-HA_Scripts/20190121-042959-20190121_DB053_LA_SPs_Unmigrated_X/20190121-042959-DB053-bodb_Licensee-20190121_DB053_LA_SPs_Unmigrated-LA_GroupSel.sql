
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_GroupSel    Script Date: 1/21/2019 4:30:03 AM ******/
/****** Object:  Stored Procedure dbo.LA_GroupSel    Script Date: 15/10/2014 16:43:23 PM ******/

CREATE PROCEDURE [dbo].[LA_GroupSel] 
    @GroupID INT = - 1
AS

/*  
	 Created: 20140819@Florent
	 Task : Select Group list 
	 DB: DB052.bodb_Licensee  
   
	 Revisions:     
*/
SET NOCOUNT ON
BEGIN	
    SELECT
		g.GroupID,
		g.GroupName,
		g.GroupDesc,			
		g.StatusID		
	FROM
		dbo.LA_Group AS g WITH(NOLOCK)		
	WHERE ( @GroupID <= 0 OR g.GroupID = @GroupID )
		 --AND g.GroupID > 0
     ORDER BY g.GroupID DESC
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_GroupSel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_GroupSel] TO [vnteam]
GO 
