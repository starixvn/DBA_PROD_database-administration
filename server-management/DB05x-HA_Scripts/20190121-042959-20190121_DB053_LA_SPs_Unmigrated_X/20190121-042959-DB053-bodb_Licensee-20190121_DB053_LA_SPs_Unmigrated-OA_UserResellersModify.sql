
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_UserResellersModify    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_UserResellersModify    Script Date: 10/21/2011 7:48:20 PM ******/
CREATE PROCEDURE [dbo].[OA_UserResellersModify]
	@UserID int,	
	@ResellerIDs varchar(5500)
	,@AdminID int
	,@Language varchar(20) = 'en-us'
	,@LoginIP varchar(30)=''
	,@ErrCode int = 0 OUTPUT  
	,@ErrMsg nvarchar(1000) = '' OUTPUT
AS
/*  
 * Created: 20110909@Elly
 * Task : Assign and unassign a reseller from a user
 * DB: DB052.bodb_Reseller  
 *  
 * Revisions:     
*/
SET NOCOUNT ON

DECLARE @startRun datetime  
	,@endRun datetime  
	,@duration int
	,@LogSPData varchar(5000)
	
SET @startRun=GETDATE()

INSERT INTO dbo.OA_UserResellers (
	UserID,
	ResellerID
) 
SELECT
	@UserID,
	val AS ResellerID
FROM dbo.strSplit(@ResellerIDs,',')

IF @@Error>0
BEGIN
	SELECT @ErrCode=1, @ErrMsg='Fail to	assign ResellerID '+@ResellerIDs+' to UserID '+CONVERT(varchar(10),@UserID)
	RETURN
END

SELECT @LogSPData ='<OA_UserResellersModify CustID="'+ coalesce(cast(@UserID as varchar(10)),space(1)) + '" ' +  
	'ResellerID="'+ coalesce(@ResellerIDs,space(1)) + '" ' +  
	'Language="'+ coalesce(cast(@Language as varchar(20)),space(1)) + '" ' +  
	'UserID="'+ coalesce(cast(@AdminID as varchar(20)),space(1)) + '" ' +  
	'IP="'+ coalesce(cast(@LoginIP as varchar(30)),space(1)) + '" />'  

SET @endRun = getdate()  
SET @duration  = datediff (millisecond,@startRun,@endRun)   

EXEC dbo.OA_WriteLog_UserLog_RunSP  
	@UserID = @AdminID,   
	@CustID = @UserID,
	@SPName='OA_UserResellersModify',
	--@ActionID = 0,  
	@TrackingValue = @LogSPData,  
	@duration = @duration
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_UserResellersModify] TO [bodbAdminNet]
GO 
