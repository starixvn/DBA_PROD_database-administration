--check rowcount
select obj.name, sum(p.rows) row_count
from sys.objects obj
	inner join sys.partitions p on obj.object_id = p.object_id
	inner join sys.indexes i on p.object_id = i.object_id and p.index_id = i.index_id 
	inner join sys.data_spaces ds on i.data_space_id = ds.data_space_id 
	inner join sys.partition_schemes ps on ds.data_space_id = ps.data_space_id 
	inner join sys.partition_functions pf on ps.function_id = pf.function_id 
	inner join sys.destination_data_spaces dds on dds.partition_scheme_id = ds.data_space_id and p.partition_number = dds.destination_id 
	left outer join sys.partition_range_values prv on prv.function_id = ps.function_id and p.partition_number = prv.boundary_id 
	inner join sys.data_spaces ds2 on ds2.data_space_id = dds.data_space_id 
where i.type_desc = 'CLUSTERED' and obj.object_id in (object_id('bettrans_bk')
														, object_id('bettransG')
														, object_id('bettransLC_bk')
														, object_id('bettransm')
														, object_id('bettransRnG_bk')
														, object_id('Dot_Admin_LiveLog')
														, object_id('transfer_bk'))
	and cast(value as datetime) between '2020-01-01' and '2021-01-01'
group by obj.name
order by obj.name

go

declare @__datefrom smalldatetime, @__dateto smalldatetime
select @__datefrom = '2020-01-01', @__dateto = '2021-01-01'

select 'translog_bk' as tableName,  count(1) from dbo.translog_bk with(nolock) where winlostdate >= @__datefrom and winlostdate < @__dateto
union all
select 'BetParlayResult' as tableName,  count(1) from dbo.BetParlayResult with(nolock) where winlostdate >= @__datefrom and winlostdate < @__dateto
union all
select 'betParlayResult_Archive' as tableName,  count(1) from dbo.betParlayResult_Archive with(nolock) where winlostdate >= @__datefrom and winlostdate < @__dateto
union all
select 'match_bk' as tableName,  count(1) from dbo.match_bk with(nolock) where eventdate >= @__datefrom and eventdate < @__dateto
union all
select 'match_remark' as tableName,  count(1) from dbo.match_remark s with(nolock) inner join dbo.match_bk m with(nolock) on s.matchid = m.matchid where eventdate >= @__datefrom and eventdate < @__dateto
union all
select 'odds_bk' as tableName,  count(1) from dbo.odds_bk s with(nolock) inner join dbo.match_bk m with(nolock) on s.matchid = m.matchid where eventdate >= @__datefrom and eventdate < @__dateto
union all
select 'Odds3rd_bk' as tableName,  count(1) from dbo.Odds3rd_bk s with(nolock) inner join dbo.match_bk m with(nolock) on s.matchid = m.matchid where eventdate >= @__datefrom and eventdate < @__dateto
union all
select 'TOControl_Setting_bk' as tableName,  count(1) from dbo.TOControl_Setting_bk s with(nolock) inner join dbo.match_bk m with(nolock) on s.matchid = m.matchid where eventdate >= @__datefrom and eventdate < @__dateto

