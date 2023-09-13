/*
	Created: 20230912@Sol
	Task: setup email 10.40.40.33,16401
	DB: 10.40.40.33,16401-msdb
*/

USE msdb;

GO
-------------------------------------------------------------------------------------------------- 
-- BEGIN Mail Settings DBMail_Profile_FPS_DB02\FPS_01 
-------------------------------------------------------------------------------------------------- 
IF NOT EXISTS (
		SELECT *
		FROM msdb.dbo.sysmail_profile
		WHERE name = 'DBMail_Profile_FPS_DB02-FPS_01'
		)
BEGIN
	--CREATE Profile [DBMail_Profile_FPS_DB02\FPS_01] 
	EXECUTE msdb.dbo.sysmail_add_profile_sp @profile_name = 'DBMail_Profile_FPS_DB02-FPS_01',
		@description = '';
END 

--IF EXISTS profile 
IF NOT EXISTS (
		SELECT *
		FROM msdb.dbo.sysmail_account
		WHERE name = 'FPS_DB02-FPS_01'
		)
BEGIN
	--CREATE Account [FPS_DB02\FPS_01] 
	EXECUTE msdb.dbo.sysmail_add_account_sp @account_name = 'FPS_DB02-FPS_01',
		@email_address = 'DBAAdmin@onelab.tw',
		@display_name = 'FPS_DB02-FPS_01',
		@replyto_address = '',
		@description = 'DB Mail Account for FPS_DB02-FPS_01',
		@mailserver_name = '10.40.40.45',
		@mailserver_type = 'SMTP',
		@port = '25',
		@username = NULL,
		@password = NULL,
		@use_default_credentials = 0,
		@enable_ssl = 0;
END 

--IF EXISTS  account 
IF NOT EXISTS (
		SELECT *
		FROM msdb.dbo.sysmail_profileaccount pa
		INNER JOIN msdb.dbo.sysmail_profile p ON pa.profile_id = p.profile_id
		INNER JOIN msdb.dbo.sysmail_account a ON pa.account_id = a.account_id
		WHERE p.name = 'DBMail_Profile_FPS_DB02-FPS_01'
			AND a.name = 'FPS_DB02-FPS_01'
		)
BEGIN
	-- Associate Account [FPS_DB02\FPS_01] to Profile [DBMail_Profile_FPS_DB02\FPS_01] 
	EXECUTE msdb.dbo.sysmail_add_profileaccount_sp @profile_name = 'DBMail_Profile_FPS_DB02-FPS_01',
		@account_name = 'FPS_DB02-FPS_01',
		@sequence_number = 1;
END

GO