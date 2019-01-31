
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_GroupLicenseesDelete    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_GroupLicenseesDelete    Script Date: 10/21/2011 7:48:21 PM ******/
CREATE PROCEDURE [dbo].[OA_GroupLicenseesDelete]
	@GroupID int	
	,@AdminID int
	,@Language varchar(20) = 'en-us'
	,@LoginIP varchar(30)=''
	,@ErrCode int = 0 OUTPUT  
	,@ErrMsg nvarchar(1000) = '' OUTPUT 
AS
/*  
 * Created: 20110909@Elly
 * Task : UnAssign licensee(s) from Group
 * DB: DB052.bodb_Licensee  
 *  
 * Revisions:     
*/
SET NOCOUNT ON
DECLARE @startRun datetime  
	,@endRun datetime  
	,@duration int
	,@LogSPData varchar(5000)
	,@LicenseeIDs varchar(5500)
	
SET @startRun=GETDATE()

SET @LicenseeIDs=''
	
	SELECT @LicenseeIDs=@LicenseeIDs+CONVERT(varchar(10),LicenseeID)+','
	FROM dbo.OA_GroupLicensees	WITH(NOLOCK)
	WHERE GroupID=@GroupID

DELETE FROM dbo.OA_GroupLicensees WITH(ROWLOCK)
WHERE
	GroupID = @GroupID	
	
IF @@Error>0
BEGIN
	SELECT @ErrCode=1, @ErrMsg='Fail to unassign LicenseeID '+@LicenseeIDs+' from GroupID '+CONVERT(varchar(10),@GroupID)
	RETURN
END

SELECT @LogSPData ='<OA_GroupLicenseesDelete GroupID="'+ coalesce(cast(@GroupID as varchar(10)),space(1)) + '" ' +  
	'LicenseeID="'+ coalesce(cast(@LicenseeIDs as varchar(10)),space(1)) + '" ' +  
	'Language="'+ coalesce(cast(@Language as varchar(20)),space(1)) + '" ' +  
	'UserID="'+ coalesce(cast(@AdminID as varchar(20)),space(1)) + '" ' +  
	'IP="'+ coalesce(cast(@LoginIP as varchar(30)),space(1)) + '" />'  

SET @endRun = getdate()  
SET @duration  = datediff (millisecond,@startRun,@endRun)   

EXEC dbo.OA_WriteLog_UserLog_RunSP  
	@UserID = @AdminID,   
	@CustID = 0,
	@SPName='OA_GroupLicenseesDelete',
	--@ActionID = 0,  
	@TrackingValue = @LogSPData,  
	@duration = @duration
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_GroupLicenseesDelete] TO [bodbAdminNet]
GO 
