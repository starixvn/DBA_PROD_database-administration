
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_CheckUserPermissionOnFunctionID    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_CheckUserPermissionOnFunctionID    Script Date: 10/21/2011 7:48:20 PM ******/
CREATE PROCEDURE [dbo].[OA_CheckUserPermissionOnFunctionID]
	@UserID int
	,@FunctionID int	
AS
/*  
 * Created: 20110915@Elly
 * Task : check whether UserID has been assigned the FunctionID or not
 * DB: DB052.bodb_Licensee  
 *  
 * Revisions:   
 Param's Explanation:
	
*/
SET NOCOUNT ON
	DECLARE @UserPolicy tinyint, @GroupPolicy tinyint
	SET @UserPolicy=0
	SET @GroupPolicy=0
	
	SELECT @UserPolicy=Policy
	FROM dbo.OA_UserFunctions WITH(NOLOCK)
	WHERE UserID=@UserID AND FunctionID=@FunctionID	
	
	SELECT @GroupPolicy=Policy
	FROM dbo.OA_GroupFunctions AS g WITH(NOLOCK)
		INNER JOIN dbo.OA_Users AS u WITH(NOLOCK) ON g.GroupID=u.GroupID 
			AND u.UserID=@UserID					
			AND FunctionID=@FunctionID		
	
	IF @GroupPolicy >= @UserPolicy
		SELECT @GroupPolicy AS Policy
	ELSE
		SELECT @UserPolicy AS Policy
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_CheckUserPermissionOnFunctionID] TO [bodbAdminNet]
GO 
