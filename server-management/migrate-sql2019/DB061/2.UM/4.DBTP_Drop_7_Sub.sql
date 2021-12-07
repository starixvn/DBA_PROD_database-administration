 

 ---=== DBTrans drop sub
-- Dropping the transactional subscriptions

use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Bet', @subscriber = N'DB061', @destination_db = N'bodb02', @article = N'all'
GO
   
-- Dropping the transactional subscriptions

use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Bet14', @subscriber = N'DB061', @destination_db = N'bodb02', @article = N'all'
GO 
 
-- Dropping the transactional subscriptions

use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_ExecRep', @subscriber = N'DB061', @destination_db = N'bodb02', @article = N'all'
GO 
 
-- Dropping the transactional subscriptions

use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_ExecRep_UAT', @subscriber = N'DB061', @destination_db = N'bodb02', @article = N'all'
GO 
 

-- Dropping the transactional subscriptions

use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_ExecRepAcc', @subscriber = N'DB061', @destination_db = N'bodb02', @article = N'all'
GO 
 
-- Dropping the transactional subscriptions
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Sync_DB06', @subscriber = N'DB061', @destination_db = N'bodb02', @article = N'all'
GO
  
-- Dropping the transactional subscriptions

use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Vendor', @subscriber = N'DB061', @destination_db = N'bodb02', @article = N'all'
GO 
 
-- Dropping the transactional subscriptions

 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Vendor14', @subscriber = N'DB061', @destination_db = N'bodb02', @article = N'all'
GO
  
   
GO

-- Dropping the registered subscriber
exec sp_dropsubscriber @subscriber = N'DB061'
GO
GO
GO
GO
--====== DBCust drop SUB

-- Dropping the transactional subscriptions

use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_Customer_Info', @subscriber = N'DB061', @destination_db = N'bodb02', @article = N'all'
GO 
 
-- Dropping the transactional subscriptions
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_CustSetting', @subscriber = N'DB061', @destination_db = N'bodb02', @article = N'all'
GO
 
      

-- Dropping the transactional subscriptions
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_DR_sync', @subscriber = N'DB061', @destination_db = N'bodb02', @article = N'all'
GO 
 

-- Dropping the transactional subscriptions

use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_ExchangeDaily', @subscriber = N'DB061', @destination_db = N'bodb02', @article = N'all'
GO 
 

-- Dropping the transactional subscriptions

use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_ExecRepAcc_Cust', @subscriber = N'DB061', @destination_db = N'bodb02', @article = N'all'
GO
  
-- Dropping the transactional subscriptions

use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_Login_Exchange', @subscriber = N'DB061', @destination_db = N'bodb02', @article = N'all'
GO


-- Dropping the transactional subscriptions 

use [bodb_Licensee]
exec sp_dropsubscription @publication = N'Cusdb_bodb_licensee', @subscriber = N'DB061', @destination_db = N'bodb_licensee', @article = N'all'
GO
  

-- Dropping the transactional subscriptions

use [bodb_Licensee]
exec sp_dropsubscription @publication = N'CustDB_bodb_Licensee_BA', @subscriber = N'DB061', @destination_db = N'bodb_licensee', @article = N'all'
GO
 

-- Dropping the registered subscriber
exec sp_dropsubscriber @subscriber = N'DB061'
GO



---======== DBPRO drop sub

-- Dropping the transactional subscriptions

use [bodb02]
exec sp_dropsubscription @publication = N'DB02_Dot', @subscriber = N'DB061', @destination_db = N'bodb02', @article = N'all'
GO 

-- Dropping the transactional subscriptions

use [bodb02]
exec sp_dropsubscription @publication = N'DB02_event14', @subscriber = N'DB061', @destination_db = N'bodb02', @article = N'all'
GO 
 

-- Dropping the transactional subscriptions

use [bodb02]
exec sp_dropsubscription @publication = N'DB02_Odds_3rd', @subscriber = N'DB061', @destination_db = N'bodb02', @article = N'all'
GO 
   
-- Dropping the transactional subscriptions

use [bodb02]
exec sp_dropsubscription @publication = N'DB02_Odds_Info', @subscriber = N'DB061', @destination_db = N'bodb02', @article = N'all'
GO  

-- Dropping the transactional subscriptions

use [bodb02]
exec sp_dropsubscription @publication = N'DB02_Odds_Odds', @subscriber = N'DB061', @destination_db = N'bodb02', @article = N'all'
GO 
   
-- Dropping the transactional subscriptions 
use [bodb02]
exec sp_dropsubscription @publication = N'DB02_OddsOS', @subscriber = N'DB061', @destination_db = N'bodb02', @article = N'all'
GO
  

-- Dropping the transactional subscriptions
use [bodb02]
exec sp_dropsubscription @publication = N'DB02_Sync_DB06', @subscriber = N'DB061', @destination_db = N'bodb02', @article = N'all'
GO

-- Dropping the registered subscriber
exec sp_dropsubscriber @subscriber = N'DB061'
GO
 