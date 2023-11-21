/*
	Created: 20231026@Sol
	Task: setup operator
	DB: 10.40.40.34,16402-msdb
*/

USE [msdb]

GO

/****** Object:  Operator [FPS_DBA]    Script Date: 10/25/2023 11:27:41 PM ******/
EXEC msdb.dbo.sp_add_operator @name=N'FPS_DBA', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'fpsadmindb@starixsoft.com', 
		@category_name=N'[Uncategorized]'
GO

/****** Object:  Operator [VNDBA]    Script Date: 10/25/2023 11:27:42 PM ******/
EXEC msdb.dbo.sp_add_operator @name=N'VNDBA', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'pontus@starixsoft.com', 
		@category_name=N'[Uncategorized]'
GO