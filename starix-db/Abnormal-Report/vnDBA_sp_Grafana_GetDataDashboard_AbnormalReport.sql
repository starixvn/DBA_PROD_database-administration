USE [StarixDB]
GO
/****** Object:  StoredProcedure [dbo].[vnDBA_sp_Grafana_GetDataDashboard_AbnormalReport]    Script Date: 4/8/2025 10:46:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[vnDBA_sp_Grafana_GetDataDashboard_AbnormalReport]
	@timefrom		DATETIME,
	@timeto			DATETIME,
	@ServerName		VARCHAR(1000)='' ,
	@SPName			VARCHAR(256)='' ,
	@PropertyAbnormal VARCHAR(1000) = '',
	@Paneltype		SMALLINT = 1,
	@weekdiff		SMALLINT	= 0

AS
BEGIN

	  	
	IF (@SPName = '' AND @Paneltype = 1 ) OR @ServerName = ''
		RETURN


	DECLARE	@server_zone	SMALLINT = -4;

	DECLARE @currentDate DATETIME, @sqlCMD NVARCHAR(MAX), @textDay VARCHAR(8), @LinkServerName VARCHAR(256), @SrvName_Archive VARCHAR(256), @SrvName_Active VARCHAR(256)
	,@dateFrom DATE, @dateTo DATE
	DECLARE @tb_RangeDate TABLE (textDay VARCHAR(8), IsCheck BIT)

	SELECT	@timefrom	= DATEADD(WEEK, -@weekdiff, DATEADD(HOUR, @server_zone, @timefrom))
		,	@timeto		= DATEADD(WEEK, -@weekdiff, DATEADD(HOUR, @server_zone, @timeto))
		;

	
	SELECT @dateFrom = CAST(@timefrom AS DATE), @dateTo = CAST(@timeto AS DATE);

	IF @Paneltype = 3 
	BEGIN
		SELECT	ServerName,DBName,SPName,AbnormalReason,  CONVERT(VARCHAR(16), EventTimeAbnormal, 111) AS EventDate,
				CASE WHEN From_REventTime IS NULL THEN CONVERT(NVARCHAR(5), EventTimeAbnormal, 108) 
					ELSE CONVERT(NVARCHAR(5), From_REventTime, 108) + '-' +  CONVERT(NVARCHAR(5), To_REventTime, 108) + ' (' + CAST((DATEDIFF(Minute,From_REventTime,To_REventTime) + 1) AS VARCHAR(20)) + 'min)' END AS EventTime,
				QueryPlan  
		FROM DBA_AbnormalResultLog WITH(NOLOCK) 
			CROSS APPLY (SELECT top 1 value FROM string_split(@PropertyAbnormal , ',') WHERE AbnormalReason like  '%' + value + '%') b 
		WHERE LinkedServerName = @ServerName and EventTimeAbnormal BETWEEN @timefrom AND @timeto AND (SPName = @SPName or @SPName = '')
		ORDER BY EventDate,SPName

		RETURN
	END
	

	SET @currentDate = CAST(@timefrom AS DATE);

	WHILE @currentDate <= CAST(@timeto AS DATE)
	BEGIN
		INSERT INTO @tb_RangeDate (textDay, IsCheck)
		VALUES (FORMAT(@currentDate, 'yyyyMMdd'), 0);  -- Assuming IsCheck is initialized to 0

		SET @currentDate = DATEADD(DAY, 1, @currentDate);  -- Move to the next day
	END
	
	SET @currentDate = GETDATE();


	DECLARE @CounterList TABLE ([value] VARCHAR(20))
    INSERT INTO @CounterList
    VALUES('ExecutionCount'),('LogicalReads'),('CPUTime'),('ElapsedTime')

	DECLARE @StatisPrefix TABLE ([value] VARCHAR(20))
    INSERT INTO @StatisPrefix
    VALUES('Avg_per_minute')

	CREATE TABLE #CounterListCheck  ([value] VARCHAR(20))
    INSERT INTO #CounterListCheck
    SELECT b.value FROM string_split(@PropertyAbnormal,',') a INNER JOIN @CounterList b on a.value =b.value 

    IF @@ROWCOUNT = 0
        INSERT INTO #CounterListCheck SELECT value FROM @CounterList
        

    DROP TABLE IF EXISTS #Mon_SPPF_Report  
	CREATE TABLE #Mon_SPPF_Report (
          SPID INT, SPName VARCHAR(256), ServerName VARCHAR(256), DBName VARCHAR(256)
        , TimeRange INT, EventTime SMALLDATETIME
        , textDay  VARCHAR(10)
        , SPRowID INT
    )
	SELECT @sqlCMD = 'ALTER TABLE #Mon_SPPF_Report ' + CHAR(10) + 'ADD '
    SELECT @sqlCMD = @sqlCMD + ' [' + a.value + b.value + '] ' + 'DECIMAL(22,3)' + ','
    FROM @CounterList a CROSS JOIN @StatisPrefix b
    WHERE b.value IN ('','Avg_per_minute')

    SELECT @sqlCMD = SUBSTRING(@sqlCMD, 1, LEN(@sqlCMD) - 1)
    EXEC sp_executesql @sqlCMD

	SET @LinkServerName = @ServerName

	-- Get servername to select data on MonDBDW (Archive)
	SELECT @SrvName_Archive = ServerName 
	FROM dbo.Mon_Index_Report_Server WITH(NOLOCK) 
	WHERE LinkedServerName = @LinkServerName

	DECLARE @tb_ListServerName TABLE (ServerName VARCHAR(256))
	DECLARE @SPID VARCHAR(MAX)='' 
	DECLARE @SPIDs TABLE( SPID  INT, cnt INT)
    -- Get servername to select data (Active)
    SET @sqlCMD = 'SELECT SERVERNAME FROM OPENQUERY('+@LinkServerName+',''SELECT @@SERVERNAME AS SERVERNAME'')'
    INSERT INTO @tb_ListServerName
    EXEC sp_executesql @sqlcmd

    SELECT @SrvName_Active = ServerName 
	FROM @tb_ListServerName
    
	IF @LinkServerName IN ('DBSITE03KBT','DB061KBT','DB055KBT') 
	SET @SrvName_Active = @SrvName_Archive

	--IF @LinkServerName = 'DBSITE03KBT'
	--	SET @SrvName_Active = 'DBGRP03N1'
	 
	-- IF @LinkServerName = 'DB061KBT'
	--	SET @SrvName_Active = 'DB06,DB061'

	-- IF @LinkServerName = 'DB055KBT'
	--	SET @SrvName_Active = 'DB055,DB042'
	
	 
	IF @Paneltype = 2
	BEGIN
		INSERT INTO @SPIDs (SPID, cnt)
		SELECT  SPID, SUM(CASE WHEN From_REventTime IS NULL THEN 1 ELSE DATEDIFF(Minute,From_REventTime,To_REventTime) END)
		FROM dbo.DBA_AbnormalResultLog WITH(NOLOCK) 
			CROSS APPLY (SELECT top 1 value FROM string_split(@PropertyAbnormal , ',') WHERE AbnormalReason like  '%' + value + '%') b 
		WHERE LinkedServerName = @ServerName AND EventTimeAbnormal BETWEEN @timefrom AND @timeto
		GROUP BY SPID
		 
		;WITH cte_spid AS (
			SELECT SPID, cnt, ROW_NUMBER() OVER(ORDER BY cnt DESC) rowno FROM @SPIDs WHERE SPID is not null
		)
		SELECT @SPID = STRING_AGG(CAST(SPID AS VARCHAR(20)),',')
		FROM cte_spid
		WHERE rowno <= 15
	END

	WHILE (1 = 1)
    BEGIN
        SELECT TOP 1  @textDay =  textDay
        FROM @tb_RangeDate  WHERE IsCheck = 0

        IF @@ROWCOUNT = 0
            BREAK
		
		IF DATEDIFF(DAY,CAST(@textDay AS DATE),@currentDate) > 3 -- get archive  data from DBSPARE
		BEGIN
			SELECT @ServerName = ISNULL(@SrvName_Archive,@SrvName_Active) 
		END
		ELSE 
			SELECT @ServerName = @SrvName_Active
		
        SELECT @sqlCMD = 'INSERT INTO #Mon_SPPF_Report (SPID,SPRowID,SPName,ServerName,DBName,TimeRange,EventTime,textDay,' 
            + (SELECT STRING_AGG(a.value+b.value,',') FROM @CounterList a CROSS JOIN @StatisPrefix b WHERE b.VALUE IN ('Avg_per_minute') ) + ')' + CHAR(10) +
            + ' EXEC dbo.vnDBA_SP_GetAbnormalReport_xtest @LinkServerName = '''+@LinkServerName+''', @ServerName = '''+@ServerName+''', 
            @SPName = '''+@SPName+''', @SPIDs = '''+@SPID+''', @textDay = '''+@textDay+''' '
		
        EXEC sp_executesql @sqlcmd
		
        UPDATE @tb_RangeDate  SET IsCheck = 1 WHERE textDay = @textDay

    END

	SELECT @sqlCMD = 'DELETE #Mon_SPPF_Report WHERE ' + (SELECT STRING_AGG(a.value+b.value,'= 0 or ') FROM @CounterList a CROSS JOIN @StatisPrefix b WHERE b.VALUE IN ('Avg_per_minute') ) + '= 0'
    EXEC sp_executesql @sqlcmd


	IF @Paneltype = 1
	BEGIN
		SELECT @sqlcmd = '
		SELECT		[time]	=  DATEADD(WEEK, '+CAST(@weekdiff AS varchar(10))+',DATEADD(HOUR, '+CAST(-@server_zone as varchar(4))+',  EventTime))

				,	[metric]	=  l.value

				,	[value]		= CASE WHEN
				'+ (SELECT STRING_AGG(' l.value = '''+a.value+''' THEN '+a.value , ' WHEN')
				FROM @CounterList a
					CROSS JOIN @StatisPrefix b
				WHERE a.value IN (SELECT p.value FROM string_split(@PropertyAbnormal,',') p)
					AND b.value = 'Avg_per_minute' )
				+ ' END' +
			'
		FROM #CounterListCheck l
			CROSS APPLY (	SELECT  a.EventTime,
			'+ (SELECT STRING_AGG(a.value + b.value + ' AS ' + a.value , ',')
				FROM @CounterList a
					CROSS JOIN @StatisPrefix b
				WHERE a.value IN (SELECT p.value FROM string_split(@PropertyAbnormal,',') p)
					AND b.value = 'Avg_per_minute' )
			+
			' FROM #Mon_SPPF_Report a  
						) t 
		WHERE EventTime BETWEEN '''+convert(VARCHAR(20), @timefrom, 20)+''' AND '''+convert(VARCHAR(20), @timeto, 20)+'''
		ORDER BY [time],[metric]; 
		'
		
	END
	ELSE 
	BEGIN


		SELECT @sqlcmd = '
		SELECT		[time]	=  DATEADD(WEEK, '+CAST(@weekdiff AS varchar(10))+',DATEADD(HOUR, '+CAST(-@server_zone as varchar(4))+',  DATEADD(MINUTE, DATEDIFF(MINUTE, 0, EventTime) / 5 * 5, 0))) 

				,	[metric]	=  t.SPName + '' ('' + l.value + '')''

				,	[value]		= MAX(CASE WHEN
				'+ (SELECT STRING_AGG(' l.value = '''+a.value+''' THEN '+a.value , ' WHEN')
				FROM @CounterList a
					CROSS JOIN @StatisPrefix b
				WHERE a.value IN (SELECT p.value FROM string_split(@PropertyAbnormal,',') p)
					AND b.value = 'Avg_per_minute' )
				+ ' END)' +
			'
		FROM #CounterListCheck l
			CROSS APPLY (	SELECT  a.SPName,a.EventTime,
			'+ (SELECT STRING_AGG(a.value + b.value + ' AS ' + a.value , ',')
				FROM @CounterList a
					CROSS JOIN @StatisPrefix b
				WHERE a.value IN (SELECT p.value FROM string_split(@PropertyAbnormal,',') p)
					AND b.value = 'Avg_per_minute' )
			+
			' FROM #Mon_SPPF_Report a  
						) t 
		WHERE EventTime BETWEEN '''+convert(VARCHAR(20), @timefrom, 20)+''' AND '''+convert(VARCHAR(20), @timeto, 20)+'''
		GROUP BY DATEADD(MINUTE, DATEDIFF(MINUTE, 0, EventTime) / 5 * 5, 0), t.SPName, l.value
		ORDER BY [time],[metric]; 
		'

	END
	
	EXEC sp_executesql @sqlcmd
	--SELECT @sqlCMD,convert(VARCHAR(20), @timefrom, 20),convert(VARCHAR(20), @timeto, 20),@SPID
    DROP TABLE IF EXISTS #Mon_SPPF_Report  
    DROP TABLE IF EXISTS #CounterListCheck  

	

END

