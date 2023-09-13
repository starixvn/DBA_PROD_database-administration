/*
	Created: 20230912@Sol
	Task: setup alerts
	DB: 10.40.40.33,16401-msdb
*/

USE [msdb]

GO

/****** Object:  Alert [DBA_Deadlock_Alert]    Script Date: 9/12/2023 5:38:58 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'DBA_Deadlock_Alert', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'[Uncategorized]', 
		@wmi_namespace=N'\\.\root\Microsoft\SqlServer\ServerEvents\FPS_01', 
		@wmi_query=N'SELECT * FROM DEADLOCK_GRAPH', 
		@job_id=N'fa68b776-1648-486a-a64c-5c178a4051d3'
GO