--DB052/DB053 migrate storage 

-- bodb_LicenseeReport
BACKUP DATABASE [bodb_LicenseeReport] TO  
DISK = N'J:\Brice_tmp\bodb_LicenseeReport_20250304_1.bak', 
DISK = N'J:\Brice_tmp\bodb_LicenseeReport_20250304_2.bak', 
DISK = N'J:\Brice_tmp\bodb_LicenseeReport_20250304_3.bak', 
DISK = N'J:\Brice_tmp\bodb_LicenseeReport_20250304_4.bak', 
DISK = N'J:\Brice_tmp\bodb_LicenseeReport_20250304_5.bak', 
DISK = N'K:\Brice_tmp\bodb_LicenseeReport_20250304_6.bak', 
DISK = N'K:\Brice_tmp\bodb_LicenseeReport_20250304_7.bak', 
DISK = N'K:\Brice_tmp\bodb_LicenseeReport_20250304_8.bak', 
DISK = N'G:\Brice_tmp\bodb_LicenseeReport_20250304_9.bak', 
DISK = N'G:\Brice_tmp\bodb_LicenseeReport_20250304_10.bak'
WITH NOFORMAT, NOINIT, SKIP, NOREWIND, NOUNLOAD,compression,
STATS = 2, BUFFERCOUNT = 10, MAXTRANSFERSIZE = 1048576;
GO

-- bodb_LicenseeReportArchive
BACKUP DATABASE [bodb_LicenseeReportArchive] TO  
DISK = N'F:\Brice_tmp\bodb_LicenseeReportArchive_20250318.bak'
WITH NOFORMAT, NOINIT, SKIP, NOREWIND, NOUNLOAD,compression,  STATS = 2, BUFFERCOUNT = 10, MAXTRANSFERSIZE = 1048576;
GO

--bodb_N88_Archive
BACKUP DATABASE [bodb_N88_Archive] TO  
DISK = N'F:\Brice_tmp\bodb_N88_Archive_20250318.bak'
WITH NOFORMAT, NOINIT, SKIP, NOREWIND, NOUNLOAD,compression,  STATS = 2, BUFFERCOUNT = 10, MAXTRANSFERSIZE = 1048576;
GO

--MonDB
BACKUP DATABASE [MonDB] TO  
DISK = N'F:\Brice_tmp\MonDB_20250318.bak'
WITH NOFORMAT, NOINIT, SKIP, NOREWIND, NOUNLOAD,compression,  STATS = 2, BUFFERCOUNT = 10, MAXTRANSFERSIZE = 1048576;
GO

--SAS_adhocReport
BACKUP DATABASE [SAS_adhocReport] TO  
DISK = N'F:\Brice_tmp\SAS_adhocReport_20250318.bak'
WITH NOFORMAT, NOINIT, SKIP, NOREWIND, NOUNLOAD,compression,  STATS = 2, BUFFERCOUNT = 10, MAXTRANSFERSIZE = 1048576;
GO