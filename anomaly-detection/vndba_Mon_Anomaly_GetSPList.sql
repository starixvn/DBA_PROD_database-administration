use monDBDW
GO
ALTER PROCEDURE vndba_Mon_Anomaly_GetSPList
	@server varchar(64), 
	@db varchar(20),
	@fromDate smalldatetime, 
	@toDate smalldatetime, 
	@sp varchar(128) = NULL,
	@TopBy varchar(20) = 'All', 
	@type tinyint = 0,
	@MailTo varchar(1000) = ''
AS
/*
		Created: Daniel
		Date: 20180917
		Task: Report of SPs have performance anomaly
		DB: DBMONDW-MonDBDW
		
		Revisions:
			
		
		Parameter's Explanation:
			- @server, @db: Input Server's name, database's name to analyze anomaly
			- @fromDate, @toDate: Time period to collect MonDB data for analysis
			- @TopBy: Choose performance statistics to evaluate anomaly, input CPU/Reads/Writes/Duration/ ExecCNT(SP Execution counts)
			- @type: Choose method to analyze anomaly: 
				+ 0: Z-Score/ Stardard Deviation (default)
				+ 1: Growth Detection/ SPs get worse
			- @MailTo: leave blank if want to skip send mail the list, otherwise send email to the receipients specified/assigned (input emails separated by semi-colons)

*/
SET NOCOUNT ON

declare @sql varchar(1000)

create table #tmpX
(
	Eventtime smalldatetime,
	SPName varchar(128),
	ExecCNT bigint,
	Duration float,
	CPU float,
	Reads float,
	Writes float
)

select @sql = 
'select Eventtime, l.SPName COLLATE Latin1_General_CI_AS,
	execution_count ExecCNT,
	convert(float, elapsed_time)/1000/execution_count Duration,
	convert(float, CPU_Time)/1000/execution_count CPU,
	convert(float, logical_reads)/1000/execution_count Reads,
	convert(float, logical_writes)/1000/execution_count Writes
from MONDB_' + @server + '.MonDB.dbo.Mon_SPPF_Report b with(nolock)
	inner join MONDB_' + @server + '.MonDB.dbo.Mon_SPPF_List l with (nolock) on b.SPID = l.SPID
where execution_count > 0
	and b.EventTime >= ''' + convert(varchar(20),@fromDate) + '''
	and b.EventTime <= ''' + convert(varchar(20),@toDate) + '''
	and l.dbname = ''' + @db + ''''
