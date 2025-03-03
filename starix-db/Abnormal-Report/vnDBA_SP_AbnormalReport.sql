USE [StarixDB]
GO
ALTER PROCEDURE [dbo].[vnDBA_SP_AbnormalReport]
   @ServerName VARCHAR(1000)='' ,
    @DBName VARCHAR(1000)='' ,
    @SPName VARCHAR(256)='' ,
    @CheckDate DATE ='' ,
    @NumberDateCheck INT  = 1,      -- Define Minimum,Maximum Range
    @CheckTime_Day VARCHAR(1000) = NULL,  -- '20240925', -- Define Minimum,Maximum Range
    @ThresholdZCore FLOAT = 3,
    @AbnormalPoint INT = 3,
    @Debug BIT = 0,
    @PropertyAbnormal VARCHAR(1000) = ''
AS

/*
    Creator:    20241212@Evan
    Task:       Report Abnormal Stored Procedure all server
    Database:   DBDWCSS.StarixDB
        - 20241212@Evan: Initial 
        
    Param's Explanation:   
        @ServerName: 
                    '': All server
                    'ServerName': The name of the server to connect to.
        @DBName:    
                    '': All database
                    'DBName': The name of the database to analyze.
        @SPName: 
                    '': All stored procedure
                    'SPName': The name of the stored procedure to filter results.
        @CheckDate: The date for which to check the stored procedure performance.
        @NumberDateCheck: The number of days to check for performance anomalies.
        @CheckTime_Day: Specific days to check, formatted as 'YYYYMMDD'.
        @ThresholdZCore: The Z-score threshold for identifying anomalies.
        @Debug: A flag to enable or disable debug messages.
        @PropertyAbnormal: ExecutionCount|LogicalReads|CPUTime|ElapsedTime
*/



