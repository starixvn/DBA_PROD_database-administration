/***
	- Created@20211124: Bobby
	- Host: Run on DB052 - new One
	- Task: Do ATTACH db bodb_Licensee with data files
***/
use master;
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = 'bodb_Licensee')
BEGIN
 CREATE DATABASE [bodb_Licensee] ON 
      (FILENAME = N'H:\user_db\bodb_Licensee\bodb_Licensee.mdf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\bodb_Licensee_log.ldf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\bodb_Licensee_log03.ldf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\LicenseeCustComm_History_table_01.ndf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\BA\BA_Data_01.ndf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\data01.ndf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\data02.ndf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\licensee_table_02.ndf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\on_user_index_02.ndf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\on_user_table_02.ndf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\user_table_02.ndf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\userlog_table_02.ndf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\BATrans_01.ndf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\OWA\OWA_Data_02.ndf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\OWA\OWA_Index_02.ndf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\OWA\OWA_Userlog_data_03.ndf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\OWA\OWA_Userlog_index_03.ndf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\BATrans_BK_01.ndf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\BATrans_BK_02.ndf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\BA\BA_Index_01.ndf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\licensee_index_02.ndf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\DW_KPI_DATA_01.ndf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\AFF\AFF_Data_01.ndf')
        , (FILENAME = N'H:\user_db\bodb_Licensee\AFF\AFF_Index_01.ndf')
     FOR ATTACH;
END
GO

