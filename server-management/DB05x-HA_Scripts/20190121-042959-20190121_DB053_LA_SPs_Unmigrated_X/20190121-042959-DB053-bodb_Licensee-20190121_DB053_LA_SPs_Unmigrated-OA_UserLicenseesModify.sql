
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_UserLicenseesModify    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_UserLicenseesModify    Script Date: 10/21/2011 7:48:20 PM ******/
CREATE PROCEDURE [dbo].[OA_UserLicenseesModify]
	@UserID int,
	@ResellerID int,
	@LicenseeIDs varchar(5500) --'1,2,3,4'
	,@AdminID int
	,@Language varchar(20) = 'en-us'
	,@LoginIP varchar(30)=''
	,@ErrCode int = 0 OUTPUT  
	,@ErrMsg nvarchar(1000) = '' OUTPUT
AS
/*  
 * Created: 20110912@Elly
 * Task : Assign licensee to User
 * DB: DB052.bodb_Licensee  
 *  
 * Revisions:     
*/
BEGIN
SET NOCOUNT ON

DECLARE @startRun datetime  
	,@endRun datetime  
	,@duration int
	,@LogSPData varchar(5000)
	
SET @startRun=GETDATE()

	INSERT INTO dbo.OA_UserLicensees (
		UserID,
		ResellerID,
		LicenseeID
		) 
	SELECT
		@UserID,
		@ResellerID,
		val AS LicenseeID
	FROM dbo.strSplit (@LicenseeIDs,',')	

IF @@Error>0
BEGIN
	SELECT @ErrCode=1, @ErrMsg='Fail to	assign LicenseeID '+CONVERT(varchar(10),@LicenseeIDs)+' to UserID '+CONVERT(varchar(10),@UserID)
	RETURN
END

SELECT @LogSPData ='<OA_UserLicenseesModify CustID="'+coalesce(cast(@UserID as varchar(10)),space(1)) + '" ' +  
	'LicenseeID="'+ coalesce(cast(@LicenseeIDs as varchar(10)),space(1)) + '" ' +  
	'Language="'+ coalesce(cast(@Language as varchar(20)),space(1)) + '" ' +  
	'UserID="'+ coalesce(cast(@AdminID as varchar(20)),space(1)) + '" ' + 
	'IP="'+ coalesce(cast(@LoginIP as varchar(30)),space(1)) + '" />'  

SET @endRun = getdate()  
SET @duration  = datediff (millisecond,@startRun,@endRun)   

EXEC dbo.OA_WriteLog_UserLog_RunSP  
	@UserID = @AdminID,   
	@CustID = @UserID,
	@SPName='OA_UserLicenseesModify',
	--@ActionID = 0,  
	@TrackingValue = @LogSPData,  
	@duration = @duration
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_UserLicenseesModify] TO [bodbAdminNet]
GO 
