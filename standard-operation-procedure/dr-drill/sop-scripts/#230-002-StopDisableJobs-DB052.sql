/*
	Creator:	20190617@Billy
	Task:		#230-002 - Disable jobs before drill - DB052 - [Redmine: #114307]
	Server:		DB052@MNL

	Revision:
		- 20190617@Billy:	Initialization - [Redmine: #114307]
*/

IF	@@SERVERNAME <> N'DB052' OR DB_ID(N'_This_MNL_DR_site') IS NULL
BEGIN;
	RAISERROR('This script cannot be run on this server!', 16, 1) WITH NOWAIT;
	RETURN;
END;

--	BEGIN STEP 1:
--		Disable jobs
----------------------------------------------------------------------------------------------------

EXECUTE	msdb.dbo.sp_update_job @enabled = 0, @job_name = N'bodb_LicenseeReport: DW - Generate Daily';
EXECUTE	msdb.dbo.sp_update_job @enabled = 0, @job_name = N'bodb_LicenseeReport: Daily Summary Licensee Winloss';
EXECUTE	msdb.dbo.sp_update_job @enabled = 0, @job_name = N'bodb_LicenseeReport: Daily Gen Daily rptLicIpBetting';
GO;