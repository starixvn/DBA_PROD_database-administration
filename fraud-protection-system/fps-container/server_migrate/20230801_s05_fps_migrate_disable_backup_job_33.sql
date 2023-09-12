/*
	Created: 20230801@Sol
	Task: disable log shipping job
	DB: 10.40.40.33,16401-msdb
*/

GO

USE msdb;

GO

---log shipping - disabled copy/restore job
EXEC msdb.dbo.sp_update_job @job_name = N'LSCopy_FPS_DB02\FPS_01_FPS_LOG', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSCopy_FPS_DB02\FPS_01_FPS_ADMIN_33', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSRestore_FPS_DB02\FPS_01_FPS_LOG', @enabled = 0;
EXEC msdb.dbo.sp_update_job @job_name = N'LSRestore_FPS_DB02\FPS_01_FPS_ADMIN_33', @enabled = 0;