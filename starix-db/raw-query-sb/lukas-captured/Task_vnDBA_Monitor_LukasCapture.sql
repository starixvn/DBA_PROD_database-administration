USE	StarixDB;
GO
ALTER PROCEDURE	[dbo].[Task_vnDBA_Monitor_LukasCapture]
AS
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@ServerName		NVARCHAR(128)
		,	@Query			NVARCHAR(MAX)
		;

	DECLARE	@capturing AS TABLE (
				ObjectName		VARCHAR(1024)
			,	CounterName		VARCHAR(1024)
			,	Threshold		DECIMAL(19,9)
			,	Samples			SMALLINT
			,	Important		BIT
			);

	DECLARE	@included AS TABLE (
				MachineName		VARCHAR(1024)
			)

	DECLARE	@excluded AS TABLE (
				MachineName		VARCHAR(1024)
			);

	DECLARE	@result AS TABLE (
				MachineName		VARCHAR(1024)
			,	Done			BIT
			)

	INSERT INTO @capturing (ObjectName, CounterName, Threshold, Samples, Important)
	VALUES	('Processor', '% Processor Time', 40, 1, 1)
		,	('SQLServer:General Statistics', 'Processes blocked', 0, 3, 0)
		,	('SQLServer:General Statistics', 'Processes blocked', 20, 1, 0)
		;

	INSERT INTO	@included (MachineName)
	VALUES	('\\DBTRANS1')
		,	('\\DBTRANS2')
		,	('\\DBCUST1')
		,	('\\DBCUST2')
		,	('\\DB021')
		,	('\\DB022')
		,	('\\DB042')
		,	('\\DB052')
		,	('\\DB053')
		,	('\\DB054')
		,	('\\DB06')
		,	('\\DB05')
		;

	WHILE	0 = 0
	BEGIN;
		INSERT INTO	@result (MachineName, Done)
		SELECT	DISTINCT
				c.MachineName, 0
		FROM		@capturing AS input
		INNER JOIN	dbo.CounterDetails AS c WITH (NOLOCK)
				ON	input.ObjectName = c.ObjectName
				AND	input.CounterName = c.CounterName
		INNER JOIN	@included AS inc
				ON	c.MachineName = inc.MachineName
		LEFT JOIN	@excluded AS exc
				ON	c.MachineName = exc.MachineName
		CROSS APPLY	(
			SELECT	[CounterTime]		= MIN(_ad.CounterTime)
				,	[ViolatedCnt]		= SUM(_ad.Violated)
				,	[MaxCounterValue]	= MAX(_ad.CounterValue)
			FROM	(
				SELECT	TOP(input.Samples)
						_d.CounterTime, _d.CounterValue
					,	[Violated]	= CASE WHEN _d.CounterValue > input.Threshold THEN 1 ELSE 0 END
				FROM	dbo.vnDBA_Perf_CounterData AS _d WITH (NOLOCK)
				WHERE	_d.CounterID = c.CounterID
				ORDER BY _d.CounterTime DESC
			) AS _ad
		) AS d
		WHERE	d.ViolatedCnt >= input.Samples
			AND	d.CounterTime > DATEADD(SECOND, -30, GETDATE())
			AND	exc.MachineName IS NULL;

		UPDATE	@result
		SET		MachineName = REPLACE(CASE WHEN MachineName IN ('\\DBTRANS1', '\\DBTRANS2', '\\DBCUST1', '\\DBCUST2', '\\DB021', '\\DB022') THEN LEFT(MachineName, LEN(MachineName) - 1) ELSE MachineName END, '\\', '');

		IF	EXISTS (SELECT 1 FROM @result)
		BEGIN;
			WHILE	0 = 0
			BEGIN;
				UPDATE	TOP(1)
						r
				SET		@ServerName	= r.MachineName
					,	Done		= 1
				FROM	@result AS r
				WHERE	Done = 0;

				IF	@@ROWCOUNT = 0
					BREAK;

				SELECT	@Query	= N'';
				SELECT	@Query	= @Query + N'
INSERT INTO	dbo.vnDBA_Monitor_LukasCapture
	(	servername, capturedate, spid, ecid, blockedBy, database_login, CMD_status, wait, wait_type, waitresource, current_stmt, lastwaittype, resource_description, wait_duration_ms, current_batch, reads, logical_reads, cpu, time_elapsed_ms, program, batch_plan)
SELECT	servername, capturedate, spid, ecid, blockedBy, database_login, CMD_status, wait, wait_type, waitresource, current_stmt, lastwaittype, resource_description, wait_duration_ms, current_batch, reads, logical_reads, cpu, time_elapsed_ms, program, batch_plan
FROM	OPENQUERY(' + @ServerName + 'KBT, ''
EXECUTE	MonDB.dbo.vnDBA_sp_Monitor_LukasCapture;
'');
';
				BEGIN TRY
					EXECUTE	sys.sp_executesql @Query;
				END TRY
				BEGIN CATCH
					INSERT INTO	dbo.vnDBA_Monitor_HighCPUFailedLog (ServerName, LogDate, Message)
					SELECT	@ServerName, GETDATE(), ERROR_MESSAGE() + '// ' + @Query;
				END CATCH;
			END;

			DELETE @result;
		END;

		WAITFOR DELAY '00:00:05.000';
	END;
END;