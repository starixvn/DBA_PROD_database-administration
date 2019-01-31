
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_GroupResellersModify    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_GroupResellersModify    Script Date: 10/21/2011 7:48:21 PM ******/
CREATE PROCEDURE [dbo].[OA_GroupResellersModify]
	@GroupID int,	
	@ResellerIDs varchar(5500)
	,@AdminID int
	,@Language varchar(20) = 'en-us'
	,@LoginIP varchar(30)=''
	,@ErrCode int = 0 OUTPUT  
	,@ErrMsg nvarchar(1000) = '' OUTPUT
AS
/*  
 * Created: 20110915@Elly
 * Task : Assign reseller(s) to group
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

INSERT INTO dbo.OA_GroupResellers (
	GroupID,
	ResellerID
)
SELECT
	@GroupID,
	Val AS ResellerID
FROM dbo.strSplit(@ResellerIDs,',')

IF @@Error>0
BEGIN
	SELECT @ErrCode=1, @ErrMsg='Fail to insert data of ResellerID '+ @ResellerIDs+' and GroupID '+CONVERT(varchar(10),@GroupID)
	RETURN
END

SELECT @LogSPData ='<OA_GroupResellersModify GroupID="'+ coalesce(cast(@GroupID as varchar(10)),space(1)) + '" ' +  
	'ResellerID="'+ coalesce(@ResellerIDs ,space(1)) + '" ' +  
	'Language="'+ coalesce(cast(@Language as varchar(20)),space(1)) + '" ' +  
	'UserID="'+ coalesce(cast(@AdminID as varchar(20)),space(1)) + '" ' + 
	'IP="'+ coalesce(cast(@LoginIP as varchar(30)),space(1)) + '" />'  

SET @endRun = getdate()  
SET @duration  = datediff (millisecond,@startRun,@endRun)   

EXEC dbo.OA_WriteLog_UserLog_RunSP  
	@UserID = @AdminID,   
	@CustID = 0,
	@SPName='OA_GroupResellersModify',
	--@ActionID = 0,  
	@TrackingValue = @LogSPData,  
	@duration = @duration
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_GroupResellersModify] TO [bodbAdminNet]
GO 
