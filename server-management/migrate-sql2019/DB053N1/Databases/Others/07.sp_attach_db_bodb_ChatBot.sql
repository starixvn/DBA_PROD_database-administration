IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = 'bodb_ChatBot')
BEGIN
 CREATE DATABASE [bodb_ChatBot] ON 
      (FILENAME = N'F:\USER_DB\bodb_ChatBot\bodb_ChatBot.mdf')
        , (FILENAME = N'F:\USER_DB\bodb_ChatBot\bodb_ChatBot_log.ldf')
        , (FILENAME = N'F:\USER_DB\bodb_ChatBot\bodb_ChatBot_data.NDF')
        , (FILENAME = N'F:\USER_DB\bodb_ChatBot\bodb_ChatBot_DataLog.NDF')
     FOR ATTACH;
END
GO
