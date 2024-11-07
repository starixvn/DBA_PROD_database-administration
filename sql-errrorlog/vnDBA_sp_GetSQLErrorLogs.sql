ALTER PROCEDURE [dbo].[vnDBA_sp_GetSQLErrorLogs]
(	
	  @IntervalMinutes INT = NULL					--specify the number of minutes you want to get the error log. Set the interval time for job setup
	, @LogTextExclusionsStr VARCHAR(MAX) = NULL		--semicolon seperated string of log text exclusions
	, @LogTextExplicitSearchStr VARCHAR(MAX) = NULL	--semicolon seperated string of explicit text to search for 
	, @ProcessInfoExclusionsStr VARCHAR(MAX) = NULL	--semicolon seperated string of process info exclusions
	, @DaysBack INT = NULL							--number of days back you want to check the error log
	, @Startdate DATETIME = NULL					--if you want to search a specific time frame
    , @Enddate DATETIME = NULL						--if you want to search a specific time frame
	, @IsSendMail BIT = 0							--1 sends an email to @Email or @Operator. @Operator overrides @Email
	, @Email VARCHAR(256) = NULL					--email address you want results sent to
	, @Subject VARCHAR(1024) = NULL
	, @IsDebug BIT = 0
)
AS
/*
	Created: 20240816@Evan
	DB: ...-MonDB

	Revisions:
		- 20240816@Evan: Initialize SPs 
			
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Server VARCHAR(256) = (SELECT @@Servername)
	DECLARE @Msg VARCHAR (1000);

	---------------------------------------------------------------------------------
	--variables used for emailing results
	---------------------------------------------------------------------------------
	IF @IsSendMail = 1
	BEGIN
		DECLARE @Error_xml NVARCHAR(MAX)
		DECLARE @Error_body NVARCHAR(MAX)
	END

	---------------------------------------------------------------------------------
	--create tables to be used as exclusions
	---------------------------------------------------------------------------------

	DECLARE @LogTextExclusions TABLE (
		  LogText VARCHAR(4000)
	)
	INSERT INTO @LogTextExclusions
	SELECT value
	FROM STRING_SPLIT(@LogTextExclusionsStr, ';')
	WHERE value <> ''
	
	DECLARE @LogTextExplicitSearch TABLE (
		  LogText VARCHAR(4000)
	)
	INSERT INTO @LogTextExplicitSearch
	SELECT value
	FROM STRING_SPLIT(ISNULL(@LogTextExplicitSearchStr,''), ';')
	
	DECLARE @ProcessInfoExclusions TABLE (
		  ProcessInfo VARCHAR(256)
	)
	INSERT INTO @ProcessInfoExclusions
	SELECT value
	FROM STRING_SPLIT(@ProcessInfoExclusionsStr, ';')
	WHERE value <> ''

	---------------------------------------------------------------------------------
	--set @Hours back to a negative number, so we can go back in time
	---------------------------------------------------------------------------------
	DECLARE @CurrentTime DATETIME = GETDATE()
	
	IF ISNULL(@DaysBack,0) <> 0
	BEGIN
		SET @StartDate = DATEADD(DAY, -@DaysBack, @CurrentTime)
    END
	ELSE IF ISNULL(@IntervalMinutes,0) <> 0
	BEGIN
		SET @StartDate = DATEADD(mi, -@IntervalMinutes, @CurrentTime)
    END
	ELSE IF @Startdate IS NULL AND @Enddate IS NULL
	BEGIN
    	SET @IntervalMinutes = 30 -- default
		SET @StartDate = DATEADD(mi, -@IntervalMinutes, @CurrentTime)
    END
	
	---------------------------------------------------------------------------------
	--handle default subject
	---------------------------------------------------------------------------------

	IF @Subject IS NULL
		SET @Subject = @Server + ' Error Log Report'

	---------------------------------------------------------------------------------
	--handle case sensitivitiy just in case
	--coalation should be handled / customized if need be
	---------------------------------------------------------------------------------

	UPDATE @LogTextExclusions
	SET LogText = LOWER(LogText)

	UPDATE @LogTextExplicitSearch
	SET LogText = LOWER(LogText)

	UPDATE @ProcessInfoExclusions
	SET ProcessInfo = LOWER(ProcessInfo)

	---------------------------------------------------------------------------------
	--get @Operator email if the param was used, otherwise use @Email
	---------------------------------------------------------------------------------

	IF (@Email IS NULL AND @IsSendMail = 1)
	BEGIN
		RAISERROR ('Email is required when @IsSendMail = 1', 16, 1)
		RETURN
	END
	

	---------------------------------------------------------------------------------
	--tables to hold error log results
	---------------------------------------------------------------------------------

	DROP TABLE IF EXISTS #errorLog
	DROP TABLE IF EXISTS #enum

	CREATE TABLE #errorLog (
		  LogDate DATETIME2
		, ProcessInfo VARCHAR(64)
		, LogText VARCHAR(MAX)
	)

	CREATE TABLE #enum (
		   archive INT PRIMARY KEY
		 , log_date SMALLDATETIME
		 , log_size BIGINT
	 );
	DECLARE @minDate SMALLDATETIME, @maxDate SMALLDATETIME, @maxlog_date SMALLDATETIME

	INSERT #enum ( archive, log_date, log_size ) 
	EXEC sys.sp_enumerrorlogs;

	--SELECT @Startdate,@Enddate
	SELECT @maxlog_date = log_date FROM #enum WHERE archive = 0

	IF @IsDebug = 1
	BEGIN
		;WITH cte_enum AS (
			SELECT archive
					, LEAD(log_date) OVER (ORDER BY archive) AS previous_logdate
					, log_date
					, ISNULL(@Enddate,@maxlog_date) AS Enddate
			FROM #enum
		)
		SELECT *,
			CASE WHEN log_date < CAST(CONVERT(VARCHAR, @Startdate, 20) AS DATETIME) OR (Enddate NOT BETWEEN previous_logdate AND log_date AND log_date > Enddate) THEN '' ELSE 'x' END AS CheckIn
		FROM cte_enum 
	END
	
    -- filter out log files we won't use
	;WITH cte_enum AS (
		SELECT archive
				, LEAD(log_date) OVER (ORDER BY archive) AS previous_logdate
				, log_date
				, ISNULL(@Enddate,@maxlog_date) AS Enddate
		FROM #enum
	)
	DELETE e 
	FROM cte_enum AS e 
	WHERE e.archive > 0 AND
		(log_date < CAST(CONVERT(VARCHAR, @Startdate, 20) AS DATETIME) 
			OR (Enddate NOT BETWEEN previous_logdate AND log_date AND log_date > Enddate) )

	SELECT @maxDate = MAX(log_date), @minDate = MIN(log_date) FROM #enum

	IF @IsDebug = 1
	BEGIN
		PRINT ' ========='+@@SERVERNAME+'========= '  + CHAR(10)
		SELECT @Msg = 'CurrentTime: ' +  ISNULL(TRY_CONVERT (VARCHAR(20), @CurrentTime, 120),'null') + CHAR(10)
					+ 'IntervalMinutes: ' +  ISNULL(TRY_CONVERT (VARCHAR(20), @IntervalMinutes),'null') + CHAR(10)
					+ 'DaysBack: ' +  ISNULL(TRY_CONVERT (VARCHAR(20), @DaysBack),'null') + CHAR(10)
					+ 'Startdate: ' +  ISNULL(TRY_CONVERT (VARCHAR(20), @Startdate, 120),'null') + CHAR(10)
					+ 'Enddate: ' +  ISNULL(TRY_CONVERT (VARCHAR(20), @Enddate, 120),'null') + CHAR(10)
					+ 'LogTimeRange [' +  ISNULL(TRY_CONVERT (VARCHAR(20), @minDate, 120),'null') 
						+ ' - ' +  ISNULL(TRY_CONVERT (VARCHAR(20), @maxDate, 120),'null') + ']' + CHAR(10)
					+ 'Logfile No: ['  + (SELECT ISNULL(STRING_AGG(e.archive, ','),'null') FROM #enum AS e ) + ']' + CHAR(10)
	
		PRINT @Msg
	END
	
	/*variables for the variable gods*/
    DECLARE
        @l_log int = 0 /*low log file id*/,
        @h_log int = 0 /*high log file id*/ 
 
	 /*Set the min and max logs we're getting for the loop*/
    SELECT
        @l_log = MIN(e.archive),
        @h_log = MAX(e.archive)
    FROM #enum AS e

	DECLARE @MaxNumberOfLogfiles INT = 100, @i INT
	SET @i = @l_log
	DECLARE @Sql VARCHAR(MAX)
	
	WHILE (@i <= @h_log)
	BEGIN
		
		SET @Sql = 'INSERT INTO #errorLog
		EXEC master.dbo.xp_readerrorlog
			' + CAST(@i AS CHAR(3)) + '
			,1
			," "
			," "
			,''' + CONVERT(VARCHAR(19), @StartDate, 120) + '''
			,' + CASE WHEN @Enddate IS NULL THEN 'null' ELSE 
				'''' + CONVERT(VARCHAR(19), @Enddate, 120) + '''' END + ' 
			,"DESC"
			'
		IF @i >= @MaxNumberOfLogfiles 
			BREAK
			
		EXEC (@Sql)
		SET @i = @i + 1

		IF @IsDebug = 1
		BEGIN
			PRINT @Sql + CHAR(10)
		END
	END
	
	IF @IsSendMail = 0
	BEGIN
		
		SELECT @Server AS ServerName
				, el.LogDate
				, el.ProcessInfo
				, el.LogText
		FROM #errorLog el
			LEFT JOIN @LogTextExclusions ex ON LOWER(el.LogText) LIKE '%' + ex.LogText + '%'
			LEFT JOIN @LogTextExplicitSearch es ON LOWER(el.LogText) LIKE '%' + es.LogText + '%'
			LEFT JOIN @ProcessInfoExclusions pie ON LOWER(el.ProcessInfo) = pie.ProcessInfo
		WHERE ex.LogText IS NULL
			AND es.LogText IS NOT NULL
			AND pie.ProcessInfo IS NULL
			AND LogDate >= @StartDate
		ORDER BY el.LogDate DESC
				, CASE
						WHEN el.LogText LIKE 'Error:%' THEN 1
						ELSE 2
					END
	END

	ELSE

	BEGIN
		IF (
				SELECT COUNT(*)
				FROM #errorLog el
					LEFT JOIN @LogTextExclusions ex ON LOWER(el.LogText) LIKE '%' + ex.LogText + '%'
					LEFT JOIN @LogTextExplicitSearch es ON LOWER(el.LogText) LIKE '%' + es.LogText + '%'
					LEFT JOIN @ProcessInfoExclusions pie ON LOWER(el.ProcessInfo) = pie.ProcessInfo
				WHERE ex.LogText IS NULL
					AND es.LogText IS NOT NULL
					AND pie.ProcessInfo IS NULL
					AND LogDate >= @StartDate
			) > 0
		BEGIN
			SET @Error_xml = CAST((
				SELECT convert(VARCHAR(20), el.LogDate, 120) AS 'td'
					 , ''
					 , el.ProcessInfo AS 'td'
					 , ''
					 , el.LogText AS 'td'
				FROM #errorLog el
					LEFT JOIN @LogTextExclusions ex ON LOWER(el.LogText) LIKE '%' + ex.LogText + '%'
					LEFT JOIN @LogTextExplicitSearch es ON LOWER(el.LogText) LIKE '%' + es.LogText + '%'
					LEFT JOIN @ProcessInfoExclusions pie ON LOWER(el.ProcessInfo) = pie.ProcessInfo
				WHERE ex.LogText IS NULL
					AND es.LogText IS NOT NULL
					AND pie.ProcessInfo IS NULL
					AND LogDate >= @StartDate
				FOR XML PATH ('tr'), ELEMENTS
			) AS NVARCHAR(MAX))

			SET @Error_body = '<html><body><H3>SQL Error Log</H3>
						<table border = 1>
						<tr>
						<th>LogDate</th> <th>ProcessInfo</th> <th>LogText</th>'

			SET @Error_body = @Error_body + @Error_xml + '</table></body><html>'


			SELECT @Subject AS [subject]
				 , @Error_body AS error_body
			--exec msdb..sp_send_dbmail
			--,@Recipients = @Email
			--,@Subject = @Subject
			--,@Body = @Error_body
			--,@Body_format = 'HTML'
		END
	END
END

