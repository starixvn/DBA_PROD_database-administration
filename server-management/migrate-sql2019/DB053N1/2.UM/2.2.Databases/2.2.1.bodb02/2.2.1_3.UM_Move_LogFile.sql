/***
	- Created@20211124: Bobby
	- Host: Run on DB053N1
	- Task: Do restoring backup diff of bodb02
***/
use master;
GO
ALTER DATABASE bodb02 SET OFFLINE;  
GO

ALTER DATABASE bodb02   
MODIFY FILE ( NAME = bodb02_LogG, FILENAME = 'I:\user_db\bodb02\bodb02_LogG.ldf');  
GO

-- move file G:\user_db\bodb02\bodb02_LogG.ldf to I:\user_db\bodb02\bodb02_LogG.ldf
GO

ALTER DATABASE bodb02 SET ONLINE;  
GO