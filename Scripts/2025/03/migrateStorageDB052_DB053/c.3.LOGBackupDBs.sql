--DB052/DB053 migrate storage 

-- bodb_LicenseeReport
BACKUP LOG  [bodb_LicenseeReport] TO  
DISK = N'F:\Brice_tmp\bodb_LicenseeReport_20250318.trn'
GO

-- bodb_LicenseeReportArchive
BACKUP LOG  [bodb_LicenseeReportArchive] TO  
DISK = N'F:\Brice_tmp\bodb_LicenseeReportArchive_20250318.trn'
GO

--bodb_N88_Archive
BACKUP LOG  [bodb_N88_Archive] TO  
DISK = N'F:\Brice_tmp\bodb_N88_Archive_20250318.trn'
GO

--MonDB
BACKUP LOG  [MonDB] TO  
DISK = N'F:\Brice_tmp\MonDB_20250318.trn'
GO

--SAS_adhocReport
BACKUP LOG  [SAS_adhocReport] TO  
DISK = N'F:\Brice_tmp\SAS_adhocReport_20250318.trn'
GO