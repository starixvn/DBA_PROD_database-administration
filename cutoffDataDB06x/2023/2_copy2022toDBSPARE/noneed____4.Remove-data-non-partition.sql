

set nocount on
create table __annual_archive_date (datefrom smalldatetime, dateto smalldatetime)
insert into __annual_archive_date(datefrom, dateto) values('2019-01-01', '2021-01-01')

go
begin --translog_BK
	declare @eventdate smalldatetime, @message varchar(2000), @datefrom smalldatetime, @dateto smalldatetime
		, @max_wld smalldatetime
	select @eventdate = min(winlostdate) from dbo.translog_BK with(nolock)
	select @datefrom = datefrom, @dateto = dateto from __annual_archive_date
	while @eventdate >= @datefrom
	begin 
		if @eventdate = @dateto
			break
		delete from dbo.translog_BK
		where winlostdate = @eventdate

		insert into mondb.dbo.cutoff_bodb_archive2019(tableName,actionDate,winlostdate,deletedRow) 
		values ('translog_BK' ,getdate(),@eventdate,@@rowcount))
		

		set @eventdate = dateadd(day, 1, @eventdate)

	end

end

go
begin --TOControl_Setting_bk
	declare @eventdate smalldatetime, @message varchar(2000), @datefrom smalldatetime, @dateto smalldatetime, @max_wld smalldatetime
	select @eventdate = min(eventdate) from dbo.match_bk with(nolock)
	select @datefrom = datefrom, @dateto = dateto from __annual_archive_date


	while @eventdate >= @datefrom
	begin 
		if @eventdate = @dateto
			break
				
		delete s
		from dbo.TOControl_Setting_bk s where winlostdate = @eventdate

		insert into mondb.dbo.cutoff_bodb_archive2019(tableName,actionDate,winlostdate,deletedRow) 
		values ('TOControl_Setting_bk' ,getdate(),@eventdate,@@rowcount))

		set @eventdate = dateadd(day, 1, @eventdate)

	end

	----------------------------------------------------------------------------//last round--need to double check
	--delete from dbo.TOControl_Setting_bk where winlostdate is null
end

go
begin --BetParlayResult
	declare @eventdate smalldatetime, @message varchar(2000), @datefrom smalldatetime, @dateto smalldatetime, @max_wld smalldatetime
	select @eventdate = min(eventdate) from dbo.match_bk with(nolock)
	select @datefrom = datefrom, @dateto = dateto from __annual_archive_date

	while @eventdate >= @datefrom
	begin 

		if @eventdate = @dateto
			break
			
		delete s
		from dbo.BetParlayResult s
		where winlostdate = @eventdate

		insert into mondb.dbo.cutoff_bodb_archive2019(tableName,actionDate,winlostdate,deletedRow) 
		values ('BetParlayResult' ,getdate(),@eventdate,@@rowcount))

		set @eventdate = dateadd(day, 1, @eventdate)

	end
end

go
begin --betParlayResult_Archive
	declare @eventdate smalldatetime, @message varchar(2000), @datefrom smalldatetime, @dateto smalldatetime, @max_wld smalldatetime
	select @eventdate = min(eventdate) from dbo.match_bk with(nolock)
	select @datefrom = datefrom, @dateto = dateto from __annual_archive_date

	while @eventdate >= @datefrom
	begin 

		if @eventdate = @dateto
			break
			
		delete s
		from dbo.betParlayResult_Archive s
		where winlostdate = @eventdate
	
		insert into mondb.dbo.cutoff_bodb_archive2019(tableName,actionDate,winlostdate,deletedRow) 
		values ('betParlayResult_Archive' ,getdate(),@eventdate,@@rowcount))

		set @eventdate = dateadd(day, 1, @eventdate)

	end

end

