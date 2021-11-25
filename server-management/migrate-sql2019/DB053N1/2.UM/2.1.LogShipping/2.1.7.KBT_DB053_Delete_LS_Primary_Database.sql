/***
	- Created: Bobby
	- Host: Run on DB052
	- Task: Delete primary database on DB053
***/
use msdb;
GO
EXEC sp_delete_log_shipping_primary_database N'bodb_ChatBot'
GO
EXEC sp_delete_log_shipping_primary_database N'bodb_FraudSensor'
GO
EXEC sp_delete_log_shipping_primary_database N'bodb_Ploutos'
GO