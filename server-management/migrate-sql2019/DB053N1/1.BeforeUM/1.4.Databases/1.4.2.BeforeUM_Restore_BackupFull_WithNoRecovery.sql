/***
	- Created@20211124: Bobby
	- Host: Run on DB053N1
	- Task: Restore the backup full of bodb02
***/
use master;
go
RESTORE DATABASE bodb02  
   FROM DISK = N'G:\MSSQL\Backup\bodb02_full_init_202112208.bak'  
   WITH MOVE 'bodb02_LogG' TO 'G:\user_db\bodb02\bodb02_LogG.ldf',
   FILE = 1, NORECOVERY, REPLACE,  STATS = 5;  
GO  