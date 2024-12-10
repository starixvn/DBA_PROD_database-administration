-- This stored procedure analyzes the performance of stored procedures
-- @ServerName: The name of the server to connect to
-- @DBName: The name of the database to analyze
-- @SPName: The name of the stored procedure to filter results
-- The procedure collects execution statistics and identifies anomalies
ALTER PROCEDURE vnDBA_SP_AbnormalReport 
   @ServerName VARCHAR(1000)='' ,
    @DBName VARCHAR(1000)='' ,
    @SPName VARCHAR(256)='' ,
    @StdevTime_DayBefore INT  = 4,      -- Define Minimum,Maximum Range
    @StdevTime_TextDays VARCHAR(1000) = NULL,  -- '20240925', -- Define Minimum,Maximum Range
    @Threshold_ZCore FLOAT = 3,
    @Threshold_CV INT = 1,              -- STDEV / AVG
    @FilterDate DATE ='' ,
    @FilterDate_HoursBefore INT = 0 ,    -- Search 
    @Debug BIT = 0
AS
--select @FilterDate = DATEADD(DAY,-1,GETDATE()) 
/*
    Created: @Evan
    DB: 
    Revisions: 
        - @Evan: Initial 
    Param's Explanation:   
        @SPName: Filter SP Name
        @StdevTime_DayBefore = N:  Compare standard deviation on data set N days ago
        @FilterDate_HoursBefore = N:  Filter results by last N hoursr
            
*/