--====
go
begin --Odds3rd_bk
	declare @eventdate smalldatetime, @message varchar(2000), @datefrom smalldatetime, @dateto smalldatetime, @max_wld smalldatetime
	select @eventdate = min(eventdate) from dbo.match_bk with(nolock)
	select @datefrom = datefrom, @dateto = dateto from __annual_archive_date

	declare @__matchIds table(matchid int primary key)

	while @eventdate >= @datefrom
	begin
		if @eventdate = @dateto
			break
			
		delete from @__matchIds
		insert into @__matchIds 
		select matchid from dbo.match_bk with(nolock) where eventdate = @eventdate
		group by matchid

		delete s
		from dbo.Odds3rd_bk s
		where exists (select top 1 1 from @__matchIds t where s.matchid = t.matchid)
	
		insert into mondb.dbo.cutoff_bodb_archive2019(tableName,actionDate,winlostdate,deletedRow) 
		values ('Odds3rd_bk' ,getdate(),@eventdate,@@rowcount))


		set @eventdate = dateadd(day, 1, @eventdate)

	end
end

go
begin --Odds_bk
	declare @eventdate smalldatetime, @message varchar(2000), @datefrom smalldatetime, @dateto smalldatetime, @max_wld smalldatetime
	select @eventdate = min(eventdate) from dbo.match_bk with(nolock)
	select @datefrom = datefrom, @dateto = dateto from __annual_archive_date

	declare @__matchIds table(matchid int primary key)

	while @eventdate >= @datefrom
	begin
		if @eventdate = @dateto
			break
			
		delete from @__matchIds
		insert into @__matchIds 
		select matchid from match_bk where eventdate = @eventdate
		group by matchid

		delete s
		from dbo.Odds_bk s
		where exists (select top 1 1 from @__matchIds t where s.matchid = t.matchid)
	
		insert into mondb.dbo.cutoff_bodb_archive2019(tableName,actionDate,winlostdate,deletedRow) 
		values ('Odds_bk' ,getdate(),@eventdate,@@rowcount))

		set @eventdate = dateadd(day, 1, @eventdate)

	end
end

go
begin ---match_remark
	declare @eventdate smalldatetime, @message varchar(2000), @datefrom smalldatetime, @dateto smalldatetime, @max_wld smalldatetime
	select @eventdate = min(eventdate) from dbo.match_bk with (nolock)
	select @datefrom = datefrom, @dateto = dateto from __annual_archive_date
	while @eventdate >= @datefrom
	begin 
		if @eventdate = @dateto
			break
			
		delete r
		from dbo.match_remark r
			inner join dbo.match_bk m on r.matchid = m.matchid
		where eventdate = @eventdate
	
		insert into mondb.dbo.cutoff_bodb_archive2019(tableName,actionDate,winlostdate,deletedRow) 
		values ('match_remark' ,getdate(),@eventdate,@@rowcount))
		
		set @eventdate = dateadd(day, 1, @eventdate)

	end

end

go
begin --VSOutright_bk
	declare @datefrom smalldatetime, @dateto smalldatetime
	select @datefrom = datefrom, @dateto = dateto from __annual_archive_date
	delete dbo.VSOutright_bk where eventdate >= @datefrom and eventdate < @dateto
end

go
begin ---match_bk ==> last table
	declare @eventdate smalldatetime, @message varchar(2000), @datefrom smalldatetime, @dateto smalldatetime, @max_wld smalldatetime
	select @eventdate = min(eventdate) from dbo.match_bk with (nolock)
	select @datefrom = datefrom, @dateto = dateto from __annual_archive_date
	while @eventdate >= @datefrom
	begin 
		if @eventdate = @dateto
			break
						
		delete m
		from dbo.match_bk m
		where eventdate = @eventdate
	
		set @message = 'match_bk ==> currentdate: ' + convert(varchar(50), getdate(), 121) + ' - eventdate: ' + convert(varchar(50), @eventdate, 121) + ' - count: ' + cast(@@rowcount as varchar)
		raiserror (@message, 0, 1) with nowait
		insert into mondb.dbo.cutoff_bodb_archive2019(tableName,actionDate,winlostdate,deletedRow) 
		values ('match_bk' ,getdate(),@eventdate,@@rowcount))
		
		set @eventdate = dateadd(day, 1, @eventdate)

	end
end
