/*
	Creator:	20190723@Billy
	Task:		BetBackup database creation script - [Redmine: #116270]
	Server:		DBBETBK
*/


USE	master;
GO

CREATE DATABASE	BetBackup
ON	PRIMARY
		(	NAME		= N'BetBackup'
		,	FILENAME	= N'D:\IBC_DB\BetBackup\BetBackup.mdf'
		,	SIZE		= 4MB
		,	MAXSIZE		= UNLIMITED
		,	FILEGROWTH	= 4MB
		)

-- Default FILEGROUPs --
,	FILEGROUP DATA DEFAULT
		(	NAME		= N'BetBackup_DATA'
		,	FILENAME	= N'D:\IBC_DB\BetBackup\BetBackup_DATA.ndf'
		,	SIZE		= 32MB
		,	MAXSIZE		= UNLIMITED
		,	FILEGROWTH	= 32MB
		)
,	FILEGROUP IDX
		(	NAME		= N'BetBackup_IDX'
		,	FILENAME	= N'D:\IBC_DB\BetBackup\BetBackup_IDX.ndf'
		,	SIZE		= 32MB
		,	MAXSIZE		= UNLIMITED
		,	FILEGROWTH	= 32MB
		)

-- bettrans FILEGROUPs --
,	FILEGROUP bettrans_DATA
		(	NAME		= N'bettrans_DATA'
		,	FILENAME	= N'D:\IBC_DB\BetBackup\bettrans_DATA.ndf'
		,	SIZE		= 32MB
		,	MAXSIZE		= UNLIMITED
		,	FILEGROWTH	= 32MB
		)
,	FILEGROUP bettrans_IDX
		(	NAME		= N'bettrans_IDX'
		,	FILENAME	= N'D:\IBC_DB\BetBackup\bettrans_IDX.ndf'
		,	SIZE		= 32MB
		,	MAXSIZE		= UNLIMITED
		,	FILEGROWTH	= 32MB
		)

-- bettransm FILEGROUP --
,	FILEGROUP bettransm_DATA
		(	NAME		= N'bettransm_DATA'
		,	FILENAME	= N'D:\IBC_DB\BetBackup\bettransm_DATA.ndf'
		,	SIZE		= 32MB
		,	MAXSIZE		= UNLIMITED
		,	FILEGROWTH	= 32MB
		)
,	FILEGROUP bettransm_IDX
		(	NAME		= N'bettransm_IDX'
		,	FILENAME	= N'D:\IBC_DB\BetBackup\bettransm_IDX.ndf'
		,	SIZE		= 32MB
		,	MAXSIZE		= UNLIMITED
		,	FILEGROWTH	= 32MB
		)

-- translog FILEGROUP --
,	FILEGROUP translog_DATA
		(	NAME		= N'translog_DATA'
		,	FILENAME	= N'D:\IBC_DB\BetBackup\translog_DATA.ndf'
		,	SIZE		= 32MB
		,	MAXSIZE		= UNLIMITED
		,	FILEGROWTH	= 32MB
		)
,	FILEGROUP translog_IDX
		(	NAME		= N'translog_IDX'
		,	FILENAME	= N'D:\IBC_DB\BetBackup\translog_IDX.ndf'
		,	SIZE		= 32MB
		,	MAXSIZE		= UNLIMITED
		,	FILEGROWTH	= 32MB
		)

-- bettransReject FILEGROUPs --
,	FILEGROUP bettransReject_DATA
		(	NAME		= N'bettransReject_DATA'
		,	FILENAME	= N'D:\IBC_DB\BetBackup\bettransReject_DATA.ndf'
		,	SIZE		= 32MB
		,	MAXSIZE		= UNLIMITED
		,	FILEGROWTH	= 32MB
		)
,	FILEGROUP bettransReject_IDX
		(	NAME		= N'bettransReject_IDX'
		,	FILENAME	= N'D:\IBC_DB\BetBackup\bettransReject_IDX.ndf'
		,	SIZE		= 32MB
		,	MAXSIZE		= UNLIMITED
		,	FILEGROWTH	= 32MB
		)

-- translogReject FILEGROUP --
,	FILEGROUP translogReject_DATA
		(	NAME		= N'translogReject_DATA'
		,	FILENAME	= N'D:\IBC_DB\BetBackup\translogReject_DATA.ndf'
		,	SIZE		= 32MB
		,	MAXSIZE		= UNLIMITED
		,	FILEGROWTH	= 32MB
		)
,	FILEGROUP translogReject_IDX
		(	NAME		= N'translogReject_IDX'
		,	FILENAME	= N'D:\IBC_DB\BetBackup\translogReject_IDX.ndf'
		,	SIZE		= 32MB
		,	MAXSIZE		= UNLIMITED
		,	FILEGROWTH	= 32MB
		)

-- LOG --
	LOG ON
		(	NAME		= N'BetBackup_LOG'
		,	FILENAME	= N'D:\IBC_DB\BetBackup\BetBackup_LOG.ldf'
		,	SIZE		= 512MB
		,	MAXSIZE		= UNLIMITED
		,	FILEGROWTH	= 512MB
		)
;

ALTER DATABASE BetBackup SET COMPATIBILITY_LEVEL = 100;
ALTER DATABASE BetBackup SET RECOVERY SIMPLE;
ALTER DATABASE BetBackup SET DB_CHAINING ON;
ALTER DATABASE BetBackup SET READ_WRITE;
ALTER AUTHORIZATION ON DATABASE::BetBackup TO sa;
GO
