/*<info serverAlias="DBTXN-MonDB,DBCUST-MonDB,DBPRO-MonDB,DBACC-MonDB,DBAGE-MonDB,DBONUSER-MonDB,DBWH-MonDB,DB042-MonDB,DBAFF-MonDB,FPSDEV-PerfMonDB,FPSDI-PerfMonDB,FPSLICALL-PerfMonDB" executers="bodbAdminNet,vnteam" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [vndba_sp_traceread]
	@TraceID INT = 0,
	@TraceFilename VARCHAR(200) = ''
AS
/*
		Created: Daniel
		Date: 20160819
		Task: Read trace from trace file
		DB: All servers - db master
		
		Revisions:
			20170701@Daniel: 
				- no trace specified -> get the latest trace from user session
				- Add writes column output
		
		Parameter's Explanation:
		  
	  
*/
BEGIN

	SET NOCOUNT ON

	DECLARE @file TABLE ([path] VARCHAR(200))
	DECLARE @folder NVARCHAR(100) = 'G:\TraceFiles\'

	IF (@TraceFilename = '' AND @TraceID = 0) --no trace specified -> get the latest trace from user session
		SELECT TOP 1 @TraceID = id
		FROM sys.traces 
		WHERE path LIKE @folder + REPLACE(CONVERT(VARCHAR(50), SYSTEM_USER), '\', '-') + '-' + CONVERT(VARCHAR(5), @@SPID) + '-%'
		ORDER BY start_time desc

	IF (@TraceID <> 0 OR @TraceFilename = '' )
	BEGIN
		INSERT INTO @file
		SELECT [path] FROM sys.traces
		WHERE id = @TraceID
	END
	ELSE
	BEGIN
		INSERT INTO @file
		SELECT @folder + @TraceFilename [path]
	END


	--SELECT id TraceID, 
	--	CASE status 
	--		WHEN 0 THEN 'Not running' 
	--		WHEN 1 THEN 'Running' 
	--		ELSE 'Closed' 
	--	END Status,
	--	REPLACE([path], @folder, '') [Trace File],
	--	start_time,
	--	'EXEC MonDB.dbo.vndba_sp_traceread @TraceId = ' + CONVERT(VARCHAR(3), id) ReadCmd
	--FROM sys.traces 
	--WHERE path LIKE @folder + REPLACE(CONVERT(VARCHAR(50), SYSTEM_USER), '\', '-') + '-' + CONVERT(VARCHAR(5), @@SPID) + '-%'	
	--ORDER BY start_time desc


	SELECT te.name [Event],
		SPID,
		--CONVERT(xml, CONVERT(NVARCHAR(MAX), (SELECT REPLACE(CONVERT(NVARCHAR(MAX), TextData), '', '?') FOR XML PATH('')), 1), 1)  TextDataXML,
		CONVERT(XML, (SELECT N' --' + char(13) + CONVERT(NVARCHAR(MAX), TextData) + char(13) + N'--' AS [processing-instruction(query)] FOR XML PATH(''))) TextDataXML,
		TextData,
		HostName, ApplicationName, LoginName,
		Duration/1000 Duration, Reads,  Writes, CPU,
		DatabaseName, StartTime, EndTime
	FROM 
	(
		SELECT [path] FROM @file
	) t
		CROSS APPLY sys.fn_trace_gettable(t.[path], DEFAULT) tt
		LEFT JOIN sys.trace_events te ON tt.EventClass = te.trace_event_id
	WHERE SPID IS NOT NULL
	ORDER BY EventSequence
END


