/***
	- Created@20211124: Bobby
	- Host: Run on AWS@DB052
	- Task: Delete Log secondary database on DB052
***/
use master;
GO
EXEC sp_delete_log_shipping_secondary_database N'bodb_ChatBot'
GO