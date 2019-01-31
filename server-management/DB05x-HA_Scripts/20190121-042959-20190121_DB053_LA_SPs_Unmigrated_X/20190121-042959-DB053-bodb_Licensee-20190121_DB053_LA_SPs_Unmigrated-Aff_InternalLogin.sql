
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Aff_InternalLogin    Script Date: 1/21/2019 4:30:00 AM ******/
CREATE PROCEDURE [dbo].[Aff_InternalLogin]
	@LicenseeName		VARCHAR (50),
	@Username			VARCHAR(50),
	@EncryptedPassword	VARCHAR (50),
	@LoginTime			DATETIME,
	@LoginIP			VARCHAR(50),
	@ServerID			INT = 0 OUTPUT,	
	@LoginDomain		NVARCHAR(253)	= NULL,
	@BrowserName		NVARCHAR(255)	= NULL,
	@Platform			NVARCHAR(255)	= NULL,  
	@CountryCode		VARCHAR(64)		= NULL,  	
	@Language			VARCHAR(20)		= 'en-us',
	@UserID				INT				OUTPUT,
	@ErrMsg				NVARCHAR(1000)	= '' OUTPUT,
    @ErrCode			INT				= 0 OUTPUT	
AS

/*
	Created by: [20150929@Victor]
	Task: Login to Affiliate thru Internal site
	DB: DBLIC.bodb_Licensee
	Param's Explanation:
		
	Revisions:
		- 20171002@Percy: Write more password into log [RedmineID: #83692]
*/

BEGIN
	SET NOCOUNT ON

	DECLARE @Begin		DATETIME
	DECLARE @Duration	INT

	SET @Begin = GETDATE()

	DECLARE @FirstName	NVARCHAR(50)
	DECLARE @LastName	NVARCHAR(50)
	DECLARE @UserRole	VARCHAR(50)
	DECLARE @Email		VARCHAR(50)
	DECLARE @Status		VARCHAR(30)
	DECLARE @LogData	NVARCHAR(600)

	IF (DATEDIFF(SECOND, @LoginTime, GETDATE()) > 90)
	BEGIN
		SELECT @ErrCode = 100, @ErrMsg = 'The link has been expired!'
		
		SET @LogData = 'Failed(Link_Expired)'
	END
	ELSE
	BEGIN
		SELECT @UserID = UserID, @UserRole = UserRole, @FirstName = FirstName, @LastName = LastName, @Email = Email, @Status = Status
		FROM dbo.Users WITH (NOLOCK)
		WHERE Username = @UserName
			AND LicenseeName = @LicenseeName
			AND UserPwd = @EncryptedPassword
			AND IsInternal = 1

		IF (ISNULL(@UserID, 0) = 0)
		BEGIN
			SELECT @ErrCode = 101, @ErrMsg = 'Wrong username or password.'
		
			SET @LogData = 'Failed(User_Not_Found)'
		END
		ELSE IF (@Status <> 'Open')
		BEGIN
			SELECT @ErrCode = 102, @ErrMsg = 'This user is not active.'
		
			SET @LogData = 'Failed(User_Not_Active)'
		END
		ELSE
		BEGIN
			DECLARE @LicenseeID INT, @RowCnt INT, @EnableBA BIT, @IsAllowedMemberComm BIT

			IF @UserRole = 'Licensee'
			BEGIN
				SELECT @RowCnt = COUNT(*) FROM dbo.Aff_LicenseeUser WITH (NOLOCK) WHERE UserID = @UserID AND IsActive = 1
				
				IF (@RowCnt > 1)
				BEGIN
					SELECT @ErrCode = 103, @ErrMsg = 'This user has too many licensees.'
					
					SET @LogData = 'Failed(User_Too_Many_Licensees)'
				END	
				ELSE
				BEGIN
					SELECT @LicenseeID = LicenseeID FROM dbo.Aff_LicenseeUser WITH (NOLOCK)
					WHERE UserID = @UserID AND IsActive = 1
			
					IF (@LicenseeID IS NULL)
					BEGIN
							SELECT @ErrCode = 104, @ErrMsg = 'This user has no licensee.'
							
							SET @LogData = 'Failed(User_Not_Found_Licensee)'     
					END
					ELSE
					BEGIN
						SELECT @EnableBA = EnableBA FROM dbo.LicenseeBAConfig WITH (NOLOCK) WHERE LicenseeID = @LicenseeID
						SELECT @IsAllowedMemberComm = IsAllowedMemberComm FROM dbo.Licensees WITH (NOLOCK) WHERE LicenseeID = @LicenseeID

						SELECT
							@UserID							AS UserID,
							@Username						AS Username,
							@UserRole						AS UserRole,
							@FirstName						AS FirstName,
							@LastName						AS LastName,
							@Email							AS Email,
							@Status							AS Status,
							@LicenseeID						AS LicenseeID,
							ISNULL(@EnableBA, 0)			AS EnableBA,
							isnull(@IsAllowedMemberComm, 0) AS IsAllowedMemberComm,
							1								AS IsInternal
						
						SET @LogData = 'Success'
					END	
				END
			END
		END
	END

	IF ISNULL(@LogData, '') <> ''
	BEGIN
		SELECT @UserID = ISNULL(@UserID, 0), @ServerID = 200, @Duration = DATEDIFF(MILLISECOND, @Begin, GETDATE())
		SELECT @LogData	= 'User: ' + @UserName +  ' - ' + 'Password: ' + @EncryptedPassword + ' - ' + @LogData

		EXEC dbo.Aff_WriteLog_UserLog_Login
			@UserID = @UserID,
			@ServerID = @ServerID,
			@LoginIP = @LoginIP,
			@DomainName = @LoginDomain,
			@ActionID = 5001,
			@Doing = @LogData,
			@BrowserName = @BrowserName,
			@Platform = @Platform,
			@CountryCode = @CountryCode,
			@Duration = @Duration
	END
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[Aff_InternalLogin] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[Aff_InternalLogin] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Aff_InternalLogin] TO [bodbLicenseeNet]
GO 
