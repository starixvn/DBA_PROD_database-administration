/***
	- Created@2021224: Bobby
	- Host: Run on MNL@DB052
	- Task: Delete Log secondary database on DB052
***/
use master;
GO
EXEC sp_delete_log_shipping_secondary_database  @secondary_database =N'bodb_PlaytechCS'
GO
EXEC sp_delete_log_shipping_secondary_database  @secondary_database =N'Affiliate_12Bet'
GO
EXEC sp_delete_log_shipping_secondary_database  @secondary_database =N'Affiliate_Spondemo'
GO
EXEC sp_delete_log_shipping_secondary_database  @secondary_database =N'Affiliate_Aoncash'
GO
EXEC sp_delete_log_shipping_secondary_database  @secondary_database =N'bodb_MMS'
GO
EXEC sp_delete_log_shipping_secondary_database  @secondary_database =N'Affiliate_itcbet'
GO
EXEC sp_delete_log_shipping_secondary_database  @secondary_database =N'Affiliate_N8G'
GO
EXEC sp_delete_log_shipping_secondary_database  @secondary_database =N'bodb_CRM'
GO
EXEC sp_delete_log_shipping_secondary_database  @secondary_database =N'Affiliate_Athena000'
GO
EXEC sp_delete_log_shipping_secondary_database  @secondary_database =N'Affiliate_N8B'
GO
EXEC sp_delete_log_shipping_secondary_database  @secondary_database =N'bodb_oddsfeed'
GO
EXEC sp_delete_log_shipping_secondary_database  @secondary_database =N'bodb_Maintenance'
GO
EXEC sp_delete_log_shipping_secondary_database  @secondary_database =N'Affiliate_MacauBet'
GO
EXEC sp_delete_log_shipping_secondary_database  @secondary_database =N'Affiliate_N88'
GO
EXEC sp_delete_log_shipping_secondary_database  @secondary_database =N'bodb_OIC'
GO
EXEC sp_delete_log_shipping_secondary_database  @secondary_database =N'bodb_3rdProduct'
GO