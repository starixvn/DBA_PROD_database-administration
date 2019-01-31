
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_UserFunctionsGetByUserID    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_UserFunctionsGetByUserID    Script Date: 10/21/2011 7:48:20 PM ******/
CREATE PROCEDURE [dbo].[OA_UserFunctionsGetByUserID]
	@UserID int
AS
/*  
 * Created: 20110920@Elly
 * Task : Get list of functions and its policy of a User only
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
	dbo.OA_UserFunctions AS uf WITH(NOLOCK)
	INNER JOIN dbo.OA_Functions AS f WITH(NOLOCK) ON f.FunctionID=uf.FunctionID
WHERE 
	uf.UserID = @UserID
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_UserFunctionsGetByUserID] TO [bodbAdminNet]
GO 
