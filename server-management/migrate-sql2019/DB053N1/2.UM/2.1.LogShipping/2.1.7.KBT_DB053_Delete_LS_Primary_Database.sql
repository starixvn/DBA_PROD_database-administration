/***
	- Created: Bobby
	- Host: Run on DB053
	- Task: Delete LS primary database on DB053
***/
use master;
GO
EXEC sp_delete_log_shipping_primary_database N'bodb_ChatBot'
GO
EXEC sp_delete_log_shipping_primary_database N'bodb_FraudSensor'
GO
EXEC sp_delete_log_shipping_primary_database N'bodb_Ploutos'
GO