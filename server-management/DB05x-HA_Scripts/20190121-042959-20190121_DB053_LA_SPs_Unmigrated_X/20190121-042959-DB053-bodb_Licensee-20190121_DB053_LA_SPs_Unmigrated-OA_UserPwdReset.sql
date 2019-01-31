
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_UserPwdReset    Script Date: 1/21/2019 4:30:09 AM ******/
/****** Object:  Stored Procedure dbo.OA_UserPwdReset    Script Date: 10/21/2011 7:48:20 PM ******/
CREATE PROCEDURE [dbo].[OA_UserPwdReset]
	@AdminID int,	
	@UserID int,	
	@Pwd varchar(50),
	@UserSalt varchar(50),   
	@Language varchar(20) = 'en-us',
	@LoginIP varchar(30)='',
	@ErrCode int = 0 OUTPUT,  
	@ErrMsg nvarchar(1000) = '' OUTPUT  
AS

/*
	Created by: [20110914@Elly]
	Task: Reset Pwd of a Licensee user
	DB: DB052.bodb_Licensee
	Revisions:
*/

SET NOCOUNT ON

DECLARE @startRun datetime  
	,@endRun datetime  
	,@duration int  
	,@LogSPData varchar(5000)  
	,@LogSPDataOld varchar(5000)  
	
set @startRun = getdate()  

IF NOT EXISTS (SELECT 1	
			FROM(SELECT functionid
				FROM dbo.OA_UserFunctions AS uf (NOLOCK) 
				WHERE UserID=@AdminID
				
				UNION ALL
				
				SELECT functionid  
					FROM dbo.OA_Users AS u WITH(NOLOCK) 
						INNER JOIN dbo.OA_GroupFunctions AS gf (NOLOCK) ON gf.GroupID=u.GroupID AND u.UserID=@AdminID					
				) AS u
				INNER JOIN dbo.OA_Functions AS f WITH(NOLOCK) ON f.FunctionID=u.FunctionID AND f.FunctionName='Manage User'
			)
BEGIN
	select @ErrMsg = case @Language when 'en-us' then 'You are not authorized!'  
         when 'zh-cn' then 'You are not authorized!'
         when 'zh-tw' then 'You are not authorized!'
         when 'Ja' then 'You are not authorized!'
         when 'TH' then 'You are not authorized!'
         when 'KO' then 'You are not authorized!'
         else 'You are not authorized!'
        end ,@ErrCode=101
    return    
END

IF NOT EXISTS (SELECT 1 FROM OA_Users (nolock) WHERE  UserID = @UserID)
BEGIN
	select @ErrMsg = case @Language when 'en-us' then 'This user does not exist!'
         when 'zh-cn' then 'This user does not exist!'
         when 'zh-tw' then 'This user does not exist!'
         when 'Ja' then 'This user does not exist!'
         when 'TH' then 'This user does not exist!'
         when 'KO' then 'This user does not exist!'
         else 'This user does not exist!'
        end ,@ErrCode=102 
    return    
END



UPDATE dbo.OA_Users   with (ROWLOCK,UPDLOCK)
SET 
	UserPwd = @Pwd,   
	UserSalt = @UserSalt  
WHERE 
	UserID = @UserID
	
IF @@Error>0
BEGIN
	SELECT @ErrCode=1, @ErrMsg='Fail to reset password'
	RETURN
END

Select @LogSPData ='<OA_UserPwdReset CustID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +  
 'UserID="'+ coalesce(cast(@AdminID as varchar(20)),space(1)) + '" ' +  
 'Language="'+ coalesce(cast(@Language as varchar(20)),space(1)) + '" ' +  
 'IP="'+ coalesce(cast(@LoginIP as varchar(30)),space(1)) + '" />'  

set @endRun = getdate()  
set @duration  = datediff (millisecond,@startRun,@endRun)   
---------------------------  
EXEC dbo.OA_WriteLog_UserLog_RunSP  
 @UserID = @AdminID,   
 @CustID = @UserID,  
 @SPName='OA_UserPwdReset',
 @ActionID = 2,  
 @TrackingValue = @LogSPData,  
 @TrackingValue2 = @LogSPDataOld,  
 @duration = @duration
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OA_UserPwdReset] TO [bodbAdminNet]
GO 
