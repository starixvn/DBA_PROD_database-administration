  



--=================================DB052-=================================--
-- Dropping the transactional subscriptions
 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Bet', @subscriber = N'DB052', @destination_db = N'bodb02', @article = N'all'
GO 
-- Dropping the transactional subscriptions 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Bet14', @subscriber = N'DB052', @destination_db = N'bodb02', @article = N'all'
GO 
-- Dropping the transactional subscriptions 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_ExecRep', @subscriber = N'DB052', @destination_db = N'bodb02', @article = N'all'
GO 
-- Dropping the transactional subscriptions 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_ExecRep_UAT', @subscriber = N'DB052', @destination_db = N'bodb02', @article = N'all'
GO 
-- Dropping the transactional subscriptions
 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_ExecRepAcc', @subscriber = N'DB052', @destination_db = N'bodb02', @article = N'all'
GO
-- Dropping the transactional subscriptions 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Vendor', @subscriber = N'DB052', @destination_db = N'bodb02', @article = N'all'
GO 
-- Dropping the transactional subscriptions 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Vendor14', @subscriber = N'DB052', @destination_db = N'bodb02', @article = N'all'
GO 
   
-- Dropping the registered subscriber
exec sp_dropsubscriber @subscriber = N'DB052'
GO 
--=================================DB054C2\DB054-=================================--
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Bet', @subscriber = N'DB054C2\DB054', @destination_db = N'bodb02', @article = N'all'
GO 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Bet14', @subscriber = N'DB054C2\DB054', @destination_db = N'bodb02', @article = N'all'
GO 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_ExecRep', @subscriber = N'DB054C2\DB054', @destination_db = N'bodb02', @article = N'all'
GO 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_ExecRep_UAT', @subscriber = N'DB054C2\DB054', @destination_db = N'bodb02', @article = N'all'
GO 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_ExecRepAcc', @subscriber = N'DB054C2\DB054', @destination_db = N'bodb02', @article = N'all'
GO
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Vendor', @subscriber = N'DB054C2\DB054', @destination_db = N'bodb02', @article = N'all'
GO 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Vendor14', @subscriber = N'DB054C2\DB054', @destination_db = N'bodb02', @article = N'all'
GO 

-- Dropping the registered subscriber
exec sp_dropsubscriber @subscriber = N'DB054C2\DB054'
GO 
--=================================DB06C2\DB06-=================================--
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Bet', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb02', @article = N'all'
GO 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Bet14', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb02', @article = N'all'
GO  
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_ExecRep', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb02', @article = N'all'
GO 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_ExecRep_UAT', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb02', @article = N'all'
GO 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_ExecRepAcc', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb02', @article = N'all'
GO   
-- Dropping the transactional subscriptions 
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Sync_DB06', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb02', @article = N'all'
GO  
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Vendor', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb02', @article = N'all'
GO  
use [bodb02]
exec sp_dropsubscription @publication = N'DBTrans_Vendor14', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb02', @article = N'all'
GO 

-- Dropping the registered subscriber
exec sp_dropsubscriber @subscriber = N'DB06C2\DB06'
GO

 