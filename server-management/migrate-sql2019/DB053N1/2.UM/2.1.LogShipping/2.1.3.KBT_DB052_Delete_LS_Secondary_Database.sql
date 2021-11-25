/***
	- Created@20211124: Bobby
	- Host: Run on DB052
	- Task: Delete Log secondary database on DB053
***/
use msdb;
GO
EXEC sp_delete_log_shipping_secondary_database N'bodb_ChatBot'
GO
EXEC sp_delete_log_shipping_secondary_database N'bodb_FraudSensor'
GO
EXEC sp_delete_log_shipping_secondary_database N'bodb_Ploutos'
GO