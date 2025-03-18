declare @bk_dir nvarchar(max) =N'\\db053\G$\BACKUP\DB053.bodb_Ploutos_20250317.bak'
declare @restore_DB nvarchar(100) = N'bodb_Ploutos'
-- Create a temporary table to hold the results of RESTORE FILELISTONLY with 22 columns
IF OBJECT_ID('tempdb..##FileList') IS NOT NULL DROP TABLE #FileList
CREATE TABLE    #FileList (
                                LogicalName                             NVARCHAR(1000)
                        ,       PhysicalName                    NVARCHAR(1000)
                        ,       Type                                    VARCHAR(10)
                        ,       FileGroupName                   VARCHAR(1000)
                        ,       Size                                    VARCHAR(100)
                        ,       MaxSize                                 VARCHAR(100)
                        ,       FileId                                  VARCHAR(10)
                        ,       CreateLSN                               VARCHAR(1000)
                        ,       DropLSN                                 VARCHAR(1000)
                        ,       UniqueId                                VARCHAR(1000)
                        ,       ReadOnlyLSN                             VARCHAR(100)
                        ,       ReadWriteLSN                    VARCHAR(100)
                        ,       BackupSizeInBytes               VARCHAR(100)
                        ,       SourceBlockSize                 VARCHAR(100)
                        ,       FileGroupId                             VARCHAR(100)
                        ,       LogGroupGUID                    VARCHAR(100)
                        ,       DifferentialBaseLSN             VARCHAR(1000)
                        ,       DifferentialBaseGUID    VARCHAR(1000)
                        ,       IsReadOnly                              VARCHAR(100)
                        ,       IsPresent                               VARCHAR(10)
                        ,       TDEThumbprint                   VARCHAR(10)
                        ,   SnapshotUrl                         VARCHAR(1000)
                        );


-- Insert the results of RESTORE FILELISTONLY into the temporary table using dynamic SQL
DECLARE @FileListSQL NVARCHAR(MAX);
SET @FileListSQL = 'RESTORE FILELISTONLY FROM DISK = '''+@bk_dir+''';';

-- Execute the RESTORE FILELISTONLY and insert results into the temporary table
INSERT INTO #FileList 
(
                                LogicalName             
                        ,       PhysicalName            
                        ,       Type                    
                        ,       FileGroupName           
                        ,       Size                    
                        ,       MaxSize                 
                        ,       FileId                  
                        ,       CreateLSN               
                        ,       DropLSN                 
                        ,       UniqueId                
                        ,       ReadOnlyLSN             
                        ,       ReadWriteLSN            
                        ,       BackupSizeInBytes       
                        ,       SourceBlockSize         
                        ,       FileGroupId             
                        ,       LogGroupGUID            
                        ,       DifferentialBaseLSN     
                        ,       DifferentialBaseGUID    
                        ,       IsReadOnly              
                        ,       IsPresent               
                        ,       TDEThumbprint           
                        ,   SnapshotUrl                 
                        )

EXEC sp_executesql @FileListSQL;

-- Now, loop through the results and build the MOVE clauses
DECLARE @LogicalName NVARCHAR(128), @PhysicalName NVARCHAR(260);

DECLARE @RestoreCommand NVARCHAR(MAX) = 'RESTORE DATABASE '+@restore_DB+' FROM DISK = '''+@bk_dir+''' 
WITH FILE = 1,norecovery,replace';
-- Concatenate the MOVE clauses for each file
select 'if (select 1 from sys.databases where name like '''+@restore_DB+''' and state_desc =''RESTORING'')=1'
union all
select @RestoreCommand
union all
select 
', MOVE ''' + LogicalName + ''' TO ''' + replace(replace(PhysicalName,'I:','J:'),'F:','K:') + ''''
FROM #FileList
union all
select 
',NOUNLOAD, STATS = 10;'
-- Clean up
DROP TABLE #FileList;

