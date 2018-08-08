/*<info serverAlias="DB06-MonDB,DB052-MonDB,DB053-MonDB,DB05-MonDB" executers="bodbAdminNet,vnteam,vndba" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
USE [MONDB]
GO
ALTER PROCEDURE [vndba_sp_trace]
	@TraceTimer INT = 30,
	@AppNameLike NVARCHAR(30) = '',
	@LoginNameLike NVARCHAR(30),
	@DatabaseNameLike NVARCHAR(30),
	@DatabaseNameLike2 NVARCHAR(30) = '',		
	@MinCPU INT = 0,
	@TextDataLike NVARCHAR(256),
	@TextDataLike2 NVARCHAR(256) = '',
	@TextDataLike3 NVARCHAR(256) = '',
	@TextDataLike4 NVARCHAR(256) = '',
	@TraceStartEvents BIT = 0,
	@Mode TINYINT = 0,
	@HasError BIT = 0 OUTPUT,
	@ErrorMsg VARCHAR(200) = '' OUTPUT	
AS
/*
		Created: Daniel
		Date: 20160819
		Task: Trace SP/sql statements, for SQL profiler alternative
		DB: All servers - db master
		
		Revisions:
			20170712@Daniel: Add write column data
		
		Parameter's Explanation:
		  . @TraceTimer: Set trace duration string in seconds, not allow set more than 30min/1800s
		  . @TraceStartEvents: Include trace starting events, in case commands started but cannot complete due to problem or long run time-out queries
		  . @Mode: run mode
		    + 0: User need to wait for trace done then get the result
		    + 1: Expert mode, just start trace and return trace info  for user to check later
		  
--Sample test:		  
EXEC dbo.DBA_TraceX
	@TraceTimer = 600,
	@LoginNameLike = 'bodb%',
	@DatabaseNameLike = 'bodb02',
	@MinCPU = 0,
	@TextDataLike = '%EXEC%',
	@TraceStartEvents = 0
		  
*/

SET NOCOUNT ON

--Safety checks
IF (ISNULL(@TraceTimer,0) > 1800)
BEGIN
	SET @ErrorMsg = 'Error:  Not allow to run trace for more than 30 minutes'
	SET @HasError = 1
	PRINT @ErrorMsg
	RETURN
END
IF (ISNULL(@TraceTimer,0) > 120 AND @Mode = 0)
BEGIN
	SET @ErrorMsg = 'Error:  Not allow long-running trace more than 2 minutes in express mode'
	SET @HasError = 1
	RETURN
END

IF CHARINDEX('%', ISNULL(@LoginNameLike,'')) > 0 --not exact search
BEGIN
	IF (LEN(ISNULL(REPLACE(@LoginNameLike, '%', ''),'')) < 3)
	BEGIN
		SET @ErrorMsg = 'Error:  Filter @LoginNameLike is too short or not set. Please set at least 3 characters, not including wildcard %'
		SET @HasError = 1
		PRINT @ErrorMsg
		RETURN
	END
END
ELSE--exact search
BEGIN
	IF (LEN(ISNULL(@LoginNameLike,'')) = 0)
	BEGIN
		SET @ErrorMsg = 'Error:  Filter @LoginNameLike is empty or not set'
		SET @HasError = 1
		PRINT @ErrorMsg
		RETURN
	END
END

IF CHARINDEX('%', ISNULL(@DatabaseNameLike,'')) > 0 --not exact search
BEGIN
	IF (LEN(ISNULL(REPLACE(@DatabaseNameLike, '%', ''),'')) < 3)
	BEGIN
		SET @ErrorMsg = 'Error:  Filter @DatabaseNameLike is too short or not set. Please set at least 3 characters, not including wildcard %'
		SET @HasError = 1
		PRINT @ErrorMsg
		RETURN
	END
END
ELSE--exact search
BEGIN
	IF (LEN(ISNULL(@DatabaseNameLike,'')) = 0)
	BEGIN
		SET @ErrorMsg = 'Error:  Filter @DatabaseNameLike is empty or not set'
		SET @HasError = 1
		PRINT @ErrorMsg
		RETURN
	END
