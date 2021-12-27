/***
	- Created@20211124: Bobby
	- Host: Run on DB052 - old One
	- Task: Migrate SQLJobs - Disable
***/
USE [msdb]
GO
exec dbo.sp_update_job @job_name=N'DBA_Reorg_Index', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_N8B: Generate Data Daily', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb02: Retrieve BA Transaction', @enabled=0
exec dbo.sp_update_job @job_name=N'TEST_BENJAMIN', @enabled=0
exec dbo.sp_update_job @job_name=N'DBA : MonDB Get DB Info', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb02: Check/Verify ExchangeDaily', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb_PlaytechCS: Execute Product3rd_ImportQueue Background', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_AonCash: Commission Monthly Transfer', @enabled=0
exec dbo.sp_update_job @job_name=N'vnDBA : Objects Monitoring - Collect Data', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_itcbet: Daily Summary Rate', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb02: Check Settlement status', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb_N88: Generate daily data for N88_RptWinloss', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb_RMS: Copy parlay tickets to rmBettrans', @enabled=0
exec dbo.sp_update_job @job_name=N'BK : FC Rej', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_MacauBet: Clear Login', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb_LicenseeReport: Licensee Winloss - Check and Correct Data', @enabled=0
exec dbo.sp_update_job @job_name=N'__SYNC: [DB053-DB052] bodb_Age', @enabled=0
exec dbo.sp_update_job @job_name=N'DBA_Full_Backup', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_12BET: Generate Data Daily', @enabled=0
exec dbo.sp_update_job @job_name=N'vndba_monitor_whoisactive', @enabled=0
exec dbo.sp_update_job @job_name=N'vndba: temp perf report test', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb_Summary: Generate Data - CN88', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb_Summary: Generate Data - Before MoveBets', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_N88: Generate Data Daily', @enabled=0
exec dbo.sp_update_job @job_name=N'viet: perf report', @enabled=0
exec dbo.sp_update_job @job_name=N'DBA: update stats', @enabled=0
exec dbo.sp_update_job @job_name=N'DBA: Database BackupHistory Cleanup', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb02: SSB - Get settled tickets', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_AonCash: Clear Login', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_N8G: Summarize Data Monthly', @enabled=0
exec dbo.sp_update_job @job_name=N'DBA_Diff_Backup', @enabled=0
exec dbo.sp_update_job @job_name=N'BK : FC', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_12BET: Summarize Data Monthly', @enabled=0
exec dbo.sp_update_job @job_name=N'__SYNC: [DB053 to DB052] - bodb_PlaytechCS-2', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_itcbet: Backup Commission Group', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb_Summary: Check and Correct Data - After MoveBets', @enabled=0
exec dbo.sp_update_job @job_name=N'__SYNC: [DB053 to DB052] - bodb_PlaytechCS', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_MacauBet: Backup Commission Group', @enabled=0
exec dbo.sp_update_job @job_name=N'DBA_Deadlock_Monitor', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb_LicenseeReport: DWPromotion - Generate Daily', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_N8B: Summarize Data Monthly', @enabled=0
exec dbo.sp_update_job @job_name=N'DBA_MonDB_Reorg', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb_3rdProduct: Check Exchange data monthly', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_AonCash: Daily Summary Rate', @enabled=0
exec dbo.sp_update_job @job_name=N'DBA - performance report (daily) test', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb_Summary - Weekly Company Balance History', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_Athena000: Clear Login', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb_RMS: MBU Copy & Sum Data', @enabled=0
exec dbo.sp_update_job @job_name=N'DB052 : VERIFY DailySummary (Move Bet)', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb02: SSB - TO Control -  Get tickets', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb_LicenseeReport: DW - Check and Correct Data', @enabled=0
exec dbo.sp_update_job @job_name=N'DBA_Getlockinfo 5 Secs', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb_LicenseeReport: DW - Generate Daily', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb_LicenseeReport: Daily Summary Licensee Winloss', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_MacauBet: Commission Monthly Transfer', @enabled=0
exec dbo.sp_update_job @job_name=N'vndba: temp SC perf report test', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_Athena000: Daily Summary Rate', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb_oddsfeed: Move PartnerStatistics', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_N8G: Generate Data Daily', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb02: TOControl Delete old transition', @enabled=0
exec dbo.sp_update_job @job_name=N'DBA_Getwaitinfo 5 Secs', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_AonCash: Backup Commission Group', @enabled=0
exec dbo.sp_update_job @job_name=N'DBA : Monitor Job Fail', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb02: Verify BA Tickets', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_Athena000: Commission Monthly Transfer', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_Athena000: Backup Commission Group', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_12BET-On_user : clear login', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_itcbet: Clear Login', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_N88: Summarize Data Monthly', @enabled=0
exec dbo.sp_update_job @job_name=N'vndba: SC health check test', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_MacauBet: Daily Summary Rate', @enabled=0
exec dbo.sp_update_job @job_name=N'BK : Clear Old Bet', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb02 : Remove Settlement Logs', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb_licenseeReport: Daily CHECKSUM DepositData', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb_CRM: Delete old feedback info weekly', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb_RMS: MBU Check Sum & Delete Data', @enabled=0
exec dbo.sp_update_job @job_name=N'bodb_N88: API_Queue Process', @enabled=0
exec dbo.sp_update_job @job_name=N'Affiliate_itcbet: Commission Monthly Transfer', @enabled=0
GO

