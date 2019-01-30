/*============================================================================
   Script to report Memory usage details of a SQL Server instance
   Author: Sakthivel Chidambaram, Microsoft http://blogs.msdn.com/b/sqlsakthi 

   Date: June 2012
   Version: V2
   
   V1: Initial Release
   V2: Added PLE, Memory grants pending, Checkpoint, Lazy write,Free list counters

   THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
   ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
   TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
   PARTICULAR PURPOSE. 

============================================================================*/ 
-- We don't need the row count
SET NOCOUNT ON

SELECT physical_memory_in_use_kb AS Actual_Usage,large_page_allocations_kb AS large_Pages,
locked_page_allocations_kb AS locked_Pages,virtual_address_space_committed_kb AS VAS_Committed,
large_page_allocations_kb + locked_page_allocations_kb + 427000
FROM sys.dm_os_process_memory

select(physical_memory_in_use_kb/1024)Memory_usedby_Sqlserver_MB,(locked_page_allocations_kb/1024 )Locked_pages_used_Sqlserver_MB,
(total_virtual_address_space_kb/1024 )Total_VAS_in_MB,process_physical_memory_low,process_virtual_memory_low
from sys. dm_os_process_memory

-- Get size of SQL Server Page in bytes
DECLARE @pg_size INT, @Instancename varchar(50) 
SELECT @pg_size = low from master..spt_values where number = 1 and type = 'E' 

-- Extract perfmon counters to a temporary table
IF OBJECT_ID('tempdb..#perfmon_counters') is not null DROP TABLE #perfmon_counters
SELECT * INTO #perfmon_counters FROM sys.dm_os_performance_counters

-- Get SQL Server instance name
SELECT @Instancename = LEFT([object_name], (CHARINDEX(':',[object_name]))) FROM #perfmon_counters WHERE counter_name = 'Buffer cache hit ratio' 

-- Print Memory usage details
PRINT '----------------------------------------------------------------------------------------------------' 
PRINT 'Memory usage details for SQL Server instance ' + @@SERVERNAME + ' (' + CAST(SERVERPROPERTY('productversion') AS VARCHAR) + ' - ' + SUBSTRING(@@VERSION, CHARINDEX('X',@@VERSION),4) + ' - ' + CAST(SERVERPROPERTY('edition') AS VARCHAR) + ')' 
PRINT '----------------------------------------------------------------------------------------------------' 
 
SELECT CEILING(physical_memory_in_bytes/1048576.0) as [Physical Memory_MB], CEILING(physical_memory_in_bytes/1073741824.0) as [Physical Memory_GB]
	, CEILING(virtual_memory_in_bytes/1073741824.0) as [Virtual Memory GB] , 'Memory visible to the Operating System' AS _desc
FROM sys.dm_os_sys_info 

SELECT (bpool_committed*8)/1024.0 as BPool_Committed_MB, (bpool_commit_target*8)/1024.0 as BPool_Commit_Tgt_MB
	,(bpool_visible*8)/1024.0 as BPool_Visible_MB, 'Buffer Pool Usage at the Moment' as _desc