+ case when @sp is null then '' else 'and l.spname = ''' + @sp + '''' end

insert #tmpX
exec (@sql)

;with t as (
	select Eventtime, l.SPName,
		execution_count ExecCNT,  
		convert(float, elapsed_time)/1000/execution_count Duration,
		convert(float, CPU_Time)/1000/execution_count CPU,
		convert(float, logical_reads)/1000/execution_count Reads,
		convert(float, logical_writes)/1000/execution_count Writes
	from Mon_SPPF_Report b with(nolock)
		inner join Mon_SPPF_List l with (nolock) on b.SPID = l.SPID and b.serverID = l.serverID
	where execution_count > 0
		and l.dbname = @db and l.servername = @server
		and b.EventTime >= @fromDate and b.EventTime <= @toDate
		and l.spname = isnull(@sp, l.spname)
	UNION ALL
	select * from #tmpX
)
select t.Eventtime, t.SPName,
	t.Duration,
	t.CPU,
	t.ExecCNT,
	t.Reads,
	t.Writes,

	avg_Duration,
	avg_CPU,
	avg_ExecCNT,
	avg_Reads,
	avg_Writes,

    (Duration - avg_Duration) / nullif(std_Duration, 0) as z_Duration,
	(CPU - avg_CPU) / nullif(std_CPU, 0) as z_CPU,
	(ExecCNT - avg_ExecCNT) / nullif(std_ExecCNT, 0) as z_ExecCNT,
	(Reads - avg_Reads) / nullif(std_Reads, 0) as z_Reads,
	(Writes - avg_Writes) / nullif(std_Writes, 0) as z_Writes
into #tmpZ
from t inner join
    (
		select spname, 
			avg(Duration) avg_Duration, stdev(Duration) std_Duration,
			avg(CPU) avg_CPU, stdev(CPU) std_CPU,
			avg(ExecCNT) avg_ExecCNT, stdev(ExecCNT) std_ExecCNT,
			avg(Reads) avg_Reads, stdev(Reads) std_Reads,
			avg(Writes) avg_Writes, stdev(Writes) std_Writes
		from t
		group by spname
		--having avg(Duration) > 0
     ) tt
     on t.spname = tt.spname
--order by ABS((Duration - avg_Duration) / nullif(std_Duration, 0)) desc

--exclude low use SP
delete #tmpZ
where spname IN(select spname from #tmpZ group by spname having count(1) < 10)

if(@sp is not null)
BEGIN
	select Eventtime, ExecCNT, Duration, CPU, Reads, Writes, z_ExecCNT, z_Duration, z_CPU, z_Reads, z_Writes
	from #tmpZ order by Eventtime
	RETURN
END

declare @cols varchar(100)
declare @topByList TABLE(ID tinyint identity(1,1), TopBy varchar(20)) 
DECLARE @subject VARCHAR(200), @title VARCHAR(200)
DECLARE @body VARCHAR(MAX), @profile_name SYSNAME

insert @topByList(TopBy)
select 'CPU'
union all select 'ExecCNT'
union all select 'Duration'
union all select 'Reads'
--union all select 'Writes'

if(@topBy = 'All')
BEGIN
	while(1=1)
	BEGIN
		select top 1 @topBy = TopBy from @topByList order by [ID]
		if (@@rowcount = 0) BREAK

		--start process item in topBy List
		set @cols = @topBy + ', avg_' + @topBy + ' [Normal ' + @topBy + '], ' +
		case @topBy
			when 'ExecCNT'  then 'Duration, CPU, Reads, Writes'
			when 'Duration' then 'ExecCNT, CPU, Reads, Writes'
			when 'CPU'      then 'ExecCNT, Duration, Reads, Writes'
			when 'Reads'    then 'ExecCNT, Duration, CPU, Writes'
			when 'Writes'   then 'ExecCNT, Duration, CPU, Reads'
		end
		set @sql = N'
			;with cte as
			(	
				select * , ROW_NUMBER() over(partition by spname order by z_' + @topBy + ' desc) as rowID
				from #tmpZ
			)
			select TOP (200) ROW_NUMBER() OVER (Order by z_' + @topBy + ' desc) [Rank], SPName, Eventtime, ' + @cols + ', z_' + @topBy + '
			into ##tmpMonDB_Z_Perf
			from cte 
			where rowID = 1 and avg_' + @topBy + ' >= 0.01'

		EXEC(@sql)

		if (ISNULL(@MailTo, '') = '') --Return data only
			select * from ##tmpMonDB_Z_Perf order by [Rank]
		else --Perform Send Mail:
		BEGIN
			--Change column data type for send mail number format
			set @sql = 
			'ALTER TABLE ##tmpMonDB_Z_Perf ALTER COLUMN Duration money
			ALTER TABLE ##tmpMonDB_Z_Perf ALTER COLUMN CPU money
			ALTER TABLE ##tmpMonDB_Z_Perf ALTER COLUMN Reads money
			ALTER TABLE ##tmpMonDB_Z_Perf ALTER COLUMN Writes money
			' + case when @topBy <> 'ExecCNT' then 'ALTER TABLE ##tmpMonDB_Z_Perf ALTER COLUMN [Normal ' + @topBy + '] money' else '' end + '
			ALTER TABLE ##tmpMonDB_Z_Perf DROP COLUMN z_' + @topBy

			EXEC(@sql)

			SET @title = @Server + '.' + @db + ' ' + @topBy + ' Anomaly Report From [' + convert(varchar(20), @fromDate) + '] To [' + convert(varchar(20), @toDate) + ']'
			SET @subject = @Server + '.' + @db + ' ' + @topBy + ' ANOMALY REPORT'

			EXEC dbo.DBA_QueryToHtmlTable @html = @body OUTPUT, 
				@title = @title, 
				@orderBy = 'order by [Rank]',  
				@query = N'select * from ##tmpMonDB_Z_Perf'

			EXEC msdb.dbo.sp_send_dbmail @recipients = @MailTo
				, @body = @body
				, @body_format ='HTML'
				, @sensitivity = 'Personal'
				, @importance = 'Normal'
				, @copy_recipients = ''
				, @subject = @subject
				, @profile_name = @profile_name
		END
		drop table ##tmpMonDB_Z_Perf
		--End process item
		
		delete @topByList where topBy = @topBy

	END --end while

END
ELSE IF (@topBy IN(select topBy from @topByList))
BEGIN
	set @cols = @topBy + ', avg_' + @topBy + ' [Normal ' + @topBy + '], ' +
	case @topBy
		when 'ExecCNT'  then 'Duration, CPU, Reads, Writes'
		when 'Duration' then 'ExecCNT, CPU, Reads, Writes'
		when 'CPU'      then 'ExecCNT, Duration, Reads, Writes'
		when 'Reads'    then 'ExecCNT, Duration, CPU, Writes'
		when 'Writes'   then 'ExecCNT, Duration, CPU, Reads'
	end
	set @sql = N'
		;with cte as
		(	
			select * , ROW_NUMBER() over(partition by spname order by z_' + @topBy + ' desc) as rowID
			from #tmpZ
		)
		select TOP (200) ROW_NUMBER() OVER (Order by z_' + @topBy + ' desc) [Rank], SPName, Eventtime, ' + @cols + ', z_' + @topBy + '
		into ##tmpMonDB_Z_Perf
		from cte 
		where rowID = 1 and avg_' + @topBy + ' >= 0.01'

	EXEC(@sql)

	if (ISNULL(@MailTo, '') = '') --Return data only
		select * from ##tmpMonDB_Z_Perf order by [Rank]
	else --Perform Send Mail:
	BEGIN
		--Change column data type for send mail number format
		set @sql = 
		'ALTER TABLE ##tmpMonDB_Z_Perf ALTER COLUMN Duration money
		ALTER TABLE ##tmpMonDB_Z_Perf ALTER COLUMN CPU money
		ALTER TABLE ##tmpMonDB_Z_Perf ALTER COLUMN Reads money
		ALTER TABLE ##tmpMonDB_Z_Perf ALTER COLUMN Writes money
		' + case when @topBy <> 'ExecCNT' then 'ALTER TABLE ##tmpMonDB_Z_Perf ALTER COLUMN [Normal ' + @topBy + '] money' else '' end + '
		ALTER TABLE ##tmpMonDB_Z_Perf DROP COLUMN z_' + @topBy

		EXEC(@sql)


		SET @title = @Server + '.' + @db + ' ' + @topBy + ' Anomaly Report From [' + convert(varchar(20), @fromDate) + '] To [' + convert(varchar(20), @toDate) + ']'
		SET @subject = @Server + '.' + @db + ' ' + @topBy + ' ANOMALY REPORT'

		EXEC dbo.DBA_QueryToHtmlTable @html = @body OUTPUT, 
			@title = @title, 
			@orderBy = 'order by [Rank]',  
			@query = N'select * from ##tmpMonDB_Z_Perf'

		EXEC msdb.dbo.sp_send_dbmail @recipients = @MailTo
			, @body = @body
			, @body_format ='HTML'
			, @sensitivity = 'Personal'
			, @importance = 'Normal'
			, @copy_recipients = ''
			, @subject = @subject
			, @profile_name = @profile_name
	END

	drop table ##tmpMonDB_Z_Perf
END

drop table #tmpX
drop table #tmpZ
