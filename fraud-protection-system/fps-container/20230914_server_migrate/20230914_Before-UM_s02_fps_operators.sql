/*
	Created: 20230912@Sol
	Task: setup operator
	DB: 10.40.40.33,16401-msdb
*/

USE [msdb]

GO

/****** Object:  Operator [FPS_DBA]    Script Date: 9/12/2023 5:37:38 AM ******/
EXEC msdb.dbo.sp_add_operator @name=N'FPS_DBA', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'fpsadmindb@starixvn.com', 
		@category_name=N'[Uncategorized]'
GO

/****** Object:  Operator [VNDBA]    Script Date: 9/12/2023 5:37:38 AM ******/
EXEC msdb.dbo.sp_add_operator @name=N'VNDBA', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'pontus@starixvn.com', 
		@category_name=N'[Uncategorized]'
GO

