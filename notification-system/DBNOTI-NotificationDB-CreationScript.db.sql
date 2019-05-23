USE	master;
GO
CREATE DATABASE NotificationDB
	ON	PRIMARY (
			NAME		= N'NotificationDB'
		,	FILENAME	= N'G:\USER_DB\NotificationDB\NotificationDB.mdf'
		,	SIZE		= 4096KB
		,	FILEGROWTH	= 4096KB
		)
	,	FILEGROUP DATA (
			NAME		= N'NotificationDB_DATA'
		,	FILENAME	= N'G:\USER_DB\NotificationDB\NotificationDB_DATA.ndf'
		,	SIZE		= 131072KB
		,	FILEGROWTH	= 131072KB
		)
	,	FILEGROUP IDX (
			NAME		= N'NotificationDB_IDX'
		,	FILENAME	= N'G:\USER_DB\NotificationDB\NotificationDB_IDX.ndf'
		,	SIZE		= 131072KB
		,	FILEGROWTH	= 131072KB
		)
	LOG ON (
		NAME		= N'NotificationDB_log'
	,	FILENAME	= N'G:\USER_DB\NotificationDB\NotificationDB_log.ldf'
	,	SIZE		= 1048576KB
	,	FILEGROWTH	= 524288KB
	);
GO
USE	NotificationDB;
GO
IF	NOT EXISTS (SELECT 1 FROM sys.filegroups WITH (NOLOCK) WHERE is_default = 1 AND name = N'DATA')
	ALTER DATABASE NotificationDB MODIFY FILEGROUP DATA DEFAULT;
GO
EXECUTE	sys.sp_changedbowner @loginame = N'sa', @map = false;
GO
