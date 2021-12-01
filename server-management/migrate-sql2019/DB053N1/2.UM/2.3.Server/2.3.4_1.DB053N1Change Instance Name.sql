-- SITDB05NEW(Single) ( -> SITDB05)
-- 1.First collect the output of the current instance configuration
EXEC sp_helpserver 'DB053N1'
SELECT @@servername

-- 2.EXECute the below query to change the instance name
EXEC sp_dropserver 'DB053N1' 
GO 
EXEC sp_addserver 'DB053' , 'local'
GO