END
IF CHARINDEX('%', ISNULL(@DatabaseNameLike2,'')) > 0 --not exact search
BEGIN
	IF (LEN(ISNULL(REPLACE(@DatabaseNameLike2, '%', ''),'')) < 3)
	BEGIN
		SET @ErrorMsg = 'Error:  Filter @DatabaseNameLike2 is too short. Please set at least 3 characters, not including wildcard %'
		SET @HasError = 1
		PRINT @ErrorMsg
		RETURN
	END
END


IF CHARINDEX('%', ISNULL(@TextDataLike,'')) > 0 --not exact search
BEGIN
	IF (LEN(ISNULL(REPLACE(@TextDataLike, '%', ''),'')) < 4)
	BEGIN
		SET @ErrorMsg = 'Error:  Filter @TextDataLike is too short or not set. Please set at least 4 characters, not including wildcard %'
		SET @HasError = 1
		PRINT @ErrorMsg
		RETURN
	END
END
ELSE --exact search
BEGIN
	IF (LEN(ISNULL(@TextDataLike,'')) = 0)
	BEGIN
		SET @ErrorMsg = 'Error:  Filter @TextDataLike is empty or not set'
		SET @HasError = 1
		PRINT @ErrorMsg
		RETURN
	END
END
IF CHARINDEX('%', ISNULL(@TextDataLike2,'')) > 0 --not exact search
BEGIN
	IF (LEN(ISNULL(REPLACE(@TextDataLike2, '%', ''),'')) < 4)
	BEGIN
		SET @ErrorMsg = 'Error:  Filter @TextDataLike2 is too short. Please set at least 4 characters, not including wildcard %'
		SET @HasError = 1
		PRINT @ErrorMsg
		RETURN
	END
END
IF CHARINDEX('%', ISNULL(@TextDataLike3,'')) > 0 --not exact search
BEGIN
	IF (LEN(ISNULL(REPLACE(@TextDataLike3, '%', ''),'')) < 4)
	BEGIN
		SET @ErrorMsg = 'Error:  Filter @TextDataLike3 is too short. Please set at least 4 characters, not including wildcard %'
		SET @HasError = 1
		PRINT @ErrorMsg
		RETURN
	END
END
IF CHARINDEX('%', ISNULL(@TextDataLike4,'')) > 0 --not exact search
BEGIN
	IF (LEN(ISNULL(REPLACE(@TextDataLike4, '%', ''),'')) < 4)
	BEGIN
		SET @ErrorMsg = 'Error:  Filter @TextDataLike4 is too short. Please set at least 4 characters, not including wildcard %'
		SET @HasError = 1
		PRINT @ErrorMsg
		RETURN
	END
END

IF((SELECT COUNT(1) FROM sys.traces WHERE is_default = 0 AND status = 1) > 4)
BEGIN
	PRINT 'Sorry! Server already has many traces running, please contact DBA for further instructions.'
	SET @HasError = 1
	PRINT @ErrorMsg
	RETURN
END