FROM sys.dm_os_sys_info 
------------------------
SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB,'Total Memory used by SQL Server Buffer Pool as reported by Perfmon counters' as _desc
FROM #perfmon_counters WHERE counter_name = 'Total Server Memory (KB)' 
union all
SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB, 'Memory needed as per current Workload for SQL Server instance' as _desc
FROM #perfmon_counters WHERE counter_name = 'Target Server Memory (KB)' 
union all
SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB, 'Total amount of dynamic memory the server is using for maintaining connections' as _desc 
FROM #perfmon_counters WHERE counter_name = 'Connection Memory (KB)'
union all
SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB,'Total amount of dynamic memory the server is using for locks' as _desc 
FROM #perfmon_counters WHERE counter_name = 'Lock Memory (KB)' 
union all
SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB,'Total amount of dynamic memory the server is using for the dynamic SQL cache' _desc 
FROM #perfmon_counters WHERE counter_name = 'SQL Cache Memory (KB)' 
union all 
SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB,'Total amount of dynamic memory the server is using for query optimization' as _desc 
FROM #perfmon_counters WHERE counter_name = 'Optimizer Memory (KB) ' 
union all 
SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB,'Total amount of dynamic memory used for hash, sort and create index operations.' as _desc 
FROM #perfmon_counters WHERE counter_name = 'Granted Workspace Memory (KB) ' 
union all
SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB,'Total Amount of memory consumed by cursors' as _desc 
FROM #perfmon_counters WHERE counter_name = 'Cursor memory usage' and instance_name = '_Total' 
--------------------
SELECT cntr_value as [8KB_Pages], (cntr_value*@pg_size)/1024.0 as Pages_in_KB, (cntr_value*@pg_size)/1048576.0 as Pages_in_MB
	,'Number of pages in the buffer pool (includes database, free, and stolen).' as _desc
FROM #perfmon_counters WHERE object_name= @Instancename+'Buffer Manager' and counter_name = 'Total pages' 
union all
SELECT cntr_value as [8KB_Pages], (cntr_value*@pg_size)/1024.0 as Pages_in_KB, (cntr_value*@pg_size)/1048576.0 as Pages_in_MB
	,'Number of Data pages in the buffer pool'  as _desc 
FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Database pages' 
union all 
SELECT cntr_value as [8KB_Pages], (cntr_value*@pg_size)/1024.0 as Pages_in_KB, (cntr_value*@pg_size)/1048576.0 as Pages_in_MB
	,'Number of Free pages in the buffer pool' as _desc 
FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Free pages' 
union all 
SELECT cntr_value as [8KB_Pages], (cntr_value*@pg_size)/1024.0 as Pages_in_KB, (cntr_value*@pg_size)/1048576.0 as Pages_in_MB
	,'Number of Reserved pages in the buffer pool' as _desc 
FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Reserved pages' 
union all  
SELECT cntr_value as [8KB_Pages], (cntr_value*@pg_size)/1024.0 as Pages_in_KB, (cntr_value*@pg_size)/1048576.0 as Pages_in_MB
	,'Number of Stolen pages in the buffer pool' as _desc 
FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Stolen pages' 
union all 
SELECT cntr_value as [8KB_Pages], (cntr_value*@pg_size)/1024.0 as Pages_in_KB, (cntr_value*@pg_size)/1048576.0 as Pages_in_MB
	,'Number of Plan Cache pages in the buffer pool' as _desc 
FROM #perfmon_counters WHERE object_name=@Instancename+'Plan Cache' and counter_name = 'Cache Pages' and instance_name = '_Total'

-------------------------------------- 
SELECT 'Free list stalls/sec' title, cntr_value as [value],'Number of requests per second that had to wait for a free page' _desc 
FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Free list stalls/sec'
union all 
SELECT 'Checkpoint pages/sec' title,cntr_value as [value],'Number of pages flushed to disk/sec by a checkpoint or other operation that require all dirty pages to be flushed' _desc 
FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Checkpoint pages/sec'
union all
SELECT 'Lazy writes/sec' as title,cntr_value as [value],'Number of buffers written per second by the buffer manager"s lazy writer' as _desc 
FROM #perfmon_counters WHERE object_name=@Instancename+'Buffer Manager' and counter_name = 'Lazy writes/sec'
union all 
SELECT 'Memory Grants Pending' as title,cntr_value as [value],'Total number of processes waiting for a workspace memory grant' _desc 
FROM #perfmon_counters WHERE object_name=@Instancename+'Memory Manager' and counter_name = 'Memory Grants Pending'
union all
SELECT 'Memory Grants Outstanding' as title, cntr_value as [value], 'Total number of processes that have successfully acquired a workspace memory grant' _desc 
FROM #perfmon_counters WHERE object_name=@Instancename+'Memory Manager' and counter_name = 'Memory Grants Outstanding'
