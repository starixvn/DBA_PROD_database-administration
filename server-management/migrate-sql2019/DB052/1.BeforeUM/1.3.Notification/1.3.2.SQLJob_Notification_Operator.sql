/***
	- Created@20211229: Bobby
	- Host: Run on DB052N2
***/
USE [msdb]
GO

/****** Object:  Operator [DBAAdmin]    Script Date: 12/24/2021 5:42:34 AM ******/
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

/****** Object:  Operator [Don]    Script Date: 12/24/2021 5:42:34 AM ******/
EXEC msdb.dbo.sp_add_operator @name=N'Don', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'Don.Pham@starixvn.com', 
		@category_name=N'[Uncategorized]'
GO

/****** Object:  Operator [StarixDBA]    Script Date: 12/24/2021 5:42:34 AM ******/
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

/****** Object:  Operator [Thien]    Script Date: 12/24/2021 5:42:34 AM ******/
EXEC msdb.dbo.sp_add_operator @name=N'Thien', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'thien.pham@starixvn.com', 
		@category_name=N'[Uncategorized]'
GO

/****** Object:  Operator [TWDBA]    Script Date: 12/24/2021 5:42:34 AM ******/
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

/****** Object:  Operator [Viet]    Script Date: 12/24/2021 5:42:34 AM ******/
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

/****** Object:  Operator [vnDBA]    Script Date: 12/24/2021 5:42:34 AM ******/
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


