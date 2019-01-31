
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.DBA_Exec    Script Date: 1/21/2019 4:30:01 AM ******/
CREATE PROCEDURE [dbo].[DBA_Exec]  
 @SPName varchar(200)  
AS  
SET NOCOUNT ON  
  
Declare @maxParam int, @maxParam_out int  
  
select @maxParam = max(colorder)  
from syscolumns sc  
where id in (select id from sysobjects where name = @SPName)  
  
select @maxParam_out = max(colorder)  
from syscolumns sc  
where id in (select id from sysobjects where name = @SPName)   
 and sc.isoutparam = 1  
  
select 'Declare ' + sc.name + ' ' + st.name   
  + case when st.name in ('varchar', 'nvarchar') then '(' + cast(sc.length as varchar(10)) + ')' else '' end, -3 as colorder  
from syscolumns sc  
 inner join systypes st on sc.xtype = st.xusertype  
where id in (select id from sysobjects where name = @SPName)  
 and sc.isoutparam = 1  
union all   
  
select '---------------------------------', -2 as colorder  
  
union all  
  
select 'EXEC dbo.'+@SPName + ' ', -1 as colorder  
  
union all  
  
select name + ' = ' + name + case when isoutparam = 1 then ' OUTPUT' else '' end   
 + case when colorder < @maxParam then ',' else '' end  
 , colorder  
from syscolumns   
where id in (select id from sysobjects where name = @SPName)   
  
union all   
  
select '---------------------------------', 1000 as colorder  
  
union all  
  
select case when @maxParam_out > 0 then 'select ' else '' end, 1000 as colorder  
  
union all  
  
select  sc.name + ' as ' + replace(sc.name, '@', '')   
 + case when colorder < @maxParam_out then ',' else '' end  
 , 1001 as colorder  
from syscolumns sc  
 inner join systypes st on sc.xtype = st.xusertype  
where id in (select id from sysobjects where name = @SPName)  
 and sc.isoutparam = 1  
  
order by colorder  
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
