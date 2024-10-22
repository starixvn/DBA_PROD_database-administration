/*
	Created: 20241022@Daniel
	Task: Replication adjust - Drop subs old SiteDBs
	DB: DBCUST
*/

-- Dropping the transactional subscriptions
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_DBTrans_CustInfo', @subscriber = N'DBGRP01L', @destination_db = N'CustDB', @article = N'all'
GO
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_DBTrans_CustInfo', @subscriber = N'DBGRP02L', @destination_db = N'CustDB', @article = N'all'
GO
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_DBTrans_CustInfo', @subscriber = N'DBGRP03L', @destination_db = N'CustDB', @article = N'all'
GO


-- Dropping the transactional subscriptions
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_DBTrans_Exchange', @subscriber = N'DBGRP01L', @destination_db = N'CustDB', @article = N'all'
GO
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_DBTrans_Exchange', @subscriber = N'DBGRP02L', @destination_db = N'CustDB', @article = N'all'
GO
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_DBTrans_Exchange', @subscriber = N'DBGRP03L', @destination_db = N'CustDB', @article = N'all'
GO
