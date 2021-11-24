/***
	- Created@20211124: Bobby
	- Host: Run on DB053
	- Task: Do restoring backup diff of bodb02
***/
use master;
go
-- Now restore the differential database backup, the second backup on   
RESTORE DATABASE bodb02
   FROM DISK = N'G:\MSSQL\Backup\bodb02_diff.bak' 
   WITH FILE = 1,  
   RECOVERY;  
GO  