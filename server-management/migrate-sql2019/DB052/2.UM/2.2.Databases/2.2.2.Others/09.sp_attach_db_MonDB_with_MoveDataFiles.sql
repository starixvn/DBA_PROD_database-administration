/***
	- Created@20211124: Bobby
	- Host: Run on DB052 - new One
	- Task: Do ATTACH db MonDB with data files
***/
use master;
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = 'MonDB')
BEGIN
 CREATE DATABASE [MonDB] ON 
      (FILENAME = N'F:\USER_DB\MonDB\MonDB.mdf')
        , (FILENAME = N'F:\USER_DB\MonDB\MonDB_log.ldf')
     FOR ATTACH;
END
GO