BEGIN

    SET NOCOUNT ON;

    -- Set the current date and time
    DECLARE @CurrDate DATETIME = GETDATE()

    -- Filter range time by param @FilterDate_HoursBefore
    DECLARE @Filter_Todate DATETIME = GETDATE()
    DECLARE @Filter_Fromdate DATETIME = DATEADD(HOUR, -@FilterDate_HoursBefore, @CurrDate)

    -- Filter range time by param @FilterDate
    IF @FilterDate IS NOT NULL
    BEGIN
        SELECT @Filter_Fromdate = @FilterDate
        SELECT @Filter_Todate = CAST(@FilterDate AS DATETIME) + '23:59:59.997';
        SELECT @FilterDate_HoursBefore = -1
    END

    -- Get list linked-server
    DECLARE @tb_ListLinkedServer TABLE (LinkedServerName VARCHAR(256) , IsCheck BIT DEFAULT(0), ErrMsg  VARCHAR(1000), sqlcmd varchar(max))
     
    INSERT INTO @tb_ListLinkedServer (LinkedServerName)
    SELECT DISTINCT linkedServer 
    FROM vnDBA_Perf_Servers c WITH (NOLOCK) 
    WHERE linkedServer IS NOT NULL AND isMonitored = 1 AND (@ServerName = '' OR c.linkedServer IN (SELECT value FROM string_split (@ServerName,',')))
    AND linkedServer not in (
    'DBDIST03KBT','DBGRP01N1KBT','DBGRP01N2KBT','DBGRP02N1KBT','DBGRP02N2KBT','DBGRP03N1KBT','DBGRP03N2KBT','DBTP02C_INST2'
    ,'DBDW2KBT','DBODDSC1KBT','DBODDSC2KBT')

    --Could not find stored procedure 'MonDB.dbo.vnDBA_sp_GetPlanCount'.
    --DBDW2KBT
    --DBODDSC1KBT
    --DBODDSC2KBT


    DROP TABLE IF EXISTS #tmp_MonReport_Statistics
    DROP TABLE IF EXISTS #tmp_MonReport
    DROP TABLE IF EXISTS #tmp_AbnormalResult
    DROP TABLE IF EXISTS #tb_AbnormalList
    DROP TABLE IF EXISTS #tb_AbnormalList_temp
    DROP TABLE IF EXISTS #tb_query_store_state

    -- Get info Mon_SPPF_Report
    CREATE TABLE #tmp_MonReport (
          SPID INT, SPName VARCHAR(256), ServerName VARCHAR(256), DBName VARCHAR(256)
        , Execution_count DECIMAL(22,3), CPUTime DECIMAL(22,3), LogicalReads DECIMAL(22,3)
        , ElapsedTime DECIMAL(22,3)
        , TimeRange INT, EventTime SMALLDATETIME
        , ExecCount_Per_minute DECIMAL(22,3), CPUTime_Per_minute DECIMAL(22,3)
        , LogicalReads_Per_minute DECIMAL(22,3), ElapsedTime_Per_minute DECIMAL(22,3)
        , RowNo INT
    )
    CREATE CLUSTERED INDEX [IX_tmpMonReport_SPID] ON #tmp_MonReport (SPID, EventTime)

    -- Get statistics
    CREATE TABLE #tmp_MonReport_Statistics (
          SPID INT
        , Avg_ExecutionCount DECIMAL(22,3), Avg_CPUTime DECIMAL(22,3)
        , Avg_LogicalReads DECIMAL(22,3), Avg_ElapsedTime DECIMAL(22,3)
        , StdDev_ExecutionCount DECIMAL(22,3), StdDev_CPUTime DECIMAL(22,3)
        , StdDev_LogicalReads DECIMAL(22,3), StdDev_ElapsedTime DECIMAL(22,3)
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

    DECLARE @AbnormalPoint SMALLINT = 3; -- 

    CREATE TABLE #tb_query_store_state  (
        ServerName VARCHAR(256), LinkedServerName VARCHAR(256)
        , DBName VARCHAR(256), QueryStoreState VARCHAR(8)
        , isChecked BIT DEFAULT ((0))
    )
    DECLARE @tb_query_store_info TABLE (
        SPName VARCHAR(256),query_id BIGINT,plan_cnt SMALLINT, rownum INT, QueryIDs VARCHAR(MAX)
    )

    DECLARE @Yesterdate SMALLDATETIME = DATEADD(DAY,-1,@CurrDate)
    DECLARE @Msg VARCHAR (500)
    DECLARE @sqlCMD NVARCHAR(MAX), @textDay VARCHAR(8) , @LinkServerName VARCHAR(256) , @SrvName VARCHAR(256) 
    DECLARE @Json VARCHAR(MAX);
    DECLARE @_DBName VARCHAR(256);

    -- List Scan date 
    DECLARE @tb_RangeDate TABLE (textDay VARCHAR(8), IsCheck BIT)
    -- Get range time to calculate Standard deviation (STDEV)
    IF EXISTS (SELECT 1 FROM STRING_SPLIT (@StdevTime_TextDays,',') WHERE VALUE <> '')
    BEGIN
        INSERT INTO @tb_RangeDate  (textDay,IsCheck)
        SELECT VALUE, 0 FROM STRING_SPLIT (@StdevTime_TextDays,',') WHERE VALUE <> ''
    END
    ELSE
    BEGIN
        SET @Msg = 'Get data Mon_SPPF_Report from Todate - (Todate - '+CAST(@StdevTime_DayBefore as varchar(2))+')'

        WHILE (@StdevTime_DayBefore >= 0) BEGIN
            INSERT INTO @tb_RangeDate  (textDay,IsCheck)
            SELECT CONVERT(VARCHAR(8), DATEADD(DAY, -@StdevTime_DayBefore, @CurrDate), 112), 0
            SET @StdevTime_DayBefore = @StdevTime_DayBefore - 1
        END
    END

    -- Process each linked server get info Mon_SPPF_Report
    RAISERROR (@Msg , 0, 1) WITH NOWAIT
    
    WHILE EXISTS (SELECT TOP 1 1 FROM @tb_ListLinkedServer WHERE IsCheck = 0)
    BEGIN TRY
        SELECT TOP 1 @LinkServerName = LinkedServerName
        FROM @tb_ListLinkedServer WHERE IsCheck = 0

        SET @Msg = CHAR(9) + 'Processing: ' + @LinkServerName
        RAISERROR (@Msg , 0, 1) WITH NOWAIT

        -- Delete temp data
        TRUNCATE TABLE #tmp_MonReport
        TRUNCATE TABLE #tmp_MonReport_Statistics

        -- Reset @tb_RangeDate for next server
        UPDATE @tb_RangeDate  SET IsCheck = 0
    
        -- Loop through RangeDate
        WHILE EXISTS (SELECT 1 FROM @tb_RangeDate  WHERE IsCheck = 0)
        BEGIN
            SELECT TOP 1  @textDay =  textDay
            FROM @tb_RangeDate  WHERE IsCheck = 0
        
            SET @sqlCMD = '
                INSERT INTO #tmp_MonReport (SPID, SPName, ServerName, DBName, Execution_count, CPUTime, LogicalReads, ElapsedTime, TimeRange, EventTime, 
                                            ExecCount_Per_minute, CPUTime_Per_minute, LogicalReads_Per_minute, ElapsedTime_Per_minute, RowNo)
                SELECT * 
                FROM OPENQUERY('+QUOTENAME(@LinkServerName)+',
                        ''SELECT a.SPID
                                , b.SPName
                                , @@SERVERNAME
                                , b.DBName
                                , Execution_count
                                , cpu_time AS CPUTime
                                , logical_reads AS LogicalReads
                                , elapsed_time AS r
                                , TimeRange
                                , EventTime
                                , CEILING(CAST(Execution_count / ISNULL(TimeRange, 1) AS DECIMAL(22,3)))
                                , CAST(cpu_time/ Execution_count / ISNULL(TimeRange, 1) /1000 AS DECIMAL(22,3))
                                , CAST(logical_reads/ Execution_count  / ISNULL(TimeRange, 1) AS DECIMAL(22,3))
                                , CAST(CONVERT(FLOAT,elapsed_time)/ Execution_count / ISNULL(TimeRange, 1) /1000000 AS DECIMAL(22,3))
                                , ROW_NUMBER() OVER (PARTITION BY a.SPID, CAST(a.EventTime AS DATE) ORDER BY a.EventTime)
                        FROM MonDB.dbo.Mon_SPPF_Report a WITH (NOLOCK)
                            INNER JOIN MonDB.dbo.Mon_SPPF_List b WITH (NOLOCK) ON a.SPID = b.SPID
                        WHERE '
                            + CASE WHEN @DBName <> '' THEN 'b.DBName IN (SELECT VALUE FROM string_split( '''''+@DBName+''''','''','''')) AND ' ELSE '' END 
                            + CASE WHEN @SPName <> '' THEN '(b.SPName = '''''+@SPName+''''') AND ' ELSE '' END 
                                + 'textDay = '''''+@textDay+'''''
                            AND Execution_count <> 0''
                )
            '
        --select @sqlcmd
            EXEC sp_executesql @sqlcmd
            UPDATE @tb_RangeDate  SET IsCheck = 1 WHERE textDay = @textDay
        END

        -- Filter out stored procedures that start with 'sp_MS' to exclude system procedures
        DELETE #tmp_MonReport WHERE SPName LIKE 'sp_MS%' OR SPName LIKE 'Repl_%' OR  SPName LIKE 'vndba_%' 
        
        -- Remove SPs that are executed non-consecutive
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
        WHERE SPID IN (SELECT a.SPID FROM cte_AvgExecPerHour a WHERE a.avg_ExecutionCountPerHour < 50)

        ;WITH cte_avgstdev AS
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
            GROUP BY SPID
        )

        INSERT INTO #tmp_MonReport_Statistics (SPID, Avg_ExecutionCount, Avg_CPUTime, Avg_LogicalReads, Avg_ElapsedTime, 
            StdDev_ExecutionCount, StdDev_CPUTime, StdDev_LogicalReads, StdDev_ElapsedTime)
        SELECT SPID , Avg_ExecutionCount , Avg_CPUTime , Avg_LogicalReads , Avg_ElapsedTime , 
            StdDev_ExecutionCount , StdDev_CPUTime , StdDev_LogicalReads , StdDev_ElapsedTime
        FROM cte_avgstdev

        --code get abnormal
        IF @Debug = 1 
        BEGIN
            SELECT @Filter_Fromdate Fromdate ,@Filter_Todate  Todate, (SELECT STRING_AGG(textDay,'; ') from @tb_RangeDate ) as checkdate
              
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
                                
                            , CASE WHEN StdDev_ExecutionCount = 0 THEN 0 ELSE CAST((ExecCount_Per_minute - Avg_ExecutionCount) / StdDev_ExecutionCount AS DECIMAL(8,3)) END AS ExecCount_ZCore
                            , CASE WHEN StdDev_CPUTime = 0 THEN 0 ELSE CAST((CPUTime_Per_minute - Avg_CPUTime) / StdDev_CPUTime AS DECIMAL(8,3)) END AS CPUTime_ZCore
                            , CASE WHEN StdDev_ElapsedTime = 0 THEN 0 ELSE CAST((ElapsedTime_Per_minute - Avg_ElapsedTime) / StdDev_ElapsedTime AS DECIMAL(8,3)) END AS ElapsedTime_ZCore
                            , CASE WHEN StdDev_LogicalReads = 0 THEN 0 ELSE CAST((LogicalReads_Per_minute - Avg_LogicalReads) / StdDev_LogicalReads AS DECIMAL(8,3)) END AS LogicalReads_ZCore
                    ) b
                WHERE (EventTime BETWEEN @Filter_Fromdate AND @Filter_Todate OR @FilterDate_HoursBefore = 0)
                   -- AND (Is_ExecutionCount_Abnomaly = 1 OR Is_CPUTime_Abnomaly = 1 OR Is_ElapsedTime_Abnomaly = 1 OR Is_LogicalReads_Abnomaly = 1)
            )
            SELECT 
            SPID ,SPRowID , SPName , ServerName  , DBName ,EventDate , EventTime , ExecCount_Per_minute , CPUTime_Per_minute , LogicalReads_Per_minute
                , ElapsedTime_Per_minute , AbnormalReason
                , ExecCount_ZCore , CPUTime_ZCore , LogicalReads_ZCore , ElapsedTime_ZCore, RowNo
                --, LEAD(SPRowID) OVER (PARTITION BY SPID, CAST(EventTime AS DATE) ORDER BY EventTime) - SPRowID AS DiffNextPoint
            FROM cte_result
            ORDER BY EventTime

        END
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
                                
                        , CASE WHEN StdDev_ExecutionCount = 0 THEN 0 ELSE CAST((ExecCount_Per_minute - Avg_ExecutionCount) / StdDev_ExecutionCount AS DECIMAL(8,3)) END AS ExecCount_ZCore
                        , CASE WHEN StdDev_CPUTime = 0 THEN 0 ELSE CAST((CPUTime_Per_minute - Avg_CPUTime) / StdDev_CPUTime AS DECIMAL(8,3)) END AS CPUTime_ZCore
                        , CASE WHEN StdDev_ElapsedTime = 0 THEN 0 ELSE CAST((ElapsedTime_Per_minute - Avg_ElapsedTime) / StdDev_ElapsedTime AS DECIMAL(8,3)) END AS ElapsedTime_ZCore
                        , CASE WHEN StdDev_LogicalReads = 0 THEN 0 ELSE CAST((LogicalReads_Per_minute - Avg_LogicalReads) / StdDev_LogicalReads AS DECIMAL(8,3)) END AS LogicalReads_ZCore
                ) b
            WHERE (EventTime BETWEEN @Filter_Fromdate AND @Filter_Todate OR @FilterDate_HoursBefore = 0)
                AND (Is_ExecutionCount_Abnomaly = 1 OR Is_CPUTime_Abnomaly = 1 OR Is_ElapsedTime_Abnomaly = 1 OR Is_LogicalReads_Abnomaly = 1)
        )
        INSERT INTO #tb_AbnormalList_temp (SPID, SPRowID , SPName , ServerName  , DBName , EventDate, EventTime , ExecCount_Per_minute , CPUTime_Per_minute , LogicalReads_Per_minute , 
        ElapsedTime_Per_minute , AbnormalReason, ExecCount_ZCore , CPUTime_ZCore , LogicalReads_ZCore , ElapsedTime_ZCore, RowNo) --, DiffNextPoint
        SELECT 
        SPID ,SPRowID , SPName , ServerName  , DBName ,EventDate , EventTime , ExecCount_Per_minute , CPUTime_Per_minute , LogicalReads_Per_minute
            , ElapsedTime_Per_minute , AbnormalReason
            , ExecCount_ZCore , CPUTime_ZCore , LogicalReads_ZCore , ElapsedTime_ZCore, RowNo
            --, LEAD(SPRowID) OVER (PARTITION BY SPID, CAST(EventTime AS DATE) ORDER BY EventTime) - SPRowID AS DiffNextPoint
        FROM cte_result

        INSERT INTO #tb_AbnormalList (SPID , SPName , ServerName , LinkedServerName , DBName , EventTime , EventDate , ExecCount_Per_minute , 
                CPUTime_Per_minute , LogicalReads_Per_minute , ElapsedTime_Per_minute , AbnormalReason , ExecCount_ZCore , CPUTime_ZCore , LogicalReads_ZCore , 
                ElapsedTime_ZCore , IsAbnormalRecurrent, SPRowID)
        SELECT SPID , SPName , ServerName , @LinkServerName , DBName , EventTime , EventDate ,  ExecCount_Per_minute , 
        CPUTime_Per_minute , LogicalReads_Per_minute , ElapsedTime_Per_minute , AbnormalReason , ExecCount_ZCore , CPUTime_ZCore , LogicalReads_ZCore , 
        ElapsedTime_ZCore , 0 AS IsAbnormalRecurrent , SPRowID
        FROM #tb_AbnormalList_temp  
        WHERE RowNo = 1

        -- Calculate the zCore value around the anomaly point; if it below the threshold, exclude it.
        ;WITH cte_AbnormalRecurrent  AS
        (
            SELECT a.SPID, MIN (a.SPRowID) SPRowID, a.EventDate
            FROM #tb_AbnormalList a INNER JOIN #tb_AbnormalList_temp b ON a.SPID = b.SPID 
                AND b.SPRowID  BETWEEN -(@AbnormalPoint - 1) + a.SPRowID AND (@AbnormalPoint - 1) + a.SPRowID
                AND a.EventDate = b.EventDate
            GROUP BY a.SPID, a.EventDate
            HAVING COUNT(a.SPID) >= @AbnormalPoint
        )
        UPDATE  a 
        SET 
            IsAbnormalRecurrent = 1
        FROM #tb_AbnormalList a INNER JOIN cte_AbnormalRecurrent b 
        ON a.SPID = b.SPID AND a.EventDate = b.EventDate AND a.SPRowID = b.SPRowID

        --------------------
        ;WITH cte_GetFromToEventTime  AS
        (
            SELECT a.SPID, MIN (b.EventTime) FromEventTime, MAX (b.EventTime) ToEventTime, MIN (a.SPRowID) SPRowID, a.EventDate
            FROM #tb_AbnormalList a INNER JOIN #tb_AbnormalList_temp b ON a.SPID = b.SPID 
                AND a.EventDate = b.EventDate
            WHERE IsAbnormalRecurrent = 1
            GROUP BY a.SPID, a.EventDate
        )
        UPDATE  a 
        SET 
            a.FromEventTime = b.FromEventTime,
            a.ToEventTime = b.ToEventTime
        FROM #tb_AbnormalList a INNER JOIN cte_GetFromToEventTime b 
        ON a.SPID = b.SPID AND a.EventDate = b.EventDate AND a.SPRowID = b.SPRowID

        -- Get final sendmail
        INSERT INTO #tmp_AbnormalResult (SPName, ServerName, LinkedServerName, DBName, EventTimeAbnormal, From_REventTime, To_REventTime, AbnormalReason, QueryPlan, IsAbnormalRecurrent, isExclude)
        SELECT a.SPName, a.ServerName, a.LinkedServerName, a.DBName, a.EventTime, a.FromEventTime, a.ToEventTime, 
            'High: ' + a.AbnormalReason + CASE WHEN a.IsAbnormalRecurrent = 1 THEN ' (R)' ELSE '' END, 'Not Found', a.IsAbnormalRecurrent, 
            IIF(a.IsAbnormalRecurrent = 0, 1 , 0) AS isExclude
        FROM #tb_AbnormalList a 

        TRUNCATE TABLE  #tb_AbnormalList
        TRUNCATE TABLE  #tb_AbnormalList_temp

        -- get query store state
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
        INSERT INTO #tb_query_store_state (LinkedServerName, ServerName, DBName, QueryStoreState)
        EXEC sp_executesql @sqlcmd

        UPDATE @tb_ListLinkedServer SET IsCheck = 1 WHERE LinkedServerName = @LinkServerName
    END TRY
    BEGIN CATCH
        SELECT @LinkServerName, ERROR_MESSAGE() AS ErrorMessage;
        UPDATE @tb_ListLinkedServer SET IsCheck = 1 WHERE LinkedServerName = @LinkServerName
    END CATCH
    -- End Process get info Mon_SPPF_Report
    
    -- =========================================================================================================================

    -- Process each linked server get info query_store
    WHILE EXISTS (SELECT TOP 1 1 FROM #tb_query_store_state WHERE isChecked = 0)
    BEGIN
        DELETE FROM @tb_query_store_info

        SELECT TOP 1 @LinkServerName = LinkedServerName , @_DBName = DBName 
        FROM #tb_query_store_state WHERE isChecked = 0
        
        --Convert table to JSON
        SELECT @json = 
        (
            SELECT 
                rsm.SPName,
                CONVERT(VARCHAR(25),rsm.EventTimeAbnormal,121) AS EventTime
            FROM 
                #tmp_AbnormalResult rsm 
            WHERE rsm.DBName = @_DBName AND rsm.LinkedServerName = @LinkServerName
            FOR JSON PATH
        );


        -- Execute remote procedure to get plan count
        SELECT @sqlCMD = N'EXEC '+ @LinkServerName +'.MonDB.dbo.vnDBA_sp_GetPlanCount @DBName = '''+@_DBName+''', @SPList = ''' + ISNULL(@json,'') +''', @IntervalMin = 30 '
        
        IF @json IS NOT NULL 
        BEGIN 
             BEGIN TRY
                
                INSERT INTO @tb_query_store_info (SPName,QueryIDs,plan_cnt,rownum)
                EXEC sp_executesql @sqlCMD
                
                 --abnomal Execution_count, n times in-a-row, whatever number of query plans
                --abnomal avgCPU or avg read, n times in-a-row, then            
                -- if 1 query plan mean might different in parameter input  
                -- or if 1 query plan might query text change in query store (after deployment that make query text change) 
                -- if n query plan mean plan changed    

                UPDATE a 
                SET 
                    isExclude = CASE WHEN b.plan_cnt = 1 AND a.IsAbnormalRecurrent = 0 AND AbnormalReason NOT LIKE '%ExecutionCount%' THEN 1 ELSE 0 END
                FROM #tmp_AbnormalResult a 
                    INNER JOIN @tb_query_store_info b ON a.SPName = b.SPName
                WHERE a.LinkedServerName = @LinkServerName AND DBName = @_DBName AND b.rownum = 1

                ;WITH cte_query_store AS (
                    SELECT STRING_AGG (CAST(QueryIDs AS VARCHAR(MAX)) + ' (x' + CAST(plan_cnt AS VARCHAR(100)) + ')','<br>') as plan_cnt, SPName
                    FROM @tb_query_store_info 
                    GROUP BY SPName
                )
                UPDATE a 
                SET a.QueryPlan = plan_cnt
                FROM #tmp_AbnormalResult a 
                    INNER JOIN cte_query_store b ON a.SPName = b.SPName

            END TRY
            BEGIN CATCH
                SELECT ERROR_MESSAGE(), @sqlCMD
            END CATCH

        END
       
        UPDATE  #tb_query_store_state SET isChecked = 1 WHERE DBName = @_DBName AND LinkedServerName = @LinkServerName
    END
    -- End Process get info query_store

    -- =========================================================================================================================

    DECLARE @Subject VARCHAR(1024) = '[Abnormal Report] Data Checking on '-- + ISNULL(CONVERT(VARCHAR(20), @FilterDate, 105), '' )
    DECLARE @Mail_xml NVARCHAR(MAX), @Mail_body NVARCHAR(MAX), @Mail_header NVARCHAR(MAX)
    
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
                                        REPLACE(ISNULL(CONVERT(VARCHAR(16), t.To_REventTime, 20),''), '-', '/')  + ' )' ELSE '' END AS 'td','' ,
                t.QueryPlan AS 'td',''
            FROM #tmp_AbnormalResult t
            WHERE  isExclude = 0 AND LinkedServerName = @LinkServerName
            ORDER BY  t.EventTimeAbnormal
            FOR XML PATH ('tr'), ELEMENTS
        ) AS NVARCHAR(MAX))

        SET @Mail_body = @Mail_header + REPLACE(@Mail_xml,'&lt;BR&gt;','<br>') + '</table></body> <BR> * (R) : Continuous Abnormality <html>'

        INSERT INTO @tb_SendMail (LinkServerName,Mail_body)
        SELECT @LinkServerName,@Mail_body
        
        -- Send noti mail
         IF @Mail_body IS NOT NULL
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

DECLARE @Checkdate DATE = DATEADD(DAY,0,GETDATE()) 
--SELECT @Checkdate
EXEC vnDBA_SP_AbnormalReport @ServerName = 'DBCUSTKBT'
                           , @DBName = 'SiteConfig'
                           , @Threshold_ZCore = 3
                           , @Threshold_CV = 0
                           , @SPName = 'Portal_Sub_GetCurrency'
                           , @FilterDate = @Checkdate
                           , @debug = 0
GO




