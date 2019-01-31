
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_GroupsGetAll    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_GroupsGetAll    Script Date: 10/21/2011 7:48:21 PM ******/
CREATE PROCEDURE [dbo].[OA_GroupsGetAll]
	@UserID int	
AS
/*  
 * Created: 20110915@Elly
 * Task : get all groups of a user who has permission on 'Manage Group'
 * DB: DB052.bodb_Licensee  
 *  
 * Revisions:   
 Param's Explanation:
	
*/
SET NOCOUNT ON
--SELECT * FROM dbo.OA_Functions

IF EXISTS(
SELECT 1
FROM
	dbo.OA_Functions AS f WITH (NOLOCK)
	INNER JOIN (SELECT FunctionID
				FROM
					dbo.OA_UserFunctions WITH (NOLOCK)
				WHERE
					UserID = @UserID

				UNION ALL

				SELECT FunctionID
				FROM
					dbo.OA_GroupFunctions AS g WITH (NOLOCK)
					INNER JOIN dbo.OA_Users AS u WITH (NOLOCK)
						ON g.GroupID = u.GroupID AND u.UserID = @UserID
			   ) AS t
		ON t.FunctionID = f.FunctionID AND FunctionName = 'Manage Group')
BEGIN
SELECT g.GroupID
	 , g.GroupName
	 , g.GroupDesc
	 , ISNULL(u.UserCount,0) AS UserCount
	 , g.IsActive
	 , g.CreatedDate
	 , g.ModifiedDate
	 , g.Creator AS CreatorId
	 , c.UserName AS CreatorUserName
FROM
	dbo.OA_Groups AS g WITH (NOLOCK)
	LEFT JOIN dbo.OA_Users AS c WITH (NOLOCK)
		ON g.Creator = c.UserID
	LEFT JOIN (SELECT GroupID
					 , count(1) AS UserCount
				FROM
					dbo.OA_Users AS u WITH (NOLOCK)
				GROUP BY
					GroupID
			   ) AS u
		ON g.GroupID = u.GroupID
--ORDER BY IsActive DESC		

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_GroupsGetAll] TO [bodbAdminNet]
GO 
