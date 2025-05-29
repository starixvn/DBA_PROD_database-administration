/*
	Creator:	20250529@Malcolm
	Task:		Create triggers and permission to prevent updating data [Redmine: #128261]
	Server:		DBCUST/DBTRANS
*/

USE	master;
GO


SET NOCOUNT ON

DECLARE @Database TABLE (Id INT IDENTITY(1, 1), DatabaseId INT, DatabaseName VARCHAR(200))

DROP TABLE IF EXISTS #t

INSERT INTO @Database (DatabaseId, DatabaseName)
SELECT database_id, '[' + name + ']'
FROM sys.databases 
WHERE state_desc = 'ONLINE' AND is_read_only = 0 AND database_id >= 5 AND Name NOT IN ('distribution', 'MonDB')

DECLARE @sql NVARCHAR(MAX), @SQL_Result NVARCHAR(MAX) = ''


SELECT @SQL_Result = STRING_AGG(CONVERT(NVARCHAR(MAX), 'USE ' + DatabaseName + CHAR(13) + 'GO' + CHAR(13) + '
IF NOT EXISTS (
    SELECT 1 FROM sys.database_principals WHERE name = ''ReadOnlyUser''
)
CREATE USER [ReadOnlyUser] WITHOUT LOGIN' + CHAR(13) + 'GO' + CHAR(13) + CHAR(13)), '')
FROM @Database

SELECT @SQL_Result FOR XML PATH('')
