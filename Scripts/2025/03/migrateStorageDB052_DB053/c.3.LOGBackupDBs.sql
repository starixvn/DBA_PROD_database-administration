--DB052/DB053 migrate storage 

--MonDB
BACKUP LOG  [MonDB] TO  
DISK = N'F:\Brice_tmp\MonDB_20250318.trn'
GO


go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_bodb_3rdProduct'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_bodb_AGE'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_bodb_LicenseeReport'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_bodb_LicenseeReportArchive'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_bodb_N88'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_bodb_N88_Archive'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_bodb_PlaytechCS'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_bodb_YashBet'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_bodb_YashBet_Archive'
go
--execute msdb.dbo.sp_start_job @job_name=N'LSBackup_MonDB'
go
--execute msdb.dbo.sp_start_job @job_name=N'LSBackup_SAS_adhocReport'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_Affiliate_12B'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_Affiliate_12bet'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_Affiliate_9Bet'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_Affiliate_Aoncash'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_Affiliate_Athena000'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_Affiliate_itcbet'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_Affiliate_MacauBet'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_Affiliate_N88'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_Affiliate_N8B'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_Affiliate_N8G'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_Affiliate_Spondemo'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_Affiliate_YashBet'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_bk'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_bodb_12B'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_bodb_12B_Archive'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_bodb_CRM'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_bodb_FraudSensor'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_bodb_PlaytechCS'
go
--execute msdb.dbo.sp_start_job @job_name=N'LSBackup_bodb_Ploutos'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_bodb_RMS'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_bodb_Summary'
go
execute msdb.dbo.sp_start_job @job_name=N'LSBackup_MessageNotification'
go