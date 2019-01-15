/*
	Creator: Dominic@20190114
	Task: Delete sql job "Archive Deposit Member - Step 1: Collect Dormant Member" in DBCUST
			because we has an alternative one in DB06
	Redmine: https://nexdev.net/issues/107931
	Run at:	msdb@DBCUST
*/

USE msdb ;  
GO  
  
EXEC sp_delete_job  @job_name = N'Archive Deposit Member - Step 1: Collect Dormant Member' ;  
GO  