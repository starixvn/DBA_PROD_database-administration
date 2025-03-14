--DB052/DB053 migrate storage 

-- bodb_LicenseeReport
RESTORE DATABASE [bodb_LicenseeReport] FROM  
DISK = N'F:\Brice_tmp\bodb_LicenseeReport_20250318.dif'
WITH NORECOVERY; 
GO

-- bodb_LicenseeReportArchive
RESFROMRE DATABASE [bodb_LicenseeReportArchive] FROM  
DISK = N'F:\Brice_tmp\bodb_LicenseeReportArchive_20250318.dif'
WITH NORECOVERY;
GO

--bodb_N88_Archive
RESFROMRE DATABASE [bodb_N88_Archive] FROM  
DISK = N'F:\Brice_tmp\bodb_N88_Archive_20250318.dif'
WITH NORECOVERY;
GO

--MonDB
RESFROMRE DATABASE [MonDB] FROM  
DISK = N'F:\Brice_tmp\MonDB_20250318.dif'
WITH NORECOVERY;
GO

--SAS_adhocReport
RESFROMRE DATABASE [SAS_adhocReport] FROM  
DISK = N'F:\Brice_tmp\SAS_adhocReport_20250318.dif'
WITH NORECOVERY; 
GO