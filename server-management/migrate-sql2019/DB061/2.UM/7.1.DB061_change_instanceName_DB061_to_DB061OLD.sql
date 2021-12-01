-- DB061(Single) ( -> DB061OLD)
-- 1.First collect the output of the current instance configuration
EXEC sp_helpserver 'DB061'
SELECT @@servername

-- 2.EXECute the below query to change the instance name
EXEC sp_dropserver 'DB061' 
GO 
EXEC sp_addserver 'DB061OLD' , 'local'
GO

