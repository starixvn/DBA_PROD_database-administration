--Task: Change file location
--Run on db061
use MASTER
go

ALTER DATABASE bodb_Licensee
MODIFY FILE (NAME = bodb_Licensee_log, FILENAME = 'H:\User_DB\bodb_Licensee\bodb_Licensee_log.ldf'),
MODIFY FILE (NAME = BA_Data_1, FILENAME = 'H:\User_DB\bodb_Licensee\BA_Data_01.ndf'),
MODIFY FILE (NAME = BA_Index_1, FILENAME = 'H:\User_DB\bodb_Licensee\BA_Index_01.ndf'),
MODIFY FILE (NAME = BATrans_BK, FILENAME = 'H:\USER_DB\bodb_Licensee\BATrans_BK.ndf'),
MODIFY FILE (NAME = data01, FILENAME = 'H:\User_DB\bodb_Licensee\data01.ndf'),
MODIFY FILE (NAME = data02, FILENAME = 'H:\User_DB\bodb_licensee\data02.ndf'),
MODIFY FILE (NAME = licensee_index_2, FILENAME = 'H:\User_DB\bodb_licensee\licensee_index_02.ndf'),
MODIFY FILE (NAME = licensee_table_02, FILENAME = 'H:\User_DB\bodb_Licensee\licensee_table_02.ndf'),
MODIFY FILE (NAME = LicenseeCustComm_History_table_01, FILENAME = 'H:\USER_DB\bodb_Licensee\LicenseeCustComm_History_table_01.ndf'),
MODIFY FILE (NAME = on_user_index_02, FILENAME = 'H:\User_DB\bodb_Licensee\on_user_index_02.ndf'),
MODIFY FILE (NAME = on_user_table_02, FILENAME = 'H:\User_DB\bodb_Licensee\on_user_table_02.ndf'),
MODIFY FILE (NAME = OWA_DATA, FILENAME = 'H:\USER_DB\bodb_licensee\OWN_DATA.ndf'),
MODIFY FILE (NAME = OWA_INDEX, FILENAME = 'H:\USER_DB\bodb_licensee\OWA_INDEX.ndf'),
MODIFY FILE (NAME = bodb_Licensee, FILENAME = 'H:\User_DB\bodb_Licensee\bodb_Licensee.mdf'),
MODIFY FILE (NAME = user_table_02, FILENAME = 'H:\User_DB\bodb_Licensee\user_table_02.ndf'),
go