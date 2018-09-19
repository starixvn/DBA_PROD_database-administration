use monDBDW
GO
ALTER PROCEDURE Task_vndba_Mon_Anomaly_Report
AS
/*
		Created: Daniel
		Date: 20180919
		Task: Auto Job Report of SPs have performance anomaly for all servers
		DB: DBMONDW-MonDBDW
		
		Revisions:
			
		
		Parameter's Explanation:
*/
BEGIN
	SET NOCOUNT ON

	declare @server varchar(64), @db varchar(20), @ID tinyint
	declare @fromDate smalldatetime, @toDate smalldatetime, @type tinyint, @topBy varchar(20)
	
	declare @ServerList TABLE(ID tinyint identity(1,1), ServerName varchar(20), DBName varchar(30)) 

	select 
		--@fromDate = dateadd(hour, -24, GetDate()), 
		--@toDate = GetDate()
		@type = 0, @topBy = 'All',
		@fromDate = '2018-9-16', 
		@toDate = GetDate()

	insert @ServerList(ServerName, DBName)
	select 'DBTRANS', 'bodb02' union all
	select 'DBTRANS', 'IntgTransDB' union all

	select 'DBCUST', 'custdb' union all 
	select 'DBCUST', 'SiteConfig' union all 
	select 'DBCUST', 'NAP_UserControl' union all

	select 'DB042', 'bodb02' union all

	select 'DB05', 'bodb02' union all
	select 'DB05', 'bodb_Message' union all 

	select 'DB052', 'bodb02' union all 
	select 'DB052', 'bodb_Licensee' union all
	select 'DB052', 'bodb_LicenseeReport' union all
	select 'DB052', 'bodb_CustomerLog' union all

	select 'DB053', 'bodb02' union all 
	select 'DB053', 'bodb_AGE' union all
	select 'DB053', 'bodb_ChatBot' union all

	select 'DB054', 'bodb02' union all 
	select 'DB054', 'bodb_AGE' union all 

	select 'DB06', 'bodb02' union all 
	select 'DB06', 'bodb_Report' union all 
	select 'DB06', 'bodb_Archive'

	while(1=1)
	BEGIN
		select top 1 @ID = [ID], @server = servername, @db = dbname from @ServerList order by [ID]
		if (@@rowcount = 0) BREAK

		--start process item in Server List
		exec dbo.vndba_Mon_Anomaly_GetSPList
			@server = @server, 
			@db = @db,
			@fromDate = @fromDate, 
			@toDate = @toDate, 
			@TopBy = @topBy, 
			@type = @type
			,@MailTo = 'daniel.truong@starixsoft.com'
		--End process item
		
		delete @ServerList where [ID] = @ID

	END --end while
END