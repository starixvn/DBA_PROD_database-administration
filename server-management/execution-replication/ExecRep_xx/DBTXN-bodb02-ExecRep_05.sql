USE	bodb02;
GO

ALTER PROCEDURE [dbo].[ExecRep_05]
(
	@winlostdate datetime = ''
)
AS
begin
	set nocount on 
	if @@servername not in ('DB05','DB052','DB053','DB054','DB06','DBTP','DBTRANS','DB230','DB231','DB232')
		return 

	if @winlostdate <> '2015-07-21'
		return

	if  ( select count(1) from sys.objects where name in ('bettransm','bettransm14')) = 2
	begin
		
			delete from bettransm14
			where winlostdate = @winlostdate		
	end 

	if  ( select count(1) from sys.objects where name in ('bettransG','bettransg14')) = 2
	begin
		
		delete from bettransG14
		where winlostdate = @winlostdate		
	end
end 


GO

