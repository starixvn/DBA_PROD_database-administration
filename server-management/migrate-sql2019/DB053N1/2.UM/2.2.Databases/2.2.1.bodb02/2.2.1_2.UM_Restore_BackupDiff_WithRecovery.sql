/***
	- Created@20211124: Bobby
	- Host: Run on DB053N1
	- Task: Do restoring backup diff of bodb02
***/
use master;
go
-- Now restore the differential database backup, the second backup on   
RESTORE DATABASE bodb02
   FROM DISK = N'G:\MSSQL\Backup\bodb02_diff_20211208.bak' 
   WITH MOVE 'bodb02_LogG' TO 'G:\user_db\bodb02\bodb02_LogG.ldf',
   FILE = 1, RECOVERY,  STATS = 5;  
GO  