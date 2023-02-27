use bodb_Summary
go

declare @__dateFrom datetime
	, @__dateTo datetime
	, @__tableName varchar(128) = ''
	, @__filegroup_pattern varchar(512) = ''
	, @__filegroupName varchar(200) = ''
	, @__pathFile varchar(512) = ''
	, @__data_space_id int = 0
	, @__partitionSchemaName varchar(200) = ''
	, @__partitionFunctionName varchar(200) = ''

select @__dateFrom = '2023-01-31'
	, @__dateTo = '2025-12-31'
	, @__tableName = 'sum_winloss_old'
	, @__data_space_id = 159

select top 1 @__partitionSchemaName = ps.name, @__partitionFunctionName = pf.name
from sys.objects obj
	inner join sys.partitions p on obj.object_id = p.object_id
	inner join sys.indexes i on p.object_id = i.object_id and p.index_id = i.index_id 
	inner join sys.data_spaces ds on i.data_space_id = ds.data_space_id 
	inner join sys.partition_schemes ps on ds.data_space_id = ps.data_space_id 
	inner join sys.partition_functions pf on ps.function_id = pf.function_id 
	inner join sys.destination_data_spaces dds on dds.partition_scheme_id = ds.data_space_id and p.partition_number = dds.destination_id 
	left outer join sys.partition_range_values prv on prv.function_id = ps.function_id and p.partition_number = prv.boundary_id 
	inner join sys.data_spaces ds2 on ds2.data_space_id = dds.data_space_id 
where obj.object_id = object_id(@__tableName)

select @__filegroup_pattern = replace(name, right(name, 5), '') 
	, @__pathFile = replace(physical_name, '\' + reverse(substring(reverse(physical_name), 0, charindex('\', reverse(physical_name)))), '')
from sys.database_files where data_space_id = @__data_space_id

print '-------------------------'
print '--table: ' + @__tableName
print '--start: ' + convert(varchar(10), @__dateFrom, 121)
print '--end: ' + convert(varchar(10), @__dateTo, 121)
print '--ps: ' + @__partitionSchemaName
print '--pf: ' + @__partitionFunctionName
print '--file group: ' + @__filegroup_pattern
print '--path file: ' + @__pathFile
print '-------------------------'

while @__dateFrom < @__dateTo
begin
	select @__filegroupName = @__filegroup_pattern + right(year(@__dateFrom), 2) + 'M' + FORMAT(month(@__dateFrom), '00')
	print 'ALTER DATABASE ' + db_name() + ' ADD FILEGROUP ' + @__filegroupName + ';'
	print 'ALTER DATABASE ' + db_name() + ' ADD FILE (NAME = N'''+@__filegroupName+''', FILENAME = N'''+@__pathFile + '\' + @__filegroupName + '.ndf' + ''', SIZE = 512KB, MAXSIZE = UNLIMITED, FILEGROWTH = 32768KB) TO FILEGROUP ' + @__filegroupName;
	print 'ALTER PARTITION SCHEME ' + @__partitionSchemaName + ' NEXT USED ' + @__filegroupName + ';'
	print 'ALTER PARTITION FUNCTION ' + @__partitionFunctionName + '() SPLIT RANGE (N''' + convert(varchar(10), eomonth(@__dateFrom), 121) + ' 23:59:59.997' + ''');'
	print 'RAISERROR(''Added ' + @__filegroupName + ''', 0, 0) WITH NOWAIT;'
	print ''
	set @__dateFrom = dateadd(MONTH, 1, @__dateFrom)

end