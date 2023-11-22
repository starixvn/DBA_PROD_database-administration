/*
	Created: 20231026@Sol
	Task: disable log shipping job fps_db02
	DB: fps_db02-msdb
*/

GO

USE msdb;

GO

---disable backup job
EXEC msdb.dbo.sp_update_job @job_name = N'LSAlert_FPS_DB02', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSBackup_FPS_DeviceFingerprint', @enabled = 0;

GO