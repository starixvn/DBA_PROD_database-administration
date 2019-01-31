
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_GroupsModify    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_GroupsModify    Script Date: 10/21/2011 7:48:21 PM ******/
CREATE PROCEDURE [dbo].[OA_GroupsModify]
	@GroupID int OUTPUT,
	@GroupName nvarchar(50),
	@GroupDesc nvarchar(100),
	--@IsActive bit,
	@CreatedDate datetime,
	@ModifiedDate datetime,
	@Creator int
	,@Language varchar(20) = 'en-us'
	,@LoginIP varchar(30)=''
	,@ErrCode int = 0 OUTPUT  
	,@ErrMsg nvarchar(1000) = '' OUTPUT 
AS
/*  
 * Created: 20110909@Elly
 * Task : Add or modify a group
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

IF EXISTS(SELECT 1 FROM dbo.OA_Groups WITH(NOLOCK) WHERE GroupID = @GroupID)
BEGIN
	SELECT @LogSPDataOld ='<OA_GroupsModify cutsid="'+ coalesce(cast(@GroupID as varchar(10)),space(1)) + '" ' +  	
		'GroupName="'+ coalesce(cast(GroupName as varchar(20)),space(1)) + '" ' +  
		'GroupDesc="'+ coalesce(cast(GroupDesc as varchar(20)),space(1)) + '" ' +  
		--'IsActive="'+ coalesce(cast(IsActive as varchar(20)),space(1)) + '" ' +  
		'ModifiedDate="'+ coalesce(cast(ModifiedDate as varchar(20)),space(1)) + '" ' +  
		'Language="'+ coalesce(cast(@Language as varchar(20)),space(1)) + '" ' +  
		'IP="'+ coalesce(cast(@LoginIP as varchar(30)),space(1)) + '" />'  
	FROM  dbo.OA_Groups WITH(NOLOCK)
	WHERE GroupID = @GroupID
		
	UPDATE dbo.OA_Groups WITH(UPDLOCK,ROWLOCK)
	SET
		GroupName = @GroupName,
		GroupDesc = @GroupDesc,
		--IsActive = @IsActive,		
		ModifiedDate = @ModifiedDate		
	WHERE
		GroupID = @GroupID
		
	IF @@Error>0
	BEGIN
		SELECT @ErrCode=1, @ErrMsg='Fail to update information of the GroupID '+CONVERT(varchar(10),@GroupID)
		RETURN
	END
END
ELSE
BEGIN
	INSERT INTO dbo.OA_Groups 
	(	GroupName,
		GroupDesc,
		IsActive,
		CreatedDate,
		ModifiedDate,
		Creator
	) VALUES (		
		@GroupName,
		@GroupDesc,
		--@IsActive,
		1,
		@CreatedDate,
		@ModifiedDate,
		@Creator
	)
	
	SET @GroupID=SCOPE_IDENTITY()
	
	IF @@Error>0
	BEGIN
		SELECT @ErrCode=1, @ErrMsg='Fail to insert information of the GroupID '+CONVERT(varchar(10),@GroupID)
		RETURN
	END	
	
END

SELECT @LogSPData ='<OA_GroupsModify GroupID="'+ coalesce(cast(@GroupID as varchar(10)),space(1)) + '" ' +  	
	'GroupName="'+ coalesce(cast(@GroupName as varchar(20)),space(1)) + '" ' +  
	'GroupDesc="'+ coalesce(cast(@GroupDesc as varchar(20)),space(1)) + '" ' +  
	--'IsActive="'+ coalesce(cast(@IsActive as varchar(20)),space(1)) + '" ' +  
	'ModifiedDate="'+ coalesce(cast(@ModifiedDate as varchar(20)),space(1)) + '" ' +  
	'Language="'+ coalesce(cast(@Language as varchar(20)),space(1)) + '" ' +  
	'UserID="'+ coalesce(cast(@Creator as varchar(20)),space(1)) + '" ' +  
	'IP="'+ coalesce(cast(@LoginIP as varchar(30)),space(1)) + '" />'  

SET @endRun = getdate()  
SET @duration  = datediff (millisecond,@startRun,@endRun)   

EXEC dbo.OA_WriteLog_UserLog_RunSP  
	@UserID = @Creator,   
	@CustID = 0,
	@SPName='OA_GroupsModify',
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
 GRANT EXECUTE ON [dbo].[OA_GroupsModify] TO [bodbAdminNet]
GO 
