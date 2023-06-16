RESTORE FILELISTONLY
FROM DISK = 'PATH\To\FullBackup.bak';
go
USE [master]
RESTORE DATABASE [bodb_Archive22] 
FILEGROUP='PRIMARY'
FROM  DISK = N'E:\bodb_archive_bk\bodb_archive_full_20230226.bak' WITH
MOVE N'' TO N'.mdf',  
MOVE N'' TO N'.ldf',  
PARTIAL,
NORECOVERY,
STATS = 5
 
GO

USE [master]
RESTORE DATABASE [bodb_Archive22] 
FILEGROUP=''
FROM  DISK = N'E:\bodb_archive_bk\bodb_archive_full_20230226.bak'   
WITH
MOVE N'' TO N'.ndf',   
...

MOVE N'TPLog_log' TO N'L:\SQL2017A\FGTest2_log.ldf',  
RECOVERY,  STATS = 5
 
GO