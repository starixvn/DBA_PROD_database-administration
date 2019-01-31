/*
	Task: Alter sps to get bodb_licensee data from db053 (HA DB052 down, for OddsFeed)
	Run at DB054
*/


USE [bodb_OddsFeed]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[Odds_ExistedAdmin_Sel]
	@Username VARCHAR(50),
	@ErrCode INT  = 0 OUTPUT,
	@ErrMsg NVARCHAR(200) = '' OUTPUT
AS  
  
/**    
 * Created : 20130312@Long
 * Task  : Get existed administrator
 * DB  : bodb_oddsfeed,bodb02, bodb_Licensee 
 *    
 * Revisions:       
 * Param's Explanation:   
 */  
SET NOCOUNT ON;

IF EXISTS(SELECT TOP 1 *
			FROM bodb02.dbo.customer c with(nolock)
			WHERE c.roleid=6 and c.username=@Username)
BEGIN
	SELECT c.username, c.firstname, c.lastname, c.email, c.userpwd as password, '1' as roleid
	FROM bodb02.dbo.customer c with(nolock)
	WHERE c.roleid=6 and c.username=@Username
	ORDER BY c.username
END
ELSE
BEGIN
	IF EXISTS(SELECT TOP 1 *
				FROM DB053.bodb_Licensee.dbo.Users u with(nolock)
				WHERE u.userrole='Licensee' and u.username=@Username)
	BEGIN
		SELECT u.username, u.firstname, u.lastname, u.email, u.userpwd as password, '2' as roleid
		FROM DB053.bodb_Licensee.dbo.Users u with(nolock)
		WHERE u.userrole='Licensee' and u.username=@Username
		ORDER BY u.username
	END
	ELSE
	BEGIN
		SELECT @ErrCode = 10043, @ErrMsg = 'Error! Cannot find this username. This account is not existed.'
		RETURN
	END
END
  



GO

GRANT EXECUTE ON [dbo].[Odds_ExistedAdmin_Sel] TO [bodbAdminNet] AS [dbo]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[Odds_LicenseeSel]
AS
/*
Created: 20130307@Phillip
Task : Select list licensee
DB: DBLIC.bodb_Licensee
Revisions:
	- 

Param's Explanation:
	- 
*/

SET NOCOUNT ON


SELECT [LicenseeID]
      ,[LicenseeName]
FROM DB053.bodb_Licensee.dbo.licensees WITH(NOLOCK)
WHERE [LicenseeID] not in (SELECT [LicenseeID] 
							FROM [dbo].[System] with (nolock) 
							WHERE [LicenseeID] is not null)





GO

GRANT EXECUTE ON [dbo].[Odds_LicenseeSel] TO [bodbAdminNet] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[Odds_LicenseeSel] TO [VNTeam] AS [dbo]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[Odds_Top10Admin_Sel]
	@Username VARCHAR(50)
AS  
  
/**    
 * Created : 20130312@Long
 * Task  : Get existed administrator
 * DB  : bodb_oddsfeed,bodb02, bodb_Licensee 
 *    
 * Revisions:       
 * Param's Explanation:   
 */  
SET NOCOUNT ON;

SELECT TOP 10 RES.username
FROM (
	SELECT c.username	
	FROM bodb02.dbo.customer c with(nolock)
	WHERE c.roleid in (6,10) and c.username like '%' + @Username + '%'
	UNION
	SELECT u.username
	FROM DB053.bodb_Licensee.dbo.Users u with(nolock)
	WHERE u.userrole='Licensee' and u.username like '%' + @Username + '%'
) as RES
WHERE RES.username NOT IN
	(SELECT username
	from AdminUser with(nolock))
  


  



GO

GRANT ALTER ON [dbo].[Odds_Top10Admin_Sel] TO [bodbAdminNet] AS [dbo]
GO

GRANT CONTROL ON [dbo].[Odds_Top10Admin_Sel] TO [bodbAdminNet] AS [dbo]
GO

GRANT EXECUTE ON [dbo].[Odds_Top10Admin_Sel] TO [bodbAdminNet] AS [dbo]
GO

GRANT TAKE OWNERSHIP ON [dbo].[Odds_Top10Admin_Sel] TO [bodbAdminNet] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[Odds_Top10Admin_Sel] TO [bodbAdminNet] AS [dbo]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


  
ALTER PROCEDURE [dbo].[Odds_User_Login]  
 @UserName VARCHAR(50),  
 @UserPwd VARCHAR(50),   
 @LoginDomain NVARCHAR(300),   
 @LoginIP VARCHAR(20),    
 @SystemIdNameList NVARCHAR(1000)='' OUTPUT,    
 @ErrCode INT = 0 OUTPUT,  
 @ErrMsg NVARCHAR(4000) = '' OUTPUT  
