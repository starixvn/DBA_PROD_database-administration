-- DB061N3(Single) ( -> DB061)
-- 1.First collect the output of the current instance configuration
EXEC sp_helpserver 'DB061N3'
SELECT @@servername

-- 2.EXECute the below query to change the instance name
EXEC sp_dropserver 'DB061N3' 
GO 
EXEC sp_addserver 'DB061' , 'local'
GO

