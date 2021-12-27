/***
	- Created@20211229: Bobby
	- Host: Run on DB052N2
***/

use master;
select '(''' + name + ''',''' + cast(value as varchar(10)) + '''),' as sql
from sys.configurations
go

-- RUN on DB052N2
;
with cte as (
	select name, value
	from (
		values ('recovery interval (min)','0'),
		('allow updates','0'),
		('user connections','0'),
		('locks','0'),
		('open objects','0'),
		('fill factor (%)','0'),
		('disallow results from triggers','0'),
		('nested triggers','1'),
		('server trigger recursion','1'),
		('remote access','1'),
		('default language','0'),
		('cross db ownership chaining','0'),
		('max worker threads','0'),
		('network packet size (B)','4096'),
		('show advanced options','1'),
		('remote proc trans','0'),
		('c2 audit mode','0'),
		('default full-text language','1033'),
		('two digit year cutoff','2049'),
		('index create memory (KB)','0'),
		('priority boost','0'),
		('remote login timeout (s)','20'),
		('remote query timeout (s)','600'),
		('cursor threshold','-1'),
		('set working set size','0'),
		('user options','64'),
		('affinity mask','0'),
		('max text repl size (B)','65536'),
		('media retention','0'),
		('cost threshold for parallelism','50'),
		('max degree of parallelism','4'),
		('min memory per query (KB)','1024'),
		('query wait (s)','-1'),
		('min server memory (MB)','32768'),
		('max server memory (MB)','225280'),
		('query governor cost limit','0'),
		('lightweight pooling','0'),
		('scan for startup procs','0'),
		('awe enabled','0'),
		('affinity64 mask','0'),
		('affinity I/O mask','0'),
		('affinity64 I/O mask','0'),
		('transform noise words','0'),
		('precompute rank','0'),
		('PH timeout (s)','60'),
		('clr enabled','1'),
		('max full-text crawl range','4'),
		('ft notify bandwidth (min)','0'),
		('ft notify bandwidth (max)','100'),
		('ft crawl bandwidth (min)','0'),
		('ft crawl bandwidth (max)','100'),
		('default trace enabled','1'),
		('blocked process threshold (s)','0'),
		('in-doubt xact resolution','0'),
		('remote admin connections','1'),
		('common criteria compliance enabled','0'),
		('EKM provider enabled','0'),
		('backup compression default','1'),
		('filestream access level','0'),
		('optimize for ad hoc workloads','1'),
		('access check cache bucket count','0'),
		('access check cache quota','0'),
		('Agent XPs','1'),
		('SQL Mail XPs','0'),
		('Database Mail XPs','1'),
		('SMO and DMO XPs','1'),
		('Ole Automation Procedures','0'),
		('xp_cmdshell','0'),
		('Ad Hoc Distributed Queries','0'),
		('Replication XPs','0')
	) as t(name, value)
), compare as (
	select cte.name, cte.value as value_053, cast(cf.value as varchar(10)) value_053N1
	from cte
	left join sys.configurations cf with(nolock) on cf.name = cte.name
)
select 'exec sp_configure ''' + c.name + ''',''' + c.value_053 + '''' as cmd
from compare c
where value_053 <> value_053N1

use master 
go
exec sp_configure
go

exec sp_configure 'show advanced options', 1
RECONFIGURE  
GO 
exec sp_configure 'remote login timeout (s)',20
RECONFIGURE  
GO 
exec sp_configure 'user options',64
RECONFIGURE  
GO 
exec sp_configure 'cost threshold for parallelism',50;
RECONFIGURE  
GO 
exec sp_configure 'max degree of parallelism',4
RECONFIGURE  
GO 
exec sp_configure 'min server memory (MB)',32768
RECONFIGURE  
GO 
exec sp_configure 'max server memory (MB)',225280
RECONFIGURE  
GO 
exec sp_configure 'clr enabled',1
RECONFIGURE  
GO 
exec sp_configure 'backup compression default',1
RECONFIGURE  
GO 
exec sp_configure 'optimize for ad hoc workloads',1
RECONFIGURE  
GO 
exec sp_configure 'Database Mail XPs',1
RECONFIGURE  
GO 
exec sp_configure 'clr strict security',0
RECONFIGURE  
GO 
