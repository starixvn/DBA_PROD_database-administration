/*
	Created: 20231026@Sol
	Task: disable log shipping job
	DB: 10.40.40.34,16402-msdb
*/

GO

USE msdb;

GO

---log shipping - disabled copy/restore job
EXEC msdb.dbo.sp_update_job @job_name = N'LSAlert_FPS_DB02', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSCopy_FPS_DB02_FPS_DeviceFingerprint', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSRestore_FPS_DB02_FPS_DeviceFingerprint', @enabled = 0;

GO