-- with recompile  
AS  
/*  
 * Created: 20121206@Thai  
 * Task : User Login into Odds Feed - Licensee system  
 * DB: [bodb_oddsfeed],[bodb_licensee],[bodb02]  
 *  Description:  
 * Revisions:    
 * Modify:   
  - 20130306@Thai: Check user's role in bodb02 (for IT Admin) and bodb_Licensee (for Licensee)  
  - 20130315@Thai: If "Invalid user name/ password"   
      -> We will increase LoginCount by 1.   
       If LoginCount>5 then we will update the IsActive=0 for this admin in  5 minutes.  
   
*/  
SET NOCOUNT ON  
  
DECLARE @UserID INT  
DECLARE @FirstName NVARCHAR(50)  
DECLARE @LastName NVARCHAR(50)  
DECLARE @RoleID TINYINT  
DECLARE @Email VARCHAR(50)  
DECLARE @IsActive BIT  
DECLARE @LoginCount INT  
DECLARE @IsImport BIT  
DECLARE @LogData NVARCHAR(500)  
DECLARE @LastLogin DATETIME  
  
DECLARE @IsSuccess BIT  
DECLARE @UserRole NVARCHAR(50)  
  
DECLARE @MaxLoginCount INT  
DECLARE @MaxLoginTime INT  
  
SET @MaxLoginCount = 5  
SET @MaxLoginTime = 5  
  
-- If LoginCount = 5 then we will lock this user in  5 minutes.  
SELECT @LoginCount = LoginCount, @LastLogin = LastLogin FROM AdminUser WITH (NOLOCK) WHERE Username = @UserName  
IF @LoginCount = (@MaxLoginCount+1) AND DATEDIFF(mi, @LastLogin, getdate()) <= @MaxLoginTime  
BEGIN   
 SELECT @ErrMsg = 'Sorry! Your account has been locked in 5 minutes because the number of failed logins is exceeded 5 times. Please contact to administrator!', @ErrCode=100     
 SET @LogData = 'User: ' + @UserName +  ' - ' + 'the number of failed logins is exceeded 5 times'    
END  
ELSE  
BEGIN  
--------------------------------------------------------------------------------------------      
SELECT @UserID=UserID, @RoleID=RoleID, @FirstName=FirstName, @LastName= LastName, @Email= Email, @IsActive= IsActive, @IsImport = IsImport  
FROM AdminUser WITH (NOLOCK)  
WHERE Username = @UserName AND "Password" = @UserPwd  
  
IF (@UserID IS NULL)  
BEGIN  
 SELECT @ErrMsg = 'Wrong username or password.', @ErrCode=101       
    SET @LogData = 'User: ' + @UserName +  ' - ' + 'Failed(User Not Found)'     
          
    -- If LoginCount = 5 then we will update the IsActive=0 for this admin in  5 minutes.  
    IF @LoginCount = @MaxLoginCount   
    BEGIN    
  UPDATE AdminUser WITH (UPDLOCK) SET IsActive = 0, LoginCount = LoginCount + 1, LastLogin = getdate()   
  WHERE Username = @UserName  
    
  SELECT @ErrMsg = 'Sorry! Your account has been locked in 5 minutes because the number of failed logins is exceeded 5 times. Please contact to administrator!', @ErrCode=100     
  SET @LogData = 'User: ' + @UserName +  ' - ' + 'the number of failed logins is exceeded 5 times'    
   
    END  
    ELSE -- increase LoginCount by 1 if IsActive = 1  
    BEGIN   
  UPDATE AdminUser WITH (UPDLOCK) SET LoginCount = LoginCount + 1   
  WHERE Username = @UserName AND IsActive = 1  
 END  
END  
ELSE IF ((@IsActive IS NULL or @IsActive <> 'True') AND @LoginCount = 0)  
BEGIN  
 SELECT @ErrMsg = 'This user is not active.', @ErrCode=102       
    SET @LogData = 'User: ' + @UserName + ' - ' + 'Failed(User Not Active)'     
