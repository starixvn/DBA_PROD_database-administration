/***
	- Created@20211124: Bobby
	- Host: Run on DB052 - new One
	- Task: Do ATTACH db bodb_3rd AIO with data files - 3 dbs
***/
use master;
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = 'bodb_3rdProduct')
BEGIN
 CREATE DATABASE [bodb_3rdProduct] ON 
      (FILENAME = N'F:\USER_DB\bodb_3rdProduct\bodb_3rdProduct.mdf')
        , (FILENAME = N'F:\USER_DB\bodb_3rdProduct\bodb_3rdProduct_log.ldf')
        , (FILENAME = N'F:\USER_DB\bodb_3rdProduct\3rdProduct_Data.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_3rdProduct\3rdProduct_Index.ndf')
     FOR ATTACH;
END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = 'bodb_Oddsfeed')
BEGIN
 CREATE DATABASE [bodb_Oddsfeed] ON 
      (FILENAME = N'F:\USER_DB\bodb_oddsfeed\bodb_oddsfeed.mdf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\bodb_oddsfeed_log.ldf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\AccInfoData.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\AccInfoIndex.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\DATA.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\INDEX.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\Statistics_2013.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\Statistics_2014.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\Statistics_2015.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\Statistics_2016.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\Statistics_MAX.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\UserLog_2013.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\UserLog_2014.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\UserLog_2015.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\UserLog_2016.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\UserLog_MAX.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\Statistics_2017.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\Statistics_2018.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\UserLog_2017.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\UserLog_2018.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\Statistics_2019.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\Statistics_2020.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\Statistics_2021.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\Statistics_2022.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\UserLog_2019.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\UserLog_2020.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\UserLog_2021.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_oddsfeed\UserLog_2022.ndf')
     FOR ATTACH;
END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = 'bodb_PlaytechCS')
BEGIN
 CREATE DATABASE [bodb_PlaytechCS] ON 
      (FILENAME = N'I:\user_db\bodb_PlaytechCS\bodb_PlaytechCS.mdf')
        , (FILENAME = N'F:\USER_DB\bodb_PlaytechCS\bodb_PlaytechCS_log.ldf')
        , (FILENAME = N'I:\user_db\bodb_PlaytechCS\bettrans_PlaytechCS_Index_01.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_PlaytechCS\bettrans_PlaytechCS_Data_01.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_PlaytechCS\bettrans_playtechCS_Table_01.ndf')
     FOR ATTACH;
END
GO
