/***
	- Created@20211124: Bobby
	- Host: Run on DB052 - new One
	- Task: Do ATTACH db LASDB with data files
***/
use master;
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = 'LASDB')
BEGIN
 CREATE DATABASE [LASDB] ON 
      (FILENAME = N'H:\user_db\LasDB\LASDB.mdf')
        , (FILENAME = N'H:\user_db\LasDB\LASDB_log.ldf')
        , (FILENAME = N'H:\user_db\LasDB\AgentBetLimit_Table_01.ndf')
        , (FILENAME = N'H:\user_db\LasDB\AgentDiscount_Table_01.ndf')
        , (FILENAME = N'H:\user_db\LasDB\AgentInfo_Index_01.ndf')
        , (FILENAME = N'H:\user_db\LasDB\AgentInfo_Table_01.ndf')
        , (FILENAME = N'H:\user_db\LasDB\AgentPositionTaking_Table_01.ndf')
        , (FILENAME = N'H:\user_db\LasDB\AgentUser_Table_01.ndf')
        , (FILENAME = N'H:\user_db\LasDB\Balance.ndf')
        , (FILENAME = N'H:\user_db\LasDB\BetTrans_Agent_Index_01.ndf')
        , (FILENAME = N'H:\user_db\LasDB\BetTrans_Agent_Table_01.ndf')
        , (FILENAME = N'H:\user_db\LasDB\Bettrans_Index1_01.NDF')
        , (FILENAME = N'H:\user_db\LasDB\Bettrans_Index2_01.NDF')
        , (FILENAME = N'H:\user_db\LasDB\Bettrans_Index3_01.NDF')
        , (FILENAME = N'H:\user_db\LasDB\Bettrans_Table_01.NDF')
        , (FILENAME = N'H:\user_db\LasDB\Bettrans_Table_02.NDF')
        , (FILENAME = N'H:\user_db\LasDB\BetTrans14_Agent_Index_01.ndf')
        , (FILENAME = N'H:\user_db\LasDB\BetTrans14_Agent_Table_01.ndf')
        , (FILENAME = N'H:\user_db\LasDB\Bettrans14_Index_01.NDF')
        , (FILENAME = N'H:\user_db\LasDB\Bettrans14_Table_01.NDF')
        , (FILENAME = N'H:\user_db\LasDB\Bettrans14_Table_02.NDF')
        , (FILENAME = N'H:\user_db\LasDB\BettransM_Index_01.NDF')
        , (FILENAME = N'H:\user_db\LasDB\BettransM_Table_01.NDF')
        , (FILENAME = N'H:\user_db\LasDB\BettransM14_Index_01.NDF')
        , (FILENAME = N'H:\user_db\LasDB\BettransM14_Table_01.NDF')
        , (FILENAME = N'H:\user_db\LasDB\CustBetLimit_Table_01.ndf')
        , (FILENAME = N'H:\user_db\LasDB\CustDiscount_Table_01.ndf')
        , (FILENAME = N'H:\user_db\LasDB\CustInfo_Index_01.ndf')
        , (FILENAME = N'H:\user_db\LasDB\CustInfo_Table_01.ndf')
        , (FILENAME = N'H:\user_db\LasDB\CustPositionTaking_Table_01.ndf')
        , (FILENAME = N'H:\user_db\LasDB\CustPositionTaking_Table_02.ndf')
        , (FILENAME = N'H:\user_db\LasDB\CustPositionTaking_Table_03.ndf')
        , (FILENAME = N'F:\USER_DB\LasDB\LASDB_log2.ldf')
        , (FILENAME = N'H:\user_db\LasDB\DATA_01.ndf')
        , (FILENAME = N'H:\user_db\LasDB\DATA_02.ndf')
        , (FILENAME = N'H:\user_db\LasDB\DATA_03.ndf')
        , (FILENAME = N'H:\user_db\LasDB\LicenseeGroupComm_Table.mdf')
        , (FILENAME = N'H:\user_db\LasDB\Event_Table_01.NDF')
        , (FILENAME = N'H:\user_db\LasDB\Event14_Index_01.NDF')
        , (FILENAME = N'H:\user_db\LasDB\Event14_Table_01.NDF')
        , (FILENAME = N'H:\user_db\LasDB\INDEX_01.NDF')
        , (FILENAME = N'H:\user_db\LasDB\INDEX_02.NDF')
        , (FILENAME = N'H:\user_db\LasDB\INDEX_03.NDF')
        , (FILENAME = N'H:\user_db\LASDB\CustPositionTaking_Index1_01.ndf')
        , (FILENAME = N'H:\user_db\LASDB\CustPositionTaking3rd_Index1_01.ndf')
        , (FILENAME = N'H:\user_db\LASDB\AgentProductSetting_Table_01.ndf')
        , (FILENAME = N'H:\user_db\LasDB\Sum_WinLoss_index_01.ndf')
        , (FILENAME = N'H:\user_db\LasDB\Sum_WinLoss_table_01.ndf')
        , (FILENAME = N'H:\user_db\LasDB\AgentDiscount_3rd_Table.ndf')
        , (FILENAME = N'H:\user_db\LasDB\AgentPositionTaking_3rd_Table.ndf')
        , (FILENAME = N'H:\user_db\LasDB\AgentBetLimit_3rd_Table.ndf')
        , (FILENAME = N'H:\user_db\LasDB\CustPositionTaking_3rd_Table_01.ndf')
        , (FILENAME = N'H:\user_db\LasDB\serviceBroker_01.ndf')
        , (FILENAME = N'H:\user_db\LasDB\serviceBroker_02.ndf')
     FOR ATTACH;
