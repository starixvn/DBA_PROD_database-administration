


--========================================DB052===========================================---
-- Dropping the transactional subscriptions 
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_Customer_Info', @subscriber = N'DB052', @destination_db = N'bodb02', @article = N'all'
GO
-- Dropping the transactional subscriptions
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_ExchangeDaily', @subscriber = N'DB052', @destination_db = N'bodb02', @article = N'all'
GO

-- Dropping the transactional subscriptions 
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_ExecRepAcc_Cust', @subscriber = N'DB052', @destination_db = N'bodb02', @article = N'all'
GO 
-- Dropping the transactional subscriptions 
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_Login_Exchange', @subscriber = N'DB052', @destination_db = N'bodb02', @article = N'all'
GO 
-- Dropping the transactional subscriptions
use [bodb_Licensee]
exec sp_dropsubscription @publication = N'Cusdb_bodb_licensee', @subscriber = N'DB052', @destination_db = N'bodb_licensee', @article = N'all'
GO
 -- Dropping the transactional subscriptions
use [bodb_Licensee]
exec sp_dropsubscription @publication = N'CustDB_bodb_Licensee_BA', @subscriber = N'DB052', @destination_db = N'bodb_licensee', @article = N'all'
GO 
-- Dropping the registered subscriber
exec sp_dropsubscriber @subscriber = N'DB052'
GO 

--========================================DB054C2\DB054===========================================---
-- Dropping the transactional subscriptions
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_Customer_Info', @subscriber = N'DB054C2\DB054', @destination_db = N'bodb02', @article = N'all'
GO 
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_ExchangeDaily', @subscriber = N'DB054C2\DB054', @destination_db = N'bodb02', @article = N'all'
GO 
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_ExecRepAcc_Cust', @subscriber = N'DB054C2\DB054', @destination_db = N'bodb02', @article = N'all'
GO 
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_Login_Exchange', @subscriber = N'DB054C2\DB054', @destination_db = N'bodb02', @article = N'all'
GO 

use [bodb_Licensee]
exec sp_dropsubscription @publication = N'Cusdb_bodb_licensee', @subscriber = N'DB054C2\DB054', @destination_db = N'bodb_licensee', @article = N'all'
GO
use [bodb_Licensee]
exec sp_dropsubscription @publication = N'CustDB_bodb_Licensee_BA', @subscriber = N'DB054C2\DB054', @destination_db = N'bodb_licensee', @article = N'all'
GO
GO
-- Dropping the registered subscriber
exec sp_dropsubscriber @subscriber = N'DB054C2\DB054'
GO 

--========================================DB06C2\DB06===========================================---
-- Dropping the transactional subscriptions
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_Customer_Info', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb02', @article = N'all'
GO
-- Dropping the transactional subscriptions 
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_CustSetting', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb02', @article = N'all'
GO
    
-- Dropping the transactional subscriptions 
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_DR_sync', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb02', @article = N'all'
GO
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_ExchangeDaily', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb02', @article = N'all'
GO
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_ExecRepAcc_Cust', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb02', @article = N'all'
GO 
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_Login_Exchange', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb02', @article = N'all'
GO 
use [bodb_Licensee]
exec sp_dropsubscription @publication = N'Cusdb_bodb_licensee', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb_licensee', @article = N'all'
GO 
 
use [bodb_Licensee]
exec sp_dropsubscription @publication = N'CustDB_bodb_Licensee_BA', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb_licensee', @article = N'all'
GO

-- Dropping the registered subscriber
exec sp_dropsubscriber @subscriber = N'DB06C2\DB06'
GO
 