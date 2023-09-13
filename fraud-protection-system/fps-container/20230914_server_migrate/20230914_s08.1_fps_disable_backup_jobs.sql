/*
	Created: 20230912@Sol
	Task: disable log shipping job
	DB: FPS_DB02\FPS_01-msdb
*/

GO

USE msdb;

GO

EXEC msdb.dbo.sp_update_job @job_name = N'LSAlert_FPS_DB02\FPS_01', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSBackup_FPS_ADMIN', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSBackup_FPS_BODB_TRANS', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSBackup_FPS_DEV', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSBackup_FPS_EVI', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSBackup_FPS_MiddleService', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSBackup_FPS_RPT', @enabled = 0;

GO