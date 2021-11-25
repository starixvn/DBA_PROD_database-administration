IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = 'bodb_PlaytechCS')
BEGIN
 CREATE DATABASE [bodb_PlaytechCS] ON 
      (FILENAME = N'F:\USER_DB\bodb_PlaytechCS\bodb_PlaytechCS.mdf')
        , (FILENAME = N'F:\USER_DB\bodb_PlaytechCS\bodb_PlaytechCS_log.ldf')
        , (FILENAME = N'F:\USER_DB\bodb_PlaytechCS\bettrans_PlaytechCS_Index_01.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_PlaytechCS\bettrans_PlaytechCS_Data_01.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_PlaytechCS\bettrans_playtechCS_Table_01.ndf')
     FOR ATTACH;
END
GO
