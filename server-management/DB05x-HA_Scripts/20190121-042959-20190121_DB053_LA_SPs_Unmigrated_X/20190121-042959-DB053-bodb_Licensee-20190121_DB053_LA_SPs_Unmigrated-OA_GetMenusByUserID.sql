
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_GetMenusByUserID    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_GetMenusByUserID    Script Date: 10/21/2011 7:48:20 PM ******/
CREATE PROCEDURE [dbo].[OA_GetMenusByUserID]
	@UserID int
AS
/*  
 * Created: 20110914@Elly
 * Task : Get Menus that the UserID have access right
 * DB: DB052.bodb_Licensee  
 *  
 * Revisions:     
*/
SET NOCOUNT ON

SELECT m.ParentID AS ParentID
		,m.ParentName AS ParentName		
		,m.MenuID
		,m.MenuName
		,m.URL		
		,m.DisplayOrder
FROM (
		SELECT 
			CASE WHEN ISNULL(A.FunctionID,0) = 0 THEN B.FunctionID ELSE A.FunctionID END AS FunctionID,
			CASE WHEN ISNULL(A.Policy,0) < ISNULL(B.Policy,0) THEN ISNULL(B.Policy,0) ELSE ISNULL(A.Policy,0) END AS Policy
		FROM 
		(
			SELECT FunctionID,Policy
			FROM dbo.OA_GroupFunctions AS gf WITH(NOLOCK)
				INNER JOIN dbo.OA_Users AS u WITH(NOLOCK) ON gf.GroupID=u.GroupID AND u.UserID=@UserID
		) A
		FULL OUTER JOIN
		(
			SELECT FunctionID,policy		
			FROM dbo.OA_UserFunctions WITH(NOLOCK)
			WHERE UserID=@UserID
		) B
		ON A.FunctionID = B.FunctionID
	)AS t
	INNER JOIN dbo.OA_Functions AS f WITH(NOLOCK) ON f.FunctionID=t.FunctionID AND f.IsActive=1	
	INNER JOIN dbo.OA_Menus as m WITH (NOLOCK) ON f.FunctionID = m.FunctionID
WHERE t.Policy >= m.Policy AND m.IsActive = 1
ORDER BY m.DisplayOrder
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_GetMenusByUserID] TO [bodbAdminNet]
GO 