END
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = 'Las_LogDB')
BEGIN
 CREATE DATABASE [Las_LogDB] ON 
      (FILENAME = N'F:\USER_DB\Las_LogDB\LasLog.mdf')
        , (FILENAME = N'F:\USER_DB\Las_LogDB\LasLog_log.ldf')
        , (FILENAME = N'F:\USER_DB\Las_LogDB\DATA.ndf')
        , (FILENAME = N'F:\USER_DB\Las_LogDB\LoginAgent.ndf')
        , (FILENAME = N'F:\USER_DB\Las_LogDB\RunSpAgent.ndf')
        , (FILENAME = N'F:\USER_DB\Las_LogDB\RunSpCust.ndf')
        , (FILENAME = N'F:\USER_DB\Las_LogDB\LoginAdmin.ndf')
        , (FILENAME = N'F:\USER_DB\Las_LogDB\TransferLog.ndf')
     FOR ATTACH;
END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = 'SummaryLasDB')
BEGIN
 CREATE DATABASE [SummaryLasDB] ON 
      (FILENAME = N'F:\USER_DB\SummaryLasDB\SummaryLasDB.mdf')
        , (FILENAME = N'F:\USER_DB\SummaryLasDB\SummaryLasDB_log.ldf')
        , (FILENAME = N'F:\USER_DB\SummaryLasDB\Sum_WinLoss_Agent_Table_01.ndf')
        , (FILENAME = N'F:\USER_DB\SummaryLasDB\Sum_WinLoss_Cust_Table_01.ndf')
        , (FILENAME = N'F:\USER_DB\SummaryLasDB\rptLASWinlost_Agent_Index.ndf')
        , (FILENAME = N'F:\USER_DB\SummaryLasDB\rptLASWinlost_Agent_Table.ndf')
        , (FILENAME = N'F:\USER_DB\SummaryLasDB\rptLASWinlost_bk_Agent_Index.ndf')
        , (FILENAME = N'F:\USER_DB\SummaryLasDB\rptLASWinlost_bk_Agent_Table.ndf')
        , (FILENAME = N'F:\USER_DB\SummaryLasDB\rptLASWinlost_bk_Index.ndf')
        , (FILENAME = N'F:\USER_DB\SummaryLasDB\rptLASWinlost_bk_Table.ndf')
        , (FILENAME = N'F:\USER_DB\SummaryLasDB\rptLASWinlost_Index.ndf')
        , (FILENAME = N'F:\USER_DB\SummaryLasDB\rptLASWinlost_Table.ndf')
     FOR ATTACH;
END
GO
