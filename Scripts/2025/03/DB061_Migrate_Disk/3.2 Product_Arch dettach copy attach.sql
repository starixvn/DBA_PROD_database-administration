/*
	Task: Detach-attach database MonDB
	
	Created on 20250311 by Daniel
	Run on DB061
*/


--1. Stop & Disable related jobs
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_Del_Over4YearData'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Del_Over4YearData', @enabled = 0;
EXEC msdb.dbo.sp_stop_job @job_name = 'DBA_Full_Backup_Weekly'; EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Full_Backup_Weekly', @enabled = 0;


--2. Detach db
USE [master]
GO
ALTER DATABASE [Product_Archive] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'Product_Archive'
GO


--3. Copy file (cmd)
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive Product_Archive_log.ldf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2025Q1.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2025Q2.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2025Q3.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2025Q4.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2026Q1.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2026Q2.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2026Q3.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2026Q4.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2027Q1.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2027Q2.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2027Q3.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2027Q4.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2028Q1.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2028Q2.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2028Q3.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2028Q4.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2029Q1.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2029Q2.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2029Q3.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2029Q4.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2030Q1.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2030Q2.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2030Q3.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2030Q4.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2031Q1.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2031Q2.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2031Q3.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2031Q4.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2032Q1.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2032Q2.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2032Q3.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2032Q4.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2033Q1.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2033Q2.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2033Q3.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2033Q4.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2034Q1.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2034Q2.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2034Q3.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2034Q4.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2035Q1.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2035Q2.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2035Q3.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2035Q4.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2036Q1.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2036Q2.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2036Q3.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2036Q4.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2037Q1.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2037Q2.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2037Q3.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2037Q4.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2038Q1.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2038Q2.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2038Q3.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2038Q4.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_2039Q1.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_Index.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LiveLog_MAX.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LuckyDraw_Data_02.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LuckyDraw_Data_03.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LuckyDraw_Data_04.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LuckyDraw_Data01.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive LuckyDraw_Index.ndf /COPYALL /MT:16
robocopy F:\USER_DB\Product_Archive L:\USER_DB\Product_Archive Product_Archive.mdf /COPYALL /MT:16


--4. Attach db
USE [master]
GO
CREATE DATABASE [Product_Archive] ON
 (FILENAME = 'L:\USER_DB\Product_Archive\Product_Archive_log.ldf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2025Q1.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2025Q2.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2025Q3.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2025Q4.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2026Q1.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2026Q2.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2026Q3.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2026Q4.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2027Q1.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2027Q2.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2027Q3.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2027Q4.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2028Q1.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2028Q2.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2028Q3.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2028Q4.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2029Q1.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2029Q2.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2029Q3.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2029Q4.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2030Q1.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2030Q2.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2030Q3.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2030Q4.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2031Q1.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2031Q2.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2031Q3.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2031Q4.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2032Q1.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2032Q2.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2032Q3.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2032Q4.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2033Q1.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2033Q2.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2033Q3.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2033Q4.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2034Q1.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2034Q2.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2034Q3.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2034Q4.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2035Q1.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2035Q2.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2035Q3.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2035Q4.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2036Q1.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2036Q2.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2036Q3.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2036Q4.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2037Q1.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2037Q2.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2037Q3.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2037Q4.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2038Q1.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2038Q2.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2038Q3.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2038Q4.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_2039Q1.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_Index.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LiveLog_MAX.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LuckyDraw_Data_02.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LuckyDraw_Data_03.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LuckyDraw_Data_04.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LuckyDraw_Data01.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\LuckyDraw_Index.ndf')
,(FILENAME = 'L:\USER_DB\Product_Archive\Product_Archive.mdf')
 FOR ATTACH
GO

--5. Enable back Job
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Del_Over4YearData', @enabled = 1;
EXEC msdb.dbo.sp_update_job @job_name = 'DBA_Full_Backup_Weekly', @enabled = 1;

