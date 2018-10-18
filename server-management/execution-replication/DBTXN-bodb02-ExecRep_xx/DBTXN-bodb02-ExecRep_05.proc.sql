SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE [dbo].[ExecRep_05]
(
	@winlostdate datetime = ''
)
AS
/*
	Creator:	@
	Task:		Description - [Redmine: #00000]
	Database:	DBTXN.bodb02
	
	Revisions:
		- 00000000@Creator:	Initial - [Redmine: #00000]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
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
/*<info serverAlias="DBTXN-bodb02" executers="" viewers="" isFunction="0" isNested="0"></info>*/