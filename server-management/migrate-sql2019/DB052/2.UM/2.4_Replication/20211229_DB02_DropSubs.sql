

--==========================================DB052======================================================-- 
-- Dropping the transactional subscriptions 
use [bodb02]
exec sp_dropsubscription @publication = N'DB02_Dot', @subscriber = N'DB052', @destination_db = N'bodb02', @article = N'all'
GO 
-- Dropping the transactional subscriptions

use [bodb02]
exec sp_dropsubscription @publication = N'DB02_event14', @subscriber = N'DB052', @destination_db = N'bodb02', @article = N'all'
GO 
-- Dropping the transactional subscriptions
GO
use [bodb02]
exec sp_dropsubscription @publication = N'DB02_Odds_3rd', @subscriber = N'DB052', @destination_db = N'bodb02', @article = N'all'
GO 
-- Dropping the transactional subscriptions
 
use [bodb02]
exec sp_dropsubscription @publication = N'DB02_Odds_Info', @subscriber = N'DB052', @destination_db = N'bodb02', @article = N'all'
GO 

-- Dropping the transactional subscriptions 
use [bodb02]
exec sp_dropsubscription @publication = N'DB02_Odds_Odds', @subscriber = N'DB052', @destination_db = N'bodb02', @article = N'all'
GO  
  
use master 
GO
-- Dropping the registered subscriber
exec sp_dropsubscriber @subscriber = N'DB052'
GO 

 
--==========================================DB054C2\DB054======================================================--
use [bodb02]
exec sp_dropsubscription @publication = N'DB02_event14', @subscriber = N'DB054C2\DB054', @destination_db = N'bodb02', @article = N'all'
GO 
 use [bodb02]
exec sp_dropsubscription @publication = N'DB02_Odds_3rd', @subscriber = N'DB054C2\DB054', @destination_db = N'bodb02', @article = N'all'
GO 
use [bodb02]
exec sp_dropsubscription @publication = N'DB02_Odds_Info', @subscriber = N'DB054C2\DB054', @destination_db = N'bodb02', @article = N'all'
GO 
use [bodb02]
exec sp_dropsubscription @publication = N'DB02_Odds_Odds', @subscriber = N'DB054C2\DB054', @destination_db = N'bodb02', @article = N'all'
GO 
-- Dropping the registered subscriber
exec sp_dropsubscriber @subscriber = N'DB054C2\DB054'
GO
 --==========================================DB06C2\DB06======================================================--
 GO
use [bodb02]
exec sp_dropsubscription @publication = N'DB02_Dot', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb02', @article = N'all'
GO 
use [bodb02]
exec sp_dropsubscription @publication = N'DB02_event14', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb02', @article = N'all'
GO  
use [bodb02]
exec sp_dropsubscription @publication = N'DB02_Odds_3rd', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb02', @article = N'all'
GO 
use [bodb02]
exec sp_dropsubscription @publication = N'DB02_Odds_Info', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb02', @article = N'all'
GO  
use [bodb02]
exec sp_dropsubscription @publication = N'DB02_Odds_Odds', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb02', @article = N'all'
GO  

-- Dropping the transactional subscriptions 
use [bodb02]
exec sp_dropsubscription @publication = N'DB02_OddsOS', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb02', @article = N'all'
GO 
-- Dropping the transactional subscriptions 
use [bodb02]
exec sp_dropsubscription @publication = N'DB02_Sync_DB06', @subscriber = N'DB06C2\DB06', @destination_db = N'bodb02', @article = N'all'
GO 

-- Dropping the registered subscriber
exec sp_dropsubscriber @subscriber = N'DB06C2\DB06'
GO
 
