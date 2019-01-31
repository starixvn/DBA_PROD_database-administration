
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OA_UsersModify    Script Date: 1/21/2019 4:30:10 AM ******/
/****** Object:  Stored Procedure dbo.OA_UsersModify    Script Date: 10/21/2011 7:48:20 PM ******/
CREATE PROCEDURE [dbo].[OA_UsersModify]
	@UserID int OUTPUT,
	@GroupID int,
	@UserName nvarchar(50),
	@DisplayName nvarchar(50),
	@UserPwd varchar(50)='',
	@UserSalt varchar(50)='',
	@IsActive bit,
	@CreatedDate datetime,
	@ModifiedDate datetime,
	@Creator int	
	,@Language varchar(20) = 'en-us'
	,@LoginIP varchar(30)=''
	,@ErrCode int = 0 OUTPUT  
	,@ErrMsg nvarchar(1000) = '' OUTPUT 
AS
/*  
 * Created: 20110919@Elly
 * Task : Add or modify a user
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

IF EXISTS(SELECT 1 FROM dbo.OA_Users WITH(NOLOCK) WHERE UserID = @UserID)
BEGIN
	SELECT @LogSPDataOld ='<OA_UsersModify CustID="'+ coalesce(cast(@UserID as varchar(10)),space(1)) + '" ' +  	
		'UserName="'+ coalesce(cast(UserName as varchar(20)),space(1)) + '" ' +  
		'DisplayName="'+ coalesce(cast(DisplayName as varchar(20)),space(1)) + '" ' +  
		'IsActive="'+ coalesce(cast(IsActive as varchar(20)),space(1)) + '" ' +  
		'ModifiedDate="'+ coalesce(cast(ModifiedDate as varchar(20)),space(1)) + '" ' +  
		'Language="'+ coalesce(cast(@Language as varchar(20)),space(1)) + '" ' +  
		'UserID="'+ coalesce(cast(@Creator as varchar(20)),space(1)) + '" ' + 
		'IP="'+ coalesce(cast(@LoginIP as varchar(30)),space(1)) + '" />'  
	FROM  dbo.OA_Users WITH(NOLOCK)
	WHERE UserID = @UserID
	
	IF @UserPwd<>'' AND @UserSalt <> ''
	BEGIN
		UPDATE dbo.OA_Users WITH(UPDLOCK,ROWLOCK)
		SET
			UserName = @UserName,
			DisplayName = @DisplayName,
			IsActive = @IsActive,		
			ModifiedDate = @ModifiedDate,
			UserPwd = @UserPwd,
			UserSalt = @UserSalt,
			GroupID = @GroupID		
		WHERE
			UserID = @UserID
	END
	ELSE
	BEGIN
		UPDATE dbo.OA_Users WITH(UPDLOCK,ROWLOCK)
		SET
			UserName = @UserName,
			DisplayName = @DisplayName,
			IsActive = @IsActive,		
			ModifiedDate = @ModifiedDate,
			GroupID = @GroupID		
		WHERE
			UserID = @UserID
	END	
	
		
	IF @@Error>0
	BEGIN
		SELECT @ErrCode=100, @ErrMsg='Fail to update information of the UserID '+CONVERT(varchar(10),@UserID)
		RETURN
	END
END
ELSE
BEGIN
	IF @UserPwd='' OR @UserSalt =''
	BEGIN
		SELECT @ErrCode=101, @ErrMsg='Password or Password Salt could not be left blank!'
		RETURN
	END
	ELSE
	BEGIN
		INSERT INTO dbo.OA_Users 
		(		
			GroupID,
			Username,
			UserPwd,
			DisplayName,
			UserSalt,
			IsActive,
			Creator,
			CreatedDate,
			ModifiedDate		
		) VALUES (		
			@GroupID,
			@Username,
			@UserPwd,
			@DisplayName,
			@UserSalt,
			@IsActive,
			@Creator,
			@CreatedDate,
			@ModifiedDate
		)
	END

	
	
	SET @UserID=SCOPE_IDENTITY()
	
	IF @@Error>0
	BEGIN
		SELECT @ErrCode=102, @ErrMsg='Fail to insert information of the UserID '+CONVERT(varchar(10),@UserID)
		RETURN
	END
END

SELECT @LogSPData ='<OA_UsersModify CustID="'+ coalesce(cast(@UserID as varchar(10)),space(1)) + '" ' +  	
	'UserName="'+ coalesce(cast(@UserName as varchar(20)),space(1)) + '" ' +  
	'DisplayName="'+ coalesce(cast(@DisplayName as varchar(20)),space(1)) + '" ' +  
	'IsActive="'+ coalesce(cast(@IsActive as varchar(20)),space(1)) + '" ' +  
	'ModifiedDate="'+ coalesce(cast(@ModifiedDate as varchar(20)),space(1)) + '" ' +  
	'Language="'+ coalesce(cast(@Language as varchar(20)),space(1)) + '" ' +  
	'UserID="'+ coalesce(cast(@Creator as varchar(20)),space(1)) + '" ' +  
	'IP="'+ coalesce(cast(@LoginIP as varchar(30)),space(1)) + '" />'  

SET @endRun = getdate()  
SET @duration  = datediff (millisecond,@startRun,@endRun)   

EXEC dbo.OA_WriteLog_UserLog_RunSP  
	@UserID = @Creator,   
	@CustID = @UserID,
	@SPName='OA_UsersModify',
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
 GRANT EXECUTE ON [dbo].[OA_UsersModify] TO [bodbAdminNet]
GO 
