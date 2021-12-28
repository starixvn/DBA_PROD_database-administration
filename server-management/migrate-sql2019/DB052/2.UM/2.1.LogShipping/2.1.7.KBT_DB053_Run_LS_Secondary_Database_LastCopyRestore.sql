/***
	- Created@2021224: Bobby
	- Host: Run on KBT@DB053
	- Task: RUN LS secondary databases on DB053 - Last Run
***/
use msdb;
GO
EXEC dbo.sp_start_job @job_name=N'LSCopy_db052_Affiliate_itcbet';
GO
EXEC dbo.sp_start_job @job_name=N'LSRestore_db052_Affiliate_itcbet';
GO
EXEC dbo.sp_start_job @job_name=N'LSCopy_db052_bodb_OIC';
GO
EXEC dbo.sp_start_job @job_name=N'LSRestore_db052_bodb_OIC';
GO
EXEC dbo.sp_start_job @job_name=N'LSCopy_db052_Affiliate_N8B';
GO
EXEC dbo.sp_start_job @job_name=N'LSRestore_db052_Affiliate_N8B';
GO
EXEC dbo.sp_start_job @job_name=N'LSCopy_db052_Affiliate_N88';
GO
EXEC dbo.sp_start_job @job_name=N'LSRestore_db052_Affiliate_N88';
GO
EXEC dbo.sp_start_job @job_name=N'LSCopy_db052_bodb_CRM';
GO
EXEC dbo.sp_start_job @job_name=N'LSRestore_db052_bodb_CRM';
GO
EXEC dbo.sp_start_job @job_name=N'LSCopy_db052_bodb_Maintenance';
GO
EXEC dbo.sp_start_job @job_name=N'LSRestore_db052_bodb_Maintenance';
GO
EXEC dbo.sp_start_job @job_name=N'LSCopy_db052_Affiliate_MacauBet';
GO
EXEC dbo.sp_start_job @job_name=N'LSRestore_db052_Affiliate_MacauBet';
GO
EXEC dbo.sp_start_job @job_name=N'LSCopy_db052_Affiliate_N8G';
GO
EXEC dbo.sp_start_job @job_name=N'LSRestore_db052_Affiliate_N8G';
GO
EXEC dbo.sp_start_job @job_name=N'LSCopy_db052_Affiliate_Spondemo';
GO
EXEC dbo.sp_start_job @job_name=N'LSRestore_db052_Affiliate_Spondemo';
GO
EXEC dbo.sp_start_job @job_name=N'LSCopy_db052_Affiliate_12BET';
GO
EXEC dbo.sp_start_job @job_name=N'LSRestore_db052_Affiliate_12BET';
GO
EXEC dbo.sp_start_job @job_name=N'LSCopy_db052_bodb_Oddsfeed';
GO
EXEC dbo.sp_start_job @job_name=N'LSRestore_db052_bodb_Oddsfeed';
GO
EXEC dbo.sp_start_job @job_name=N'LSCopy_db052_Affiliate_Aoncash';
GO
EXEC dbo.sp_start_job @job_name=N'LSRestore_db052_Affiliate_Aoncash';
GO
EXEC dbo.sp_start_job @job_name=N'LSCopy_db052_bodb_MMS';
GO
EXEC dbo.sp_start_job @job_name=N'LSRestore_db052_bodb_MMS';
GO
EXEC dbo.sp_start_job @job_name=N'LSCopy_db052_bodb_RMS';
GO
EXEC dbo.sp_start_job @job_name=N'LSRestore_db052_bodb_RMS';
GO
EXEC dbo.sp_start_job @job_name=N'LSCopy_db052_Affiliate_Athena000';
GO
EXEC dbo.sp_start_job @job_name=N'LSRestore_db052_Affiliate_Athena000';
GO
