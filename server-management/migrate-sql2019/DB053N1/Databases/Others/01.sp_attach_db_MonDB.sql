IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = 'MonDB')
BEGIN
 CREATE DATABASE [MonDB] ON 
      (FILENAME = N'G:\user_db\MonDB\MonDB.mdf')
        , (FILENAME = N'G:\user_db\MonDB\MonDB_log.ldf')
     FOR ATTACH;
END
GO
