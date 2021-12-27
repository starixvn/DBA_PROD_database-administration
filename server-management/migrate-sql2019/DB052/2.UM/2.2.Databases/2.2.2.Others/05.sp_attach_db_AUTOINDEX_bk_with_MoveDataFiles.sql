/***
	- Created@20211124: Bobby
	- Host: Run on DB052 - new One
	- Task: Do ATTACH db AUTOINDEXRECS vs bk with data files
***/
use master;
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = 'AUTOINDEXRECS')
BEGIN
 CREATE DATABASE [AUTOINDEXRECS] ON 
      (FILENAME = N'F:\USER_DB\AUTOINDEXRECS\AUTOINDEXRECS.mdf')
        , (FILENAME = N'F:\USER_DB\AUTOINDEXRECS\AUTOINDEXRECS_log.LDF')
     FOR ATTACH;
END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = 'bk')
BEGIN
 CREATE DATABASE [bk] ON 
      (FILENAME = N'I:\user_db\bk\bk.mdf')
        , (FILENAME = N'I:\user_db\bk\bk_log.ldf')
        , (FILENAME = N'I:\user_db\bk\bk_5.ldf')
        , (FILENAME = N'I:\user_db\bk\bk_02.ndf')
        , (FILENAME = N'I:\user_db\bk\bk_03.ndf')
        , (FILENAME = N'I:\user_db\bk\bk_04.ndf')
        , (FILENAME = N'I:\user_db\bk\bets_data.ndf')
        , (FILENAME = N'I:\user_db\bk\bets_index.ndf')
        , (FILENAME = N'I:\user_db\bk\betsReject_data.ndf')
        , (FILENAME = N'I:\user_db\bk\betsReject_index.ndf')
     FOR ATTACH;
END
GO
