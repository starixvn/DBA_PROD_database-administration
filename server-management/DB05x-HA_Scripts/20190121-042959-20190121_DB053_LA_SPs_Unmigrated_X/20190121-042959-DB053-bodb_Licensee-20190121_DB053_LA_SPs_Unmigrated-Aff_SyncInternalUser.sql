
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Aff_SyncInternalUser    Script Date: 1/21/2019 4:30:00 AM ******/

CREATE PROCEDURE [dbo].[Aff_SyncInternalUser]
	@LicenseeName		VARCHAR(50),
	@Username			VARCHAR(MAX),
	@EncryptedPassword	VARCHAR(MAX),
	@Langkey			VARCHAR(20) = 'en-US',
	@AffGroup			TINYINT = 0,
	@ErrMsg				NVARCHAR(1000)	= '' OUTPUT,
    @ErrCode			INT				= 0 OUTPUT
AS

/*
	Created by: [20150929@Victor]
	Task: Synchronize Affiliate User thru Internal site
	DB: DBLIC/bodb_Licensee
	Param's Explanation:
	@AffGroup: 0 - None, 1 - Affiliate Admin
	@Username = 'pgmPeter,StarixDev'
	@EncryptedPassword = 'dasdweifrgnf,ghatreDGNH'
	
	Revisions:
		- 20151215@Francis: Support multiple users synchronization
		- 20160125@Francis: Revise sp to ignore user with blank username or password
		- 20161206@Alex: Always sync currencies for all users.
		- 20171002@Percy: Write more password into log [RedmineID: #83692]
		- 20180108@Percy: Hotfix - Dont remove user policy [RedmineID: #89235]
		- 20180109@Don: Hotfix - In case of inserting new user, updating wrong password [RedmineID: #89235]
*/

