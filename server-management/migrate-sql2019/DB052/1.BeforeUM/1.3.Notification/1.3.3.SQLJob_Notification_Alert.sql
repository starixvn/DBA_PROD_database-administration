/***
	- Created@20211229: Bobby
	- Host: Run on DB052N2
***/

USE [msdb]
GO

/****** Object:  Alert [DBA_Deadlock_Alert]    Script Date: 12/24/2021 5:44:14 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'DBA_Deadlock_Alert', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'[Uncategorized]', 
		@wmi_namespace=N'\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER', 
		@wmi_query=N'SELECT * FROM DEADLOCK_GRAPH', 
		@job_id=N'7BEAEB62-12BF-4A1E-A72F-6A3CD68F5CBF'
GO

/****** Object:  Alert [Log shipping Primary Server Alert.]    Script Date: 12/24/2021 5:44:14 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Log shipping Primary Server Alert.', 
		@message_id=14420, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Log shipping Secondary Server Alert.]    Script Date: 12/24/2021 5:44:14 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Log shipping Secondary Server Alert.', 
		@message_id=14421, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


