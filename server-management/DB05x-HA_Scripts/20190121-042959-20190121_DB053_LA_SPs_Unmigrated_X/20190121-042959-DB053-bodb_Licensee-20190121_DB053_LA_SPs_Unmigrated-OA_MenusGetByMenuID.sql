
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_MenusGetByMenuID    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_MenusGetByMenuID    Script Date: 10/21/2011 7:48:21 PM ******/
CREATE PROCEDURE [dbo].[OA_MenusGetByMenuID]
	@MenuID INT
AS
/*  
 * Created: 20111014@Lewis
 * Task : Get a specific menu by its id
 * DB: DB052.bodb_Licensee  
 *  
 * Revisions:     
*/
SET NOCOUNT ON

SELECT	
	 m.MenuID
	,m.MenuName
	,m.MenuDesc
	,m.ParentID
	,m.ParentName
	,m.URL
	,m.CreatedDate
	,m.ModifiedDate
	,m.DisplayOrder
	,m.Creator
	,m.IsActive
	,f.FunctionID
	,f.FunctionName
	,m.Policy

FROM
	dbo.OA_Menus AS m WITH (NOLOCK)
JOIN
	dbo.OA_Functions f WITH (NOLOCK)
ON  m.FunctionID = f.FunctionID

WHERE m.MenuID = @MenuID
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_MenusGetByMenuID] TO [bodbAdminNet]
GO 
