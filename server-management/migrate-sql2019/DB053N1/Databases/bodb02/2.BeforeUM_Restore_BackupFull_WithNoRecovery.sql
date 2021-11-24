/***
	- Created@20211124: Bobby
	- Host: Run on DB053
	- Task: Restore the backup full of bodb02
***/
use master;
go
RESTORE DATABASE bodb02  
   FROM DISK = N'D:\MSSQL\Backup\bodb02_full_init.bak'  
   WITH NORECOVERY;  
GO  