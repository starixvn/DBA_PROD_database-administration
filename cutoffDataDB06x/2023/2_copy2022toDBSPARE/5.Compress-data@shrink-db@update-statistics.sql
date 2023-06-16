 
select distinct 'alter table ' + t.name + ' rebuild partition = all with (data_compression = page)' cmd_compression_table
from sys.partitions p
inner join sys.tables t
on p.object_id = t.object_id
where p.data_compression = 0
order by 1

select distinct 'alter index ' + i.name + ' on '+t.name+' rebuild partition = all with (data_compression = page)' cmd_compression_table
from sys.partitions p
inner join sys.indexes i on p.object_id = i.object_id
inner join sys.tables t on i.object_id = t.object_id
where p.data_compression = 0
order by 1

-- shrink db
use master
go

DBCC SHRINKDATABASE ('bodb_Archive20', 1)
GO

-- update stats
USE bodb_Archive20
GO

EXEC sp_updatestats
GO

select 'DROP USER [' + name + '];' as cmd,  * 
from sys.sysusers where uid < 1000 and uid > 4
	and name not like 'vnteam'
	and name not like 'vndba'

-- generate attach script
USE bodb_Archive20
GO

declare @cmd nvarchar(max)
SET @cmd = 'CREATE DATABASE [bodb_Archive20] ON ' + char(13)

select @cmd = @cmd + '( FILENAME = N''' + physical_name +'''),' + char(13)
from sys.database_files

set @cmd = LEFT(@cmd, LEN(@cmd) - 2) + char(13) + 'FOR ATTACH'
select @cmd