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
