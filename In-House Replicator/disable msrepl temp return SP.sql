/*
	Task: Generate alter msrep SPs putting return to stop replication on rep tables
	Created by Daniel @20240801
	Run on subscribers db direct repl from DBCUST: DB04x, DB05x, DB06x, DBTP10C, DBTRANS, DBGRPxx, DBDWx(KL only)

*/

declare 
	@ViewOnly BIT = 1 --WARNING!!!! Turning off view only will EXEC ALTER SP command on destination server
	,@rollback BIT = 0 -- turn rollback on - 1 if want to enable msrepl (remove return in SPs)

declare @subName varchar(50)

select @subName = @@SERVERNAME

if (@subName LIKE '%DBGRP%')
	select @subName = stuff(@subName, patindex('%N[123]', @subName), 2, 'L')

select distinct sa.name, del_cmd, ins_cmd, upd_cmd
into #tmpRepInfo
from DBCUST.CustDB.dbo.syspublications sp 
	inner join DBCUST.CustDB.dbo.sysarticles sa on sp.pubid = sa.pubid 
	inner join DBCUST.CustDB.dbo.syssubscriptions s on sa.artid = s.artid
	inner join DBCUST.master.dbo.sysservers srv on s.srvid = srv.srvid
where sa.type = '1' and srv.srvname = @subName
	--and sp.name IN('CustDB_CustSetting') --filter publication
	and sa.name IN( --filter tables
'Dep_CustBAActive',
'Dep_CustBetLimit_Special',
'Dep_CustBetSetting_Agent',
'Dep_CustBetSetting_Member',
'Dep_CustBetSettingGame_Agent',
'Dep_CustBetSettingGame_Member',
'Dep_CustBetSettingGameGroup_Member',
'Dep_CustCategoryHistory',
'Dep_CustDiscountGroupSetting_Member',
'Dep_CustDiscountSetting_Agent',
'Dep_CustDiscountSetting_Member',
'Dep_Customer_Archived',
'Dep_CustomerClass',
'Dep_CustProductSetting',
'Dep_CustProductStatus',
'Dep_CustPTGroupSetting_Member',
'Dep_CustPTSetting_Agent',
'Dep_CustPTSetting_Member',
'Dep_CustSetting_AGCasino',
'Dep_CustSettingGame',
'Dep_CustSettingMode',
'Dep_CustSpecialLevel',
'Dep_CustStakeLevel_Agent',
'Dep_CustStakeLevel_Member',
'Dep_CustSuper',
'Dep_CustVIP',
'Dep_DefaultOddGroup',
'Dep_LicenseeProductSetting',
'Dep_ProductBetSetting',
'Dep_ProductSetting',
'Dep_ProductSettingDetail',
'Dep_ProductStatusProfile',
'Dep_StakeLevel',
'Dep_StakeLevelGroupDetail',
'Dep_SuperSetting_AGCasino',
'Dep_SupperProductSetting'
	)

--select * from #tmpRepInfo

DECLARE @FullText NVARCHAR(MAX) = ''

select ri.name tblName, p.name spName, 
	m.[definition] Def,
	case when @rollback = 1 then REPLACE(isnull(definition, 'Empty SP!!'), 'return /*skip replicated data from MSRepl*/ ', '') 
	else stuff([definition], patindex('%begin%', [definition]) + 6, 0, 'return /*skip replicated data from MSRepl*/ ') end Def_mod
into #tmpAlter
from sys.OBJECTS as o
	inner join sys.sql_modules as m on o.[object_id] = m.[object_id]
	inner join sys.procedures as p on m.object_id = p.object_id
	inner join #tmpRepInfo ri on 
		(
			p.name = substring(ri.del_cmd, patindex('%sp_MSdel%', ri.del_cmd), len(ri.name)+12)
			or p.name = substring(ri.ins_cmd, patindex('%sp_MSins%', ri.ins_cmd), len(ri.name)+12)
			or p.name = substring(ri.upd_cmd, patindex('%sp_MSupd%', ri.upd_cmd), len(ri.name)+12)
		)
where o.name like 'sp_MS%'
--order by o.name

select top 50000 @FullText = @FullText + CHAR(13) + CHAR(13) + '--============================================================================' + CHAR(13) 
	+ REPLACE(Def_mod, 'create proc', 'alter proc') + CHAR(13) + 'GO'
from #tmpAlter
order by tblName, spName

--select * from #tmpAlter where Def_mod not like '%Inscustomer]%'

select CONVERT(XML, (SELECT N' --' + char(13) + CONVERT(NVARCHAR(MAX), @FullText) + char(13) + N'--' AS [processing-instruction(query)] FOR XML PATH('')))  [sql]

select REPLACE(Def_mod, 'create proc', 'alter proc') from #tmpAlter order by tblName, spName

if (@ViewOnly = 0)
begin
	declare @spName varchar(50) = '',  @sql nvarchar(max) = ''
	while(1=1)
	begin
		select top 1 @spName= spName,  @sql = REPLACE(Def_mod, 'create proc', 'alter proc') from #tmpAlter
		if (@@ROWCOUNT = 0) break
		exec sp_executesql @sql
		delete #tmpAlter where spname = @spname
	end
end


drop table #tmpRepInfo
drop table #tmpAlter


