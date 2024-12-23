-- This stored procedure analyzes the performance of stored procedures
-- @ServerName: The name of the server to connect to
-- @DBName: The name of the database to analyze
-- @SPName: The name of the stored procedure to filter results
-- The procedure collects execution statistics and identifies anomalies
ALTER PROCEDURE vnDBA_SP_AbnormalReport 
   @ServerName VARCHAR(1000)='' ,
    @DBName VARCHAR(1000)='' ,
    @SPName VARCHAR(256)='' ,
    @CheckDate DATE ='' ,
    @NumberDateCheck INT  = 2,      -- Define Minimum,Maximum Range
    @CheckTime_Day VARCHAR(1000) = NULL,  -- '20240925', -- Define Minimum,Maximum Range
    @Threshold_ZCore FLOAT = 3,
    @Threshold_CV INT = 1,              -- STDEV / AVG
    @Debug BIT = 0
AS
--select @FromDate = DATEADD(DAY,-1,GETDATE()) 
/*
    Created: @Evan
    DB: 
    Revisions: 
        - @Evan: Initial 
    Param's Explanation:   
        @SPName: Filter SP Name
        @NumberDateCheck = N:  Compare standard deviation on data set N days ago
            
*/


BEGIN

    SET NOCOUNT ON;

    -- Set the current date and time
    DECLARE     @Filter_Todate SMALLDATETIME 
            ,   @Filter_Fromdate SMALLDATETIME

    -- Filter range time by param @FromDate
    DECLARE @textDayFilter VARCHAR(8)
    SELECT @textDayFilter = CONVERT(VARCHAR(8),@CheckDate,112)

    SELECT @Filter_Fromdate = @CheckDate
    SELECT @Filter_Todate = CAST(@CheckDate AS SMALLDATETIME) + '23:59:00';
  
    -- Get list linked-server
    DECLARE @tb_ListServerName TABLE (ServerName VARCHAR(256))
    DECLARE @tb_ListLinkedServer TABLE (LinkedServerName VARCHAR(256) , IsCheck BIT DEFAULT(0), ErrMsg  VARCHAR(1000), sqlcmd varchar(max))
    
    DROP TABLE IF EXISTS #tmp_MonReport_Statistics
    DROP TABLE IF EXISTS #tmp_MonReport
    DROP TABLE IF EXISTS #tmp_AbnormalResult
    DROP TABLE IF EXISTS #tb_AbnormalList
    DROP TABLE IF EXISTS #tb_AbnormalList_temp
    DROP TABLE IF EXISTS #tb_ServersHasQueryStore

    -- Get info Mon_SPPF_Report
    CREATE TABLE #tmp_MonReport (
          SPID INT, SPName VARCHAR(256), ServerName VARCHAR(256), DBName VARCHAR(256)
        , Execution_count DECIMAL(22,3), CPUTime DECIMAL(22,3), LogicalReads DECIMAL(22,3)
        , ElapsedTime DECIMAL(22,3)
        , TimeRange INT, EventTime SMALLDATETIME
        , ExecCount_Per_minute DECIMAL(22,3), CPUTime_Per_minute DECIMAL(22,3)
        , LogicalReads_Per_minute DECIMAL(22,3), ElapsedTime_Per_minute DECIMAL(22,3)
        , textDay  VARCHAR(10)
        , RowNo INT
    )
    CREATE CLUSTERED INDEX [IX_tmpMonReport_SPID] ON #tmp_MonReport (SPID, textDay)

    -- Get statistics
    CREATE TABLE #tmp_MonReport_Statistics (
          SPID INT
        , Avg_ExecutionCount DECIMAL(22,3), Avg_CPUTime DECIMAL(22,3), Avg_LogicalReads DECIMAL(22,3), Avg_ElapsedTime DECIMAL(22,3)
        , StdDev_ExecutionCount DECIMAL(22,3), StdDev_CPUTime DECIMAL(22,3), StdDev_LogicalReads DECIMAL(22,3), StdDev_ElapsedTime DECIMAL(22,3)
        , Q3_ExecutionCount DECIMAL(22,3), Q3_CPUTime DECIMAL(22,3), Q3_LogicalReads DECIMAL(22,3), Q3_ElapsedTime DECIMAL(22,3)
        , IQR_ExecutionCount DECIMAL(22,3), IQR_CPUTime DECIMAL(22,3), IQR_LogicalReads DECIMAL(22,3), IQR_ElapsedTime DECIMAL(22,3)
    )

    CREATE TABLE #tmp_AbnormalResult (
        SPName VARCHAR(256) , ServerName VARCHAR(256)
        , LinkedServerName VARCHAR(256), DBName VARCHAR(256)
        , EventTimeAbnormal SMALLDATETIME , From_REventTime SMALLDATETIME ,To_REventTime SMALLDATETIME , AbnormalReason VARCHAR(MAX)
        , QueryPlan VARCHAR(MAX), IsAbnormalRecurrent BIT , isExclude BIT , isChecked BIT DEFAULT(0)
    ) 
     CREATE TABLE #tb_AbnormalList  (
         SPID INT, SPName VARCHAR(256), ServerName VARCHAR(256), LinkedServerName VARCHAR(256), DBName VARCHAR(256)
        , EventDate DATE, EventTime SMALLDATETIME, FromEventTime SMALLDATETIME, ToEventTime SMALLDATETIME 
        , ExecCount_Per_minute DECIMAL(22,3), CPUTime_Per_minute DECIMAL(22,3), LogicalReads_Per_minute DECIMAL(22,3)
        , ElapsedTime_Per_minute DECIMAL(22,3)
        , AbnormalReason VARCHAR(MAX)
        , ExecCount_ZCore DECIMAL(22,3), CPUTime_ZCore DECIMAL(22,3)
        , LogicalReads_ZCore DECIMAL(22,3), ElapsedTime_ZCore DECIMAL(22,3)
        , ExecPlanCnt SMALLINT, IsAbnormalRecurrent BIT
        , SPRowID INT
    )
    CREATE TABLE #tb_AbnormalList_temp  (
          SPID INT, SPName VARCHAR(256), ServerName VARCHAR(256), DBName VARCHAR(256)
        , EventDate DATE, EventTime SMALLDATETIME
        , ExecCount_Per_minute DECIMAL(22,3), CPUTime_Per_minute DECIMAL(22,3), LogicalReads_Per_minute DECIMAL(22,3)
        ,  ElapsedTime_Per_minute DECIMAL(22,3)
        , AbnormalReason VARCHAR(MAX), RowNo INT, DiffNextPoint INT
        , ExecCount_ZCore DECIMAL(22,3), CPUTime_ZCore DECIMAL(22,3)
        , LogicalReads_ZCore DECIMAL(22,3), ElapsedTime_ZCore DECIMAL(22,3)
        , SPRowID INT
    )
    
    DECLARE @tb_SendMail TABLE (LinkServerName VARCHAR(1000), Mail_body VARCHAR(MAX))
    DECLARE @AbnormalPoint SMALLINT = 3, @isCheck_QUERYSTORE BIT = 1; 

    CREATE TABLE #tb_ServersHasQueryStore  (
        ServerName VARCHAR(256), LinkedServerName VARCHAR(256)
        , DBName VARCHAR(256), QueryStoreState VARCHAR(8)
        , isChecked BIT DEFAULT ((0))
    )

    DECLARE @tb_DataQueryStore TABLE (
       EventTime SMALLDATETIME, SPName VARCHAR(256),plan_cnt SMALLINT, rownum INT, QueryIDs VARCHAR(MAX)
    )

    DECLARE @CurrDate DATETIME = GETDATE()
    DECLARE @Yesterdate SMALLDATETIME = DATEADD(DAY,-1,@CurrDate), @Msg VARCHAR (500)
            ,@sqlCMD NVARCHAR(MAX), @textDay VARCHAR(8) , @LinkServerName VARCHAR(256) , @SrvName VARCHAR(256) , @EventDate SMALLDATETIME
            ,@Json VARCHAR(MAX)
            ,@_DBName VARCHAR(256)

    -- List Scan date 
    DECLARE @tb_RangeDate TABLE (textDay VARCHAR(8), IsCheck BIT)
    DECLARE @tb_RangeDate1 TABLE (textDay VARCHAR(8), IsCheck BIT)
    DECLARE @i INT = @NumberDateCheck

    -- Get range time to calculate Standard deviation (STDEV)
    IF EXISTS (SELECT 1 FROM STRING_SPLIT (@CheckTime_Day,',') WHERE VALUE <> '')
    BEGIN
        INSERT INTO @tb_RangeDate  (textDay,IsCheck)
        SELECT VALUE, 0 FROM STRING_SPLIT (@CheckTime_Day,',') WHERE VALUE <> ''
    END
    ELSE
    BEGIN
        WHILE (@i >= 0) 
        BEGIN
            INSERT INTO @tb_RangeDate  (textDay,IsCheck)
            SELECT CONVERT(VARCHAR(8), DATEADD(DAY, -7 * @i, @CheckDate), 112), 0

            SET @i = @i - 1
        END


  --      DECLARE @FromDate DATE = GETDATE()
  --      DECLARE @NumberDateCheck INT  = 1
  --      DECLARE @tb_RangeDate TABLE (textDay VARCHAR(8), IsCheck BIT)
  --      WHILE (@NumberDateCheck >= 0) BEGIN
  --          INSERT INTO @tb_RangeDate  (textDay,IsCheck)
  --          SELECT CONVERT(VARCHAR(8), DATEADD(DAY,-7 * @NumberDateCheck, @FromDate), 112), 0

  --          SET @NumberDateCheck = @NumberDateCheck - 1
  --      END
  --      select * from @tb_RangeDate
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
  
    --Could not find stored procedure 'MonDB.dbo.vnDBA_sp_GetPlanCount'.
    --DBDW2KBT
    --DBODDSC1KBT
    --DBODDSC2KBT
    -- Process each linked server get info Mon_SPPF_Report
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
    
    WHILE EXISTS (SELECT TOP 1 1 FROM @tb_ListLinkedServer WHERE IsCheck = 0)
    BEGIN TRY
       
        DELETE FROM @tb_ListServerName

        SELECT TOP 1 @LinkServerName = LinkedServerName
        FROM @tb_ListLinkedServer WHERE IsCheck = 0 

        SELECT @SrvName = ServerName FROM dbo.Mon_Index_Report_Server WITH(NOLOCK) WHERE LinkedServerName = @LinkServerName

        IF ISNULL(@SrvName , '') = '' 
        BEGIN
            SET @sqlCMD = 'SELECT SERVERNAME FROM OPENQUERY('+@LinkServerName+',''SELECT @@SERVERNAME AS SERVERNAME'')'
            INSERT INTO @tb_ListServerName
            EXEC sp_executesql @sqlcmd

            SELECT @SrvName = ServerName FROM @tb_ListServerName
        END

        IF @Debug = 1   
        BEGIN
            SET @Msg = CHAR(9) + 'Start on: ' + @LinkServerName
            RAISERROR (@Msg , 0, 1) WITH NOWAIT
        END

        -- Delete/Reset temp table
        TRUNCATE TABLE #tmp_MonReport
        TRUNCATE TABLE #tmp_MonReport_Statistics

        -- Reset @tb_RangeDate for next server
        UPDATE @tb_RangeDate  SET IsCheck = 0
        DELETE FROM @tb_RangeDate1

        DECLARE @MissMonReport TABLE (SPID INT, MissDateCount INT);
        DECLARE @SPIDs VARCHAR(MAX)  = ''

        -- Loop through RangeDate
        SET @Msg = 'Get data MonReport'
        IF @Debug = 1   
            RAISERROR (@Msg , 0, 1) WITH NOWAIT

        WHILE EXISTS (SELECT 1 FROM @tb_RangeDate  WHERE IsCheck = 0)
        BEGIN
            SELECT TOP 1  @textDay =  textDay
            FROM @tb_RangeDate  WHERE IsCheck = 0

            INSERT INTO #tmp_MonReport (SPID, SPName, ServerName, DBName, Execution_count, CPUTime, LogicalReads, ElapsedTime, TimeRange, EventTime,ExecCount_Per_minute, CPUTime_Per_minute, LogicalReads_Per_minute, ElapsedTime_Per_minute,textDay, RowNo)
            EXEC dbo.vnDBA_SP_GetAbnormalReport @LinkServerName = @LinkServerName, @ServerName = @SrvName, @DBName = @DBName, @SPName = @SPName, @SPIDs = @SPIDs, @textDay = @textDay
            --EXEC dbo.vnDBA_SP_GetAbnormalReport @LinkServerName = 'DBCUSTKBT', @ServerName = 'DBCUST', @DBName = 'CustDB', @SPName = 'Acc_CustomerInsMember_MAg', @textDay = '20241212'
            UPDATE @tb_RangeDate  SET IsCheck = 1 WHERE textDay = @textDay

        END

        -- Check list sp has no data for the selected date range and retrieves data from the previous date
        SET @Msg = 'Check list sp has no data for the selected date range'
        IF @Debug = 1   
            RAISERROR (@Msg , 0, 1) WITH NOWAIT
        
        ;WITH cte_grouptextday AS (
            SELECT SPID,textDay
            FROM #tmp_MonReport
            GROUP BY SPID,textDay
        )
        INSERT INTO @MissMonReport (SPID, MissDateCount)
        SELECT SPID,MissDateCount
        FROM
        (
            SELECT a.SPID, @NumberDateCheck - SUM(IIF(b.SPID IS NULL,0,1)) AS MissDateCount
            FROM  cte_grouptextday a 
                LEFT JOIN cte_grouptextday b on a.SPID = b.SPID AND a.textDay = b.textDay AND b.textDay <> @textDayFilter
            GROUP BY a.SPID
        ) a
        WHERE MissDateCount = @NumberDateCheck  
        
        IF EXISTS ( SELECT TOP 1 1 FROM @MissMonReport)
        BEGIN
            SET @Msg = 'Retrieves data from the previous date'
            IF @Debug = 1   
                RAISERROR (@Msg , 0, 1) WITH NOWAIT

            SELECT @SPIDs = STRING_AGG(CAST(SPID AS VARCHAR(10)) , ',') FROM @MissMonReport
        
            SET @i = @NumberDateCheck 
            WHILE (@i > 0) 
            BEGIN
                INSERT INTO @tb_RangeDate1  (textDay,IsCheck)
                SELECT CONVERT(VARCHAR(8), DATEADD(DAY, (-7 * @i) - (@NumberDateCheck * 7)  , @CheckDate ), 112), 0

                SET @i = @i - 1
            END

             -- Loop through RangeDate1
            SET @Msg = ''
            IF @Debug = 1   
                RAISERROR (@Msg , 0, 1) WITH NOWAIT

            WHILE EXISTS (SELECT 1 FROM @tb_RangeDate1  WHERE IsCheck = 0)
            BEGIN
                SELECT TOP 1  @textDay =  textDay
                FROM @tb_RangeDate1  WHERE IsCheck = 0

                INSERT INTO #tmp_MonReport (SPID, SPName, ServerName, DBName, Execution_count, CPUTime, LogicalReads, ElapsedTime, TimeRange, 
                    EventTime,ExecCount_Per_minute, CPUTime_Per_minute, LogicalReads_Per_minute, ElapsedTime_Per_minute,textDay, RowNo)
                EXEC dbo.vnDBA_SP_GetAbnormalReport @LinkServerName = @LinkServerName, @ServerName = @SrvName, @DBName = @DBName, @SPName = @SPName, @SPIDs = @SPIDs, @textDay = @textDay

                select @LinkServerName, @ServerName, @DBName, @SPName, @SPIDs, @textDay
                UPDATE @tb_RangeDate1  SET IsCheck = 1 WHERE textDay = @textDay

            END
        END

        IF @SPName = ''
        BEGIN
            -- Filter out stored procedures that start with 'sp_MS' to exclude system procedures
            DELETE #tmp_MonReport WHERE ( SPName LIKE 'sp_MS%' OR SPName LIKE 'Repl_%' OR  SPName LIKE 'vndba_%' OR  SPName LIKE 'DBA_%' OR  SPName LIKE '%Repl%' ) 
        
            ---- Remove SPs that are executed non-consecutive
            ;WITH cte_AvgExecPerHour AS (
             SELECT SPID, AVG(ExecutionCountPerHour) avg_ExecutionCountPerHour
             FROM (
                 SELECT SPID,SUM(ISNULL(TimeRange,1)) ExecutionCountPerHour
                 FROM #tmp_MonReport WHERE EventTime >= @Yesterdate and EventTime < @CurrDate
                 GROUP BY SPID, DATEPART(HOUR,EventTime)
             )   a
             GROUP BY SPID
            )
            DELETE 
            FROM #tmp_MonReport 
            WHERE SPID IN (SELECT a.SPID FROM cte_AvgExecPerHour a WHERE a.avg_ExecutionCountPerHour < 40)
        END

        SET @Msg = 'Get Statistics from MonReport'
        IF @Debug = 1   
            RAISERROR (@Msg , 0, 1) WITH NOWAIT

         ;WITH cte_IQR AS (
            SELECT DISTINCT SPID
                    , PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Execution_count) OVER (PARTITION BY SPID) AS Q1_Execution_count
                    , PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Execution_count) OVER (PARTITION BY SPID) AS Q3_Execution_count
                    , PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY CPUTime_Per_minute) OVER (PARTITION BY SPID) AS Q1_CPU
                    , PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY CPUTime_Per_minute) OVER (PARTITION BY SPID) AS Q3_CPU
                    , PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY LogicalReads_Per_minute) OVER (PARTITION BY SPID) AS Q1_LogicalRead
                    , PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY LogicalReads_Per_minute) OVER (PARTITION BY SPID) AS Q3_LogicalRead
                    , PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ElapsedTime_Per_minute) OVER (PARTITION BY SPID) AS Q1_ElapsedTime
                    , PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ElapsedTime_Per_minute) OVER (PARTITION BY SPID) AS Q3_ElapsedTime
            FROM #tmp_MonReport
            WHERE textDay <> @textDayFilter
        ), cte_avgstdev AS
        (
            SELECT SPID
               , AVG(Execution_count) AS Avg_ExecutionCount
                    , AVG(CPUTime_Per_minute) AS Avg_CPUTime
                    , AVG(LogicalReads_Per_minute) AS Avg_LogicalReads
                    , AVG(ElapsedTime_Per_minute) AS Avg_ElapsedTime
                    , STDEV(ExecCount_Per_minute) AS StdDev_ExecutionCount
                    , STDEV(CPUTime_Per_minute) AS StdDev_CPUTime
                    , STDEV(LogicalReads_Per_minute) AS StdDev_LogicalReads
                    , STDEV(ElapsedTime_Per_minute) AS StdDev_ElapsedTime
            FROM #tmp_MonReport
            WHERE textDay <> @textDayFilter
            GROUP BY SPID
        )
        
        INSERT INTO #tmp_MonReport_Statistics (SPID, Avg_ExecutionCount, Avg_CPUTime, Avg_LogicalReads, Avg_ElapsedTime, 
            StdDev_ExecutionCount, StdDev_CPUTime, StdDev_LogicalReads, StdDev_ElapsedTime, IQR_ExecutionCount, IQR_CPUTime, IQR_LogicalReads, IQR_ElapsedTime
            , Q3_ExecutionCount , Q3_CPUTime , Q3_LogicalReads , Q3_ElapsedTime)
        SELECT a.SPID , Avg_ExecutionCount , Avg_CPUTime , Avg_LogicalReads , Avg_ElapsedTime , 
            StdDev_ExecutionCount , StdDev_CPUTime , StdDev_LogicalReads , StdDev_ElapsedTime ,
            (Q3_Execution_count - Q1_Execution_count) * 1.5 AS IQR_ExecutionCount ,
            (Q3_CPU - Q1_CPU) * 1.5 AS IQR_CPUTime ,
            (Q3_LogicalRead - Q1_LogicalRead) * 1.5 AS IQR_LogicalReads ,
            (Q3_ElapsedTime - Q1_ElapsedTime) * 1.5 AS IQR_ElapsedTime ,
             Q3_Execution_count , Q3_CPU , Q3_LogicalRead , Q3_ElapsedTime
        FROM cte_avgstdev a LEFT JOIN cte_IQR b ON a.SPID = b.SPID 

        --code get abnormal

        IF @Debug = 1  AND @SPName <> ''
        BEGIN
            SELECT @Filter_Fromdate Fromdate ,@Filter_Todate  Todate, (SELECT STRING_AGG(textDay,'; ') from @tb_RangeDate ) as checkdate
            
            SELECT * FROM #tmp_MonReport_Statistics

            ;WITH cte_result AS
            (
            SELECT s.SPID, s.RowNo AS SPRowID , SPName , ServerName , DBName , CAST(EventTime AS DATE) AS EventDate , EventTime , ExecCount_Per_minute , 
                CPUTime_Per_minute , LogicalReads_Per_minute, ElapsedTime_Per_minute , Avg_ExecutionCount , 
                Avg_CPUTime , Avg_LogicalReads , Avg_ElapsedTime , StdDev_ExecutionCount , StdDev_CPUTime , StdDev_LogicalReads , 
                StdDev_ElapsedTime , ExecCount_ZCore , CPUTime_ZCore , ElapsedTime_ZCore , LogicalReads_ZCore ,
                CONCAT_WS(',',IIF(Is_ExecutionCount_Abnomaly = 1,'ExecutionCount',NULL),IIF(Is_CPUTime_Abnomaly = 1,'CPUTime',NULL),IIF(Is_ElapsedTime_Abnomaly = 1,'ElapsedTime',NULL)
                            ,IIF(Is_LogicalReads_Abnomaly = 1,'LogicalReads',NULL)) AS AbnormalReason
                , ROW_NUMBER() OVER (PARTITION BY s.SPID , CAST(EventTime AS DATE) ORDER BY (b.ExecCount_ZCore + b.CPUTime_ZCore + b.ElapsedTime_ZCore + b.LogicalReads_ZCore) DESC) AS RowNo
            FROM #tmp_MonReport s
                INNER JOIN #tmp_MonReport_Statistics t ON s.SPID = t.SPID
                CROSS APPLY (
                    SELECT  
                        CASE WHEN ((ExecCount_Per_minute - Avg_ExecutionCount) > @Threshold_ZCore * StdDev_ExecutionCount) 
                            AND StdDev_ExecutionCount > 0 
                            AND IIF(Avg_ExecutionCount=0,0,StdDev_ExecutionCount/Avg_ExecutionCount) > @Threshold_CV THEN 1
                        ELSE 0 END AS Is_ExecutionCount_Abnomaly
                        , CASE WHEN ((CPUTime_Per_minute - Avg_CPUTime) > @Threshold_ZCore * StdDev_CPUTime)
                            AND StdDev_CPUTime > 0 
                            AND IIF(Avg_CPUTime=0,0,StdDev_CPUTime/Avg_CPUTime) > @Threshold_CV THEN 1
                        ELSE 0 END AS Is_CPUTime_Abnomaly
                        , CASE WHEN ((ElapsedTime_Per_minute - Avg_ElapsedTime) > @Threshold_ZCore * StdDev_ElapsedTime) 
                            AND StdDev_ElapsedTime > 0 
                            AND IIF(Avg_ElapsedTime=0,0,StdDev_ElapsedTime/Avg_ElapsedTime) > @Threshold_CV THEN 1
                        ELSE 0 END AS Is_ElapsedTime_Abnomaly
                        , CASE WHEN ((LogicalReads_Per_minute - Avg_LogicalReads) > @Threshold_ZCore * StdDev_LogicalReads)
                            AND StdDev_LogicalReads > 0 
                            AND IIF(Avg_LogicalReads=0,0,StdDev_LogicalReads/Avg_LogicalReads) > @Threshold_CV THEN 1
                            ELSE 0 END AS Is_LogicalReads_Abnomaly
                                
                        , CASE WHEN StdDev_ExecutionCount = 0 THEN 0 ELSE CAST((ExecCount_Per_minute - Avg_ExecutionCount) / StdDev_ExecutionCount AS DECIMAL(22,3)) END AS ExecCount_ZCore
                        , CASE WHEN StdDev_CPUTime = 0 THEN 0 ELSE CAST((CPUTime_Per_minute - Avg_CPUTime) / StdDev_CPUTime AS DECIMAL(22,3)) END AS CPUTime_ZCore
                        , CASE WHEN StdDev_ElapsedTime = 0 THEN 0 ELSE CAST((ElapsedTime_Per_minute - Avg_ElapsedTime) / StdDev_ElapsedTime AS DECIMAL(22,3)) END AS ElapsedTime_ZCore
                        , CASE WHEN StdDev_LogicalReads = 0 THEN 0 ELSE CAST((LogicalReads_Per_minute - Avg_LogicalReads) / StdDev_LogicalReads AS DECIMAL(22,3)) END AS LogicalReads_ZCore
                ) b
            WHERE (textDay = @textDayFilter )
            AND EventTime be
                -- AND (Is_ExecutionCount_Abnomaly = 1 OR Is_CPUTime_Abnomaly = 1 OR Is_ElapsedTime_Abnomaly = 1 OR Is_LogicalReads_Abnomaly = 1)
            )
            SELECT 
            ServerName, DBName, SPID, SPName, EventTime, AbnormalReason,
            ExecCount_Per_minute, Avg_ExecutionCount, StdDev_ExecutionCount,ExecCount_ZCore,
                cast(cast(IIF(Avg_ExecutionCount=0,0,StdDev_ExecutionCount/Avg_ExecutionCount) as DECIMAL(9,4)) as float) as ExecutionCount_CV
            , CPUTime_Per_minute , Avg_CPUTime, StdDev_CPUTime,CPUTime_ZCore,
                cast(cast(IIF(Avg_CPUTime=0,0,StdDev_CPUTime/Avg_CPUTime) as DECIMAL(9,4)) as float) as CPUTime_CV
            , ElapsedTime_Per_minute , Avg_ElapsedTime, StdDev_ElapsedTime,ElapsedTime_ZCore,
                cast(cast(IIF(Avg_ElapsedTime=0,0,StdDev_ElapsedTime/Avg_ElapsedTime) as DECIMAL(9,4)) as float) as ElapsedTime_CV
            , LogicalReads_Per_minute , Avg_LogicalReads, StdDev_LogicalReads,LogicalReads_ZCore,
                cast(cast(IIF(Avg_LogicalReads=0,0,StdDev_LogicalReads/Avg_LogicalReads) as DECIMAL(9,4)) as float) as LogicalReads_CV
            --, LEAD(SPRowID) OVER (PARTITION BY SPID, CAST(EventTime AS DATE) ORDER BY EventTime) - SPRowID AS DiffNextPoint
            FROM cte_result
            ORDER BY ServerName,DBName,SPID,EventTime
               
        END
       
        SET @Msg = 'code get list abnormal'
        IF @Debug = 1   
            RAISERROR (@Msg , 0, 1) WITH NOWAIT

       ;WITH cte_result AS
        (
            SELECT 
                s.SPID,
                s.RowNo AS SPRowID,
                SPName,
                ServerName,
                DBName,
                CAST(EventTime AS DATE) AS EventDate,
                EventTime,
                ExecCount_Per_minute,
                CPUTime_Per_minute,
                LogicalReads_Per_minute,
                ElapsedTime_Per_minute,
                Avg_ExecutionCount,
                Avg_CPUTime,
                Avg_LogicalReads,
                Avg_ElapsedTime,
                StdDev_ExecutionCount,
                StdDev_CPUTime,
                StdDev_LogicalReads,
                StdDev_ElapsedTime,
                ExecCount_ZCore,
                CPUTime_ZCore,
                ElapsedTime_ZCore,
                LogicalReads_ZCore,
    
                -- Concatenate abnormal reasons based on conditions
     CONCAT_WS(',', 
                    IIF(Is_ExecutionCount_Abnomaly = 1, 'ExecutionCount', NULL),
                    IIF(Is_CPUTime_Abnomaly = 1, 'CPUTime', NULL),
                    IIF(Is_ElapsedTime_Abnomaly = 1, 'ElapsedTime', NULL),
                    IIF(Is_LogicalReads_Abnomaly = 1, 'LogicalReads', NULL)
                ) AS AbnormalReason,

                -- Row number for ranking
                ROW_NUMBER() OVER (
                    PARTITION BY s.SPID, CAST(EventTime AS DATE), 
                                CONCAT_WS(',', 
                                IIF(Is_ExecutionCount_Abnomaly = 1, 'ExecutionCount', NULL),
                                IIF(Is_CPUTime_Abnomaly = 1, 'CPUTime', NULL),
                                IIF(Is_ElapsedTime_Abnomaly = 1, 'ElapsedTime', NULL),
                                IIF(Is_LogicalReads_Abnomaly = 1, 'LogicalReads', NULL)
                            )
                    ORDER BY (b.ExecCount_ZCore + b.CPUTime_ZCore + b.ElapsedTime_ZCore + b.LogicalReads_ZCore) DESC
                ) AS RowNo

            FROM 
                #tmp_MonReport s
            INNER JOIN 
                #tmp_MonReport_Statistics t ON s.SPID = t.SPID
            CROSS APPLY (
                SELECT  
                    -- Determine anomalies based on thresholds
                    CASE 
                        WHEN ((ExecCount_Per_minute - Avg_ExecutionCount) > @Threshold_ZCore * StdDev_ExecutionCount) 
                                AND StdDev_ExecutionCount > 0 
                                AND IIF(Avg_ExecutionCount = 0, 0, StdDev_ExecutionCount / Avg_ExecutionCount) > @Threshold_CV 
                        THEN 1 ELSE 0 END AS Is_ExecutionCount_Abnomaly,

                    CASE 
                        WHEN ((CPUTime_Per_minute - Avg_CPUTime) > @Threshold_ZCore * StdDev_CPUTime)
                                AND StdDev_CPUTime > 0 
                                AND IIF(Avg_CPUTime = 0, 0, StdDev_CPUTime / Avg_CPUTime) > @Threshold_CV 
                        THEN 1 ELSE 0 END AS Is_CPUTime_Abnomaly,

                    CASE 
                        WHEN ((ElapsedTime_Per_minute - Avg_ElapsedTime) > @Threshold_ZCore * StdDev_ElapsedTime) 
                                AND StdDev_ElapsedTime > 0 
                                AND IIF(Avg_ElapsedTime = 0, 0, StdDev_ElapsedTime / Avg_ElapsedTime) > @Threshold_CV 
                        THEN 1 ELSE 0 END AS Is_ElapsedTime_Abnomaly,

                    CASE 
                        WHEN ((LogicalReads_Per_minute - Avg_LogicalReads) > @Threshold_ZCore * StdDev_LogicalReads)
                                AND StdDev_LogicalReads > 0 
                                AND IIF(Avg_LogicalReads = 0, 0, StdDev_LogicalReads / Avg_LogicalReads) > @Threshold_CV 
                        THEN 1 ELSE 0 END AS Is_LogicalReads_Abnomaly,

                    -- Calculate Z-scores
                    CASE WHEN StdDev_ExecutionCount = 0 THEN 0 
                            ELSE CAST((ExecCount_Per_minute - Avg_ExecutionCount) / StdDev_ExecutionCount AS DECIMAL(22,3)) END AS ExecCount_ZCore,

                    CASE WHEN StdDev_CPUTime = 0 THEN 0 
                            ELSE CAST((CPUTime_Per_minute - Avg_CPUTime) / StdDev_CPUTime AS DECIMAL(22,3)) END AS CPUTime_ZCore,

                    CASE WHEN StdDev_ElapsedTime = 0 THEN 0 
                            ELSE CAST((ElapsedTime_Per_minute - Avg_ElapsedTime) / StdDev_ElapsedTime AS DECIMAL(22,3)) END AS ElapsedTime_ZCore,

                    CASE WHEN StdDev_LogicalReads = 0 THEN 0 
                            ELSE CAST((LogicalReads_Per_minute - Avg_LogicalReads) / StdDev_LogicalReads AS DECIMAL(22,3)) END AS LogicalReads_ZCore
            ) b
            WHERE 
                textDay  = @textDayFilter
                --(EventTime BETWEEN @Filter_Fromdate AND @Filter_Todate)
                AND (Is_ExecutionCount_Abnomaly = 1 OR Is_CPUTime_Abnomaly = 1 OR Is_ElapsedTime_Abnomaly = 1 OR Is_LogicalReads_Abnomaly = 1)  )

        INSERT INTO #tb_AbnormalList_temp (SPID, SPRowID , SPName , ServerName  , DBName , EventDate, EventTime , ExecCount_Per_minute , CPUTime_Per_minute , LogicalReads_Per_minute , 
        ElapsedTime_Per_minute , AbnormalReason, ExecCount_ZCore , CPUTime_ZCore , LogicalReads_ZCore , ElapsedTime_ZCore, RowNo) --, DiffNextPoint
        SELECT 
        SPID ,SPRowID , SPName , ServerName  , DBName ,EventDate , EventTime , ExecCount_Per_minute , CPUTime_Per_minute , LogicalReads_Per_minute
            , ElapsedTime_Per_minute , AbnormalReason
            , ExecCount_ZCore , CPUTime_ZCore , LogicalReads_ZCore , ElapsedTime_ZCore, RowNo
            --, LEAD(SPRowID) OVER (PARTITION BY SPID, CAST(EventTime AS DATE) ORDER BY EventTime) - SPRowID AS DiffNextPoint
        FROM cte_result
        

        SET @Msg = 'Get the abnormal value at the highest point'
        IF @Debug = 1   
            RAISERROR (@Msg , 0, 1) WITH NOWAIT

        -- Get the abnormal value at the highest point
        INSERT INTO #tb_AbnormalList (SPID , SPName , ServerName , LinkedServerName , DBName , EventTime , EventDate , ExecCount_Per_minute , 
                CPUTime_Per_minute , LogicalReads_Per_minute , ElapsedTime_Per_minute , AbnormalReason , ExecCount_ZCore , CPUTime_ZCore , LogicalReads_ZCore , 
                ElapsedTime_ZCore , IsAbnormalRecurrent, SPRowID)
        SELECT SPID , SPName , ServerName , @LinkServerName , DBName , EventTime , EventDate ,  ExecCount_Per_minute , 
                CPUTime_Per_minute , LogicalReads_Per_minute , ElapsedTime_Per_minute , AbnormalReason , ExecCount_ZCore , CPUTime_ZCore , LogicalReads_ZCore , 
                ElapsedTime_ZCore , 0 AS IsAbnormalRecurrent , SPRowID
        FROM #tb_AbnormalList_temp  
        WHERE RowNo = 1

        SET @Msg = 'Calculate the zCore value around the anomaly point; if it below the threshold, exclude it'
        IF @Debug = 1   
            RAISERROR (@Msg , 0, 1) WITH NOWAIT

        -- Calculate the zCore value around the anomaly point; if it below the threshold, exclude it.
        ;WITH cte_AbnormalRecurrent  AS
        (
            SELECT a.SPID, a.SPRowID, a.EventDate, MIN(b.EventTime) min_EventTime, MAX(b.EventTime) max_EventTime
            FROM #tb_AbnormalList a 
                INNER JOIN #tb_AbnormalList_temp b ON a.SPID = b.SPID
                AND b.SPRowID  BETWEEN -(@AbnormalPoint - 1) + a.SPRowID AND (@AbnormalPoint - 1) + a.SPRowID
                AND a.EventDate = b.EventDate
            GROUP BY a.SPID,a.SPRowID, a.EventDate, b.AbnormalReason
            HAVING COUNT(a.SPID) >= @AbnormalPoint
        )
        UPDATE  a 
        SET 
            IsAbnormalRecurrent = 1,
            FromEventTime = min_EventTime,
            ToEventTime = max_EventTime
        FROM #tb_AbnormalList a INNER JOIN cte_AbnormalRecurrent b 
        ON a.SPID = b.SPID AND a.EventDate = b.EventDate AND a.SPRowID = b.SPRowID 

        -- Get final result
        SET @Msg = 'Get final result'
        IF @Debug = 1   
            RAISERROR (@Msg , 0, 1) WITH NOWAIT

        INSERT INTO #tmp_AbnormalResult (SPName, ServerName, LinkedServerName, DBName, EventTimeAbnormal, From_REventTime, To_REventTime, AbnormalReason, QueryPlan, IsAbnormalRecurrent, isExclude)
        SELECT a.SPName, a.ServerName, a.LinkedServerName, a.DBName, a.EventTime, a.FromEventTime, a.ToEventTime, 
            'High: ' + a.AbnormalReason + CASE WHEN a.IsAbnormalRecurrent = 1 THEN ' (R)' ELSE '' END, '', a.IsAbnormalRecurrent, 
            IIF (a.IsAbnormalRecurrent = 1,0,1) AS isExclude
        FROM #tb_AbnormalList a 

        TRUNCATE TABLE  #tb_AbnormalList
        TRUNCATE TABLE  #tb_AbnormalList_temp

        -- get query store state
        SET @Msg = 'get query store state'
        IF @Debug = 1   
            RAISERROR (@Msg , 0, 1) WITH NOWAIT

        SET @sqlCMD = 'SELECT '''+@LinkServerName+''',* FROM OPENQUERY('+@LinkServerName+',''
            SELECT @@SERVERNAME as SERVERNAME, name AS ''''DATABASENAME''''
                 , CASE is_query_store_on
                       WHEN 1 THEN ''''ENABLED''''
                       WHEN 0 THEN ''''DISABLED''''
                       ELSE ''''OTHER''''
                         END AS ''''QUERYSTORESTATE''''
                                FROM sys.databases
                                WHERE is_query_store_on = 1 '+ CASE WHEN @DBName = '' THEN '' ELSE ' AND name = '''''+@DBName+'''''' END + '
                            '')'
        INSERT INTO #tb_ServersHasQueryStore (LinkedServerName, ServerName, DBName, QueryStoreState)
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
    DELETE a FROM #tb_ServersHasQueryStore a INNER JOIN @tbExclude b on a.LinkedServerName = b.linkedServer and a.DBName = b.dbname

    IF @Debug = 1   
        RAISERROR ('Process each linked server get info query_store' , 0, 1) WITH NOWAIT
    
    WHILE EXISTS (SELECT TOP 1 1 FROM #tb_ServersHasQueryStore WHERE isChecked = 0)
    BEGIN
        DELETE FROM @tb_DataQueryStore

        SELECT TOP 1 @LinkServerName = LinkedServerName , @_DBName = DBName 
        FROM #tb_ServersHasQueryStore WHERE isChecked = 0
        
        --Convert table to JSON
        SELECT @json = 
        (
            SELECT 
                rsm.SPName,
                CONVERT(VARCHAR(25),rsm.EventTimeAbnormal,120) AS EventTime
            FROM 
                #tmp_AbnormalResult rsm 
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
                
                --abnomal Execution_count, n times in-a-row, whatever number of query plans
                --abnomal avgCPU or avg read, n times in-a-row, then            
                -- if 1 query plan mean might different in parameter input  
                -- or if 1 query plan might query text change in query store (after deployment that make query text change) 
                -- if n query plan mean plan changed    

                UPDATE a 
                SET 
                    isExclude = 0
                FROM #tmp_AbnormalResult a 
                    INNER JOIN @tb_DataQueryStore b ON a.SPName = b.SPName AND a.EventTimeAbnormal = b.EventTime
                WHERE a.LinkedServerName = @LinkServerName AND DBName = @_DBName AND b.rownum = 1 AND b.plan_cnt > 1

                ;WITH cte_query_store AS (
                    SELECT STRING_AGG (CAST(QueryIDs AS VARCHAR(MAX)) + ' (x' + CAST(plan_cnt AS VARCHAR(100)) + ')','<br>') as plan_cnt, EventTime, SPName
                    FROM @tb_DataQueryStore 
                    GROUP BY SPName,EventTime
                )
                UPDATE a 
                SET a.QueryPlan = plan_cnt
                FROM #tmp_AbnormalResult a 
                    INNER JOIN cte_query_store b ON a.SPName = b.SPName AND a.EventTimeAbnormal = b.EventTime

            END TRY
            BEGIN CATCH
                SELECT ERROR_MESSAGE(), @sqlCMD
            END CATCH

        END
       
        UPDATE  #tb_ServersHasQueryStore SET isChecked = 1 WHERE DBName = @_DBName AND LinkedServerName = @LinkServerName
    END
    -- End Process get info query_store

    -- =========================================================================================================================

    DECLARE @Subject VARCHAR(1024) = '[Abnormal Report] Data Checking on '-- + ISNULL(CONVERT(VARCHAR(20), @CheckDate, 105), '' )
    DECLARE @Mail_xml NVARCHAR(MAX), @Mail_body NVARCHAR(MAX), @Mail_header NVARCHAR(MAX)
    
    IF @Debug = 1   
        RAISERROR ('Process Sendmail' , 0, 1) WITH NOWAIT

    -- Process Sendmail
    WHILE (1=1)
    BEGIN
        SELECT TOP 1 @LinkServerName = LinkedServerName, @SrvName=ServerName FROM #tmp_AbnormalResult WHERE isChecked = 0 AND isExclude = 0

        IF @@ROWCOUNT = 0
            BREAK

        SELECT @Subject  = '[Abnormal Report] SP Performance Check - KBT@' + @SrvName
        SET @Mail_header = '<html><body>
                            <h1> Abnormal SP List : </h1>' +
                        '<table border = 1>
                        <tr>
                        <th>Server Name</th>
                        <th>DB Name</th>
                        <th>SP Name</th>
                        <th>Event Time</th>
                        <th>Abnormal Reason</th>   
                        <th>Query Plan Count</th>'   
        SET @Mail_xml = CAST((
            SELECT 
                t.ServerName AS 'td','',
                t.DBName AS 'td','',   
                t.SPName AS 'td','',   
                REPLACE(CONVERT(VARCHAR(16), t.EventTimeAbnormal, 20), '-', '/') AS 'td','',
                t.AbnormalReason + CASE WHEN t.IsAbnormalRecurrent = 1 THEN ' - ( ' + REPLACE(ISNULL(CONVERT(VARCHAR(16), t.From_REventTime, 20),''), '-', '/') + ' - '+
                                        REPLACE(ISNULL(CONVERT(VARCHAR(16), t.To_REventTime, 20),''), '-', '/')  + ' )' 
                                        ELSE '' END AS 'td','' ,
                t.QueryPlan AS 'td',''
            FROM #tmp_AbnormalResult t
            WHERE  isExclude = 0 AND LinkedServerName = @LinkServerName
            ORDER BY  t.DBName , t.SPName, t.EventTimeAbnormal
            FOR XML PATH ('tr'), ELEMENTS
        ) AS NVARCHAR(MAX))

        SET @Mail_body = @Mail_header + REPLACE(@Mail_xml,'&lt;BR&gt;','<br>') + '</table></body> <BR> * (R) : Continuous Abnormality <html>'

        INSERT INTO @tb_SendMail (LinkServerName,Mail_body)
        SELECT @LinkServerName,@Mail_body
        
        -- Send noti mail
         IF @Mail_body IS NOT NULL AND @Debug = 0
         BEGIN
        
            EXEC msdb.dbo.sp_send_dbmail @recipients='lukas.luu@starixsoft.com;evan.trinh@starixsoft.com'
                    , @subject = @subject 
                    , @body = @Mail_body
                    , @body_format = 'HTML'
        END
        
        
        UPDATE #tmp_AbnormalResult SET isChecked = 1 WHERE LinkedServerName = @LinkServerName

        INSERT INTO DBA_AbnormalResultLog (Logdate,ServerName,LinkedServerName,DBName,SPName,EventTimeAbnormal,From_REventTime,To_REventTime,AbnormalReason,QueryPlan,IsAbnormalRecurrent)
        SELECT CAST(@CurrDate AS DATE),ServerName,LinkedServerName,DBName,SPName,EventTimeAbnormal,From_REventTime,To_REventTime,AbnormalReason,QueryPlan,IsAbnormalRecurrent 
        FROM #tmp_AbnormalResult WHERE  isExclude = 0 AND LinkedServerName = @LinkServerName

    END
    -- End Process Sendmail

   SELECT * FROM @tb_SendMail  order by LinkServerName

END

GO
DECLARE @CheckDate DATE = '20241222'
EXEC vnDBA_SP_AbnormalReport @ServerName = 'DB02'
                           , @DBName = ''
                           , @Threshold_ZCore = 3
                           , @Threshold_CV = 0
                           , @SPName = 'Dot_Admin_GetSportsTickerChild'
                           , @CheckDate = @CheckDate
                           , @NumberDateCheck = 1
                           , @Debug = 1 
GO
