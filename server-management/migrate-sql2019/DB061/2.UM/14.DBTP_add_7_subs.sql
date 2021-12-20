

---==== DBTrans add sub
GO
exec sp_addsubscriber @subscriber = N'DB061', @type = 0, @description = N''
GO
  

-- Adding the transactional subscriptions

use [bodb02]
exec sp_addsubscription @publication = N'DBTrans_Bet', @subscriber = N'DB061', @destination_db = N'bodb02', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'DBTrans_Bet', @subscriber = N'DB061', @subscriber_db = N'bodb02', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO
 
  

-- Adding the transactional subscriptions

 
use [bodb02]
exec sp_addsubscription @publication = N'DBTrans_Bet14', @subscriber = N'DB061', @destination_db = N'bodb02', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'DBTrans_Bet14', @subscriber = N'DB061', @subscriber_db = N'bodb02', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO
  

-- Adding the transactional subscriptions

 
use [bodb02]
exec sp_addsubscription @publication = N'DBTrans_ExecRep', @subscriber = N'DB061', @destination_db = N'bodb02', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'DBTrans_ExecRep', @subscriber = N'DB061', @subscriber_db = N'bodb02', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO
  
-- Adding the transactional subscriptions

use [bodb02]
exec sp_addsubscription @publication = N'DBTrans_ExecRep_UAT', @subscriber = N'DB061', @destination_db = N'bodb02', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'DBTrans_ExecRep_UAT', @subscriber = N'DB061', @subscriber_db = N'bodb02', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO
 
-- Adding the transactional subscriptions

use [bodb02]
exec sp_addsubscription @publication = N'DBTrans_ExecRepAcc', @subscriber = N'DB061', @destination_db = N'bodb02', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'DBTrans_ExecRepAcc', @subscriber = N'DB061', @subscriber_db = N'bodb02', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO
 
  
-- Adding the transactional subscriptions
use [bodb02]
exec sp_addsubscription @publication = N'DBTrans_Sync_DB06', @subscriber = N'DB061', @destination_db = N'bodb02', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'DBTrans_Sync_DB06', @subscriber = N'DB061', @subscriber_db = N'bodb02', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO
  

-- Adding the transactional subscriptions

use [bodb02]
exec sp_addsubscription @publication = N'DBTrans_Vendor', @subscriber = N'DB061', @destination_db = N'bodb02', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'DBTrans_Vendor', @subscriber = N'DB061', @subscriber_db = N'bodb02', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO
  

-- Adding the transactional subscriptions
 
use [bodb02]
exec sp_addsubscription @publication = N'DBTrans_Vendor14', @subscriber = N'DB061', @destination_db = N'bodb02', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'DBTrans_Vendor14', @subscriber = N'DB061', @subscriber_db = N'bodb02', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO
  

----==== DBCust add sub
 
exec sp_addsubscriber @subscriber = N'DB061', @type = 0, @description = N''
GO
 
-- Adding the transactional subscriptions

use [bodb_Licensee]
exec sp_addsubscription @publication = N'Cusdb_bodb_licensee', @subscriber = N'DB061', @destination_db = N'bodb_licensee', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'Cusdb_bodb_licensee', @subscriber = N'DB061', @subscriber_db = N'bodb_licensee', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO
 
-- Adding the transactional subscriptions

use [bodb_Licensee]
exec sp_addsubscription @publication = N'CustDB_bodb_Licensee_BA', @subscriber = N'DB061', @destination_db = N'bodb_licensee', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'CustDB_bodb_Licensee_BA', @subscriber = N'DB061', @subscriber_db = N'bodb_licensee', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO
    
-- Adding the transactional subscriptions

