/***
	- Created@20211124: Bobby
	- Host: Run on DB053N1
	- Task: Migrate SQLJobs - Enable
***/
USE [msdb]
GO
exec dbo.sp_update_job @job_name=N'bodb02: SSB - Get settled tickets', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb_LicenseeReport: Daily Summary Licensee Winloss', @enabled=1
exec dbo.sp_update_job @job_name=N'FS-Get Tickets By IP', @enabled=1
exec dbo.sp_update_job @job_name=N'BK : FC Rej', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb_licenseeReport: Daily CHECKSUM DepositData', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb_Ploutos: BetTicket Filtering and VC - Sportbook', @enabled=1
exec dbo.sp_update_job @job_name=N'DBA: update stats', @enabled=1
exec dbo.sp_update_job @job_name=N'DBA : Monitor Job Fail', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb_N88: API_Queue Process', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb_LicenseeReport: DW - Generate Daily', @enabled=1
exec dbo.sp_update_job @job_name=N'vnDBA: Monitor_dba_tasks', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb_LicenseeReport: Licensee Winloss - Check and Correct Data', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb_Age: LimitLoss_Setting totalBalance update', @enabled=1
exec dbo.sp_update_job @job_name=N'vnDBA : Objects Monitoring - Collect Data', @enabled=1
exec dbo.sp_update_job @job_name=N'DBA : MonDB Get DB Info', @enabled=1
exec dbo.sp_update_job @job_name=N'DBA_Full_Backup', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb_Summary: Check and Correct Data - After MoveBets', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb_Ploutus: Check Data Consistency', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb_Summary: Generate Data - CN88', @enabled=1
exec dbo.sp_update_job @job_name=N'DBA_Deadlock_Monitor', @enabled=1
exec dbo.sp_update_job @job_name=N'vndba_monitor_whoisactive', @enabled=1
exec dbo.sp_update_job @job_name=N'DBA_Getlockinfo 5 Secs', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb_Summary: Generate Data - Before MoveBets', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb02: Verify BA Tickets', @enabled=1
exec dbo.sp_update_job @job_name=N'DBA: Database BackupHistory Cleanup', @enabled=1
exec dbo.sp_update_job @job_name=N'DBA_MonDB_Reorg', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb_3rdProduct: Check Exchange data monthly', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb_LicenseeReport: DWPromotion - Generate Daily', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb02: TOControl Delete old transition', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb_Summary - Weekly Company Balance History', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb02 : Remove Settlement Logs', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb_PlaytechCS: Execute Product3rd_ImportQueue Background', @enabled=1
exec dbo.sp_update_job @job_name=N'DBA_Getwaitinfo 5 Secs', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb_N88: Generate daily data for N88_RptWinloss', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb_LicenseeReport: DW - Check and Correct Data', @enabled=1
exec dbo.sp_update_job @job_name=N'__SYNC: [DB052 to DB053] - bodb_PlaytechCS-2', @enabled=1
exec dbo.sp_update_job @job_name=N'BK : FC', @enabled=1
exec dbo.sp_update_job @job_name=N'BK : Clear Old Bet', @enabled=1
exec dbo.sp_update_job @job_name=N'DBA_Reorg_Index', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb02: SSB - TO Control -  Get tickets', @enabled=1
exec dbo.sp_update_job @job_name=N'FS-ArchiveCleanUpData', @enabled=1
exec dbo.sp_update_job @job_name=N'__SYNC: [DB052 to DB053] - bodb_PlaytechCS', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb02: Check Settlement status', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb_Ploutos: Get New Data', @enabled=1
exec dbo.sp_update_job @job_name=N'FS-Daily Data Capturing', @enabled=1
exec dbo.sp_update_job @job_name=N'DBA_Diff_Backup', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb_Ploutos: Archive Data', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb02: Retrieve BA Transaction', @enabled=1
exec dbo.sp_update_job @job_name=N'bodb02: Check/Verify ExchangeDaily', @enabled=1
GO
