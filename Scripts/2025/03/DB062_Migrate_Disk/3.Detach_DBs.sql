/*
	Task: Detach indicated databases
		bodb_archive
		bodb_Report
		SAS_adhocReport_UAT
		MONDB
		DEL_LasDB_Archive
		bodb_TGRS
		bodb_TGRS_UAT
		
	Created on 20250303 by Daniel
	Run on DB062
*/

--bodb_archive
USE [master]
GO
ALTER DATABASE [bodb_archive] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'bodb_archive'
GO

--bodb_Report
USE [master]
GO
ALTER DATABASE [bodb_Report] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'bodb_Report'
GO

--SAS_adhocReport_UAT
USE [master]
GO
ALTER DATABASE [SAS_adhocReport_UAT] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'SAS_adhocReport_UAT'
GO

--MONDB
USE [master]
GO
ALTER DATABASE [MONDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'MONDB'
GO

--DEL_LasDB_Archive
USE [master]
GO
ALTER DATABASE [DEL_LasDB_Archive] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'DEL_LasDB_Archive'
GO

--bodb_TGRS
USE [master]
GO
ALTER DATABASE [bodb_TGRS] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'bodb_TGRS'
GO

--bodb_TGRS_UAT
USE [master]
GO
ALTER DATABASE [bodb_TGRS_UAT] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'bodb_TGRS_UAT'
GO