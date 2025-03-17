/*
	Task: Detach-attach database MonDB
	
	Created on 20250311 by Daniel
	Run on DB062
*/


--1. Stop & Disable related jobs
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA : MonDB Get DB Info'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA : MonDB Get DB Info', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA : Monitor Job Fail'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA : Monitor Job Fail', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_Deadlock_Monitor'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Deadlock_Monitor', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_Diff_Backup'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Diff_Backup', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_ExtendLogCheck'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_ExtendLogCheck', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_Full_Backup'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Full_Backup', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_Getlockinfo 5 Secs'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Getlockinfo 5 Secs', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_Getwaitinfo 5 Secs'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Getwaitinfo 5 Secs', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_Mon_ClearUpData'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Mon_ClearUpData', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_Mon_Get_TLog_Usage'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Mon_Get_TLog_Usage', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_MonDB_Reorg'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_MonDB_Reorg', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_Script_Instance_Object'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Script_Instance_Object', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_Switch_Errorlog'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Switch_Errorlog', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'vnDBA_monitor_Templog_test'; EXEC msdb.dbo.sp_update_job @job_name = 'vnDBA_monitor_Templog_test', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'vndba_monitor_whoisactive'; EXEC msdb.dbo.sp_update_job @job_name = 'vndba_monitor_whoisactive', @enabled = 0;


--2. Detach db
USE [master]
GO
ALTER DATABASE [MONDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'MONDB'
GO


--3. Copy file (cmd)
robocopy F:\USER_DB\MonDB L:\USER_DB\MonDB MONDB_log.ldf /COPYALL /MT:16
robocopy F:\USER_DB\MonDB L:\USER_DB\MonDB MONDB.mdf /COPYALL /MT:16


--4. Attach db
USE [master]
GO
CREATE DATABASE [MONDB] ON
(FILENAME = 'L:\USER_DB\MonDB\MONDB_log.ldf')
,(FILENAME = 'L:\USER_DB\MonDB\MONDB.mdf')
 FOR ATTACH
GO

--5. Enable back Job
EXEC msdb.dbo.sp_update_job @job_name = 'DBA : MonDB Get DB Info', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA : Monitor Job Fail', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Deadlock_Monitor', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Diff_Backup', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_ExtendLogCheck', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Full_Backup', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Getlockinfo 5 Secs', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Getwaitinfo 5 Secs', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Mon_ClearUpData', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Mon_Get_TLog_Usage', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_MonDB_Reorg', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Script_Instance_Object', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Switch_Errorlog', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'vnDBA_monitor_Templog_test', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'vndba_monitor_whoisactive', @enabled = 1;

