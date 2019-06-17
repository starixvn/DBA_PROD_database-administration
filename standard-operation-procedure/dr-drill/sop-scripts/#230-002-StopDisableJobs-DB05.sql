/*
	Creator:	20190617@Billy
	Task:		Disable jobs before drill - DB05 - [Redmine: #114307]
	Server:		DB05@MNL

	Revision:
		- 20190617@Billy:	Initialization - [Redmine: #114307]
*/

IF	@@SERVERNAME <> N'DB05' OR DB_ID(N'_This_MNL_DR_site') IS NULL
BEGIN;
	RAISERROR('This script cannot be run on this server!', 16, 1) WITH NOWAIT;
	RETURN;
END;

--	BEGIN STEP 1:
--		Disable jobs
----------------------------------------------------------------------------------------------------

EXECUTE	msdb.dbo.sp_update_job @enabled = 0, @job_name = N'DBA_Restore DB From IBC';
GO