BEGIN
	SET NOCOUNT ON
	
	DECLARE @Begin		DATETIME
	DECLARE @Duration	INT
	DECLARE @LogData	NVARCHAR(4000)

	SET @Begin = GETDATE()

	DECLARE @LicenseeID INT
	DECLARE @UserID		INT
	
	DECLARE @Currency		TABLE (CurrencyID INT)
	DECLARE @UsrTable		TABLE (ID INT IDENTITY(1,1), UsrName VARCHAR(50))
	DECLARE @PassWordTable	TABLE (ID INT IDENTITY(1,1), EncPassword VARCHAR(50))
	
	DECLARE @UsrName VARCHAR(50), @Password VARCHAR(50), @i INT

	SELECT @LicenseeID = LicenseeID FROM dbo.Licensees WITH (NOLOCK) WHERE LicenseeName = @LicenseeName
	
	IF @LicenseeID IS NULL
	BEGIN
		SET @ErrMsg = CASE @Langkey WHEN 'en-US' THEN 'The Licensee: ' + @LicenseeName + ' does not exist!'
									ELSE [bodb02].[dbo].[Lrf_f_Get_MsgNamebyMsgID](200021, @Langkey)
									END	
		SET @ErrCode = 101

		SELECT @LogData = 'Failed(Licensee_Not_Exist) - LicenseeName: ' + @LicenseeName
	END
	ELSE
	BEGIN
		INSERT INTO @UsrTable (UsrName)
		SELECT val FROM dbo.strSplit(@Username, ',')

		INSERT INTO @PassWordTable(EncPassword)
		SELECT val FROM dbo.strSplit(@EncryptedPassword, ',')

		IF ((SELECT MAX(id) FROM @UsrTable) <> (SELECT MAX(id) FROM @PassWordTable))
		BEGIN
			SET @ErrMsg = CASE @Langkey WHEN 'en-US' THEN 'The total number of usernames are not equal to the total number of passwords provided!'
										ELSE [bodb02].[dbo].[Lrf_f_Get_MsgNamebyMsgID](200021, @Langkey)
										END	
			SET @ErrCode = 102
			
			SELECT @LogData = 'Failed(No.Usernames_Not_Equal_No.Passwords)'
		END
		ELSE
		BEGIN
			DECLARE @cmd VARCHAR(8000)

			SELECT @cmd = '
			DECLARE @AffiliateCurrencies varchar(4000)
			SELECT @AffiliateCurrencies = Svalue FROM DBAFF.Affiliate_' + @LicenseeName + '.dbo.SystemSettings WITH (NOLOCK) WHERE Sname = ''AffiliateCurrencies''

			SELECT cc.PartnerExchangeID
			FROM dbo.strSplit (@AffiliateCurrencies,'','')
			INNER JOIN DBAFF.Affiliate_' + @LicenseeName + '.dbo.Currency c WITH (NOLOCK) ON c.CurrencyCode = val
			LEFT JOIN DBAFF.Affiliate_' + @LicenseeName + '.dbo.CurrencyConverter cc WITH (NOLOCK) on c.CurrencyID = cc.ExchangeID'

			INSERT INTO @Currency (CurrencyID)
			EXEC (@cmd)

			DECLARE @LogIns NVARCHAR(1500), @LogUpd NVARCHAR(1500)

			DECLARE @UserOldPassWord VARCHAR(50)

			SET @i = 1
			
			WHILE EXISTS (SELECT 1 FROM @UsrTable WHERE id = @i)
			BEGIN
				SELECT @UsrName = '', @Password = ''

				SELECT @UsrName = UsrName FROM @UsrTable WHERE id = @i
		
				SELECT @Password = EncPassword FROM @PassWordTable WHERE id = @i
		
				IF (ISNULL(@UsrName, '') <> '' AND ISNULL(@Password, '') <> '')
				BEGIN
					-- if user exists --> update new password, if not --> insert new
					SELECT @UserID = UserID, @UserOldPassWord = UserPwd
					FROM dbo.Users WITH (NOLOCK)
					WHERE Username = @UsrName AND LicenseeName = @LicenseeName AND IsInternal = 1

					IF @UserID IS NOT NULL
					BEGIN
						UPDATE dbo.Users WITH (ROWLOCK, UPDLOCK)
						SET UserPwd = @Password
						WHERE UserID = @UserID

						IF @LogUpd IS NULL
						BEGIN
							SELECT @LogUpd = 'Success(Update_Passwords): Username - Old Password:' + @UsrName + ' - ' + @UserOldPassWord
						END
						ELSE
						BEGIN
							SELECT @LogUpd = @LogUpd + ',' + @UsrName + ' - ' + @UserOldPassWord
						END
					END
					ELSE
					BEGIN
						INSERT INTO dbo.Users (Username, UserPwd, UserSalt, UserRole, FirstName, LastName, Status, CreateDate, LicenseeName, IsInternal)
						VALUES (@Username, @Password, '', 'Licensee', @Username, '', 'Open', GETDATE(), @LicenseeName, 1)

						SELECT @UserID = @@IDENTITY

						IF @LogIns IS NULL
						BEGIN
						SELECT
							@LogIns = 'Success(Insert_New_Users_into_'
										+ CASE WHEN @AffGroup = 1 THEN 'Admin Group' ELSE 'None Group' END + '):'
										+ ' Username:' + @UsrName
						END
						ELSE
						BEGIN
							SELECT @LogIns = @LogIns + ',' + @UsrName
						END
					END

					DECLARE @AffAdminGroup INT, @AffNoneGroup INT
					SELECT @AffNoneGroup = GroupID FROM dbo.Aff_GroupInfo WITH (NOLOCK) WHERE LicenseeID = @LicenseeID AND GroupName LIKE 'None'
					SELECT @AffAdminGroup = GroupID FROM dbo.Aff_GroupInfo WITH (NOLOCK) WHERE LicenseeID = @LicenseeID AND GroupName LIKE 'Administrator'

					DECLARE @System INT
					SELECT @System = id FROM dbo.Systems WITH (NOLOCK) WHERE SystemName LIKE 'AFF'

					-- Insert Affiliate user settings
					-- Aff Licensee User
					IF NOT EXISTS (SELECT 1 FROM dbo.Aff_LicenseeUser WITH (NOLOCK) WHERE LicenseeID = @LicenseeID AND UserID = @UserID)
					BEGIN
						INSERT INTO Aff_LicenseeUser (LicenseeID, UserID, GroupID, IsActive, ModifyDate, ModifyBy)
						SELECT @LicenseeID, @UserID, CASE WHEN @AffGroup = 1 THEN @AffAdminGroup ELSE @AffNoneGroup END, 1, GETDATE(), NULL
					END
				
					-- User Currency
					INSERT INTO dbo.CurrencyUser (UsrID, LicenseeID, CurrencyID, SystemID, IsActive)
					SELECT @UserID, @LicenseeID, CurrencyID, @System, 1
					FROM @Currency
					WHERE CurrencyID NOT IN (
						SELECT CurrencyID FROM dbo.CurrencyUser WITH (NOLOCK) WHERE UsrID = @UserID AND LicenseeID = @LicenseeID AND SystemID = @System
					)
				END
				
				SET @i = @i + 1
			END
			
			IF @LogIns IS NOT NULL OR @LogUpd IS NOT NULL
			BEGIN
				SELECT @LogData = 'Success: ' + ISNULL(@LogUpd, '') + CASE WHEN ISNULL(@LogUpd, '') = '' THEN '' ELSE ' - ' END + ISNULL(@LogIns, '')
			END
		END
	END

	IF @LogData IS NOT NULL
	BEGIN
		SELECT @UserID = ISNULL(@UserID, 0), @Duration = DATEDIFF(MILLISECOND, @Begin, GETDATE())
		SELECT @LogData	= 'Licensee: ' + @LicenseeName + ' - UserList: ' + @UserName +  ' - ' + 'PasswordList: ' + @EncryptedPassword + ' - ' + @LogData

		EXEC dbo.Aff_WriteLog_UserLog_Login
			@UserID		= @UserID,
			@ServerID	= 200,
			@ActionID	= 5002,
			@Doing		= @LogData,
			@Duration	= @Duration
	END
END

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[Aff_SyncInternalUser] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[Aff_SyncInternalUser] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Aff_SyncInternalUser] TO [bodbLicenseeNet]
GO 
