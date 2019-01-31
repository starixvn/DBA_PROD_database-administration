
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_GroupLicenseesModify    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_GroupLicenseesModify    Script Date: 10/21/2011 7:48:21 PM ******/
CREATE PROCEDURE [dbo].[OA_GroupLicenseesModify]
	@GroupID int,
	@ResellerID int,
	@LicenseeIDs varchar(5500) --'1,2,3,4'
	,@AdminID int
	,@Language varchar(20) = 'en-us'
	,@LoginIP varchar(30)=''
	,@ErrCode int = 0 OUTPUT  
	,@ErrMsg nvarchar(1000) = '' OUTPUT 
AS
/*  
 * Created: 20110909@Elly
 * Task : Assign licensee(s) to Group
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

INSERT INTO dbo.OA_GroupLicensees (
	GroupID,
	ResellerID,
	LicenseeID )
SELECT
	@GroupID,
	@ResellerID,
	val AS LicenseeID
FROM dbo.strSplit (@LicenseeIDs,',')

IF @@Error>0
BEGIN
	SELECT @ErrCode=1, @ErrMsg='Fail to insert data of LicenseeID '+CONVERT(varchar(10),@LicenseeIDs)+' and GroupID '+CONVERT(varchar(10),@GroupID)
	RETURN
END

SELECT @LogSPData ='<OA_GroupLicenseesModify GroupID="'+ coalesce(cast(@GroupID as varchar(10)),space(1)) + '" ' +  
	'LicenseeID="'+ coalesce(@LicenseeIDs  ,space(1)) + '" ' +  
	'Language="'+ coalesce(cast(@Language as varchar(20)),space(1)) + '" ' +  
	'UserID="'+ coalesce(cast(@AdminID as varchar(20)),space(1)) + '" ' +  
	'IP="'+ coalesce(cast(@LoginIP as varchar(30)),space(1)) + '" />'  

SET @endRun = getdate()  
SET @duration  = datediff (millisecond,@startRun,@endRun)   

EXEC dbo.OA_WriteLog_UserLog_RunSP  
	@UserID = @AdminID,   
	@CustID = 0,
	@SPName='OA_GroupLicenseesModify',
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
 GRANT EXECUTE ON [dbo].[OA_GroupLicenseesModify] TO [bodbAdminNet]
GO 
