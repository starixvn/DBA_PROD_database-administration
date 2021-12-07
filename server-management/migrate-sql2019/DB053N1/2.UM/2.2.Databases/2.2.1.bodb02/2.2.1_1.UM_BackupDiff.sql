/***
	- Created@20211124: Bobby
	- Host: Run on DB053
	- Task: Do the backup diff of bodb02
***/

use master;
go
-- Time elapses.  
-- Create a differential database backup, appending the backup  
-- to the backup device containing the full database backup.  
BACKUP DATABASE bodb02  
   TO DISK = N'G:\MSSQL\Backup\bodb02_diff_20211208.bak'  
   WITH DIFFERENTIAL, SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10;  
GO