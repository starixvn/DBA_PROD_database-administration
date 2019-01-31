
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_UserFunctionsDelete    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_UserFunctionsDelete    Script Date: 10/21/2011 7:48:20 PM ******/
CREATE PROCEDURE [dbo].[OA_UserFunctionsDelete]
	@UserID int	
	,@AdminID int
	,@Language varchar(20) = 'en-us'
	,@LoginIP varchar(30)=''
	,@ErrCode int = 0 OUTPUT  
	,@ErrMsg nvarchar(1000) = '' OUTPUT 
AS
/*  
 * Created: 20110913@Elly
 * Task : UnAssign a function from a user
 * DB: DB052.bodb_Licensee  
 *  
 * Revisions:     
*/
SET NOCOUNT ON

DECLARE @startRun datetime  
	,@endRun datetime  
	,@duration int
	,@LogSPData varchar(5000)
	,@FunctionIDs varchar(5500)
	
SET @startRun=GETDATE()
SET @FunctionIDs=''
	
	SELECT @FunctionIDs=@FunctionIDs+CONVERT(varchar(10),FunctionID)+','
	FROM dbo.OA_UserFunctions	WITH(NOLOCK)
	WHERE UserID=@UserID
	

DELETE FROM dbo.OA_UserFunctions WITH(ROWLOCK)
WHERE
	UserID = @UserID	
	
IF @@Error>0
BEGIN
	SELECT @ErrCode=1, @ErrMsg='Fail to	unassign FunctionID '+@FunctionIDs+' from UserID '+CONVERT(varchar(10),@UserID)
	RETURN
END

SELECT @LogSPData ='<OA_UserFunctionsDelete CustID="'+ coalesce(cast(@UserID as varchar(10)),space(1)) + '" ' +  
	'FunctionID="'+ coalesce(@FunctionIDs,space(1)) + '" ' +  
	'Language="'+ coalesce(cast(@Language as varchar(20)),space(1)) + '" ' +  
	'UserID="'+ coalesce(cast(@AdminID as varchar(20)),space(1)) + '" ' + 
	'IP="'+ coalesce(cast(@LoginIP as varchar(30)),space(1)) + '" />'  

SET @endRun = getdate()  
SET @duration  = datediff (millisecond,@startRun,@endRun)   

EXEC dbo.OA_WriteLog_UserLog_RunSP  
	@UserID = @AdminID,   
	@CustID = @UserID,
	@SPName='OA_UserFunctionsDelete',
	--@ActionID = 0,  
	@TrackingValue = @LogSPData,  
	@duration = @duration
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_UserFunctionsDelete] TO [bodbAdminNet]
GO 