DECLARE @CPUBusyPct INT
SELECT top (1) @CPUBusyPct = n.value('(ProcessUtilization)[1]', 'int')
FROM (
      SELECT DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime, 
             CONVERT (xml, record) AS record
      FROM sys.dm_os_ring_buffers CROSS JOIN sys.dm_os_sys_info
      WHERE ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR') AS t
CROSS APPLY record.nodes('/Record/SchedulerMonitorEvent/SystemHealth') AS x(n)
ORDER BY EventTime DESC

IF (@@ERROR <> 0) RETURN

IF(@CPUBusyPct > 30)
BEGIN
	SET @ErrorMsg =  'Sorry! Not allow run trace when server is busy, please contact DBA for further instructions.'
	SET @HasError = 1
	PRINT @ErrorMsg
	RETURN
END 

------------------------END Safety checks -------------------------------------------------
--Create a trace 
DECLARE @id INT, @path NVARCHAR(200), @stoptime DATETIME, @maxfilesize BIGINT = 10
DECLARE @folder NVARCHAR(100)
IF (@@SERVERNAME LIKE 'DB2%') SET @folder =  'D:\TraceFiles\' 
ELSE SET @folder =  'G:\TraceFiles\' 

--Generate trace filename:
SET @path = @folder + 
	REPLACE(CONVERT(VARCHAR(50), SYSTEM_USER), '\', '-') + '-' + 
	CONVERT(VARCHAR(5), @@SPID) + '-' +
	CONVERT(varchar,DATEPART(yy,getdate())) +
	CONVERT(varchar,datepart(mm,getdate())) +
	CONVERT(varchar,datepart(dd,getdate())) +
	CONVERT(varchar,datepart(HH,getdate())) +
	CONVERT(varchar,datepart(MI,getdate())) +
	CONVERT(varchar,datepart(SS,getdate())) +
	CONVERT(varchar,datepart(MS,getdate()))

SET @stoptime = DATEADD(SS, @TraceTimer + 30, GETDATE())

--Treat wildcard char _ as literal
SET @TextDataLike = REPLACE(@TextDataLike, '_', '[_]')
SET @TextDataLike2 = REPLACE(@TextDataLike2, '_', '[_]')
SET @TextDataLike3 = REPLACE(@TextDataLike3, '_', '[_]')
SET @TextDataLike4 = REPLACE(@TextDataLike4, '_', '[_]')
 
EXEC sys.sp_trace_create 
	@traceid = @id OUTPUT,
	@options = 2,
	@tracefile = @path,
	@maxfilesize = @maxfilesize,
	@stoptime = @stoptime,
	@filecount = 4


--Event RPC:Completed
EXEC sys.sp_trace_setevent @id, 10, 1, 1 --TextData
EXEC sys.sp_trace_setevent @id, 10, 8, 1 --Hostname
EXEC sys.sp_trace_setevent @id, 10, 10, 1 --Appname
EXEC sys.sp_trace_setevent @id, 10, 11, 1 --LoginName
EXEC sys.sp_trace_setevent @id, 10, 13, 1--duration
EXEC sys.sp_trace_setevent @id, 10, 14, 1--starttime
EXEC sys.sp_trace_setevent @id, 10, 15, 1--endtime
EXEC sys.sp_trace_setevent @id, 10, 16, 1 --Reads
EXEC sys.sp_trace_setevent @id, 10, 17, 1 --Writes
EXEC sys.sp_trace_setevent @id, 10, 18, 1 --CPU
EXEC sys.sp_trace_setevent @id, 10, 35, 1 --DBName
EXEC sys.sp_trace_setevent @id, 10, 51, 1 --EventSequence	

--Event SQL:BatchCompleted
EXEC sys.sp_trace_setevent @id, 12, 1, 1 --TextData
EXEC sys.sp_trace_setevent @id, 12, 8, 1 --Hostname
EXEC sys.sp_trace_setevent @id, 12, 10, 1 --Appname
EXEC sys.sp_trace_setevent @id, 12, 11, 1 --LoginName
EXEC sys.sp_trace_setevent @id, 12, 13, 1--duration
EXEC sys.sp_trace_setevent @id, 12, 14, 1--starttime
EXEC sys.sp_trace_setevent @id, 12, 15, 1--endtime
EXEC sys.sp_trace_setevent @id, 12, 16, 1 --Reads
EXEC sys.sp_trace_setevent @id, 12, 17, 1 --Writes
EXEC sys.sp_trace_setevent @id, 12, 18, 1 --CPU
EXEC sys.sp_trace_setevent @id, 12, 35, 1 --DBName
EXEC sys.sp_trace_setevent @id, 12, 51, 1 --EventSequence	

IF (@AppNameLike NOT LIKE '%.Net%')
BEGIN
	--Event SP:StmtCompleted
	EXEC sys.sp_trace_setevent @id, 45, 1, 1 --TextData
	EXEC sys.sp_trace_setevent @id, 45, 8, 1 --Hostname
	EXEC sys.sp_trace_setevent @id, 45, 10, 1 --Appname
	EXEC sys.sp_trace_setevent @id, 45, 11, 1 --LoginName
	EXEC sys.sp_trace_setevent @id, 45, 13, 1--duration
	EXEC sys.sp_trace_setevent @id, 45, 14, 1--starttime
	EXEC sys.sp_trace_setevent @id, 45, 15, 1--endtime
	EXEC sys.sp_trace_setevent @id, 45, 16, 1 --Reads
	EXEC sys.sp_trace_setevent @id, 45, 17, 1 --Writes
	EXEC sys.sp_trace_setevent @id, 45, 18, 1 --CPU
	EXEC sys.sp_trace_setevent @id, 45, 35, 1 --DBName
END

IF(@TraceStartEvents = 1)
BEGIN
	--Event RPC:Starting
	EXEC sys.sp_trace_setevent @id, 11, 1, 1 --TextData
	EXEC sys.sp_trace_setevent @id, 11, 8, 1 --Hostname
	EXEC sys.sp_trace_setevent @id, 11, 10, 1 --Appname
	EXEC sys.sp_trace_setevent @id, 11, 11, 1 --LoginName
	EXEC sys.sp_trace_setevent @id, 11, 14, 1--starttime
	EXEC sys.sp_trace_setevent @id, 11, 15, 1--endtime	
	EXEC sys.sp_trace_setevent @id, 11, 35, 1 --DBName
	EXEC sys.sp_trace_setevent @id, 11, 51, 1 --EventSequence	

	--Event SQL:BatchStarting
	EXEC sys.sp_trace_setevent @id, 13, 1, 1 --TextData
	EXEC sys.sp_trace_setevent @id, 13, 8, 1 --Hostname
	EXEC sys.sp_trace_setevent @id, 13, 10, 1 --Appname
	EXEC sys.sp_trace_setevent @id, 13, 11, 1 --LoginName
	EXEC sys.sp_trace_setevent @id, 13, 14, 1--starttime
	EXEC sys.sp_trace_setevent @id, 13, 15, 1--endtime	
	EXEC sys.sp_trace_setevent @id, 13, 35, 1 --DBName
	EXEC sys.sp_trace_setevent @id, 13, 51, 1 --EventSequence	

	IF (@AppNameLike NOT LIKE '%.Net%')
	BEGIN	
		--Event SP:StmtStarting
		EXEC sys.sp_trace_setevent @id, 44, 1, 1 --TextData
		EXEC sys.sp_trace_setevent @id, 44, 8, 1 --Hostname
		EXEC sys.sp_trace_setevent @id, 44, 10, 1 --Appname
		EXEC sys.sp_trace_setevent @id, 44, 11, 1 --LoginName
		EXEC sys.sp_trace_setevent @id, 44, 14, 1--starttime
		EXEC sys.sp_trace_setevent @id, 44, 15, 1--endtime	
		EXEC sys.sp_trace_setevent @id, 44, 35, 1 --DBName
	END	
END

/*
--** Get trace event info:
SELECT
      EventCategory = c.Name
    , EventClass = e.Name
    , EventColumn = t.Name
    , EventID = e.trace_event_id
    , ColumnID = b.trace_column_id, *
FROM sys.trace_categories c
JOIN sys.trace_events e ON e.category_id = c.category_id
JOIN sys.trace_event_bindings b ON b.trace_event_id = e.trace_event_id
JOIN sys.trace_columns t ON t.trace_column_id = b.trace_column_id
WHERE 1=1
	and e.Name LIKE 'SP:stmt%'
	AND b.trace_column_id IN(1,6,8,10,11,13,16,18,35) AND e.trace_event_id = 44
	--AND t.Name IN('loginname','DatabaseName','cpu','textdata')
*/
--Set trace filter on AppName (10)
DECLARE @xVal NVARCHAR(256)
SET @xVal = 'SQL Server Profiler%'
EXEC sys.sp_trace_setfilter 
	@trace_id = @id, 
	@columnid = 10,
	@logical_operator = 0, --AND
	@comparison_operator = 7, --NOT LIKE
	@value = @xVal
IF(ISNULL(@AppNameLike,'') = '') SET @AppNameLike = '%'
EXEC sys.sp_trace_setfilter 
	@trace_id = @id, 
	@columnid = 10,
	@logical_operator = 0, --AND
	@comparison_operator = 6, --LIKE
	@value = @AppNameLike

--Set trace filter on LoginName (11)
--SET @LoginNameLike = '%' + @LoginNameLike + '%'
EXEC sys.sp_trace_setfilter 
	@trace_id = @id, 
	@columnid = 11,
	@logical_operator = 0, --AND
	@comparison_operator = 6, --LIKE
	@value = @LoginNameLike
	
--Set trace filter on @TextDataLike (1)
SET @xVal = N'exec sp_%'
EXEC sys.sp_trace_setfilter 
	@trace_id = @id, 
	@columnid = 1,
	@logical_operator = 0, --AND
	@comparison_operator = 7, --NOT LIKE
	@value = @xVal
EXEC sys.sp_trace_setfilter 
	@trace_id = @id, 
	@columnid = 1,
	@logical_operator = 0, --AND
	@comparison_operator = 6, --LIKE
	@value = @TextDataLike
IF (@TextDataLike2 <> '')
BEGIN
	EXEC sys.sp_trace_setfilter 
		@trace_id = @id, 
		@columnid = 1,
		@logical_operator = 1, --OR
		@comparison_operator = 6, --LIKE
		@value = @TextDataLike2
END	
IF (@TextDataLike3 <> '')
BEGIN
	EXEC sys.sp_trace_setfilter 
		@trace_id = @id, 
		@columnid = 1,
		@logical_operator = 1, --OR
		@comparison_operator = 6, --LIKE
		@value = @TextDataLike3
END	
IF (@TextDataLike4 <> '')
BEGIN
	EXEC sys.sp_trace_setfilter 
		@trace_id = @id, 
		@columnid = 1,
		@logical_operator = 1, --OR
		@comparison_operator = 6, --LIKE
		@value = @TextDataLike4
END	
	
--Set trace filter on @DatabaseNameLike (35)
EXEC sys.sp_trace_setfilter 
	@trace_id = @id, 
	@columnid = 35,
	@logical_operator = 0, --AND
	@comparison_operator = 6, --LIKE
	@value = @DatabaseNameLike
IF (@DatabaseNameLike2 <> '')
BEGIN
	EXEC sys.sp_trace_setfilter 
		@trace_id = @id, 
		@columnid = 35,
		@logical_operator = 1, --OR
		@comparison_operator = 6, --LIKE
		@value = @DatabaseNameLike2
END	

--Set trace filter on @MinCPU (18)
IF (@MinCPU > 0)
BEGIN
	EXEC sys.sp_trace_setfilter 
		@trace_id = @id, 
		@columnid = 18,
		@logical_operator = 0, --AND
		@comparison_operator = 4, -->= (Greater Than Or Equal)
		@value = @MinCPU
END		

--start trace
EXEC sys.sp_trace_setstatus @id, 1

IF(@Mode = 0)
BEGIN
	--wait for x seconds
	DECLARE @delay CHAR(8)
	SELECT @delay = RIGHT('0' + CAST(@TraceTimer / 3600 AS VARCHAR),2) + ':' +
		RIGHT('0' + CAST((@TraceTimer / 60) % 60 AS VARCHAR),2)  + ':' +
		RIGHT('0' + CAST(@TraceTimer % 60 AS VARCHAR),2)
		
	WAITFOR DELAY @delay

	--Get trace result
	SELECT te.name [Event],
		SPID,
		--CONVERT(xml, CONVERT(NVARCHAR(MAX), (SELECT REPLACE(CONVERT(NVARCHAR(MAX), TextData), '', '?') FOR XML PATH('')), 1), 1)  TextDataXML,
		CONVERT(XML, (SELECT N' --' + char(13) + CONVERT(NVARCHAR(MAX), TextData) + char(13) + N'--' AS [processing-instruction(query)] FOR XML PATH(''))) TextDataXML,
		TextData,
		HostName, ApplicationName, LoginName,
		Duration/1000 Duration, Reads, Writes, CPU,
		DatabaseName, StartTime, EndTime
	FROM 
	(
		SELECT [path] FROM sys.traces
		WHERE [path] LIKE @path + '%'
	) t
		CROSS APPLY sys.fn_trace_gettable(t.[path], DEFAULT) tt
		LEFT JOIN sys.trace_events te ON tt.EventClass = te.trace_event_id
	WHERE SPID IS NOT NULL
	ORDER BY EventSequence

	--stop trace
	EXEC sys.sp_trace_setstatus @id, 0
	EXEC sys.sp_trace_setstatus @id, 2
END
ELSE
BEGIN
	SELECT id TraceID, 
		CASE status 
			WHEN 0 THEN 'Not running' 
			WHEN 1 THEN 'Running' 
			ELSE 'Closed' 
		END Status,
		REPLACE([path], @folder, '') [Trace File] 
	FROM sys.traces WHERE [path] LIKE @path + '%'
END


