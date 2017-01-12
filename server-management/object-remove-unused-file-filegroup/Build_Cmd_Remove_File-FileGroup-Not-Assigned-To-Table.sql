
declare @FileNameList table (RowId int identity(1,1), FileName VARCHAR(125), PathFile VARCHAR(255)
	, FileGroupName VARCHAR(125), CanRemove bit default(1))

insert into @FileNameList(FileName, PathFile, FileGroupName)
select f.name, f.filename, fg.groupname
from sys.sysfiles f
inner join sys.sysfilegroups fg on f.groupid = fg.groupid

declare @RowId int, @FileName varchar(125)
set @RowId = 1
while exists (select top 1 1 from @FileNameList where RowId = @RowId)
begin
	select @FileName = FileName
	from @FileNameList where RowId = @RowId

	set @RowId = @RowId + 1
	
	if exists (select top 1 1
				from sys.tables tt
					inner join sys.indexes ii ON tt.OBJECT_ID = ii.OBJECT_ID
					inner join sys.partitions pp ON ii.OBJECT_ID = pp.OBJECT_ID AND ii.index_id = pp.index_id
					inner join sys.allocation_units aa ON pp.PARTITION_ID = aa.container_id
					inner join sys.database_files dbf1 ON aa.data_space_id = dbf1.data_space_id
					inner join sys.filegroups fg1 ON aa.data_space_id = fg1.data_space_id
				where dbf1.name = @FileName)
	begin
		update @FileNameList
		set CanRemove = 0
		where FileName = @FileName
	end
end

--remove file
select case when t.CanRemove = 0 then '--' else '' end + 'ALTER DATABASE ' + DB_NAME() + ' REMOVE FILE ' + t.filename as [cmd_remove_file]
from (
	select distinct CanRemove, FileName
	from @FileNameList --where CanRemove = 1
)t
order by t.FileName

--remove filegroup
select case when t.CanRemove = 0 then '--' else '' end + 'ALTER DATABASE ' + DB_NAME() + ' REMOVE FILEGROUP ' + t.FileGroupName as [cmd_remove_filegroup]
from (
	select FileGroupName, MIN(case when CanRemove = 1 then 1 else 0 end) as CanRemove
	from @FileNameList --where CanRemove = 1
	group by FileGroupName
)t
order by t.FileGroupName

--select data
select * from @FileNameList
go
