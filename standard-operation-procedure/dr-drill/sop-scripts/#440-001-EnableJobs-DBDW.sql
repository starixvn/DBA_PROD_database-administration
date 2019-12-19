/*
	Creator:	20190617@Billy
	Task:		#440-001 - Enable jobs after drill - DBDW - [Redmine: #114307]
	Server:		DBDW@MNL

	Revision:
		- 20190617@Billy:	Initialization - [Redmine: #114307]
		- 20191213@Billy:	Add new job - [Redmine: #125425]
*/

IF	@@SERVERNAME <> N'DBDW' OR DB_ID(N'_This_MNL_DR_site') IS NULL
BEGIN;
	RAISERROR('This script cannot be run on this server!', 16, 1) WITH NOWAIT;
	RETURN;
END;

--	BEGIN STEP 1:
--		Disable jobs
----------------------------------------------------------------------------------------------------

EXECUTE	msdb.dbo.sp_update_job @enabled = 1, @job_name = N'bodb_Account - Data Quality Monitor';
EXECUTE	msdb.dbo.sp_update_job @enabled = 1, @job_name = N'bodb_Account - DW ETL Daily';
EXECUTE	msdb.dbo.sp_update_job @enabled = 1, @job_name = N'bodb_Account - Generate Account Transfer';
EXECUTE	msdb.dbo.sp_update_job @enabled = 1, @job_name = N'bodb_Account - Generate Monthly DW';
EXECUTE	msdb.dbo.sp_update_job @enabled = 1, @job_name = N'bodb_Account - Import data for Virtual rate monitor';
EXECUTE	msdb.dbo.sp_update_job @enabled = 1, @job_name = N'bodb_Account - Purge old data';
EXECUTE	msdb.dbo.sp_update_job @enabled = 1, @job_name = N'bodb_Account - Update Dimensions';
EXECUTE	msdb.dbo.sp_update_job @enabled = 1, @job_name = N'bodb_Account - Update Direct cust group';
EXECUTE	msdb.dbo.sp_update_job @enabled = 1, @job_name = N'bodb_Account - Update Exchange';
EXECUTE	msdb.dbo.sp_update_job @enabled = 1, @job_name = N'bodb_Account - Update IP table';
EXECUTE	msdb.dbo.sp_update_job @enabled = 1, @job_name = N'bodb_Account - Update League';
EXECUTE	msdb.dbo.sp_update_job @enabled = 1, @job_name = N'bodb_Account - Update Oanda Daily Exchange for Licensee';
EXECUTE	msdb.dbo.sp_update_job @enabled = 1, @job_name = N'DBA - Backup Full Weekly';
EXECUTE	msdb.dbo.sp_update_job @enabled = 1, @job_name = N'DBA - System Database Backup';
EXECUTE	msdb.dbo.sp_update_job @enabled = 1, @job_name = N'DBA - Update statistic';
GO