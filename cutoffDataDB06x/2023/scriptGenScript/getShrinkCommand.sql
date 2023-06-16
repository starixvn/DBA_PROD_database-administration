
SELECT DB_NAME() AS DbName, 
    df.name AS FileName, 
    df.type_desc,
    size/128.0 AS CurrentSizeMB,  
    size/128.0 - CAST(FILEPROPERTY(df.name, 'SpaceUsed') AS INT)/128.0 AS FreeSpaceMB,
	'DBCC SHRINKFILE (N''' + df.name + ''' , 0, TRUNCATEONLY)'
FROM sys.database_files df
WHERE df.type IN (0,1)
and size/128.0 - CAST(FILEPROPERTY(df.name, 'SpaceUsed') AS INT)/128.0 > 1024
