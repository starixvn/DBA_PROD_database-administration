/*
	Task enable service broker for bodb02 on DB05 & DB05BK1
*/
use bodb02
go



if @@SERVERNAME not in ('db05','db05bk1')
	return

/*
SELECT name,compatibility_level,recovery_model_desc,page_verify_option_desc
,is_auto_update_stats_async_on,is_trustworthy_on,is_parameterization_forced
,is_broker_enabled
FROM sys.databases
WHERE database_id > 4
ORDER BY 1
GO


SELECT 'ALTER DATABASE [' + name + '] SET ENABLE_BROKER WITH NO_WAIT;'
FROM sys.databases
WHERE database_id = db_id('bodb02')
ORDER BY 1
GO
*/

SET DEADLOCK_PRIORITY high

alter database bodb02 set single_user with rollback immediate

ALTER DATABASE bodb02 SET ENABLE_BROKER WITH NO_WAIT;

alter database bodb02 set multi_user

SET DEADLOCK_PRIORITY normal