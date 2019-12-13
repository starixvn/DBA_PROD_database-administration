/*
	Creator:	20190617@Billy
	Task:		#230-002 - Disable jobs before drill - DB06 - [Redmine: #114307]
	Server:		DB06@MNL

	Revision:
		- 20190617@Billy:	Initialization - [Redmine: #114307]
*/

IF	@@SERVERNAME <> N'DB06' OR DB_ID(N'_This_MNL_DR_site') IS NULL
BEGIN;
	RAISERROR('This script cannot be run on this server!', 16, 1) WITH NOWAIT;
	RETURN;
END;

--	BEGIN STEP 1:
--		Disable jobs
----------------------------------------------------------------------------------------------------

EXECUTE	msdb.dbo.sp_update_job @enabled = 0, @job_name = N'bodb_Report: Daily Summary rptStatement';
EXECUTE	msdb.dbo.sp_update_job @enabled = 0, @job_name = N'bodb_Report: Weekly Archive Into rptStatementOld';
EXECUTE	msdb.dbo.sp_update_job @enabled = 0, @job_name = N'bodb_Report: Customer Status History';
EXECUTE	msdb.dbo.sp_update_job @enabled = 0, @job_name = N'bodb02: Deposit Report Summary';
EXECUTE	msdb.dbo.sp_update_job @enabled = 0, @job_name = N'bodb02: Racing Group Report';
GO