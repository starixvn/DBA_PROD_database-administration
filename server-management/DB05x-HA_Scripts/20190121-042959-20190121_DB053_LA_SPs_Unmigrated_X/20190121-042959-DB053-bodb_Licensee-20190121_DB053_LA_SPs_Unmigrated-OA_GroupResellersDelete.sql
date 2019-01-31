
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_GroupResellersDelete    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_GroupResellersDelete    Script Date: 10/21/2011 7:48:21 PM ******/
CREATE PROCEDURE [dbo].[OA_GroupResellersDelete]
	@GroupID int
	,@AdminID int
	,@Language varchar(20) = 'en-us'
	,@LoginIP varchar(30)=''
	,@ErrCode int = 0 OUTPUT  
	,@ErrMsg nvarchar(1000) = '' OUTPUT
AS
/*  
 * Created: 20110914@Elly
 * Task : UnAssign reseller(s) to Group
 * DB: DB052.bodb_Licensee  
 *  
 * Revisions:     
*/
SET NOCOUNT ON
DECLARE @startRun datetime  
	,@endRun datetime  
	,@duration int
	,@LogSPData varchar(5000)
	,@ResellerIDs varchar(5500)
	
SET @startRun=GETDATE()	
SET @ResellerIDs=''
	
	SELECT @ResellerIDs=@ResellerIDs+CONVERT(varchar(10),ResellerID)+','
	FROM dbo.OA_GroupResellers	WITH(NOLOCK)
	WHERE GroupID=@GroupID
	
DELETE FROM dbo.OA_GroupResellers WITH(ROWLOCK)
WHERE
	GroupID = @GroupID
	
IF @@Error>0
BEGIN
	SELECT @ErrCode=1, @ErrMsg='Fail to unassign ResellerID '+@ResellerIDs+' from GroupID '+CONVERT(varchar(10),@GroupID)
	RETURN
END

SELECT @LogSPData ='<OA_GroupResellersDelete GroupID="'+ coalesce(cast(@GroupID as varchar(10)),space(1)) + '" ' +  
	'ResellerID="'+ coalesce(@ResellerIDs,space(1)) + '" ' +  
	'Language="'+ coalesce(cast(@Language as varchar(20)),space(1)) + '" ' +  
	'UserID="'+ coalesce(cast(@AdminID as varchar(20)),space(1)) + '" ' +  
	'IP="'+ coalesce(cast(@LoginIP as varchar(30)),space(1)) + '" />'  

SET @endRun = getdate()  
SET @duration  = datediff (millisecond,@startRun,@endRun)   

EXEC dbo.OA_WriteLog_UserLog_RunSP  
	@UserID = @AdminID,   
	@CustID = 0,
	@SPName='OA_GroupResellersDelete',
	--@ActionID = 0,  
	@TrackingValue = @LogSPData,  
	@duration = @duration
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_GroupResellersDelete] TO [bodbAdminNet]
GO 
