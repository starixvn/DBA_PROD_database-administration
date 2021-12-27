/***
	- Created@2021224: Bobby
	- Host: Run on KBT@DB052 -- old One
	- Task: Delete LS primary databases on DB052
***/
use master;
GO
EXEC sp_delete_log_shipping_primary_database @database = N'bodb_OIC';
GO
EXEC sp_delete_log_shipping_primary_database @database = N'Affiliate_N88';
GO
EXEC sp_delete_log_shipping_primary_database @database = N'Affiliate_N8B';
GO
EXEC sp_delete_log_shipping_primary_database @database = N'Affiliate_MacauBet';
GO
EXEC sp_delete_log_shipping_primary_database @database = N'bodb_MMS';
GO
EXEC sp_delete_log_shipping_primary_database @database = N'Affiliate_Spondemo';
GO
EXEC sp_delete_log_shipping_primary_database @database = N'bodb_PlaytechCS';
GO
EXEC sp_delete_log_shipping_primary_database @database = N'Affiliate_N8G';
GO
EXEC sp_delete_log_shipping_primary_database @database = N'bodb_3rdProduct';
GO
EXEC sp_delete_log_shipping_primary_database @database = N'bodb_RMS';
GO
EXEC sp_delete_log_shipping_primary_database @database = N'Affiliate_Athena000';
GO
EXEC sp_delete_log_shipping_primary_database @database = N'Affiliate_itcbet';
GO
EXEC sp_delete_log_shipping_primary_database @database = N'bodb_Oddsfeed';
GO
EXEC sp_delete_log_shipping_primary_database @database = N'bodb_CRM';
GO
EXEC sp_delete_log_shipping_primary_database @database = N'Affiliate_Aoncash';
GO
EXEC sp_delete_log_shipping_primary_database @database = N'bodb_Maintenance';
GO
EXEC sp_delete_log_shipping_primary_database @database = N'Affiliate_12BET';
GO