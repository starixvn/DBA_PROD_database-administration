/***
	- Created@2021224: Bobby
	- Host: Run on KBT@DB052 -- old One
	- Task: Delete LS primary databases on DB052
***/
use msdb;
GO
EXEC dbo.sp_start_job @job_name=N'LSBackup_Affiliate_12BET';
GO
EXEC dbo.sp_start_job @job_name=N'LSBackup_Affiliate_Aoncash';
GO
EXEC dbo.sp_start_job @job_name=N'LSBackup_Affiliate_Athena000';
GO
EXEC dbo.sp_start_job @job_name=N'LSBackup_Affiliate_itcbet';
GO
EXEC dbo.sp_start_job @job_name=N'LSBackup_Affiliate_MacauBet';
GO
EXEC dbo.sp_start_job @job_name=N'LSBackup_Affiliate_N88';
GO
EXEC dbo.sp_start_job @job_name=N'LSBackup_Affiliate_N8B';
GO
EXEC dbo.sp_start_job @job_name=N'LSBackup_Affiliate_N8G';
GO
EXEC dbo.sp_start_job @job_name=N'LSBackup_Affiliate_Spondemo';
GO
EXEC dbo.sp_start_job @job_name=N'LSBackup_bodb_3rdProduct';
GO
EXEC dbo.sp_start_job @job_name=N'LSBackup_bodb_CRM';
GO
EXEC dbo.sp_start_job @job_name=N'LSBackup_bodb_Maintenance';
GO
EXEC dbo.sp_start_job @job_name=N'LSBackup_bodb_MMS';
GO
EXEC dbo.sp_start_job @job_name=N'LSBackup_bodb_Oddsfeed';
GO
EXEC dbo.sp_start_job @job_name=N'LSBackup_bodb_OIC';
GO
EXEC dbo.sp_start_job @job_name=N'LSBackup_bodb_PlaytechCS';
GO
EXEC dbo.sp_start_job @job_name=N'LSBackup_bodb_RMS';
GO