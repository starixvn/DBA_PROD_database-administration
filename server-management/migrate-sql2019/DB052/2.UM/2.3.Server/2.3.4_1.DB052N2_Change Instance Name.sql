/***
	- Created@2021224: Bobby
	- Host: Run on DB052N2
	- Task: GET db properties
***/
EXEC sp_helpserver 'DB052N2'
SELECT @@servername

-- 2.EXECute the below query to change the instance name
EXEC sp_dropserver 'DB052N2' 
GO 
EXEC sp_addserver 'DB052' , 'local'
GO

