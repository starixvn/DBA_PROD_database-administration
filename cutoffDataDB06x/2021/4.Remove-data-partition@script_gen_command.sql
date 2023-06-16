
declare @__dateFrom datetime
	, @__dateTo datetime
	, @__tableName varchar(128)
	, @__destinationTableName varchar(128)
	, @__cmd_clone_table varchar(max) = ''
	, @__cmd_switch_partition varchar(max) = ''
	, @__cmd_merge_partition varchar(max) = ''
	, @__cmd_remove_file varchar(max) = ''
	, @__cmd_remove_filegroup varchar(max) = ''
	, @__partition_schema_name varchar(200) = ''
select @__dateFrom = '2019-01-01', @__dateTo = '2020-01-01'
	, @__tableName = 'bettrans_bk'
			--, @__tableName = 'bettransm'
			--, @__tableName = 'bettransG'
			--, @__tableName = 'bettransLC_bk'
			--, @__tableName = 'bettransRNG_bk'
			--, @__tableName = 'transfer_bk'
			--, @__tableName = 'Dot_Admin_LiveLog'
	, @__destinationTableName = 'bettrans_bk_v2'

select @__cmd_switch_partition = @__cmd_switch_partition + char(13) + 'alter table ' + @__tableName + ' switch partition ' + cast(p.partition_number as varchar) + ' to ' + @__destinationTableName + ' partition ' + cast(p.partition_number as varchar)
	, @__cmd_merge_partition = @__cmd_merge_partition + char(13) + 'alter partition function ' + pf.name + '() merge range (N''' + convert(varchar(50), value, 121) + ''')'
	, @__cmd_remove_file = @__cmd_remove_file + char(13) + 'alter database ['+ db_name() +'] remove file ['+ ds2.name +']'
	, @__cmd_remove_filegroup = @__cmd_remove_filegroup + char(13) + 'alter database ['+ db_name() +'] remove filegroup ['+ ds2.name +']'
	, @__partition_schema_name = ps.name
from sys.objects obj
	inner join sys.partitions p on obj.object_id = p.object_id
	inner join sys.indexes i on p.object_id = i.object_id and p.index_id = i.index_id 
	inner join sys.data_spaces ds on i.data_space_id = ds.data_space_id 
	inner join sys.partition_schemes ps on ds.data_space_id = ps.data_space_id 
	inner join sys.partition_functions pf on ps.function_id = pf.function_id 
	inner join sys.destination_data_spaces dds on dds.partition_scheme_id = ds.data_space_id and p.partition_number = dds.destination_id 
	left outer join sys.partition_range_values prv on prv.function_id = ps.function_id and p.partition_number = prv.boundary_id 
	inner join sys.data_spaces ds2 on ds2.data_space_id = dds.data_space_id 
where i.type_desc = 'CLUSTERED' and obj.object_id = object_id(@__tableName) 
	and cast(value as datetime) between @__dateFrom and @__dateTo
order by obj.name, p.partition_number

set @__cmd_clone_table = 'exec [dbo].[DBA_CloneTableStructure]
		@SourceSchema = ''dbo'',
		@SourceTable = ''' + @__tableName + ''',
		@DestinationSchema = ''dbo'',
		@DestinationTable = ''' + @__destinationTableName + ''',
		@RecreateIfExists = 1,
		@FileGroup = ''['+@__partition_schema_name+']([winlostdate])'''

declare @__drop_destination_table varchar(2000)
set @__drop_destination_table = 'drop table ' + @__destinationTableName

print @__cmd_clone_table
print char(13) print 'go'
print @__cmd_switch_partition
print char(13) print 'go'
print @__drop_destination_table
print char(13) print 'go'
print @__cmd_merge_partition
print char(13) print 'go'
print @__cmd_remove_file
print char(13) print 'go'
print @__cmd_remove_filegroup