END  
ELSE  
BEGIN  
  
 SET @IsSuccess = 0    
   
 SET @SystemIdNameList = ''  
    
 -- Check user's role in bodb02 (for IT Admin) and bodb_Licensee (for Licensee)  
 IF @IsImport = 1   
 BEGIN  
  IF @RoleID = 1 -- @UserRole = 'IT Administrator'  
  BEGIN  
   DECLARE @RoleAdminID INT  
   SELECT @RoleAdminID = roleid FROM bodb02.dbo.Customer WITH (NOLOCK) WHERE custid = @UserID   
   IF @RoleAdminID = 6 -- IT Admin  
   BEGIN  
    -- no need to check permission more  
    SET @IsSuccess = 1     
    SET @LogData = 'IT Administrator Account: ' + @username +  ' - ' + 'Success'        
   END         
  END  
  ELSE  
  IF @RoleID = 2 -- @UserRole = 'Licensee'  
  BEGIN  
   -- Check permission on bodb_licensee  
   IF NOT EXISTS (SELECT 1 FROM DB053.bodb_licensee.dbo.LicenseeUser l WITH (NOLOCK)  
       INNER JOIN DB053.bodb_licensee.dbo.Users u WITH (NOLOCK) on l.UserID = u.UserID  
       WHERE u.UserID = @UserID and l.isActive = 1)  
   BEGIN  
    SELECT @ErrMsg = 'This user are not authorized to use this system.', @ErrCode=104       
    SET @LogData = 'User: ' + @UserName + ' - ' + 'Failed(User Not Authorized)'     
   END       
   ELSE  
   BEGIN   
    DECLARE @RoleLicensee VARCHAR(50)  
    SELECT @RoleLicensee = UserRole FROM DB053.bodb_licensee.dbo.Users WITH (NOLOCK) WHERE UserID = @UserID   
    IF @RoleLicensee = 'Licensee' -- Licensee  
    BEGIN  
     -- no need to check permission more  
     SET @IsSuccess = 1     
     SET @LogData = 'Licensee Account: ' + @username +  ' - ' + 'Success'        
    END         
   END  
  END  
    
 END  
   
 -- Check in local db (bodb_oddsfeed)  
 IF @IsSuccess = 0   
 BEGIN   
  -- Get LicenseeID & SystemID  
  SELECT   
      @SystemIdNameList = CAST(s.SystemID as varchar) + ',' + s.SystemName + ';' +  @SystemIdNameList  
  FROM AdminUserSystem a WITH (NOLOCK)  
  INNER JOIN [System] s WITH (NOLOCK) on a.SystemID = s.SystemID    
  WHERE a.UserID = @UserID and a.IsActive = 1  
     and ( (@RoleID = 1)  or  (@RoleID <> 1 and s.IsActive = 1 ))
  ORDER BY s.SystemName DESC  
    
  -- Check Permission  
  IF @SystemIdNameList = ''  
  BEGIN  
   SELECT @ErrMsg = 'This user has no permission.', @ErrCode=103       
   SET @LogData = 'User: ' + @UserName + ' - ' + 'Failed(No Permission)'     
  END  
  ELSE  
  BEGIN  
   IF @RoleID = 1 -- @UserRole = 'IT Administrator'  
   BEGIN          
    SET @IsSuccess = 1          
    SET @LogData = 'IT Administrator Account: ' + @username +  ' - ' + 'Success'        
   END  
   ELSE   
   IF @RoleID = 2 -- @UserRole = 'Licensee'  
   BEGIN      
    SET @IsSuccess = 1       
    SET @LogData = 'Licensee Account: ' + @username +  ' - ' + 'Success'        
   END  
   ELSE  
   IF @RoleID = 3 -- @UserRole = 'Licensee Sub-Account'  
   BEGIN          
    SET @IsSuccess = 1          
    SET @LogData = 'Licensee Sub-Account: ' + @username +  ' - ' + 'Success'    
   END     
  END     
    
 END  
    
END  
  
-- Update LastLogin, Unclock if over 5 mins  
IF @IsSuccess = 1   
BEGIN   
 UPDATE AdminUser WITH (UPDLOCK)  
 SET   
  IsActive = 1,  
  LoginCount = 0,  
  LastLogin = getdate()  
 WHERE UserID = @UserID  
END  
  
--------------------------------------------------------------------------------------------  
END  
  
SELECT @UserID AS UserID,@Username AS Username,@RoleID AS RoleID, @FirstName AS FirstName,@LastName LastName, @Email AS Email, @IsActive AS IsActive  
  
--Write the log   
DECLARE @ExecutingSPName VARCHAR(50)  
SELECT @ExecutingSPName = OBJECT_NAME(@@ProcID)   
  
SET @UserID = ISNULL(@UserID,0)  
  
EXEC Odds_WriteLog  
   @Creator = @UserID,  
   @PartnerId = @UserID,  
   @Typename = 'Statistics',  
   @SPName = @ExecutingSPName,   
   @IP = @LoginIP,  
   @Detail = @LogData  
   
  

GO

GRANT EXECUTE ON [dbo].[Odds_User_Login] TO [bodbAdminNet] AS [dbo]
GO


