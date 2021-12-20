--check log shipping status
exec sp_help_log_shipping_monitor

-- remove log shipping
--1. On the primary server, execute sp_delete_log_shipping_primary_secondary to delete 
--the information about the secondary database from the primary server.
--DB061
EXEC master.dbo.sp_delete_log_shipping_primary_secondary
@primary_database = N'bodb_OWP'
,@secondary_server = N'DB06C2'
,@secondary_database = N'bodb_OWP'
GO
EXEC master.dbo.sp_delete_log_shipping_primary_secondary
@primary_database = N'bodb_TGRS'
,@secondary_server = N'DB06C2'
,@secondary_database = N'bodb_TGRS'
GO
EXEC master.dbo.sp_delete_log_shipping_primary_secondary
@primary_database = N'bodb_OWP'
,@secondary_server = N'10.14.1.100'
,@secondary_database = N'bodb_OWP'
GO
EXEC master.dbo.sp_delete_log_shipping_primary_secondary
@primary_database = N'bodb_TGRS'
,@secondary_server = N'10.14.1.100'
,@secondary_database = N'bodb_TGRS'
GO
--/DB061


--2. On the secondary server, execute sp_delete_log_shipping_secondary_database to delete 
--the secondary database.
--DB06, AWS_DB06 
EXEC master.dbo.sp_delete_log_shipping_secondary_database N'bodb_OWP'
go
EXEC master.dbo.sp_delete_log_shipping_secondary_database N'bodb_TGRS'
--/DB06, AWS_DB06 

--3. On the primary server, execute sp_delete_log_shipping_primary_database to delete information 
--	about the log shipping configuration from the primary server. This also deletes the backup job.
--DB061
EXEC master.dbo.sp_delete_log_shipping_primary_database N'bodb_OWP'
go
EXEC master.dbo.sp_delete_log_shipping_primary_database N'bodb_TGRS'
--/DB061
