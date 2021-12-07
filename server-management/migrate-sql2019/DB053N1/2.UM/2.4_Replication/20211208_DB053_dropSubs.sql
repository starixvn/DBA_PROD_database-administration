
---=== DBTrans drop sub
-- Dropping the transactional subscriptions
 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Bet', @subscriber = N'DB053', @destination_db = N'bodb02', @article = N'all'
GO
 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Bet14', @subscriber = N'DB053', @destination_db = N'bodb02', @article = N'all'
GO 
 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_ExecRep', @subscriber = N'DB053', @destination_db = N'bodb02', @article = N'all'
GO 
 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_ExecRep_UAT', @subscriber = N'DB053', @destination_db = N'bodb02', @article = N'all'
GO 
 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_ExecRepAcc', @subscriber = N'DB053', @destination_db = N'bodb02', @article = N'all'
GO 
 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Vendor', @subscriber = N'DB053', @destination_db = N'bodb02', @article = N'all'
GO 
 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Vendor14', @subscriber = N'DB053', @destination_db = N'bodb02', @article = N'all'
GO
-- Dropping the registered subscriber
exec sp_dropsubscriber @subscriber = N'DB053'
GO 
GO
GO
GO
--====== DBCust drop SUB
 
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_Customer_Info', @subscriber = N'DB053', @destination_db = N'bodb02', @article = N'all'
GO 
 
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_ExchangeDaily', @subscriber = N'DB053', @destination_db = N'bodb02', @article = N'all'
GO 
 
use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_ExecRepAcc_Cust', @subscriber = N'DB053', @destination_db = N'bodb02', @article = N'all'
GO 

use [CustDB]
exec sp_dropsubscription @publication = N'CustDB_Login_Exchange', @subscriber = N'DB053', @destination_db = N'bodb02', @article = N'all'
GO
use [bodb_Licensee]
exec sp_dropsubscription @publication = N'Cusdb_bodb_licensee', @subscriber = N'DB053', @destination_db = N'bodb_licensee', @article = N'all'
GO
 
use [bodb_Licensee]
exec sp_dropsubscription @publication = N'CustDB_bodb_Licensee_BA', @subscriber = N'DB053', @destination_db = N'bodb_licensee', @article = N'all'
GO
 
      
GO
-- Dropping the registered subscriber
exec sp_dropsubscriber @subscriber = N'DB053'
GO 

----===== DBRPO drop sub
 
use [bodb02]
exec sp_dropsubscription @publication = N'DB02_Dot', @subscriber = N'DB053', @destination_db = N'bodb02', @article = N'all'
GO 
GO
use [bodb02]
exec sp_dropsubscription @publication = N'DB02_event14', @subscriber = N'DB053', @destination_db = N'bodb02', @article = N'all'
GO 

 
use [bodb02]
exec sp_dropsubscription @publication = N'DB02_Odds_3rd', @subscriber = N'DB053', @destination_db = N'bodb02', @article = N'all'
GO
 
use [bodb02]
exec sp_dropsubscription @publication = N'DB02_Odds_Info', @subscriber = N'DB053', @destination_db = N'bodb02', @article = N'all'
GO 
 
use [bodb02]
exec sp_dropsubscription @publication = N'DB02_Odds_Odds', @subscriber = N'DB053', @destination_db = N'bodb02', @article = N'all'
GO 
      
	    
-- Dropping the registered subscriber
exec sp_dropsubscriber @subscriber = N'DB053'
GO