BEGIN

    SET NOCOUNT ON;

    DECLARE     @Filter_Todate SMALLDATETIME 
            ,   @Filter_Fromdate SMALLDATETIME

    -- Set date range for checking
    DECLARE @textDayFilter VARCHAR(8)
    SELECT @textDayFilter = CONVERT(VARCHAR(8),@CheckDate,112)

    SELECT @Filter_Fromdate = @CheckDate
    SELECT @Filter_Todate = CAST(@CheckDate AS SMALLDATETIME) + '23:59:00';
  
    -- Temporary tables for server names and linked servers
    DECLARE @tb_ListServerName TABLE (ServerName VARCHAR(256))
    DECLARE @tb_ListLinkedServer TABLE (LinkedServerName VARCHAR(256) , IsCheck BIT DEFAULT(0), ErrMsg  VARCHAR(1000), sqlcmd varchar(max))
    
    -- Drop temporary tables if they exist
    DROP TABLE IF EXISTS #Mon_SPPF_Report  
    DROP TABLE IF EXISTS #Mon_SPPF_Report_Stats
    DROP TABLE IF EXISTS #ListAbnormal_org 
    DROP TABLE IF EXISTS #ListAbnormal_Result
    DROP TABLE IF EXISTS #QueryStoreOnServer
    DROP TABLE IF EXISTS #AbnormaLoop

    CREATE TABLE #AbnormaLoop  (SPID INT, SPRowID INT, fromdate SMALLDATETIME, todate SMALLDATETIME, Cntnum INT)

    DECLARE @CurrDate DATETIME = GETDATE()
    DECLARE @Yesterdate SMALLDATETIME = DATEADD(DAY,-1,@CurrDate), @Msg VARCHAR (500)
            ,@sqlCMD NVARCHAR(MAX), @textDay VARCHAR(8) , @LinkServerName VARCHAR(256) , @SrvName VARCHAR(256) , @EventDate SMALLDATETIME
            ,@Json VARCHAR(MAX),@_DBName VARCHAR(256)

    DECLARE @CounterList TABLE ([value] VARCHAR(20),[Threshold] INT)
    INSERT INTO @CounterList
    VALUES('ExecutionCount',100),('LogicalReads',10000),('CPUTime',5000),('ElapsedTime',0)
   
    DECLARE @CounterListCheck TABLE ([value] VARCHAR(20),[Threshold] INT)
    INSERT INTO @CounterListCheck
    SELECT b.value,b.Threshold FROM string_split(@PropertyAbnormal,',') a INNER JOIN @CounterList b on a.value =b.value 

    IF @@ROWCOUNT = 0
        INSERT INTO @CounterListCheck SELECT value,Threshold FROM @CounterList
        
    DECLARE @StatisPrefix TABLE ([value] VARCHAR(20))
    INSERT INTO @StatisPrefix
    VALUES('Min'),('Max'),('Avg'),('Avg_per_minute'),('Stdev'),('ZCore'),('IsAbnormal'),('Threshold')
  
    DECLARE @Rules TABLE ([RuleNo] varchar(100), [Rule] varchar(100), command varchar(1000))
    INSERT INTO @Rules ([RuleNo],[Rule],command)
    VALUES
    ('IsAbnormal','Determine anomalies based on thresholds',
        'CASE WHEN ($Avg_per_minute -  $Avg) > ' + CAST(@ThresholdZCore AS VARCHAR(10)) + ' * $Stdev AND $Avg_per_minute > $Threshold AND  $Avg > $Threshold AND  $Stdev > 0 THEN 1 ELSE 0 END AS $IsAbnormal') 
    ,('zcore','Calculate Z-scores',
        'CASE WHEN $Stdev = 0 THEN 0  ELSE CAST(($Avg_per_minute - $Avg) / $Stdev AS DECIMAL(22,3)) END AS $ZCore') 
    ,
    ('Threshold','Calculate normal value',
        '(' + CAST(@ThresholdZCore AS VARCHAR(10)) + ' * $Stdev) + $Avg as $Normal') 

    --SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('Threshold')
    --SELECT STRING_AGG(a.value+b.value,',') FROM @CounterList a CROSS JOIN @StatisPrefix b where a.value IN ('ExecutionCount') AND b.value <> '' --ExecutionCountAvg_per_minute,LogicalReadsAvg_per_minute,CPUTimeAvg_per_minute,ElapsedTimeAvg_per_minute
    --SELECT STRING_AGG(b.value+'('+a.value +')',',') FROM @CounterList a CROSS JOIN @StatisPrefix b where b.value IN ('Stdev') 
    --SELECT b.value,STRING_AGG(a.value,',') FROM @CounterList a CROSS JOIN @StatisPrefix b where b.value IN ('Stdev','Avg')  
    --group by b.value
    -- (3 * StdDev_ExecutionCount) + Avg_ExecutionCount as ExecCount_Normal

    -- Get info Mon_SPPF_Report
    CREATE TABLE #Mon_SPPF_Report (
          SPID INT, SPName VARCHAR(256), ServerName VARCHAR(256), DBName VARCHAR(256)
        , TimeRange INT, EventTime SMALLDATETIME, textDay  VARCHAR(10)
        , HourOfDay INT
        , SPRowID INT
    )
    CREATE CLUSTERED INDEX [IX_tmpMonReport_SPID] ON #Mon_SPPF_Report (SPID, textDay)

    -- Create temp table
    CREATE TABLE #Mon_SPPF_Report_Stats (
          SPID INT
    )
    CREATE TABLE #ListAbnormal_org  (
          SPID INT, SPName VARCHAR(256), ServerName VARCHAR(256), DBName VARCHAR(256)
        , EventDate DATE, EventTime SMALLDATETIME
        , AbnormalReason VARCHAR(MAX)
        , AbnormalReason1 VARCHAR(MAX)
        , NormalValue VARCHAR(MAX)
        , SPRowID INT
        , RowNo INT
    )
    CREATE TABLE #ListAbnormal_Result  (
         SPID INT, SPName VARCHAR(256), ServerName VARCHAR(256), LinkedServerName VARCHAR(256), DBName VARCHAR(256)
        , EventDate DATE, EventTime SMALLDATETIME, FromEventTime SMALLDATETIME, ToEventTime SMALLDATETIME 
        , AbnormalReason VARCHAR(MAX)
        , AbnormalReason1 VARCHAR(MAX)
        , NormalValue VARCHAR(MAX)
        , ExecPlanCnt SMALLINT, IsAbnormalRecurrent BIT,QueryPlan VARCHAR(MAX), isExclude BIT , isChecked BIT DEFAULT(0)
        , SPRowID INT
    )

    CREATE TABLE #QueryStoreOnServer  (
        ServerName VARCHAR(256), LinkedServerName VARCHAR(256)
        , DBName VARCHAR(256), QueryStoreState VARCHAR(8)
        , isChecked BIT DEFAULT ((0))
    )
    
    DECLARE @tb_DataQueryStore TABLE (
       EventTime SMALLDATETIME, SPName VARCHAR(256),plan_cnt SMALLINT, rownum INT, QueryIDs VARCHAR(MAX)
    )
    -- Add column
    SELECT @sqlCMD = 'ALTER TABLE #Mon_SPPF_Report ' + CHAR(10) + 'ADD '
    SELECT @sqlCMD = @sqlCMD + ' [' + a.value + b.value + '] ' + 'DECIMAL(22,3)' + ','
    FROM @CounterList a CROSS JOIN @StatisPrefix b
    WHERE b.value IN ('','Avg_per_minute')

    SELECT @sqlCMD = SUBSTRING(@sqlCMD, 1, LEN(@sqlCMD) - 1)
    EXEC sp_executesql @sqlCMD
    
    SELECT @sqlCMD = 'ALTER TABLE #Mon_SPPF_Report_Stats ' + CHAR(10) + 'ADD '
    SELECT @sqlCMD = @sqlCMD + ' [' + a.value + b.value + '] ' + 'DECIMAL(22,3)' + ',' 
    FROM @CounterListCheck a CROSS JOIN @StatisPrefix b
    WHERE b.value IN ('Stdev','Avg','Threshold')

    SELECT @sqlCMD = SUBSTRING(@sqlCMD, 1, LEN(@sqlCMD) - 1)
    EXEC sp_executesql @sqlCMD
    SELECT @sqlCMD = 'ALTER TABLE #ListAbnormal_org ' + CHAR(10) + 'ADD '
    SELECT @sqlCMD = @sqlCMD + ' [' + a.value + b.value + '] ' + 'DECIMAL(22,3)' + ',' 
    FROM @CounterListCheck a CROSS JOIN @StatisPrefix b
    WHERE b.value IN ('ZCore')
    
    SELECT @sqlCMD = SUBSTRING(@sqlCMD, 1, LEN(@sqlCMD) - 1)
    EXEC sp_executesql @sqlCMD
    SET @sqlCMD =  REPLACE(@sqlCMD,'#ListAbnormal_org','#ListAbnormal_Result')
    EXEC sp_executesql @sqlCMD

    SELECT @sqlCMD = 'ALTER TABLE #ListAbnormal_org ' + CHAR(10) + 'ADD '
    SELECT @sqlCMD = @sqlCMD + ' [' + a.value + b.value + '] ' + 'DECIMAL(22,3)' + ',' 
    FROM @CounterListCheck a CROSS JOIN @StatisPrefix b
    WHERE b.value IN ('Threshold')

    SELECT @sqlCMD = SUBSTRING(@sqlCMD, 1, LEN(@sqlCMD) - 1)
    EXEC sp_executesql @sqlCMD
    SET @sqlCMD =  REPLACE(@sqlCMD,'#ListAbnormal_org','#ListAbnormal_Result')
    EXEC sp_executesql @sqlCMD
    
    --
    SELECT @sqlCMD = 'ALTER TABLE #ListAbnormal_org ' + CHAR(10) + 'ADD '
    SELECT @sqlCMD = @sqlCMD + ' [' + a.value + b.value + '] ' + 'DECIMAL(22,3)' + ',' 
    FROM @CounterListCheck a CROSS JOIN @StatisPrefix b
    WHERE b.value IN ('Avg_per_minute')

    SELECT @sqlCMD = SUBSTRING(@sqlCMD, 1, LEN(@sqlCMD) - 1)
    EXEC sp_executesql @sqlCMD
    SET @sqlCMD =  REPLACE(@sqlCMD,'#ListAbnormal_org','#ListAbnormal_Result')
    EXEC sp_executesql @sqlCMD

   
     
    -- ===========================

    DECLARE @tb_SendMail TABLE (LinkServerName VARCHAR(1000), Mail_body VARCHAR(MAX))
    DECLARE @isCheck_QUERYSTORE BIT = 1; 

    -- List Scan date 
    DECLARE @tb_RangeDate TABLE (textDay VARCHAR(8), IsCheck BIT)
    DECLARE @tb_RangeDate1 TABLE (textDay VARCHAR(8), IsCheck BIT)

    DECLARE @i INT = @NumberDateCheck

    -- Get range time to calculate Standard deviation (Stdev)
    IF EXISTS (SELECT 1 FROM STRING_SPLIT (@CheckTime_Day,',') WHERE VALUE <> '')
    BEGIN
        INSERT INTO @tb_RangeDate  (textDay,IsCheck)
        SELECT VALUE, 0 FROM STRING_SPLIT (@CheckTime_Day,',') WHERE VALUE <> ''

        INSERT INTO @tb_RangeDate  (textDay,IsCheck)
        SELECT CONVERT(VARCHAR(8), @CheckDate, 112),0
    END
    ELSE
    BEGIN
        WHILE (@i >= 0) 
        BEGIN
            INSERT INTO @tb_RangeDate  (textDay,IsCheck)
            SELECT CONVERT(VARCHAR(8), DATEADD(DAY, -7 * @i, @CheckDate), 112), 0

            SET @i = @i - 1
        END

    END
    
    INSERT INTO @tb_ListLinkedServer (LinkedServerName)
    SELECT DISTINCT linkedServer
    FROM vnDBA_Perf_Servers c WITH (NOLOCK) 
    WHERE linkedServer IS NOT NULL 
        AND isMonitored = 1 
        AND (@ServerName = '' OR c.linkedServer IN (SELECT value FROM string_split (@ServerName,',')) OR c.linkedServer IN (SELECT value+'KBT' FROM string_split (@ServerName,',')))
        AND linkedServer NOT IN (
        'DBDIST01CKBT','DBDIST02CKBT','DBDWCSSKBT',
        'DBDIST03KBT','DBTP02C_INST2','IHRDISTC1KBT'
        ,'DBDW2KBT','DBODDSC1KBT','DBODDSC2KBT')
    /*
        Could not find stored procedure 'MonDB.dbo.vnDBA_sp_GetPlanCount'.
            DBDW2KBT, DBODDSC1KBT, DBODDSC2KBT
    */
    
    IF @Debug = 1   
    BEGIN
        SET @Msg = CONCAT(@@SERVERNAME, '_',db_name(),'_',OBJECT_NAME(@@PROCID), ' - Processing abnormal check on: ', FORMAT(@CurrDate, 'yyyy-MM-dd HH:mm:ss'));
        RAISERROR (@Msg, 0, 1) WITH NOWAIT;

        SET @Msg = 'Get data Mon_SPPF_Report in ( ' + (SELECT STRING_AGG(textDay, ',') FROM @tb_RangeDate) +' )'
        RAISERROR (@Msg , 0, 1) WITH NOWAIT

  SET @Msg = 'Check time: ' + IIF(@textDayFilter IS NULL,'all range time',@textDayFilter)
        RAISERROR (@Msg , 0, 1) WITH NOWAIT

        SET @Msg = 'Server checklist: ' + @ServerName
        RAISERROR (@Msg , 0, 1) WITH NOWAIT

    END
    
    -- Loop through each linked server to gather information
    WHILE (1 = 1)
    BEGIN TRY
       
        DELETE FROM @tb_ListServerName

        SELECT TOP 1 @LinkServerName = LinkedServerName
        FROM @tb_ListLinkedServer WHERE IsCheck = 0 

        IF  @@ROWCOUNT = 0
            BREAK;

        -- Get servername to select data on MonDBDW (Archive)
        SELECT @SrvName = ServerName 
        FROM dbo.Mon_Index_Report_Server WITH(NOLOCK) 
        WHERE LinkedServerName = @LinkServerName

        -- Get servername to select data (Active)
        SET @sqlCMD = 'SELECT SERVERNAME FROM OPENQUERY('+QUOTENAME(@LinkServerName)+',''SELECT @@SERVERNAME AS SERVERNAME'')'
        INSERT INTO @tb_ListServerName
        EXEC sp_executesql @sqlcmd

        IF ISNULL(@SrvName , '') = '' 
        BEGIN
            SELECT @SrvName = ServerName FROM @tb_ListServerName
        END
        ELSE 
            SELECT @SrvName = @SrvName + ',' + ServerName FROM @tb_ListServerName
        
        IF @Debug = 1   
        BEGIN
            SET @Msg = CHAR(9) + 'Start on: ' + @LinkServerName
            RAISERROR (@Msg , 0, 1) WITH NOWAIT
        END

        -- Delete/Reset temp table
        TRUNCATE TABLE #Mon_SPPF_Report
        TRUNCATE TABLE #Mon_SPPF_Report_Stats
        TRUNCATE TABLE #ListAbnormal_org

        -- Reset @tb_RangeDate for next server
        UPDATE @tb_RangeDate  SET IsCheck = 0

        DELETE FROM @tb_RangeDate1

        DECLARE @SPID_table TABLE (SPID INT);
        DECLARE @SPIDs VARCHAR(MAX)  = ''

        -- Loop through RangeDate
        SET @Msg = 'Get data MonReport'
        IF @Debug = 1   
            RAISERROR (@Msg , 0, 1) WITH NOWAIT
        
        IF (SELECT COUNT(1) FROM string_split(@SPName,',')) > 1
        BEGIN
            SELECT @sqlcmd = 'SELECT * FROM OPENQUERY('+QUOTENAME(@LinkServerName)+',''select SPID from MonDB.dbo.Mon_SPPF_List WITH (NOLOCK) WHERE SPName in (SELECT value FROM string_split('''''+@SPName+''''','''','''')) '')'
            INSERT INTO @SPID_table (SPID)
            EXEC sp_executesql @sqlcmd

            SELECT @SPIDs = STRING_AGG(SPID,',') FROM @SPID_table
            SET @SPName  = ''
        END

        WHILE (1 = 1)
        BEGIN
            SELECT TOP 1  @textDay =  textDay
            FROM @tb_RangeDate  WHERE IsCheck = 0
            IF @@ROWCOUNT = 0
                BREAK
            
            SELECT @sqlCMD = 'INSERT INTO #Mon_SPPF_Report (SPID,SPRowID,SPName,ServerName,DBName,TimeRange,EventTime,HourOfDay,textDay,' 
                + (SELECT STRING_AGG(a.value+b.value,',') FROM @CounterList a CROSS JOIN @StatisPrefix b WHERE b.VALUE IN ('Avg_per_minute') ) + ')' + CHAR(10) +
                + ' EXEC dbo.vnDBA_SP_GetAbnormalReport @LinkServerName = '''+@LinkServerName+''', @ServerName = '''+@SrvName+''', 
                @DBName = '''+@DBName+''', @SPName = '''+@SPName+''', @SPIDs = '''+@SPIDs+''', @textDay = '''+@textDay+''' '

            EXEC sp_executesql @sqlcmd

            UPDATE @tb_RangeDate  SET IsCheck = 1 WHERE textDay = @textDay

        END
        
        -- Check list sp has no data for the selected date range then retrieves data from the previous date
        -- DECLARE @MissMonReport TABLE (SPID INT, MissDateCount INT);
        --;WITH cte_grouptextday AS (
        --    SELECT SPID,textDay
        --    FROM #Mon_SPPF_Report
        --    GROUP BY SPID,textDay
        --)
        --INSERT INTO @MissMonReport (SPID, MissDateCount)
        --SELECT SPID,MissDateCount
        --FROM
        --(
        --    SELECT a.SPID, @NumberDateCheck - SUM(IIF(b.SPID IS NULL,0,1)) AS MissDateCount
        --    FROM  cte_grouptextday a 
        --        LEFT JOIN cte_grouptextday b on a.SPID = b.SPID AND a.textDay = b.textDay AND b.textDay <> @textDayFilter
        --    GROUP BY a.SPID
        --) a
        --WHERE MissDateCount = @NumberDateCheck  
        
        --IF EXISTS ( SELECT TOP 1 1 FROM @MissMonReport)
        --BEGIN
        --    SET @Msg = 'Retrieves data from the previous date'
        --    IF @Debug = 1   
        --        RAISERROR (@Msg , 0, 1) WITH NOWAIT

        --    SELECT @SPIDs = STRING_AGG(CAST(SPID AS VARCHAR(10)) , ',') FROM @MissMonReport
        
        --    SET @i = @NumberDateCheck 
        --    WHILE (@i > 0) 
        --    BEGIN 
        --        INSERT INTO @tb_RangeDate1  (textDay,IsCheck)
        --        SELECT CONVERT(VARCHAR(8), DATEADD(DAY, (-7 * @i) - (@NumberDateCheck * 7)  , @CheckDate ), 112), 0

        --        SET @i = @i - 1
        --    END

        --     -- Loop through RangeDate1
        --    SET @Msg = ''
        --    IF @Debug = 1   
        --        RAISERROR (@Msg , 0, 1) WITH NOWAIT

        --    WHILE (1 = 1)
        --    BEGIN
        --        SELECT TOP 1  @textDay =  textDay
        --        FROM @tb_RangeDate1  WHERE IsCheck = 0
        --        IF @@ROWCOUNT = 0
        --            BREAK

        --        SELECT @sqlCMD = 'INSERT INTO #Mon_SPPF_Report (SPID,SPRowID,SPName,ServerName,DBName,TimeRange,EventTime,textDay,' 
        --        + (SELECT STRING_AGG(a.value+b.value,',') FROM @CounterList a CROSS JOIN @StatisPrefix b WHERE b.VALUE IN ('Avg_per_minute') ) + ')' + CHAR(10) +
        --        + ' EXEC dbo.vnDBA_SP_GetAbnormalReport @LinkServerName = '''+@LinkServerName+''', @ServerName = '''+@SrvName+''', 
        --        @DBName = '''+@DBName+''', @SPName = '''+@SPName+''', @SPIDs = '''+@SPIDs+''', @textDay = '''+@textDay+''' '
                    
        --        EXEC sp_executesql @sqlcmd

        --        UPDATE @tb_RangeDate1  SET IsCheck = 1 WHERE textDay = @textDay

        --    END
        --END
        
        -- Filter out stored procedures that start with 'sp_MS' to exclude system procedures
        DELETE #Mon_SPPF_Report 
        WHERE ( SPName LIKE 'sp[_]%' OR  SPName LIKE 'vndba[_]%' OR   SPName LIKE '%Repl%' OR   SPName LIKE 'SSB[_]%' OR   SPName LIKE 'f[_]%' ) 
        
        -- Remove SPs that are executed non-consecutive
        ;WITH cte_AvgExecPerHour AS (
            SELECT SPID, AVG(ExecutionCountPerHour) avg_ExecutionCountPerHour, EventDate
            FROM (
                SELECT SPID,SUM(ISNULL(TimeRange,1)) ExecutionCountPerHour, DATEPART(DAY,EventTime) as EventDate
                FROM #Mon_SPPF_Report --WHERE EventTime >= @Yesterdate and EventTime < @CurrDate
                GROUP BY SPID, DATEPART(HOUR,EventTime), DATEPART(DAY,EventTime)
            )   a
            GROUP BY SPID,EventDate
        )
        DELETE 
        FROM #Mon_SPPF_Report 
        WHERE SPID IN (SELECT a.SPID FROM cte_AvgExecPerHour a WHERE a.avg_ExecutionCountPerHour < 10)


        SET @Msg = 'Get Statistics from MonReport'
        IF @Debug = 1   
            RAISERROR (@Msg , 0, 1) WITH NOWAIT


        SELECT @sqlCMD = '
            ;WITH cte_avgStdev AS
        (
            SELECT SPID,
                '+ (SELECT STRING_AGG('AVG(' + a.value+b.value +') AS '+ a.value + 'Avg',',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('Avg_per_minute') ) +',
                '+ (SELECT STRING_AGG('Stdev(' + a.value+b.value +') AS '+ a.value + 'Stdev',',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('Avg_per_minute') ) +'
            FROM #Mon_SPPF_Report
            WHERE textDay <> '''+@textDayFilter+''' -- Exclude check date
            GROUP BY SPID
        )
        INSERT INTO #Mon_SPPF_Report_Stats (SPID,
        '+(SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('Avg'))+', 
        '+(SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('Stdev') )+', 
        '+(SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('Threshold') )+' 
            )
        SELECT a.SPID ,'+(SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('Avg') )+' , 
            '+(SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('Stdev') )+' ,
            '+
            CONCAT_WS(',',NULL,((SELECT REPLACE(a.command,'$',b.value) FROM @Rules a CROSS JOIN @CounterListCheck b WHERE a.RuleNo='Threshold' AND b.value = 'ExecutionCount' )+ CHAR(10))
                ,((SELECT REPLACE(a.command,'$',b.value) FROM @Rules a CROSS JOIN @CounterListCheck b WHERE a.RuleNo='Threshold' AND b.value = 'LogicalReads' )+ CHAR(10))
                    ,((SELECT REPLACE(a.command,'$',b.value) FROM @Rules a CROSS JOIN @CounterListCheck b WHERE a.RuleNo='Threshold' AND b.value = 'CPUTime' )+ CHAR(10))
                ,((SELECT REPLACE(a.command,'$',b.value) FROM @Rules a CROSS JOIN @CounterListCheck b WHERE a.RuleNo='Threshold' AND b.value = 'ElapsedTime' )+ CHAR(10))
                ) 
            + ' ,
        FROM cte_avgStdev a
        '
        EXEC sp_executesql @sqlcmd
        
        SET @Msg = 'code get list abnormal'
        IF @Debug = 1   
            RAISERROR (@Msg , 0, 1) WITH NOWAIT

        SELECT @sqlCMD =  ';WITH cte_result AS
        (
            SELECT 
                s.SPID,
                s.SPRowID,
                SPName,
                ServerName,
                DBName,
                CAST(EventTime AS DATE) AS EventDate,
                EventTime,
   
                ' + (SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('Avg_per_minute') ) +',
                ' + (SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('Avg') ) +',
                ' + (SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('Stdev') ) +',
                ' + (SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('ZCore') ) +',
                ' + (SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('Threshold') ) +',
               
                -- Concatenate abnormal reasons based on conditions
                 CONCAT_WS('','',null, 
                ' + (SELECT STRING_AGG('IIF(' + a.value +  b.value +' = 1, '''+a.value+''', NULL)',',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('IsAbnormal') )  +'
                ) AS AbnormalReason1,
                CONCAT_WS('','',null, 
                ' + (SELECT STRING_AGG('IIF(' + a.value +  b.value +' = 1, '''+a.value+''+ '( ZCore = ''+ CAST('+  a.value + c.value +' AS VARCHAR(50)) + '')'', NULL)',',') 
                                            FROM @CounterListCheck a CROSS APPLY (SELECT * FROM @StatisPrefix b  WHERE b.value IN ('IsAbnormal')) b
                                                                    CROSS APPLY (SELECT * FROM @StatisPrefix b  WHERE b.value IN ('ZCore')) c
                                            GROUP BY b.value )  +'
                ) AS AbnormalReason,
                CONCAT_WS('','',null, 
                ' + (SELECT STRING_AGG('IIF(' + a.value +  b.value +' = 1, '''+a.value+''+ '(''+ CAST('+  a.value + d.value +' AS VARCHAR(50)) + '')'', NULL)',',') 
                                            FROM @CounterListCheck a CROSS APPLY (SELECT * FROM @StatisPrefix b  WHERE b.value IN ('IsAbnormal')) b
                                                                    CROSS APPLY (SELECT * FROM @StatisPrefix b  WHERE b.value IN ('Avg_per_minute')) d
                                            GROUP BY b.value )  +'
                ) AS NormalValue,
                '+
                '
                -- Row number for ranking
                ROW_NUMBER() OVER (
                    PARTITION BY s.SPID, CAST(EventTime AS DATE), 
                                CONCAT_WS('','', null,
                        ' + (SELECT STRING_AGG('IIF('  + a.value +  b.value + ' = 1, '''+a.value+''', NULL)',',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('IsAbnormal') ) +'
                    )
                    ORDER BY (
                    ' + (SELECT STRING_AGG(a.value+b.value,' + ') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('ZCore') ) + '
                    ) DESC
                ) AS RowNo

            FROM 
                #Mon_SPPF_Report s
            INNER JOIN 
                #Mon_SPPF_Report_Stats t ON s.SPID = t.SPID
            CROSS APPLY (
                SELECT  
                    -- Determine anomalies based on thresholds
                        '+ 
                    CONCAT_WS(',',((SELECT REPLACE(REPLACE(a.command,'$Threshold',b.Threshold),'$',b.value) FROM @Rules a CROSS JOIN @CounterListCheck b WHERE a.RuleNo='IsAbnormal' AND b.value = 'ExecutionCount' )+ CHAR(10)),
                         ((SELECT REPLACE(REPLACE(a.command,'$Threshold',b.Threshold),'$',b.value) FROM @Rules a CROSS JOIN @CounterListCheck b WHERE a.RuleNo='IsAbnormal' AND b.value = 'CPUTime' )+ CHAR(10))
                        ,((SELECT REPLACE(REPLACE(a.command,'$Threshold',b.Threshold),'$',b.value) FROM @Rules a CROSS JOIN @CounterListCheck b WHERE a.RuleNo='IsAbnormal' AND b.value = 'ElapsedTime' )+ CHAR(10))
                        ,((SELECT REPLACE(REPLACE(a.command,'$Threshold',b.Threshold),'$',b.value) FROM @Rules a CROSS JOIN @CounterListCheck b WHERE a.RuleNo='IsAbnormal' AND b.value = 'LogicalReads' )+ CHAR(10))
                        ) +','+
                    CONCAT_WS(',',NULL,((SELECT REPLACE(REPLACE(a.command,'$Threshold',b.Threshold),'$',b.value) FROM @Rules a CROSS JOIN @CounterListCheck b WHERE a.RuleNo='zcore' AND b.value = 'ExecutionCount' )+ CHAR(10)),
                         ((SELECT REPLACE(REPLACE(a.command,'$Threshold',b.Threshold),'$',b.value) FROM @Rules a CROSS JOIN @CounterListCheck b WHERE a.RuleNo='zcore' AND b.value = 'CPUTime' )+ CHAR(10))
                        ,((SELECT REPLACE(REPLACE(a.command,'$Threshold',b.Threshold),'$',b.value) FROM @Rules a CROSS JOIN @CounterListCheck b WHERE a.RuleNo='zcore' AND b.value = 'ElapsedTime' )+ CHAR(10))
                        ,((SELECT REPLACE(REPLACE(a.command,'$Threshold',b.Threshold),'$',b.value) FROM @Rules a CROSS JOIN @CounterListCheck b WHERE a.RuleNo='zcore' AND b.value = 'LogicalReads' )+ CHAR(10))
                        ) +
            ') b
            WHERE 
                textDay  = '''+@textDayFilter+''' 
                AND 
                (' + (SELECT STRING_AGG(a.value+b.value + ' = 1',' OR ') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('IsAbnormal') ) + ')' + CHAR(10) +'
                )

        INSERT INTO #ListAbnormal_org (SPID, SPRowID , SPName , ServerName  , DBName , EventDate, EventTime , 
            ' + (SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('Avg_per_minute') ) + ',' + CHAR(10) +'
                ' + (SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('ZCore') ) + ',' + CHAR(10) +'
                ' + (SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('Threshold') ) + ',' + CHAR(10) +'
         AbnormalReason,AbnormalReason1, NormalValue, RowNo) 
        SELECT 
            SPID, SPRowID , SPName , ServerName  , DBName , EventDate, EventTime , 
                ' + (SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('Avg_per_minute') ) + ',' + CHAR(10) +'
                ' + (SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('ZCore') ) + ',' + CHAR(10) +'
                ' + (SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('Threshold') ) + ',' + CHAR(10) +'
            AbnormalReason,AbnormalReason1, NormalValue, RowNo
        FROM cte_result
        '
        EXEC sp_executesql @sqlcmd
        
        SET @Msg = 'Get the abnormal value at the highest point'
        IF @Debug = 1   
            RAISERROR (@Msg , 0, 1) WITH NOWAIT

        TRUNCATE TABLE #AbnormaLoop

        -- Calculate the zCore value around the anomaly point; if it below the threshold, exclude it.
        ;WITH cte_AbnormalRecurrent  AS
        (
            SELECT a.SPID, a.SPRowID, a.EventTime, 1 as lvl
            FROM #ListAbnormal_org a 
            UNION ALL
            SELECT  b.SPID, b.SPRowID, b.EventTime, a.lvl + 1 as lvl 
            FROM cte_AbnormalRecurrent a
                INNER JOIN #ListAbnormal_org b ON a.SPID = b.SPID AND a.SPRowID + 1 = b.SPRowID
        )
        INSERT INTO #AbnormaLoop (SPID,SPRowID,fromdate,todate,Cntnum)
        SELECT SPID, SPRowID,MIN(EventTime) EventTime_min, MAX(EventTime) EventTime_max, COUNT(1) AS cnt_Abnormal
        FROM (
            SELECT  SPID, 
                    SPRowID - COUNT(1) + 1 AS SPRowID , 
                    EventTime
            FROM cte_AbnormalRecurrent 
            GROUP BY SPID, SPRowID, EventTime
        ) a
        GROUP BY SPID, SPRowID
        HAVING COUNT(1) >= @AbnormalPoint -- threshold = 3
        OPTION (maxrecursion 0) 

         -- Get final result 
        SET @Msg = 'Get final result'
        IF @Debug = 1   
            RAISERROR (@Msg , 0, 1) WITH NOWAIT
            
        SELECT @sqlCMD = '
        INSERT INTO #ListAbnormal_Result (SPID , SPName , ServerName , LinkedServerName , DBName , EventTime , EventDate ,
        '
        + (SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('Avg_per_minute') ) + ','
        + (SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('ZCore') ) + ','
        + (SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('Threshold') ) + ','
        + 'IsAbnormalRecurrent, FromEventTime, ToEventTime, SPRowID, AbnormalReason,AbnormalReason1, NormalValue, QueryPlan, isExclude) ' + CHAR(10) +
      
        + 'SELECT a.SPID , SPName , ServerName , '''+@LinkServerName+''' , DBName , EventTime , EventDate ,'
        + (SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('Avg_per_minute') ) + ','
        + (SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('ZCore') ) + ','
        + (SELECT STRING_AGG(a.value+b.value,',') FROM @CounterListCheck a CROSS JOIN @StatisPrefix b where b.value IN ('Threshold') ) + ','
        + 'IIF(b.SPID IS NULL,0,1) AS IsAbnormalRecurrent , b.fromdate AS FromEventTime, b.todate AS ToEventTime
            , a.SPRowID,a.AbnormalReason,a.AbnormalReason1,a.NormalValue, 
            '''',IIF (IIF(b.SPID IS NULL,0,1) = 1,0,1) AS isExclude
            FROM #ListAbnormal_org  a 
                LEFT JOIN #AbnormaLoop b ON a.SPID = b.SPID AND a.SPRowID = b.SPRowID
            WHERE b.SPID IS NOT NULL OR a.RowNo = 1
            '
        EXEC sp_executesql @sqlcmd
      
        -- get query store state
        SET @Msg = 'get query store state'
        IF @Debug = 1   
            RAISERROR (@Msg , 0, 1) WITH NOWAIT

        SET @sqlCMD = 'SELECT '''+@LinkServerName+''',* FROM OPENQUERY('+QUOTENAME(@LinkServerName)+',''
            SELECT @@SERVERNAME as SERVERNAME, name AS ''''DATABASENAME''''
                 , CASE is_query_store_on
                       WHEN 1 THEN ''''ENABLED''''
                       WHEN 0 THEN ''''DISABLED''''
                       ELSE ''''OTHER''''
                         END AS ''''QUERYSTORESTATE''''
                                FROM sys.databases
                                WHERE is_query_store_on = 1 '+ CASE WHEN @DBName = '' THEN '' ELSE ' AND name = '''''+@DBName+'''''' END + '
                            '')'
        INSERT INTO #QueryStoreOnServer (LinkedServerName, ServerName, DBName, QueryStoreState)
        EXEC sp_executesql @sqlcmd

        UPDATE @tb_ListLinkedServer SET IsCheck = 1 WHERE LinkedServerName = @LinkServerName
    END TRY
    BEGIN CATCH
        SELECT @LinkServerName, ERROR_MESSAGE() AS ErrorMessage, @Msg, @sqlCMD ;
        UPDATE @tb_ListLinkedServer SET IsCheck = 1 WHERE LinkedServerName = @LinkServerName
    END CATCH
    -- End Process get info Mon_SPPF_Report
    
    -- =========================================================================================================================

    -- Process each linked server get info query_store
    DECLARE @tbExclude Table (linkedServer varchar(255), dbname varchar(255))
    INSERT INTO @tbExclude VALUES('DB061KBT','WASAVerse'),('DB062KBT','WASAVerse')

    DELETE a FROM #QueryStoreOnServer a INNER JOIN @tbExclude b on a.LinkedServerName = b.linkedServer and a.DBName = b.dbname

    IF @Debug = 1   
        RAISERROR ('Process each linked server get info query_store' , 0, 1) WITH NOWAIT
    
    WHILE EXISTS (SELECT TOP 1 1 FROM #QueryStoreOnServer WHERE isChecked = 0)
    BEGIN
        DELETE FROM @tb_DataQueryStore

        SELECT TOP 1 @LinkServerName = LinkedServerName , @_DBName = DBName 
        FROM #QueryStoreOnServer WHERE isChecked = 0
        
        --Convert table to JSON
        SELECT @json = 
        (
            SELECT 
                rsm.SPName,
                CONVERT(VARCHAR(25),rsm.EventTime,120) AS EventTime
            FROM 
                #ListAbnormal_Result rsm 
            WHERE rsm.DBName = @_DBName AND rsm.LinkedServerName = @LinkServerName 
                AND IsAbnormalRecurrent = 0 
                AND (AbnormalReason LIKE '%CPUTime%' OR AbnormalReason LIKE '%ElapsedTime%'OR AbnormalReason LIKE '%LogicalReads%')

            FOR JSON PATH
        );

        -- Execute remote procedure to get plan count
        SELECT @sqlCMD = N'EXEC '+ @LinkServerName +'.MonDB.dbo.vnDBA_sp_GetPlanCount @DBName = '''+@_DBName+''', @SPList = ''' + ISNULL(@json,'') +''', @IntervalMin = 2'
        
        IF @json IS NOT NULL 
        BEGIN 
             BEGIN TRY
               
                INSERT INTO @tb_DataQueryStore (EventTime,SPName,QueryIDs,plan_cnt,rownum)
                EXEC sp_executesql @sqlCMD
                
                --abnomal ExecutionCount, n times in-a-row, whatever number of query plans
                --abnomal avgCPU or avg read, n times in-a-row, then            
                -- if 1 query plan mean might different in parameter input  
                -- or if 1 query plan might query text change in query store (after deployment that make query text change) 
                -- if n query plan mean plan changed    

                UPDATE a 
                SET 
                    isExclude = 0
                FROM #ListAbnormal_Result a 
                    INNER JOIN @tb_DataQueryStore b ON a.SPName = b.SPName AND a.EventTime = b.EventTime
                WHERE a.LinkedServerName = @LinkServerName AND DBName = @_DBName AND b.rownum = 1 AND b.plan_cnt > 1


                -- Delete plan count = 1
                DELETE FROM @tb_DataQueryStore WHERE plan_cnt = 1

                ;WITH cte_query_store AS (
                    SELECT STRING_AGG (CAST(QueryIDs AS VARCHAR(MAX)) + ' (x' + CAST(plan_cnt AS VARCHAR(100)) + ')','<br>') as plan_cnt, EventTime, SPName
                    FROM @tb_DataQueryStore 
                    GROUP BY SPName,EventTime
                )
                UPDATE a 
                SET a.QueryPlan = plan_cnt
                FROM #ListAbnormal_Result a 
                    INNER JOIN cte_query_store b ON a.SPName = b.SPName AND a.EventTime = b.EventTime

            END TRY
            BEGIN CATCH
                SELECT ERROR_MESSAGE(), @sqlCMD
            END CATCH

        END
       
        UPDATE  #QueryStoreOnServer SET isChecked = 1 WHERE DBName = @_DBName AND LinkedServerName = @LinkServerName
    END
    -- End Process get info query_store

    -- =========================================================================================================================

    DECLARE @Subject VARCHAR(1024) = '[Abnormal Report] Data Checking on '-- + ISNULL(CONVERT(VARCHAR(20), @CheckDate, 105), '' )
    DECLARE @Mail_xml NVARCHAR(MAX), @Mail_body NVARCHAR(MAX), @Mail_header NVARCHAR(MAX)
    DECLARE @tbMail_xml TABLE (Mail_xml NVARCHAR(MAX))
    
    IF @Debug = 1   
        RAISERROR ('Process Sendmail' , 0, 1) WITH NOWAIT
    

    -- One more step to checking by hours

    SELECT * FROM #ListAbnormal_Result


    -- Process Sendmail
    WHILE (1=1)
    BEGIN
        SELECT TOP 1 @LinkServerName = LinkedServerName, @SrvName=ServerName FROM #ListAbnormal_Result WHERE isChecked = 0 AND isExclude = 0

        IF @@ROWCOUNT = 0
            BREAK
            
        DELETE FROM @tbMail_xml
        SELECT @Subject  = '[Abnormal Report] SP Performance Check - KBT@' + @SrvName
        SET @Mail_header = '<html>
                            <head>
                                <style>
                                    body { font-family: Arial, sans-serif; }
                                    h1 { color: #333; }
                                    table { width: 100%; border-collapse: collapse; }
                                    th, td { padding: 8px; text-align: left; border: 1px solid #ddd; }
                                    th { background-color: #f2f2f2; }
                                    ul { padding-left: 20px}
                                    tr:nth-child(even) { background-color: #f9f9f9; }
                                    tr:hover { background-color: #f1f1f1; }
                                </style>
                            </head>
                            <body>
                            <h1> Abnormal Stored Procedure Report</h1> <p>Generated on: '+FORMAT(@CurrDate, 'yyyy-MM-dd HH:mm:ss')+' (GMT-4)</p> ' + 
                            '<table border = 1>
                            <tr>
                            <th>.No</th>
                            <th>ServerName</th>
                            <th>DBName</th>
                            <th>SPName</th>
                            <th>EventDate</th>
                            <th>Reason Abnormal</th>
                            <th>AbnormalTime</th>
                            <th>QueryPlan</th>'

        
        SELECT @sqlCMD =  N'SELECT CAST((
            SELECT 
                ROW_NUMBER() OVER (ORDER BY t.DBName ,  t.SPName ) AS ''td'','''',
                t.ServerName AS ''td'','''',
                t.DBName AS ''td'','''',
                t.SPName AS ''td'','''',
                t.EventDate AS ''td'','''',
                STUFF((SELECT DISTINCT '', '' + CAST(a.VALUE AS VARCHAR(MAX)) 
                FROM STRING_SPLIT(AbnormalReason1,'','') AS a
                FOR XML PATH('''')
                ), 1, 2, '''')  AS ''td'','''',
                '+
                N'STRING_AGG(CAST(AbnormalTimeRange AS VARCHAR(MAX)) ,'', '')  AS ''td'','''',
                QueryPlan AS ''td'',''''
            FROM 
            (
                SELECT 
                    t.ServerName ,
                    t.DBName ,   
                    t.SPName ,   
                    STRING_AGG(t.AbnormalReason1,'','') AS AbnormalReason1, 
                    CONVERT(VARCHAR(16), t.EventTime, 111) AS EventDate,
                    N''<ul><li>'' + STRING_AGG( CAST(IIF (FromEventTime IS NULL
                        ,CONVERT(NVARCHAR(5), CAST(t.EventTime AS TIME), 108)  
                        ,CONVERT(NVARCHAR(5), CAST(FromEventTime AS TIME), 108) + ''-'' + CONVERT(NVARCHAR(5), CAST(ToEventTime AS TIME), 108) +
                        '' ('' + CONVERT(NVARCHAR(5), DATEDIFF(Minute,FromEventTime,ToEventTime) + 1) +''min)'') AS NVARCHAR(MAX)), N'' </li><li> '') 
                        WITHIN GROUP (ORDER BY FromEventTime) + N''</li></ul>'' AS AbnormalTimeRange ,
                    t.QueryPlan
                FROM #ListAbnormal_Result t
                WHERE  isExclude = 0 AND LinkedServerName = '''+@LinkServerName+'''
                GROUP BY t.ServerName,t.DBName,t.SPName,CONVERT(VARCHAR(16), t.EventTime, 111),t.QueryPlan
                
            ) t
            GROUP BY t.ServerName,t.DBName,t.SPName,t.EventDate,AbnormalReason1 ,t.QueryPlan
            ORDER BY  t.DBName ,   
                    t.SPName 
            FOR XML PATH (''tr''), ELEMENTS
        ) AS NVARCHAR(MAX))' 
        
        INSERT INTO @tbMail_xml 
        EXEC sp_executesql @sqlCMD

        SELECT @Mail_xml = Mail_xml FROM @tbMail_xml

        SET @Mail_body = NULL

        SET @Mail_body = @Mail_header + REPLACE(REPLACE(@Mail_xml,'&lt;','<') ,'&gt;','>') + '</table> <p>* ================= *</p>
            <p>For more information, please refer to the <a href="https://ops3.starixplay.com/d/WhbvuOKHz/servers-anomaly-report?orgId=1&var-server_name='
            +@LinkServerName+'" target="_blank">dashboard</a>.</p> </body> <html>'

        INSERT INTO @tb_SendMail (LinkServerName,Mail_body)
        SELECT @LinkServerName,@Mail_body
        
        -- Send noti mail
         IF @Mail_body IS NOT NULL AND @Debug = 0
         BEGIN
        
            EXEC msdb.dbo.sp_send_dbmail @recipients='lukas.luu@starixsoft.com;evan.trinh@starixsoft.com;daniel.truong@starixsoft.com;patrick.pham@starixsoft.com;sol.le@starixsoft.com;brice.nguyen@starixsoft.com'
                    , @subject = @subject 
                    , @body = @Mail_body
                    , @body_format = 'HTML'

            INSERT INTO DBA_AbnormalResultLog (SPID, Logdate,ServerName,LinkedServerName,DBName,SPName,EventTimeAbnormal,From_REventTime,To_REventTime,AbnormalReason,QueryPlan,IsAbnormalRecurrent)
            SELECT SPID,CAST(@CurrDate AS DATE),ServerName,LinkedServerName,DBName,SPName,EventTime,FromEventTime,ToEventTime,AbnormalReason,QueryPlan,IsAbnormalRecurrent 
            FROM #ListAbnormal_Result WHERE  isExclude = 0 AND LinkedServerName = @LinkServerName

        END
         
        UPDATE #ListAbnormal_Result SET isChecked = 1 WHERE LinkedServerName = @LinkServerName
        
    END
    -- End Process Sendmail
    IF @Debug = 1
    BEGIN
        --SELECT * FROM #Mon_SPPF_Report
        --SELECT * FROM #Mon_SPPF_Report_Stats

        SELECT * FROM #ListAbnormal_org ORDER BY EventTime
        SELECT * FROM #ListAbnormal_Result WHERE isExclude = 0
        SELECT * FROM @tb_SendMail  order by LinkServerName
    END

END
