
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_UserPasswordUpd    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_UserPasswordUpd    Script Date: 10/21/2011 7:48:20 PM ******/
CREATE PROCEDURE [dbo].[OA_UserPasswordUpd]  
 @AdminID int,
 @UserID int, 
 @OldPwd varchar(50),   
 @NewPwd varchar(50),   
 @UserSalt varchar(50),   
 @Language varchar(20) = 'en-US',  
 @LoginIP varchar(20),  
 @ErrCode int = 0 OUTPUT,  
 @ErrMsg nvarchar(4000) = '' OUTPUT  
   
  
AS  
/*  
 * Created: 20110914@Elly
 * Task : User change password
 * DB: DB052.bodb_Licensee  
 *  
 * Revisions:     
*/  
BEGIN  
	SET NOCOUNT ON;  
	
	DECLARE @startRun datetime  
		,@endRun datetime  
		,@duration int
		,@LogSPData varchar(5000)
		,@LogSPDataOld varchar(5000)
		
	SET @startRun=GETDATE()
	
	If EXISTS(SELECT 1 FROM dbo.OA_Users WITH(NOLOCK) WHERE UserID=@UserID AND UserPwd<>@OldPwd)
	Begin
		select @ErrMsg = case @Language when 'en-us' then 'Wrong password.'  
			 when 'zh-cn' then N'Wrong password.'  
			 when 'zh-tw' then N'Wrong password.'  
			 when 'ja' then N'Wrong password.'  
			 when 'TH' then N'Wrong password.'  
			 when 'KO' then N'Wrong password.'  
			 else N'Wrong password.'  
			end ,@ErrCode=101    
		return 
	End

	if exists (select 1 from dbo.OA_Users with (nolock) where @UserId = UserId and IsActive=0)
	Begin
		select @ErrMsg = case @Language when 'en-us' then 'This user is not active.'  
			 when 'zh-cn' then N'This user is not active.'  
			 when 'zh-tw' then N'This user is not active.'  
			 when 'ja' then N'This user is not active.'  
			 when 'TH' then N'This user is not active.'  
			 when 'KO' then N'This user is not active.'  
			 else N'This user is not active.'  
			end ,@ErrCode=102
		return 
	End
			
	UPDATE dbo.OA_Users   with (UPDLOCK,ROWLOCK)
	SET UserPwd = @NewPwd,   
	  UserSalt = @UserSalt  
	WHERE UserID = @UserID
	  
	IF (@@ERROR > 0)  
	BEGIN
		SELECT @ErrCode = 100, @ErrMsg = 'Cannot change password'  
		RETURN
	END
	
	
		
	SELECT @LogSPData ='<OA_UserPasswordUpd CustID="'+ coalesce(cast(@UserID as varchar(10)),space(1)) + '" ' +  
		'UserID="'+ coalesce(cast(@AdminID as varchar(20)),space(1)) + '" ' +  
		'Language="'+ coalesce(cast(@Language as varchar(20)),space(1)) + '" ' +  
		'IP="'+ coalesce(cast(@LoginIP as varchar(30)),space(1)) + '" />'  

	SET @endRun = getdate()  
	SET @duration  = datediff (millisecond,@startRun,@endRun)   

		EXEC dbo.OA_WriteLog_UserLog_RunSP  
		@UserID = @AdminID,   
		@CustID = @UserID,
		@SPName='OA_UserPasswordUpd',
		--@ActionID = 0,  
		@TrackingValue = @LogSPData,  
		@TrackingValue2 = @LogSPDataOld,  
		@duration = @duration
		
	SET NOCOUNT OFF

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_UserPasswordUpd] TO [bodbAdminNet]
GO 
