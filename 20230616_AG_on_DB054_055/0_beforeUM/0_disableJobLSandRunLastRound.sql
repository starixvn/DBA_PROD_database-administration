/*
	set up AG on DB054/DB055
	Add bodb_N88Log & bodb_NAPLog to AG
	20230616@Brice: disable LS jobs
	run on DB054/DB055
*/

USE [msdb]
GO
if @@servername = 'DB054'
begin
	EXEC msdb.dbo.sp_update_job @job_name=N'LSBackup_bodb_N88Log', @enabled=0
	EXEC msdb.dbo.sp_update_job @job_name=N'LSBackup_bodb_NAPLog', @enabled=0
	
	EXEC sp_start_job   @job_name=N'LSBackup_bodb_N88Log'
	EXEC sp_start_job   @job_name=N'LSBackup_bodb_NAPLog'
end
else if @@servername = 'DB055'
begin
	EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_DB054_bodb_N88Log', @enabled=0
	EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_DB054_bodb_N88Log', @enabled=0
	EXEC msdb.dbo.sp_update_job @job_name=N'LSCopy_DB054_bodb_NAPLog', @enabled=0
	EXEC msdb.dbo.sp_update_job @job_name=N'LSRestore_DB054_bodb_NAPLog', @enabled=0
	
	EXEC sp_start_job   @job_name=N'LSCopy_DB054_bodb_N88Log'
	EXEC sp_start_job   @job_name=N'LSCopy_DB054_bodb_NAPLog'
	EXEC sp_start_job   @job_name=N'LSRestore_DB054_bodb_N88Log'
	EXEC sp_start_job   @job_name=N'LSRestore_DB054_bodb_NAPLog'
end