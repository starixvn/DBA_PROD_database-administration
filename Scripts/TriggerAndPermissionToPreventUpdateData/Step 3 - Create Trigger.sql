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

DROP TABLE IF EXISTS #t

INSERT INTO @Database (DatabaseId, DatabaseName)
SELECT database_id, '[' + name + ']'
FROM sys.databases 
WHERE state_desc = 'ONLINE' AND is_read_only = 0 AND database_id >= 5 AND Name NOT IN ('distribution', 'MonDB')

DECLARE @MaxId INT, @Id INT = 1, @DBName VARCHAR(200) = '' 

SELECT @MaxId = MAX(Id) FROM @Database

DECLARE @sql NVARCHAR(MAX)

CREATE TABLE #t (Id INT IDENTITY(1, 1), DatabaseName VARCHAR(200), TableName NVARCHAR(200), SchemaName VARCHAR(200))

WHILE @Id <= @MaxId
BEGIN
	SELECT @DBName = DatabaseName FROM @Database where id = @Id

	SELECT @sql = 
				  'SELECT ''' + @DBName+ ''' AS DatabaseName, t.name AS TableName, s.name  AS SchemaName
				  FROM '+ @DBName+'.sys.tables t	
					left join '+@DBName+'.sys.schemas s on s.schema_id = t.schema_id'

	INSERT INTO #t (DatabaseName, TableName, SchemaName)
	EXEC (@sql)

	SET @Id += 1

END

SELECT @Id = 1, @MaxId = MAX(Id) FROM #t

DECLARE @SQL_Trigger NVARCHAR(MAX) = '', @SQL_Result NVARCHAR(MAX)  = ''

SELECT @DBName = '', @SQL_Trigger= '', @SQL = ''

;WITH CTE AS (
SELECT DatabaseName AS  DatabaseName,   
N'CREATE OR ALTER TRIGGER ['+SchemaName+'].[trg_' + TableName+'_RestrictDML_ReadOnlyTest_xpre]
ON ['+SchemaName+'].['+TableName+']
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;
   
	IF SUSER_SNAME() IN 
	(
		''''asv_cust''''
		,''''asv_hit''''
		,''''dwrs''''
		,''''fin''''
		,''''fpsTask''''
		,''''ncb_admin''''
		,''''ncb_bot''''
		,''''ssv_fps''''
		,''''wsv_aff''''
		,''''wsv_affv''''
		,''''wsv_afinet''''
		,''''wsv_afinetv''''
		,''''wsv_ai''''
		,''''wsv_alp''''
		,''''wsv_alpv''''
		,''''wsv_crm''''
		,''''wsv_cts''''
		,''''wsv_fps''''
		,''''wsv_hermes''''
		,''''wsv_lap''''
		,''''wsv_nap''''
		,''''wsv_owp''''
		,''''wsv_pol''''
		,''''wsv_pts''''
		,''''wsv_rms''''
		,''''wsv_tgrs''''
		,''''wsv_xnap''''
		,''''sqllink''''
	) 
	   OR ORIGINAL_LOGIN() IN 
	   (
			''''asv_cust''''
			,''''asv_hit''''
			,''''dwrs''''
			,''''fin''''
			,''''fpsTask''''
			,''''ncb_admin''''
			,''''ncb_bot''''
			,''''ssv_fps''''
			,''''wsv_aff''''
			,''''wsv_affv''''
			,''''wsv_afinet''''
			,''''wsv_afinetv''''
			,''''wsv_ai''''
			,''''wsv_alp''''
			,''''wsv_alpv''''
			,''''wsv_crm''''
			,''''wsv_cts''''
			,''''wsv_fps''''
			,''''wsv_hermes''''
			,''''wsv_lap''''
			,''''wsv_nap''''
			,''''wsv_owp''''
			,''''wsv_pol''''
			,''''wsv_pts''''
			,''''wsv_rms''''
			,''''wsv_tgrs''''
			,''''wsv_xnap''''
			,''''sqllink''''
	   )
	BEGIN
		RAISERROR (''''You are not allowed to perform INSERT, UPDATE, or DELETE.'''', 16, 1);
		ROLLBACK;
		RETURN;
	END
END''' AS SQL_Trigger
FROM #t
), CTE2 AS (
SELECT N'EXEC ' + DatabaseName + N'.sys.sp_executesql' +  ' N''' + SQL_Trigger AS SQL_Text
FROM CTE
)
SELECT @SQL_Result = STRING_AGG(CONVERT(NVARCHAR(MAX), SQL_Text + CHAR(10) + CHAR(13)), '')
FROM CTE2


SELECT @SQL_Result FOR XML PATH('')