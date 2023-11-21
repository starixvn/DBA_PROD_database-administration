/*
	Created: 20230912@Sol
	Task: setup email 10.40.40.33,16401
	DB: 10.40.40.33,16401-msdb
*/

 
-------------------------------------------------------------------------------------------------- 
-- BEGIN Mail Settings FPS_DB02_DBMail_Profile 
-------------------------------------------------------------------------------------------------- 
IF NOT EXISTS(SELECT * FROM msdb.dbo.sysmail_profile WHERE  name = 'FPS_DB02_DBMail_Profile')  
BEGIN 
	--CREATE Profile [FPS_DB02_DBMail_Profile] 
	EXECUTE msdb.dbo.sysmail_add_profile_sp 
		@profile_name = 'FPS_DB02_DBMail_Profile', 
		@description  = 'DBMail_Profile_for_FPS_DB02'; 
END --IF EXISTS profile 

GO
   
IF NOT EXISTS(SELECT * FROM msdb.dbo.sysmail_account WHERE  name = 'FPS_DB02') 
BEGIN 
	--CREATE Account [FPS_DB02] 
	EXECUTE msdb.dbo.sysmail_add_account_sp 
	@account_name            = 'FPS_DB02', 
	@email_address           = 'DBAAdmin@onelab.tw', 
	@display_name            = 'FPS_DB02', 
	@replyto_address         = '', 
	@description             = 'DB Mail Account for FPS_DB02', 
	@mailserver_name         = '10.40.40.45', 
	@mailserver_type         = 'SMTP', 
	@port                    = '25', 
	@username                =  NULL , 
	@password                =  NULL ,  
	@use_default_credentials =  0 , 
	@enable_ssl              =  0 ; 
END --IF EXISTS  account 

GO
   
IF NOT EXISTS(SELECT * 
              FROM msdb.dbo.sysmail_profileaccount pa 
                INNER JOIN msdb.dbo.sysmail_profile p ON pa.profile_id = p.profile_id 
                INNER JOIN msdb.dbo.sysmail_account a ON pa.account_id = a.account_id   
              WHERE p.name = 'FPS_DB02_DBMail_Profile' 
                AND a.name = 'FPS_DB02')  
BEGIN 
	-- Associate Account [FPS_DB02] to Profile [FPS_DB02_DBMail_Profile] 
	EXECUTE msdb.dbo.sysmail_add_profileaccount_sp 
		@profile_name = 'FPS_DB02_DBMail_Profile', 
		@account_name = 'FPS_DB02', 
		@sequence_number = 1 ; 
END  
GO