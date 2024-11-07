USE [CheckDataDB]
GO
/****** Object:  StoredProcedure [dbo].[vnDBA_sp_Monitor_CollectErrorLogs]    Script Date: 11/7/2024 3:32:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[vnDBA_sp_Monitor_CollectErrorLogs]
(
    @last_n_minute INT = 5
  , @isViewOnly BIT = 0
  , @Env VARCHAR(3) = 'KBT'
)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @Msg VARCHAR (MAX);
    DECLARE @to DATETIME, @from DATETIME
    DECLARE @LogSendNotify TABLE (ServerName VARCHAR(256), ProcessInfo VARCHAR(256), MinDate SMALLDATETIME, MaxDate SMALLDATETIME, MsgLog VARCHAR(MAX), OccurCount SMALLINT, IsSend BIT DEFAULT(0))
    DECLARE @LogServerName VARCHAR(256)

    SELECT @from = VValue
         , @to = DATEADD(MINUTE, @last_n_minute, VValue)
    FROM vnDBA_Configuration WITH (NOLOCK)
    WHERE VName = 'ErrorLogTimer'
	
    IF DATEDIFF(MINUTE, @from, GETDATE()) < @last_n_minute AND @isViewOnly = 0
    BEGIN
        RETURN
    END

    IF @isViewOnly = 1
    BEGIN
        SET @to = GETDATE()
        SET @from = DATEADD(MINUTE, -@last_n_minute, @to)
    END

    -- update new capture time  
    ELSE IF @isViewOnly = 0
    BEGIN
        UPDATE vnDBA_Configuration
        SET VValue = CONVERT(VARCHAR(20), @to, 120)
        WHERE VName = 'ErrorLogTimer'
    END

    -- get list LinkedServer  
    DECLARE @tb_ListLinkedServer TABLE (
          LinkedServerName VARCHAR(128)
        , IsChecked BIT DEFAULT (0)
        , ErrMsg VARCHAR(1000)
        , sqlcmd VARCHAR(MAX)
    )

    INSERT INTO @tb_ListLinkedServer (LinkedServerName)
    SELECT DISTINCT linkedServer
    FROM vnDBA_Perf_Servers c WITH (NOLOCK)
    WHERE isMonitored = 1
		
    DROP TABLE IF EXISTS #ErrorLogData

    CREATE TABLE #ErrorLogData (
          ServerName VARCHAR(256)
        , Logdate DATETIME
        , ProcessInfo VARCHAR(64)
        , msg VARCHAR(2048)
        , CaptureDate DATETIME DEFAULT GETDATE()
    )
    
  
    DECLARE @sqlcmd NVARCHAR(MAX)
          , @LinkServerName VARCHAR(128)
		  , @LogID INT
		  , @rowcount INT

    SELECT @Msg = 'FromDate: ' +  ISNULL(TRY_CONVERT (VARCHAR(20), @from, 120),'null') + CHAR(10)
                + 'ToDate: ' +  ISNULL(TRY_CONVERT (VARCHAR(20), @to, 120),'null') + CHAR(10)
    PRINT @msg

    SET @msg = 'Get SQL Server ErrorLog from '''+ CONVERT(VARCHAR(20), @from, 120)+ ''' to '''+ CONVERT(VARCHAR(20), @to, 120)+ ''' ' + CHAR(10)
    SET @msg = 'List Linked Server: ' 
    SELECT @Msg = @Msg + STRING_AGG(LinkedServerName,' ,') FROM @tb_ListLinkedServer WHERE ErrMsg IS NULL
    
    IF @isViewOnly = 1
        PRINT @msg

    -- get data error log from each linked server  
    WHILE EXISTS (
            SELECT TOP 1 1
            FROM @tb_ListLinkedServer
            WHERE IsChecked = 0
        )
    BEGIN

        BEGIN TRY
            SELECT TOP 1 @LinkServerName = LinkedServerName
            FROM @tb_ListLinkedServer
            WHERE IsChecked = 0
            ORDER BY LinkedServerName

            SELECT @sqlcmd = N'EXEC ' + QUOTENAME(@LinkServerName) + '.MonDB.dbo.vnDBA_sp_GetSQLErrorLogs @Startdate = ''' + CONVERT(VARCHAR(20), @from, 120) + ''',@Enddate = ''' + CONVERT(VARCHAR(20), @to, 120) + ''''
            
            IF @isViewOnly = 1
                PRINT @sqlcmd

            INSERT INTO #ErrorLogData (ServerName, Logdate, ProcessInfo, msg)
            EXEC sp_executesql @sqlcmd
			SET @rowcount = @@ROWCOUNT
			 
			INSERT INTO vnDBA_JobbsErrorLog_Log (Logdate,LogText, ErrorMsg)
			VALUES (GETDATE(), '@isViewOnly = ' + CAST(@isViewOnly AS varchar(10)) + '; ' + @sqlcmd, 'Rowcount: ' + CAST(@rowcount AS varchar(20)))

            UPDATE @tb_ListLinkedServer
            SET IsChecked = 1
              , sqlcmd = @sqlcmd
            WHERE LinkedServerName = @LinkServerName

        END TRY
        BEGIN CATCH

            SELECT @Msg = ERROR_MESSAGE()

            UPDATE @tb_ListLinkedServer
            SET ErrMsg = @Msg
              , sqlcmd = @sqlcmd
              , IsChecked = 1
            WHERE LinkedServerName = @LinkServerName

            INSERT INTO vnDBA_JobbsErrorLog_Log (Logdate,LogText, ErrorMsg)
            VALUES (GETDATE(), '@isViewOnly = ' + CAST(@isViewOnly AS varchar(10)) + '; ' + @sqlcmd, 'Rowcount: ' + CAST(@rowcount AS varchar(20)))

        END CATCH

    END

  -- Delete exclusions
    DELETE [i] 
    FROM #ErrorLogData [i] 
        INNER JOIN dbo.vnDBA_ExclusionList [li] WITH(NOLOCK) ON [i].msg LIKE [li].[ExcludeText]
	WHERE li.IsActive = 1 
   
    IF @isViewOnly = 1
    BEGIN
        IF EXISTS (SELECT 1 FROM  @tb_ListLinkedServer WHERE ErrMsg IS NOT NULL)
        BEGIN   
            SELECT LinkedServerName, sqlcmd, ErrMsg FROM @tb_ListLinkedServer WHERE ErrMsg IS NOT NULL
        END

        SELECT ServerName , LogDate , ProcessInfo , msg , CaptureDate
        FROM #ErrorLogData
        ORDER BY ServerName, LogDate

    END
    ELSE
    BEGIN
        
        INSERT INTO vnDBA_SQLErrorLogs (ServerName, LogDate, ProcessInfo, msg, CaptureDate)
        SELECT ServerName
             , LogDate
             , ProcessInfo
             , msg
             , CaptureDate
        FROM #ErrorLogData

    END

    INSERT INTO @LogSendNotify(ServerName,ProcessInfo,MsgLog,OccurCount,MinDate, MaxDate)
    SELECT ServerName, ProcessInfo, msg, COUNT(1), MIN(LogDate), MAX(LogDate)
    FROM #ErrorLogData 
    GROUP BY ServerName, ProcessInfo, msg

    SELECT @Msg = '**SQL Server Log Error Detected**' + CHAR(13)+CHAR(13)

    WHILE EXISTS(SELECT 1 FROM @LogSendNotify WHERE IsSend = 0)
    BEGIN
        SELECT @Msg = '**SQL Server Log Errors**' + CHAR(13)+CHAR(13)

        SELECT TOP 1 @LogServerName = ServerName FROM @LogSendNotify WHERE IsSend = 0

        SELECT @Msg = @Msg + 'Server Name: ' + @LogServerName + @Env + CHAR(13)+CHAR(13) + 'Log Date: ' + CONVERT(VARCHAR(20), @from, 120)+ ' - ' + CONVERT(VARCHAR(20), @to, 120) 
            + CHAR(13)+CHAR(13) + 'Errors' + CHAR(13)+CHAR(13)
            
        ;WITH cte_log AS (
            SELECT ProcessInfo
			, STRING_AGG(REPLACE(REPLACE(REPLACE(MsgLog, CHAR(9), ''), CHAR(10), ''), CHAR(13), ''),'' + CHAR(13) + CHAR(13)+ CHAR(9)) WITHIN GROUP (ORDER BY CASE WHEN MsgLog LIKE 'Error:%' THEN 1 ELSE 2 END) MsgLog
			, SUM(OccurCount)/Count(ProcessInfo) OccurCount
            FROM @LogSendNotify 
            WHERE ServerName = @LogServerName 
            GROUP BY ProcessInfo,MinDate )
		, cte_log_group AS (
			SELECT MsgLog
				, SUM(OccurCount) OccurCount
				, ROW_NUMBER() OVER(ORDER BY MsgLog) stt
			FROM cte_log
			GROUP BY MsgLog )
		
        SELECT @Msg = @Msg + CAST(stt AS VARCHAR(20)) + '. ' + MsgLog + ' **(x' + CAST(OccurCount AS VARCHAR(20)) + ')**' + CHAR(13)+CHAR(13)
        FROM cte_log_group

        UPDATE a SET a.IsSend = 1 FROM @LogSendNotify a WHERE ServerName = @LogServerName
		
		IF @isViewOnly = 0
		BEGIN
			EXEC KBTDBTP.NotificationDB.dbo.DBA_Skype_NewMessage 
						@ServerName = N'PONTUS'
						, @JobId = NULL
						, @JobName = N'Custom MessageBot'
						, @Message = @Msg
						, @CaseId = 1;
		END
		ELSE 
			BEGIN
				SELECT @Msg
			END
		END

END
