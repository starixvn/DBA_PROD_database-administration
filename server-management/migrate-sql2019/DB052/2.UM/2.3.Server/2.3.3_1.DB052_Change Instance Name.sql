/***
	- Created@2021224: Bobby
	- Host: Run on DB052 - old One
	- Task: GET db properties
***/
use master;
EXEC sp_helpserver 'DB052'
SELECT @@servername

-- 2.EXECute the below query to change the instance name
EXEC sp_dropserver 'DB052' 
GO 
EXEC sp_addserver 'DB052OLD' , 'local'
GO

