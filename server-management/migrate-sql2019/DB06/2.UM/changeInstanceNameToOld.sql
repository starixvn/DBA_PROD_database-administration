select @@SERVERNAME
/*
	Task - Upgrade SQL Server DB06 to 2019
		+ change InstanceName
	Run on DB06C2\DB06
*/

-- 1.First collect the output of the current instance configuration
EXEC sp_helpserver 'DB06C2\DB06'
SELECT @@servername

-- 2.EXECute the below query to change the instance name
EXEC sp_dropserver 'DB06C2\DB06' 
GO 
EXEC sp_addserver 'DB06C2\DB06OLD' , 'local'
GO

