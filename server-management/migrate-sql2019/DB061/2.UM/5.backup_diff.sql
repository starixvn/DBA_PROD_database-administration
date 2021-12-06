CREATE TABLE #databaseBackupList(RowId INT IDENTITY(1,1), databaseName VARCHAR(200))
INSERT INTO #databaseBackupList(databaseName)
values ('bodb02'),('LasDB_Archive'),('bodb_ACC'),('bodb_Licensee'),('bodb_OWP'),('bodb_TGRS'),('MonDB'),('LogDB'),('LogPDB')

DECLARE @RowId INT, @serverName VARCHAR(128), @databaseName VARCHAR(128)
	, @date VARCHAR(50), @fileName VARCHAR(255), @time VARCHAR(10)
	, @BackupPath varchar(50) = 'G:\UMBackup'
SELECT @RowId = 1, @serverName = @@SERVERNAME
	, @date = CONVERT(VARCHAR(10), GETDATE(), 112)
	, @time = REPLACE(CONVERT(VARCHAR(5), GETDATE(), 108), ':', '')
WHILE EXISTS (SELECT TOP 1 1 FROM #databaseBackupList WHERE RowId = @RowId)
BEGIN

	SELECT @databaseName = databaseName
	FROM #databaseBackupList WHERE RowId = @RowId

	SET @RowId = @RowId + 1
	
	SET @fileName = @BackupPath + '\' + @serverName + '.' + @databaseName + '_' + @date + '_' + @time + '.dif' 
	BACKUP DATABASE @databaseName TO DISK = @fileName WITH DIFFERENTIAL, FORMAT, INIT, COMPRESSION


END

DROP TABLE #databaseBackupList
