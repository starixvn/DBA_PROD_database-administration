/***
	- Created@20211124: Bobby
	- Host: Run on DB053
	- Task: Remove secondary database on DB053
***/
use master;
GO
EXEC sp_delete_log_shipping_primary_secondary
@primary_database = N'bodb_ChatBot'
,@secondary_server = N'10.11.1.21'
,@secondary_database = N'bodb_ChatBot';
GO
EXEC sp_delete_log_shipping_primary_secondary
@primary_database = N'bodb_ChatBot'
,@secondary_server = N'10.14.1.92'
,@secondary_database = N'bodb_ChatBot';
GO
EXEC sp_delete_log_shipping_primary_secondary
@primary_database = N'bodb_ChatBot'
,@secondary_server = N'DB052'
,@secondary_database = N'bodb_ChatBot';
GO
EXEC sp_delete_log_shipping_primary_secondary
@primary_database = N'bodb_FraudSensor'
,@secondary_server = N'DB052'
,@secondary_database = N'bodb_FraudSensor';
GO
EXEC sp_delete_log_shipping_primary_secondary
@primary_database = N'bodb_Ploutos'
,@secondary_server = N'DB052'
,@secondary_database = N'bodb_Ploutos';
GO