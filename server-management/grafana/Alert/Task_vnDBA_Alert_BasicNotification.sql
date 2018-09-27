SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
ALTER PROCEDURE	dbo.Task_vnDBA_Alert_BasicNotification
						@sample		TINYINT		= 2
AS
/*
	Creator:	20180618@Billy
	Task:		Basic Alert Norification - [Redmine: #96988]
	Database:	DBSTARIX.StarixDB
	
	Revisions:
		- 20180618@Billy:	Initial - [Redmine: #96988]
		- 20180927@Billy:	Change blocking alert to Skype - [Redmine: #102224]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@message	NVARCHAR(MAX)
		,	@alertTime	DATETIME
		;
	
	DECLARE	@capturing AS TABLE (
				ObjectName		VARCHAR(1024)
			,	CounterName		VARCHAR(1024)
			,	Threshold		DECIMAL(19,9)
			,	IsLetstalk		BIT
			);

	DECLARE	@excluded AS TABLE (
				MachineName		VARCHAR(1024)
			);

	DECLARE	@result AS TABLE (
				MachineName		VARCHAR(1024)
			,	ObjectName		VARCHAR(1024)
			,	CounterName		VARCHAR(1024)
			,	CounterTime		DATETIME
			,	CounterValue	DECIMAL(19,2)
			,	IsLetstalk		BIT
			)

	INSERT INTO @capturing (ObjectName, CounterName, Threshold, IsLetstalk)
	VALUES	('SQLServer:General Statistics', 'Processes blocked', 2, 0)
		,	('Processor', '% Processor Time', 60, 1)
		;

	INSERT INTO	@excluded (MachineName)
	VALUES	('\\DBSPARE')
		,	('\\DBDWCSS')
		,	('\\DBDW')
		,	('\\DBDW2')
		,	('\\DBDIST')
		,	('\\DBDIST02')
		,	('\\DBDIST03')
		,	('\\DBDISTRM')
		;

	WHILE	0 = 0
	BEGIN;
		INSERT INTO	@result (MachineName, ObjectName, CounterName, CounterTime, CounterValue, IsLetstalk)
		SELECT	c.MachineName, c.ObjectName, c.CounterName, d.CounterTime, d.MaxCounterValue, input.IsLetstalk
		FROM		@capturing AS input
		INNER JOIN	dbo.CounterDetails AS c WITH (NOLOCK)
				ON	input.ObjectName = c.ObjectName
				AND	input.CounterName = c.CounterName
		LEFT JOIN	@excluded AS ex
				ON	c.MachineName LIKE ex.MachineName
		CROSS APPLY	(
			SELECT	[CounterTime]		= MIN(_ad.CounterTime)
				,	[ViolatedCnt]		= SUM(_ad.Violated)
				,	[MaxCounterValue]	= MAX(_ad.CounterValue)
			FROM	(
				SELECT	TOP(@sample + 1)
						_d.CounterTime, _d.CounterValue
					,	[Violated]	= CASE WHEN _d.CounterValue > input.Threshold THEN 1 ELSE 0 END
				FROM	dbo.vnDBA_Perf_CounterData AS _d WITH (NOLOCK)
				WHERE	_d.CounterID = c.CounterID
				ORDER BY _d.CounterTime DESC
			) AS _ad
		) AS d
		WHERE	d.ViolatedCnt >= @sample
			AND	d.CounterTime > DATEADD(SECOND, -30, GETDATE())
			AND	ex.MachineName IS NULL;

		IF	EXISTS (SELECT 1 FROM @result)
		BEGIN;
			SELECT	@alertTime = GETDATE();

			SELECT	@message = N'SYSTEM ALERT - ' + CONVERT(NVARCHAR, @alertTime, 120) + rs.str
			FROM	(
				SELECT	N'

[' + REPLACE(_r.MachineName, '\\', '') + N']' + _rs.str
				FROM	(
					SELECT	DISTINCT
							_rm.MachineName
					FROM	@result AS _rm
					WHERE	_rm.IsLetstalk = 1
				) AS _r
				CROSS APPLY	(
					SELECT	N'
    - ' + _rm.ObjectName + N'[' + CONVERT(NVARCHAR(32), _rm.CounterName, 121) + N'] = ' + CONVERT(NVARCHAR(32), _rm.CounterValue)
					FROM	@result AS _rm
					WHERE	_rm.MachineName = _r.MachineName
						AND	_rm.IsLetstalk = 1
					FOR XML PATH ('')
					,	TYPE
				) AS _xr(xml)
				CROSS APPLY	(
					SELECT	_xr.xml.value('.[1]', 'NVARCHAR(MAX)')
				) AS _rs(str)
				FOR XML PATH ('')
				,	TYPE
			) AS xr(xml)
			CROSS APPLY	(
				SELECT	xr.xml.value('.[1]', 'NVARCHAR(MAX)')
			) AS rs(str);

			EXECUTE	DBMONDW.MonDBDW.dbo.DBA_Letstalk_NewJobMessage
						@ServerName	= N'PONTUS'
					,	@JobId		= NULL
					,	@JobName	= N'Custom Message'
					,	@Message	= @message
					,	@isSimple	= 1
					;
					
			SELECT	@message = N'SYSTEM ALERT - ' + CONVERT(NVARCHAR, @alertTime, 120) + rs.str
			FROM	(
				SELECT	N'

[' + REPLACE(_r.MachineName, '\\', '') + N']' + _rs.str
				FROM	(
					SELECT	DISTINCT
							_rm.MachineName
					FROM	@result AS _rm
					WHERE	_rm.IsLetstalk = 0
				) AS _r
				CROSS APPLY	(
					SELECT	N'
    - ' + _rm.ObjectName + N'[' + CONVERT(NVARCHAR(32), _rm.CounterName, 121) + N'] = ' + CONVERT(NVARCHAR(32), _rm.CounterValue)
					FROM	@result AS _rm
					WHERE	_rm.MachineName = _r.MachineName
						AND	_rm.IsLetstalk = 0
					FOR XML PATH ('')
					,	TYPE
				) AS _xr(xml)
				CROSS APPLY	(
					SELECT	_xr.xml.value('.[1]', 'NVARCHAR(MAX)')
				) AS _rs(str)
				FOR XML PATH ('')
				,	TYPE
			) AS xr(xml)
			CROSS APPLY	(
				SELECT	xr.xml.value('.[1]', 'NVARCHAR(MAX)')
			) AS rs(str);

			EXECUTE	DBMONDW.MonDBDW.dbo.DBA_Skype_NewMessage
						@ServerName	= N'PONTUS'
					,	@JobId		= NULL
					,	@JobName	= N'Custom Message'
					,	@Message	= @message
					,	@isSimple	= 1
					;

			SELECT	@message = N'Alerted - ' + CONVERT(NVARCHAR(32), GETDATE(), 121);
			RAISERROR(@message, 0, 0) WITH NOWAIT;

			DELETE @result;
		END;

		WAITFOR DELAY '00:00:10.000';
	END;
END;
GO
/*<info serverAlias="DBSTARIX-StarixDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/