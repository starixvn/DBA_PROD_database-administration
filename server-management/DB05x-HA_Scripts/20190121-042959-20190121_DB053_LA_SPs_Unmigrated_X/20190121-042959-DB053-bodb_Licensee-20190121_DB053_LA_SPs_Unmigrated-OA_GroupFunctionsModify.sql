
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_GroupFunctionsModify    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_GroupFunctionsModify    Script Date: 10/21/2011 7:48:21 PM ******/
CREATE PROCEDURE [dbo].[OA_GroupFunctionsModify]
	@GroupID int,
	@FunctionIDs varchar(5500),
	--@LicenseeID int,
	--@ResellerID int,
	@Policy tinyint
	,@AdminID int
	,@Language varchar(20) = 'en-us'
	,@LoginIP varchar(30)=''
	,@ErrCode int = 0 OUTPUT  
	,@ErrMsg nvarchar(1000) = '' OUTPUT 
AS
/*  
 * Created: 20110919@Elly
 * Task : Assign function to Group or Update Policy of Group and Function
 * DB: DB052.bodb_Licensee  
 *  
 * Revisions:     
*/
SET NOCOUNT ON
DECLARE @startRun datetime  
		,@endRun datetime  
		,@duration int
		,@LogSPData varchar(5000)
		,@LogSPDataOld varchar(5000)		
	
SET @startRun=GETDATE()		

	INSERT INTO dbo.OA_GroupFunctions (
		GroupID,
		FunctionID,
		--LicenseeID,
		--ResellerID,
		Policy
	)
	SELECT
		@GroupID,
		val AS FunctionID,
		--@LicenseeID,
		--@ResellerID,
		@Policy
	FROM dbo.strSplit (@FunctionIDs,',')
	
	IF @@Error>0
	BEGIN
		SELECT @ErrCode=1, @ErrMsg='Fail to insert data GroupID '+CONVERT(varchar(10),@GroupID)
		RETURN
	END


SELECT @LogSPData ='<OA_GroupFunctionsModify GroupID="'+ coalesce(cast(@GroupID as varchar(10)),space(1)) + '" ' +  	
	'FunctionID="'+ coalesce(@FunctionIDs,space(1)) + '" ' +  
	'Policy="'+ coalesce(cast(@Policy as varchar(10)),space(1)) + '" ' +  
	'Language="'+ coalesce(cast(@Language as varchar(20)),space(1)) + '" ' +  
	'UserID="'+ coalesce(cast(@AdminID as varchar(20)),space(1)) + '" ' +  
	'IP="'+ coalesce(cast(@LoginIP as varchar(30)),space(1)) + '" />'  

SET @endRun = getdate()  
SET @duration  = datediff (millisecond,@startRun,@endRun)   

EXEC dbo.OA_WriteLog_UserLog_RunSP  
	@UserID = @AdminID,   
	@CustID = 0,
	@SPName='OA_GroupFunctionsModify',
	--@ActionID = 0,  
	@TrackingValue = @LogSPData,  
	@TrackingValue2 = @LogSPDataOld,
	@duration = @duration
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_GroupFunctionsModify] TO [bodbAdminNet]
GO 
