USE master
GO

ALTER DATABASE bodb_Archive_staging ADD FILEGROUP [EVENT];
ALTER DATABASE bodb_Archive_staging ADD FILEGROUP [EVENT_Index];
ALTER DATABASE bodb_Archive_staging ADD FILEGROUP [bettrans_bk_table];
ALTER DATABASE bodb_Archive_staging ADD FILEGROUP [bettransG_table];
ALTER DATABASE bodb_Archive_staging ADD FILEGROUP [bettransLC_bk_table];
ALTER DATABASE bodb_Archive_staging ADD FILEGROUP [bettransm_table];
ALTER DATABASE bodb_Archive_staging ADD FILEGROUP [bettransRnG_bk_table];
ALTER DATABASE bodb_Archive_staging ADD FILEGROUP [LiveLog];
ALTER DATABASE bodb_Archive_staging ADD FILEGROUP [DATA];
ALTER DATABASE bodb_Archive_staging ADD FILEGROUP [transfer_bk_table];
ALTER DATABASE bodb_Archive_staging ADD FILEGROUP [translog_BK_table];

ALTER DATABASE bodb_Archive_staging ADD FILE (NAME = N'bodb_Archive_staging_EVENT', FILENAME = N'G:\IBC_DB\bodb_Archive_staging\bodb_Archive_staging_EVENT.ndf' , SIZE = 512KB , MAXSIZE = UNLIMITED, FILEGROWTH = 32768KB) TO FILEGROUP [EVENT];
ALTER DATABASE bodb_Archive_staging ADD FILE (NAME = N'bodb_Archive_staging_EVENT_Index', FILENAME = N'G:\IBC_DB\bodb_Archive_staging\bodb_Archive_staging_EVENT_Index.ndf' , SIZE = 512KB , MAXSIZE = UNLIMITED, FILEGROWTH = 32768KB) TO FILEGROUP [EVENT_Index];
ALTER DATABASE bodb_Archive_staging ADD FILE (NAME = N'bettrans_bk_table', FILENAME = N'G:\IBC_DB\bodb_Archive_staging\bettrans_bk_table.ndf' , SIZE = 512KB , MAXSIZE = UNLIMITED, FILEGROWTH = 32768KB) TO FILEGROUP [bettrans_bk_table];
ALTER DATABASE bodb_Archive_staging ADD FILE (NAME = N'bettransG_table', FILENAME = N'G:\IBC_DB\bodb_Archive_staging\bettransG_table.ndf' , SIZE = 512KB , MAXSIZE = UNLIMITED, FILEGROWTH = 32768KB) TO FILEGROUP [bettransG_table];
ALTER DATABASE bodb_Archive_staging ADD FILE (NAME = N'bettransLC_bk_table', FILENAME = N'G:\IBC_DB\bodb_Archive_staging\bettransLC_bk_table.ndf' , SIZE = 512KB , MAXSIZE = UNLIMITED, FILEGROWTH = 32768KB) TO FILEGROUP [bettransLC_bk_table];
ALTER DATABASE bodb_Archive_staging ADD FILE (NAME = N'bettransm_table', FILENAME = N'G:\IBC_DB\bodb_Archive_staging\bettransm_table.ndf' , SIZE = 512KB , MAXSIZE = UNLIMITED, FILEGROWTH = 32768KB) TO FILEGROUP [bettransm_table];
ALTER DATABASE bodb_Archive_staging ADD FILE (NAME = N'bettransRnG_bk_table', FILENAME = N'G:\IBC_DB\bodb_Archive_staging\bettransRnG_bk_table.ndf' , SIZE = 512KB , MAXSIZE = UNLIMITED, FILEGROWTH = 32768KB) TO FILEGROUP [bettransRnG_bk_table];
ALTER DATABASE bodb_Archive_staging ADD FILE (NAME = N'bodb_Archive_staging_LiveLog', FILENAME = N'G:\IBC_DB\bodb_Archive_staging\bodb_Archive_staging_LiveLog.ndf' , SIZE = 512KB , MAXSIZE = UNLIMITED, FILEGROWTH = 32768KB) TO FILEGROUP [LiveLog];
ALTER DATABASE bodb_Archive_staging ADD FILE (NAME = N'bodb_Archive_staging_DATA', FILENAME = N'G:\IBC_DB\bodb_Archive_staging\bodb_Archive_staging_DATA.ndf' , SIZE = 512KB , MAXSIZE = UNLIMITED, FILEGROWTH = 32768KB) TO FILEGROUP [DATA];
ALTER DATABASE bodb_Archive_staging ADD FILE (NAME = N'transfer_bk_table', FILENAME = N'G:\IBC_DB\bodb_Archive_staging\transfer_bk_table.ndf' , SIZE = 512KB , MAXSIZE = UNLIMITED, FILEGROWTH = 32768KB) TO FILEGROUP [transfer_bk_table];
ALTER DATABASE bodb_Archive_staging ADD FILE (NAME = N'translog_BK_table', FILENAME = N'G:\IBC_DB\bodb_Archive_staging\translog_BK_table.ndf' , SIZE = 512KB , MAXSIZE = UNLIMITED, FILEGROWTH = 32768KB) TO FILEGROUP [translog_BK_table];