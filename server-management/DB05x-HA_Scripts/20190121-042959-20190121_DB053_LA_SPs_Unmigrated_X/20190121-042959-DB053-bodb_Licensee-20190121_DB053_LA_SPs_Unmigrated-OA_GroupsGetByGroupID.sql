
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_GroupsGetByGroupID    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_GroupsGetByGroupID    Script Date: 10/21/2011 7:48:21 PM ******/
CREATE PROCEDURE [dbo].[OA_GroupsGetByGroupID]
	@UserID int
	,@GroupID int
AS
/*  
 * Created: 20110915@Elly
 * Task : get information of GroupID
 * DB: DB052.bodb_Licensee  
 *  
 * Revisions:   
 Param's Explanation:
	
*/
SET NOCOUNT ON
--SELECT * FROM dbo.OA_Functions

IF EXISTS(SELECT 1 
		FROM dbo.OA_Functions AS f WITH(NOLOCK) 
			INNER JOIN (SELECT FunctionID
					FROM dbo.OA_UserFunctions WITH(NOLOCK)
					WHERE UserID=@UserID
					
					UNION ALL
					
					SELECT FunctionID
					FROM dbo.OA_GroupFunctions AS g WITH(NOLOCK)
						INNER JOIN dbo.OA_Users AS u WITH(NOLOCK) ON g.GroupID=u.GroupID AND u.UserID=@UserID					
				) AS t ON t.FunctionID=f.FunctionID AND FunctionName='Manage Group')
BEGIN
	SELECT
		g.GroupID,
		g.GroupName,
		g.GroupDesc,			
		g.IsActive,
		g.CreatedDate,
		g.ModifiedDate,
		g.Creator		
	FROM
		dbo.OA_Groups AS g WITH(NOLOCK)		
	WHERE g.GroupID=@GroupID
		--AND g.IsActive=1
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_GroupsGetByGroupID] TO [bodbAdminNet]
GO 
