/*
	Task - Upgrade SQL Server DB06 to 2019
		+ backup full all DBs
	Run on DB06C2\DB06
*/

CREATE TABLE #databaseBackupList(RowId INT IDENTITY(1,1), databaseName VARCHAR(200))
INSERT INTO #databaseBackupList(databaseName)
values ('bodb02'),('bodb_Licensee'),('SAS_adhocReport'),('bodb_TGRS_UAT'),('MonDB'),('master'),('msdb')

DECLARE @RowId INT, @serverName VARCHAR(128), @databaseName VARCHAR(128)
	, @date VARCHAR(50), @fileName VARCHAR(255)
	, @BackupPath varchar(50) = 'G:\UMBackup'
SELECT @RowId = 1, @serverName = @@SERVERNAME
	, @date = CONVERT(VARCHAR(10), GETDATE(), 112)


WHILE EXISTS (SELECT TOP 1 1 FROM #databaseBackupList WHERE RowId = @RowId)
BEGIN

	SELECT @databaseName = databaseName
	FROM #databaseBackupList WHERE RowId = @RowId

	SET @RowId = @RowId + 1

	SET @fileName = @BackupPath + '\' + @serverName + '.' + @databaseName + '_' + @Date + '.bak' 
	BACKUP DATABASE @databaseName TO DISK = @fileName  WITH FORMAT, INIT, COMPRESSION

END

DROP TABLE #databaseBackupList


