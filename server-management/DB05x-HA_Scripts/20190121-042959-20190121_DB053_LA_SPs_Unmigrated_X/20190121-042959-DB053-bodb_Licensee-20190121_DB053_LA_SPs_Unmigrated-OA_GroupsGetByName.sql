
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_GroupsGetByName    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_GroupsGetByName    Script Date: 10/21/2011 7:48:21 PM ******/
CREATE PROCEDURE [dbo].[OA_GroupsGetByName]
	@GroupName NVARCHAR(50)
AS
/*  
 * Created: 20110921@Lewis
 * Task : Get a group by its name
 * DB: DB052.bodb_Licensee  
 *  
 * Revisions:   
 Param's Explanation:
	
*/
SET NOCOUNT ON

SELECT g.GroupID
	 , g.GroupName
	 , g.GroupDesc
	 , ISNULL(u.UserCount,0) as UserCount
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
WHERE
	g.GroupName = @GroupName
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_GroupsGetByName] TO [bodbAdminNet]
GO 
