/*
	Task: Generate alter SPs putting return to disable
	Created by Daniel @20240819
	Run on subscribers db DB06x, DBTP10C

*/

declare 
	@ViewOnly BIT = 1 --WARNING!!!! Turning off view only will EXEC ALTER SP command on destination server
	,@rollback BIT = 0 -- turn rollback on - 1 if want to enable msrepl (remove return in SPs)

DECLARE @FullText NVARCHAR(MAX) = ''

select p.name spName, 
	m.[definition] Def,
	case when @rollback = 1 then REPLACE(isnull(definition, 'Empty SP!!'), 'return /*skip run SP*/ ', '') 
	else stuff([definition], patindex('%begin%', [definition]) + 6, 0, 'return /*skip run SP*/ ') end Def_mod
into #tmpAlter
from sys.OBJECTS as o
	inner join sys.sql_modules as m on o.[object_id] = m.[object_id]
	inner join sys.procedures as p on m.object_id = p.object_id
where o.name IN(
'Acc_Dep_DynamicCustSetting_00',
'Acc_Dep_DynamicCustSetting_01',
'Acc_Dep_DynamicCustSetting_02',
'Acc_Dep_DynamicCustSetting_03',
'Acc_Dep_DynamicCustSetting_04',
'Acc_Dep_DynamicCustSetting_05',
'Acc_Dep_DynamicCustSetting_06',
'Acc_Dep_DynamicCustSetting_10',
'Acc_CustSetting3rd_11',
'Acc_CustSetting3rd_16'
)
--order by o.name

select top 50000 @FullText = @FullText + CHAR(13) + CHAR(13) + '--============================================================================' + CHAR(13) 
	+ REPLACE(Def_mod, 'create proc', 'alter proc') + CHAR(13) + 'GO'
from #tmpAlter
order by spName

--select * from #tmpAlter where Def_mod not like '%Inscustomer]%'

select CONVERT(XML, (SELECT N' --' + char(13) + CONVERT(NVARCHAR(MAX), @FullText) + char(13) + N'--' AS [processing-instruction(query)] FOR XML PATH('')))  [sql]

select REPLACE(Def_mod, 'create proc', 'alter proc') from #tmpAlter order by spName

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


drop table #tmpAlter


