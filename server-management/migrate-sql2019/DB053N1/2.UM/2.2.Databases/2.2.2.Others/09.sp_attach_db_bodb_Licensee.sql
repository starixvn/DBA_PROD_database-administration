IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = 'bodb_Licensee')
BEGIN
 CREATE DATABASE [bodb_Licensee] ON 
      (FILENAME = N'H:\USER_DB\bodb_Licensee\bodb_Licensee.mdf')
        , (FILENAME = N'H:\USER_DB\bodb_Licensee\bodb_Licensee_log.ldf')
        , (FILENAME = N'H:\USER_DB\bodb_Licensee\BA_Data_01.ndf')
        , (FILENAME = N'H:\USER_DB\bodb_Licensee\BA_Index_01.ndf')
        , (FILENAME = N'H:\USER_DB\bodb_Licensee\data01.ndf')
        , (FILENAME = N'H:\USER_DB\bodb_licensee\data02.ndf')
        , (FILENAME = N'H:\USER_DB\bodb_licensee\licensee_index_02.ndf')
        , (FILENAME = N'H:\USER_DB\bodb_Licensee\licensee_table_02.ndf')
        , (FILENAME = N'H:\USER_DB\bodb_Licensee\on_user_index_02.ndf')
        , (FILENAME = N'H:\USER_DB\bodb_Licensee\on_user_table_02.ndf')
        , (FILENAME = N'H:\USER_DB\bodb_Licensee\user_table_02.ndf')
        , (FILENAME = N'H:\USER_DB\bodb_Licensee\BA_DATA.ndf')
        , (FILENAME = N'H:\USER_DB\bodb_Licensee\BATrans.ndf')
        , (FILENAME = N'H:\USER_DB\bodb_Licensee\BATrans_BK_01.ndf')
        , (FILENAME = N'H:\USER_DB\bodb_Licensee\BATrans_BK_02.ndf')
        , (FILENAME = N'H:\USER_DB\bodb_licensee\OWN_DATA.ndf')
        , (FILENAME = N'H:\USER_DB\bodb_licensee\OWA_INDEX.ndf')
        , (FILENAME = N'H:\USER_DB\bodb_Licensee\LicenseeCustComm_History_table_01.ndf')
     FOR ATTACH;
END
GO
