-- SITDB05(Single) ( -> SITDB05OLD)
-- 1.First collect the output of the current instance configuration
EXEC sp_helpserver 'DB053'
SELECT @@servername

-- 2.EXECute the below query to change the instance name
EXEC sp_dropserver 'DB053' 
GO 
EXEC sp_addserver 'DB053OLD' , 'local'
GO

