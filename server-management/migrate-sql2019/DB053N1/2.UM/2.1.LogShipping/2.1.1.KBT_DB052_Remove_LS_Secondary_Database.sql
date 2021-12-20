/***
	- Created@20211124: Bobby
	- Host: Run on DB052
	- Task: Remove secondary database on DB053
***/
use master;
GO
EXEC sp_delete_log_shipping_primary_secondary
@primary_database = N'Affiliate_12BET'
,@secondary_server = N'DB053'
,@secondary_database = N'Affiliate_12Bet';
GO
EXEC sp_delete_log_shipping_primary_secondary
@primary_database = N'Affiliate_Aoncash'
,@secondary_server = N'DB053'
,@secondary_database = N'Affiliate_Aoncash';
GO
EXEC sp_delete_log_shipping_primary_secondary
@primary_database = N'Affiliate_Athena000'
,@secondary_server = N'DB053'
,@secondary_database = N'Affiliate_Athena000';
GO
EXEC sp_delete_log_shipping_primary_secondary
@primary_database = N'Affiliate_itcbet'
,@secondary_server = N'DB053'
,@secondary_database = N'Affiliate_itcbet';
GO
EXEC sp_delete_log_shipping_primary_secondary
@primary_database = N'Affiliate_MacauBet'
,@secondary_server = N'DB053'
,@secondary_database = N'Affiliate_MacauBet';
GO
EXEC sp_delete_log_shipping_primary_secondary
@primary_database = N'Affiliate_N88'
,@secondary_server = N'DB053'
,@secondary_database = N'Affiliate_N88';
GO
EXEC sp_delete_log_shipping_primary_secondary
@primary_database = N'Affiliate_N8B'
,@secondary_server = N'DB053'
,@secondary_database = N'Affiliate_N8B';
GO
EXEC sp_delete_log_shipping_primary_secondary
@primary_database = N'Affiliate_N8G'
,@secondary_server = N'DB053'
,@secondary_database = N'Affiliate_N8G';
GO
EXEC sp_delete_log_shipping_primary_secondary
@primary_database = N'Affiliate_Spondemo'
,@secondary_server = N'DB053'
,@secondary_database = N'Affiliate_Spondemo';
GO
EXEC sp_delete_log_shipping_primary_secondary
@primary_database = N'bodb_CRM'
,@secondary_server = N'DB053'
,@secondary_database = N'bodb_CRM';
GO
EXEC sp_delete_log_shipping_primary_secondary
@primary_database = N'bodb_Maintenance'
,@secondary_server = N'DB053'
,@secondary_database = N'bodb_Maintenance';
GO
EXEC sp_delete_log_shipping_primary_secondary
@primary_database = N'bodb_MMS'
,@secondary_server = N'DB053'
,@secondary_database = N'bodb_MMS';
GO
EXEC sp_delete_log_shipping_primary_secondary
@primary_database = N'bodb_Oddsfeed'
,@secondary_server = N'DB053'
,@secondary_database = N'bodb_oddsfeed';
GO
EXEC sp_delete_log_shipping_primary_secondary
@primary_database = N'bodb_OIC'
,@secondary_server = N'DB053'
,@secondary_database = N'bodb_OIC';
GO
EXEC sp_delete_log_shipping_primary_secondary
@primary_database = N'bodb_RMS'
,@secondary_server = N'DB053'
,@secondary_database = N'bodb_RMS';
GO