use [CustDB]
exec sp_addsubscription @publication = N'CustDB_Customer_Info', @subscriber = N'DB061', @destination_db = N'bodb02', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'CustDB_Customer_Info', @subscriber = N'DB061', @subscriber_db = N'bodb02', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO
 
  
-- Adding the transactional subscriptions
use [CustDB]
exec sp_addsubscription @publication = N'CustDB_CustSetting', @subscriber = N'DB061', @destination_db = N'bodb02', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'CustDB_CustSetting', @subscriber = N'DB061', @subscriber_db = N'bodb02', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO
    

-- Adding the transactional subscriptions
use [CustDB]
exec sp_addsubscription @publication = N'CustDB_DR_sync', @subscriber = N'DB061', @destination_db = N'bodb02', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'CustDB_DR_sync', @subscriber = N'DB061', @subscriber_db = N'bodb02', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO
  

-- Adding the transactional subscriptions

use [CustDB]
exec sp_addsubscription @publication = N'CustDB_ExchangeDaily', @subscriber = N'DB061', @destination_db = N'bodb02', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'CustDB_ExchangeDaily', @subscriber = N'DB061', @subscriber_db = N'bodb02', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO
  
-- Adding the transactional subscriptions

 
use [CustDB]
exec sp_addsubscription @publication = N'CustDB_ExecRepAcc_Cust', @subscriber = N'DB061', @destination_db = N'bodb02', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'CustDB_ExecRepAcc_Cust', @subscriber = N'DB061', @subscriber_db = N'bodb02', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO
  
-- Adding the transactional subscriptions
 
use [CustDB]
exec sp_addsubscription @publication = N'CustDB_Login_Exchange', @subscriber = N'DB061', @destination_db = N'bodb02', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'CustDB_Login_Exchange', @subscriber = N'DB061', @subscriber_db = N'bodb02', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO
  

----=== DB02 add sub



-- Add subscribers

exec sp_addsubscriber @subscriber = N'DB061', @type = 0, @description = N''
GO 
 
  
-- Adding the transactional subscriptions

use [bodb02]
exec sp_addsubscription @publication = N'DB02_Dot', @subscriber = N'DB061', @destination_db = N'bodb02', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'DB02_Dot', @subscriber = N'DB061', @subscriber_db = N'bodb02', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO
  
-- Adding the transactional subscriptions

use [bodb02]
exec sp_addsubscription @publication = N'DB02_event14', @subscriber = N'DB061', @destination_db = N'bodb02', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'DB02_event14', @subscriber = N'DB061', @subscriber_db = N'bodb02', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO
  

-- Adding the transactional subscriptions

use [bodb02]
exec sp_addsubscription @publication = N'DB02_Odds_3rd', @subscriber = N'DB061', @destination_db = N'bodb02', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'DB02_Odds_3rd', @subscriber = N'DB061', @subscriber_db = N'bodb02', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO 
  

-- Adding the transactional subscriptions

use [bodb02]
exec sp_addsubscription @publication = N'DB02_Odds_Info', @subscriber = N'DB061', @destination_db = N'bodb02', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'DB02_Odds_Info', @subscriber = N'DB061', @subscriber_db = N'bodb02', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO 

 
-- Adding the transactional subscriptions

 
use [bodb02]
exec sp_addsubscription @publication = N'DB02_Odds_Odds', @subscriber = N'DB061', @destination_db = N'bodb02', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'DB02_Odds_Odds', @subscriber = N'DB061', @subscriber_db = N'bodb02', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO 

  
-- Adding the transactional subscriptions
 
use [bodb02]
exec sp_addsubscription @publication = N'DB02_OddsOS', @subscriber = N'DB061', @destination_db = N'bodb02', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'DB02_OddsOS', @subscriber = N'DB061', @subscriber_db = N'bodb02', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO
   
-- Adding the transactional subscriptions
use [bodb02]
exec sp_addsubscription @publication = N'DB02_Sync_DB06', @subscriber = N'DB061', @destination_db = N'bodb02', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'DB02_Sync_DB06', @subscriber = N'DB061', @subscriber_db = N'bodb02', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO
  
