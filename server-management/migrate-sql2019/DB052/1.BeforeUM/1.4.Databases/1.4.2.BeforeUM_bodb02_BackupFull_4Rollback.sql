/***
	- Created@20211229: Bobby
	- Host: Run on DB052 - old One
	- Task: DO the backup full databases
***/

use master;
go
BACKUP DATABASE bodb02
TO DISK = N'G:\Backup\DB052.bodb02_full_init_20211229.bak'
WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10; 
GO