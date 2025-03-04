/*
	Task: Attach indicated databases:
		SAS_adhocReport_UAT - 3 files
		MONDB - 2 files
		DEL_LasDB_Archive - 14 files
		bodb_TGRS_UAT - 12 files
		
	Created on 20250303 by Daniel
	Run on DB062
*/

USE [master]
GO
CREATE DATABASE [SAS_adhocReport_UAT] ON
 (FILENAME = 'L:\USER_DB\SAS_adhocReport\SAS_adhocReport_log.ldf')
,(FILENAME = 'L:\USER_DB\SAS_adhocReport\data.ndf')
,(FILENAME = 'L:\USER_DB\SAS_adhocReport\SAS_adhocReport.mdf')

 FOR ATTACH
GO



USE [master]
GO
CREATE DATABASE [MONDB] ON
 (FILENAME = 'L:\USER_DB\MonDB\MONDB_log.ldf')
,(FILENAME = 'L:\USER_DB\MonDB\MONDB.mdf')

 FOR ATTACH
GO



USE [master]
GO
CREATE DATABASE [DEL_LasDB_Archive] ON
 (FILENAME = 'L:\USER_DB\LasDB_Archive\LASDB_log.ldf')
,(FILENAME = 'L:\USER_DB\LasDB_Archive\BETBK_data.ndf')
,(FILENAME = 'L:\USER_DB\LasDB_Archive\bettrans_agent_index.ndf')
,(FILENAME = 'L:\USER_DB\LasDB_Archive\bettrans_agent_table.ndf')
,(FILENAME = 'L:\USER_DB\LasDB_Archive\bettrans_index.ndf')
,(FILENAME = 'L:\USER_DB\LasDB_Archive\betrans_table.ndf')
,(FILENAME = 'L:\USER_DB\LasDB_Archive\bettransm_index.ndf')
,(FILENAME = 'L:\USER_DB\LasDB_Archive\betransm_table.ndf')
,(FILENAME = 'L:\USER_DB\LasDB_Archive\DATA.ndf')
,(FILENAME = 'L:\USER_DB\LasDB_Archive\INDEX.ndf')
,(FILENAME = 'L:\USER_DB\LasDB_Archive\LASDB.mdf')
,(FILENAME = 'L:\USER_DB\LasDB_Archive\TRANSBK_data.ndf')
,(FILENAME = 'L:\USER_DB\LasDB_Archive\Transfer_bk_Index.ndf')
,(FILENAME = 'L:\USER_DB\LasDB_Archive\Transfer_bk_Table.ndf')

 FOR ATTACH
GO



USE [master]
GO
CREATE DATABASE [bodb_TGRS_UAT] ON
 (FILENAME = 'K:\USER_DB\bodb_TGRS_UAT\bodb_TGRS_log.ldf')
,(FILENAME = 'K:\USER_DB\bodb_TGRS_UAT\Data.ndf')
,(FILENAME = 'K:\USER_DB\bodb_TGRS_UAT\Index.ndf')
,(FILENAME = 'K:\USER_DB\bodb_TGRS_UAT\bodb_TGRS.mdf')
,(FILENAME = 'K:\USER_DB\bodb_TGRS_UAT\Trader_StagingDB.ndf')
,(FILENAME = 'K:\USER_DB\bodb_TGRS_UAT\TraderInfo_Index.ndf')
,(FILENAME = 'K:\USER_DB\bodb_TGRS_UAT\TraderInfo_Table.ndf')
,(FILENAME = 'K:\USER_DB\bodb_TGRS_UAT\TraderPerformanceDetail_Index.ndf')
,(FILENAME = 'K:\USER_DB\bodb_TGRS_UAT\TraderPerformanceDetail_Table.ndf')
,(FILENAME = 'K:\USER_DB\bodb_TGRS_UAT\TraderPerformanceSummary_Index.ndf')
,(FILENAME = 'K:\USER_DB\bodb_TGRS_UAT\TraderPerformanceSummary_Table.ndf')
,(FILENAME = 'K:\USER_DB\bodb_TGRS_UAT\UserLog_RunSp.ndf')

 FOR ATTACH
GO
