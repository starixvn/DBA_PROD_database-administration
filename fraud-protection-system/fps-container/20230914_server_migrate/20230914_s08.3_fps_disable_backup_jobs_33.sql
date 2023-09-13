/*
	Created: 20230912@Sol
	Task: disable log shipping job
	DB: 10.40.40.33,16401-msdb
*/

GO

USE msdb;

GO

EXEC msdb.dbo.sp_update_job @job_name = N'LSAlert_FPS_DB02-FPS_01', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSCopy_FPS_DB02\FPS_01_FPS_ADMIN_33', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSCopy_FPS_DB02\FPS_01_FPS_BODB_TRANS_33', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSCopy_FPS_DB02\FPS_01_FPS_DEV_33', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSCopy_FPS_DB02\FPS_01_FPS_EVI_33', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSCopy_FPS_DB02\FPS_01_FPS_MiddleService_33', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSCopy_FPS_DB02\FPS_01_FPS_RPT_33', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSRestore_FPS_DB02\FPS_01_FPS_ADMIN_33', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSRestore_FPS_DB02\FPS_01_FPS_BODB_TRANS_33', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSRestore_FPS_DB02\FPS_01_FPS_DEV_33', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSRestore_FPS_DB02\FPS_01_FPS_EVI_33', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSRestore_FPS_DB02\FPS_01_FPS_MiddleService_33', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSRestore_FPS_DB02\FPS_01_FPS_RPT_33', @enabled = 0;

GO