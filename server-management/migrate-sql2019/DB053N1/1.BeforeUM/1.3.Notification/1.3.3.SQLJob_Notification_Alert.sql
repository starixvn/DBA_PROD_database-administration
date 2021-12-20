/***
	- Created@20211124: Bobby
	- Host: Run on DB053N1
	- Task: Migrate Notification (Mail, Alert vs Operator)
***/
USE [msdb]
GO

/****** Object:  Alert [DBA_Deadlock_Alert]    Script Date: 11/25/2021 12:42:32 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'DBA_Deadlock_Alert', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'[Uncategorized]', 
		@wmi_namespace=N'\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER', 
		@wmi_query=N'SELECT * FROM DEADLOCK_GRAPH', 
		@job_id=N'ff0f3b79-d1b4-4421-bc50-3befab469393'
GO

/****** Object:  Alert [Log shipping Primary Server Alert.]    Script Date: 11/25/2021 12:42:32 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Log shipping Primary Server Alert.', 
		@message_id=14420, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Log shipping Secondary Server Alert.]    Script Date: 11/25/2021 12:42:32 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Log shipping Secondary Server Alert.', 
		@message_id=14421, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


