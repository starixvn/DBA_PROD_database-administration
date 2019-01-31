
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_GroupFunctionsGetByGroupID    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_GroupFunctionsGetByGroupID    Script Date: 10/21/2011 7:48:21 PM ******/
CREATE PROCEDURE [dbo].[OA_GroupFunctionsGetByGroupID]
	@GroupID int
AS
/*  
 * Created: 20110919@Elly
 * Task : Get list of functions and its policy of a GroupID
 * DB: DB052.bodb_Licensee  
 *  
 * Revisions:     
*/  

SET NOCOUNT ON

SELECT	
	f.FunctionID,
	--LicenseeID,
	--ResellerID,	
	f.FunctionName,
	Policy,
	f.ParentID,
	f.ParentName	
FROM
	dbo.OA_GroupFunctions AS gf WITH(NOLOCK)
	INNER JOIN dbo.OA_Functions AS f WITH(NOLOCK) ON f.FunctionID=gf.FunctionID
WHERE
	GroupID = @GroupID
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_GroupFunctionsGetByGroupID] TO [bodbAdminNet]
GO 
