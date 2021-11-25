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
