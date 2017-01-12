
--partition scheme
select 'DROP PARTITION SCHEME ' + ps.name as [cmd_drop_partition_scheme]
from sys.partition_schemes ps 
	inner join sys.partition_functions pf on ps.function_id = pf.function_id
	left join sys.indexes i on ps.data_space_id = i.data_space_id
where i.index_id is null

--partition function
select 'DROP PARTITION FUNCTION ' + pf.name as [cmd_drop_partition_function]
from sys.partition_schemes ps 
	inner join sys.partition_functions pf on ps.function_id = pf.function_id
	left join sys.indexes i on ps.data_space_id = i.data_space_id
where i.index_id is null