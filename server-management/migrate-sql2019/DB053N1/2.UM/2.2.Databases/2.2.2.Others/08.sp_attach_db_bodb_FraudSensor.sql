IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = 'bodb_FraudSensor')
BEGIN
 CREATE DATABASE [bodb_FraudSensor] ON 
      (FILENAME = N'I:\user_db\bodb_FraudSensor\bodb_FraudSensor.mdf')
        , (FILENAME = N'I:\user_db\bodb_FraudSensor\bodb_FraudSensor_log.ldf')
        , (FILENAME = N'I:\user_db\bodb_FraudSensor\data_01.ndf')
        , (FILENAME = N'I:\user_db\bodb_FraudSensor\idx_01.ndf')
        , (FILENAME = N'I:\user_db\bodb_FraudSensor\UserLog_01.ndf')
        , (FILENAME = N'I:\user_db\bodb_FraudSensor\OddsLog_01.ndf')
        , (FILENAME = N'I:\user_db\bodb_FraudSensor\FS_Footprint.ndf')
     FOR ATTACH;
END
GO
