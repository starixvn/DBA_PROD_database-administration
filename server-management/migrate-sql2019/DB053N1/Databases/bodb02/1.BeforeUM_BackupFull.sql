/***
	- Created@20211124: Bobby
	- Host: Run on DB053
	- Task: DO the backup full of bodb02
***/

use master;
go
-- Create a full database backup first.  
BACKUP DATABASE bodb02   
   TO DISK = N'G:\MSSQL\Backup\bodb02_full_init.bak'  
   WITH INIT;  
GO  