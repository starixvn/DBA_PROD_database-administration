/***
	- Created@20211124: Bobby
	- Host: Run on DB053N1
	- Task: Migrate Notification (Mail, Alert vs Operator)
***/
USE [msdb]
GO

/****** Object:  Operator [DBAAdmin]    Script Date: 11/25/2021 12:41:40 AM ******/
EXEC msdb.dbo.sp_add_operator @name=N'DBAAdmin', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'DBAAdmin@onelab.tw', 
		@category_name=N'[Uncategorized]'
GO

/****** Object:  Operator [StarixDBA]    Script Date: 11/25/2021 12:41:40 AM ******/
EXEC msdb.dbo.sp_add_operator @name=N'StarixDBA', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'dbaadmin@starixvn.com', 
		@category_name=N'[Uncategorized]'
GO

/****** Object:  Operator [TWDBA]    Script Date: 11/25/2021 12:41:40 AM ******/
EXEC msdb.dbo.sp_add_operator @name=N'TWDBA', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'dbatw@onelab.tw', 
		@category_name=N'[Uncategorized]'
GO

/****** Object:  Operator [Viet]    Script Date: 11/25/2021 12:41:40 AM ******/
EXEC msdb.dbo.sp_add_operator @name=N'Viet', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'viet.hoang@starixvn.com', 
		@category_name=N'[Uncategorized]'
GO

/****** Object:  Operator [vnDBA]    Script Date: 11/25/2021 12:41:40 AM ******/
EXEC msdb.dbo.sp_add_operator @name=N'vnDBA', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'dbaadmin@starixvn.com', 
		@category_name=N'[Uncategorized]'
GO

/****** Object:  Operator [VNTeam]    Script Date: 11/25/2021 12:41:40 AM ******/
EXEC msdb.dbo.sp_add_operator @name=N'VNTeam', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'IT@starixvn.com', 
		@category_name=N'[Uncategorized]'
GO