/*
	Creator:	20250529@Malcolm
	Task:		Create triggers and permission to prevent updating data [Redmine: #128261]
	Server:		DBCUST/DBTRANS
*/

USE	master;
GO

SET NOCOUNT ON

DROP TABLE IF EXISTS #t

DECLARE @Database TABLE (Id INT IDENTITY(1, 1), DatabaseId INT, DatabaseName VARCHAR(200))

INSERT INTO @Database (DatabaseId, DatabaseName)
SELECT database_id, '[' + name + ']'
FROM sys.databases 
WHERE state_desc = 'ONLINE' AND is_read_only = 0 AND database_id >= 5 AND Name NOT IN ('distribution', 'MonDB')

CREATE TABLE #t (Id INT, DBName VARCHAR(200), ObjectName NVARCHAR(200))


DECLARE @MaxId INT, @Id INT = 1, @DBName VARCHAR(200) = '' 

SELECT @MaxId = MAX(Id) FROM @Database

DECLARE @sql NVARCHAR(MAX)

WHILE @Id <= @MaxId
BEGIN
	SELECT @DBName = DatabaseName FROM @Database where id = @Id

	SELECT @sql = 
				  'SELECT ''' + @DBName+ ''' AS DatabaseName, name AS TableName
				  FROM '+ @DBName+'.sys.procedures
				  where is_published = 1'

	PRINT(@sql)

	INSERT INTO #t (DBName, ObjectName)
	EXEC (@sql)

	SET @Id += 1

END



UPDATE x
	SET x.Id = x._NewId
FROM 
(	
	SELECT *, ROW_NUMBER() OVER(ORDER BY (SELECT 1))AS _NewId
	FROM #t
) x


SELECT @Id = 1

DECLARE @SQL_Result NVARCHAR(MAX) = ''

SELECT @MaxId = MAX(Id) FROM #t

PRINT ('=====================================================================')
WHILE @Id <= @MaxId
BEGIN
	
	SET @sql = ''

	SELECT @sql = 'USE ' + DBName + CHAR(13) + 'GO'  + CHAR(13) +'ALTER AUTHORIZATION ON OBJECT::dbo.' + ObjectName + ' TO dbo' + CHAR(13) + 'GO' + CHAR(13)
	FROM #t
	WHERE Id = @Id

	SELECT @SQL_Result = @SQL_Result + @sql
	SET @Id += 1

END

SELECT @SQL_Result FOR XML PATH('')

DROP TABLE #t

