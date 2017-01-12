
DECLARE @TableNameListTable TABLE (tableName VARCHAR(125))
INSERT INTO @TableNameListTable(tableName)
--values ('_del_bettrans'), ('_del_match'), ('_del_outright'), ('_del_rpt_Betting'), ('_del_rpt_Betting_BA')
--	, ('_del_rptKPI_Account'), ('_del_rptKPI_Account_BA'), ('_del_rptKPI_MTD_3rdProducts'), ('_del_rptKPI_MTD_BA_Cross')
--	, ('_del_rptKPI_MTD_Cross'), ('_del_rptKPI_Transfer'), ('_del_rptLicIPBetting'), ('_del_rptLicWinloss_old')
--	, ('_del_rptLicWinloss2'), ('_del_tbl_Customer_Account'), ('_del_tblKPI_Budgets'), ('_del_tblKPI_Stats')

values ('bettrans'), ('match'), ('outright'), ('rpt_Betting'), ('rpt_Betting_BA')
	, ('rptKPI_Account'), ('rptKPI_Account_BA'), ('rptKPI_MTD_3rdProducts'), ('rptKPI_MTD_BA_Cross')
	, ('rptKPI_MTD_Cross'), ('rptKPI_Transfer'), ('rptLicIPBetting'), ('rptLicWinloss_old')
	, ('rptLicWinloss2'), ('tbl_Customer_Account'), ('tblKPI_Budgets'), ('tblKPI_Stats')

DECLARE @FileNameList TABLE(RowIndex INT IDENTITY(1,1), FileGroupName VARCHAR(255), FileName VARCHAR(255), PhysicalFileName VARCHAR(255)
	, TableNameList VARCHAR(4000), PartitionSchemaName VARCHAR(125), PartitionFunctionName VARCHAR(125), CanRemove BIT DEFAULT(1))

INSERT INTO @FileNameList(FileGroupName, FileName, PhysicalFileName, PartitionSchemaName, PartitionFunctionName, TableNameList)
SELECT DISTINCT fg.name AS GroupName
	, dbf.name AS FileName
	, dbf.physical_name
	, ps.name AS PartitionSchemaName
	, pf.name AS PartitionFunctionName
	, STUFF((
			SELECT ', ' + ISNULL(CAST(tt.name AS VARCHAR(255)), '')
			FROM sys.tables tt
				INNER JOIN sys.indexes ii ON tt.OBJECT_ID = ii.OBJECT_ID
				INNER JOIN sys.partitions pp ON ii.OBJECT_ID = pp.OBJECT_ID AND ii.index_id = pp.index_id
				INNER JOIN sys.allocation_units aa ON pp.PARTITION_ID = aa.container_id
				INNER JOIN sys.database_files dbf1 ON aa.data_space_id = dbf1.data_space_id
				INNER JOIN sys.filegroups fg1 ON aa.data_space_id = fg1.data_space_id
			WHERE dbf1.name = dbf.name
			FOR XML PATH (''))
			, 1, 2, '') AS TableList
FROM sys.tables t
	INNER JOIN sys.indexes i ON t.OBJECT_ID = i.OBJECT_ID
	INNER JOIN sys.partitions p ON i.OBJECT_ID = p.OBJECT_ID AND i.index_id = p.index_id
	INNER JOIN sys.allocation_units a ON p.PARTITION_ID = a.container_id
	INNER JOIN sys.database_files dbf ON a.data_space_id = dbf.data_space_id
	INNER JOIN sys.filegroups fg ON a.data_space_id = fg.data_space_id
	LEFT JOIN sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
	LEFT JOIN sys.partition_functions pf ON ps.function_id = pf.function_id
WHERE t.name NOT LIKE 'dt%'
	AND i.OBJECT_ID > 255
	--AND i.index_id <= 1 --get all indexes
	AND fg.name NOT IN ('PRIMARY')
	AND t.name IN (SELECT tableName FROM @TableNameListTable)

--update @ table for file/filegroup which is using by other table
DECLARE @RowIndex INT, @TableNameList VARCHAR(4000), @xml XML, @FileName VARCHAR(255)
DECLARE @tblNnameList TABLE (TableName VARCHAR(125))
SET @RowIndex = 1
WHILE EXISTS (SELECT TOP 1 1 FROM @FileNameList WHERE RowIndex = @RowIndex)
BEGIN
	--clear data
	DELETE FROM @tblNnameList
	SELECT @TableNameList = '', @FileName = ''

	SELECT @TableNameList = TableNameList, @FileName = FileName
	FROM @FileNameList WHERE RowIndex = @RowIndex

	SET @RowIndex = @RowIndex + 1

	SET @xml = CONVERT(XML, REPLACE('<root><r t="' + @TableNameList + '"/></root>', ',','"/><r t="'))

	INSERT INTO @tblNnameList (TableName)
	SELECT LTRIM(RTRIM(T.c.value('./@t','VARCHAR(125)')))
	FROM @xml.nodes('/root/r') AS T(c)
	OPTION ( OPTIMIZE FOR ( @xml = NULL ) )

	IF EXISTS (SELECT TOP 1 1 
				FROM @tblNnameList t 
					LEFT JOIN @TableNameListTable tt ON t.TableName = tt.tableName
				WHERE tt.tableName is null)
	BEGIN
		UPDATE @FileNameList
		SET CanRemove = 0
		WHERE FileName = @FileName
	END

END

--drop table
SELECT 'DROP TABLE ' + DB_NAME() + '.dbo.' + t.TableName AS [cmd_drop_table]
FROM @TableNameListTable t
ORDER BY t.TableName

--drop partition schema
SELECT 'DROP PARTITION SCHEME ' + t.PartitionSchemaName AS [cmd_drop_partition_schema]
FROM (
	SELECT DISTINCT PartitionSchemaName
	FROM @FileNameList
	WHERE PartitionSchemaName IS NOT NULL
)t
ORDER BY t.PartitionSchemaName

--drop partition function
SELECT 'DROP PARTITION FUNCTION ' + t.PartitionFunctionName AS [cmd_drop_partition_function]
FROM (
	SELECT DISTINCT PartitionFunctionName
	FROM @FileNameList
	WHERE PartitionFunctionName IS NOT NULL
)t
ORDER BY t.PartitionFunctionName

--remove file
SELECT CASE WHEN t.CanRemove = 0 THEN '--' ELSE '' END + 'ALTER DATABASE ' + DB_NAME() + ' REMOVE FILE ' + t.FileName AS [cmd_remove_file]
FROM (
	SELECT DISTINCT CanRemove, FileName
	FROM @FileNameList
)t
ORDER BY t.FileName

--remove filegroup
SELECT CASE WHEN t.CanRemove = 0 THEN '--' ELSE '' END + 'ALTER DATABASE ' + DB_NAME() + ' REMOVE FILEGROUP ' + t.FileGroupName AS [cmd_remove_filegroup]
FROM (
	SELECT FileGroupName, MIN(CASE WHEN CanRemove = 1 THEN 1 ELSE 0 END) AS CanRemove
	FROM @FileNameList --where CanRemove = 1
	GROUP BY FileGroupName
)t
ORDER BY t.FileGroupName

--select data
SELECT * FROM @FileNameList

GO

