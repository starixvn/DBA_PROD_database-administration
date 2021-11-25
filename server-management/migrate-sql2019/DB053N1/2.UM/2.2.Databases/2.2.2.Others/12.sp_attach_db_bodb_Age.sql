IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = 'bodb_AGE')
BEGIN
 CREATE DATABASE [bodb_AGE] ON 
      (FILENAME = N'F:\USER_DB\bodb_Age\bodb_AGE.mdf')
        , (FILENAME = N'F:\USER_DB\bodb_Age\bodb_AGE_log.ldf')
        , (FILENAME = N'F:\USER_DB\bodb_AGE\ageProfiledata.NDF')
        , (FILENAME = N'F:\USER_DB\bodb_Age\ageTable_01.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_Age\ageBettransTable_01.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_Age\ageBettransIndex_01.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_Age\ageIndex_01.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_AGE\bodb_AGE_log_02.ldf')
        , (FILENAME = N'F:\USER_DB\bodb_Age\ageBettransIndex02.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_Age\ageDATA_02.ndf')
        , (FILENAME = N'F:\USER_DB\bodb_Age\ageBettransIndex03.ndf')
     FOR ATTACH;
END
GO
