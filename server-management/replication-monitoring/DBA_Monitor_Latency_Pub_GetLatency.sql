/*<info serverAlias="DBCUST-MonDB,DBTRANS-MonDB,DBPRO-MonDB,DBTP-MonDB" executers="" isFunction="0"></info>*/

USE [MonDB]

GO

ALTER PROCEDURE [dbo].[DBA_Monitor_Latency_Pub_GetLatency]
(
	@IsDebug BIT = 0,
	@Threshold INT = 30, --in second
	@IsEmail BIT = 0,
	@PubExceptionSetting VARCHAR(MAX) = '[]'
)
AS
/*  
	Created by: 20240612@Sol
	Task: replication monitor
	DB: DBTrans/DBCust/DB02/DBTP
	Revision:
		- 20240612@Sol: initial sp
		- 20240612@Sol: add json setting for exception cases

*/
BEGIN
	SET NOCOUNT ON;

	--/* get token status and checking latency
	--start get data
	DECLARE @cmd NVARCHAR(max) = '';
	DECLARE @ParamDefinition NVARCHAR(max) = '';
	DECLARE @PubId INT, @PubName SYSNAME, @PubDatabase SYSNAME, @TraceTokenId INT;
	DECLARE @MessageInfo NVARCHAR(MAX) = '';
	DECLARE @currTime TIME = CAST(GETDATE() AS TIME) --get current time

	DECLARE @TraceResult TABLE (
		distributor_latency BIGINT,
		subscriber SYSNAME NULL,
		subscriber_db SYSNAME NULL,
		subscriber_latency BIGINT,
		overall_latency BIGINT
		)

	IF (ISNULL(@PubExceptionSetting,'') = '')
		SET @PubExceptionSetting = '[]' --prevent error when parse json format

	IF (ISJSON(@PubExceptionSetting) = 0) --not a valid json format
		RAISERROR('ERROR! NOT A VALID JSON FORMAT.', 16, 1) --return user error and report to job failed

	DECLARE @RepToken TABLE (PubId int, PubName sysname, PubDatabase Sysname, TraceTokenId Int, CreatedDate Datetime2, ModifiedDate Datetime2, Latency INT, IsDone BIT, SubName Sysname, SubDatabase Sysname);
		
	SET @ParamDefinition = '@dyn_tracer_token_id int, @dyn_publication sysname';

	--store json data to temp table
	DROP TABLE IF EXISTS #tmpPubExceptionSetting

	SELECT * INTO #tmpPubExceptionSetting
	FROM OPENJSON(@PubExceptionSetting) WITH (
		PubName VARCHAR(128) 'strict $.pubName',
		Threshold INT '$.Threshold',
		FromTime VARCHAR(10) '$.FromTime',
		ToTime VARCHAR(10) '$.ToTime'
	);

	--delete settings with range time does not contain current time
	DELETE FROM #tmpPubExceptionSetting WHERE @currTime NOT BETWEEN FromTime AND ToTime

	--insert token to check
	INSERT INTO @RepToken
	SELECT PubId , PubName , PubDatabase , TraceTokenId , CreatedDate , ModifiedDate , Latency, IsDone, SubName, SubDatabase
	FROM MonDB.dbo.RepTokens r WITH(NOLOCK)
	WHERE IsDone = 0
	ORDER BY PubId;

	--loop throught tokenid
	DECLARE Token_cursor CURSOR
	FOR
		SELECT r.PubId, r.PubName, r.PubDatabase, r.TraceTokenId
		FROM @RepToken r
		ORDER BY r.PubDatabase, PubId;

	OPEN Token_cursor

	FETCH NEXT FROM Token_cursor
	INTO @PubId, @PubName, @PubDatabase, @TraceTokenId

	--loop token id to send mail
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--reset temp table
		DELETE FROM @TraceResult

		--gen command
		SET @cmd = CONCAT (
				'exec ',
				@PubDatabase,
				'.sys.sp_helptracertokenhistory @publication = @dyn_publication, @tracer_id = @dyn_tracer_token_id'
				);

		BEGIN TRY
			INSERT @TraceResult
			EXEC sp_executesql @cmd,
				@ParamDefinition,
				@dyn_publication = @PubName,
				@dyn_tracer_token_id = @TraceTokenId;

			IF @@TRANCOUNT > 0
				COMMIT TRANSACTION;

			--select * from @TraceResult
			UPDATE r
				SET r.Latency = CASE WHEN t.overall_latency IS NULL THEN DATEDIFF(SECOND, r.CreatedDate, SYSDATETIME()) ELSE t.overall_latency END,
					r.ModifiedDate = CASE when t.overall_latency is null then r.ModifiedDate else SYSDATETIME() end,
					r.IsDone = CASE when t.overall_latency is null then IsDone else 1 end
			From @RepToken r
				CROSS APPLY (
				SELECT 
					@PubName AS PubName,
					@PubDatabase AS PubDb,
					@TraceTokenId AS TokenId,
					distributor_latency,
					subscriber,
					subscriber_db,
					subscriber_latency,
					overall_latency
				FROM @TraceResult t
				) t
			WHERE r.TraceTokenId = t.TokenId AND r.SubName = t.subscriber AND r.SubDatabase = t.subscriber_db
				AND t.PubName = r.PubName AND t.PubDb = r.PubDatabase

			IF @IsDebug = 1
			BEGIN
				SELECT *
				FROM @RepToken r
				WHERE r.TraceTokenId = @TraceTokenId;

				SET @MessageInfo = CONCAT ('db | pub name | token id',' --> ',@PubDatabase,' | ',@PubName,' | ', @TraceTokenId);
				RAISERROR (@MessageInfo,0,1) WITH NOWAIT

			END

		END TRY
		BEGIN CATCH
					
			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION;

			SELECT ERROR_MESSAGE();
					
			IF @IsDebug = 1
			BEGIN
				SET @MessageInfo = CONCAT ('db | pub name | token id',' --> ',@PubDatabase,' | ',@PubName,' | ','NULL');
				RAISERROR (@MessageInfo,0,1) WITH NOWAIT
			END

		END CATCH

		FETCH NEXT FROM Token_cursor
		INTO @PubId, @PubName, @PubDatabase, @TraceTokenId
	END

	CLOSE Token_cursor;
	DEALLOCATE Token_cursor;

	---get data that need to alert
	DECLARE @Result TABLE (PubId int, PubName sysname, PubDatabase Sysname, TraceTokenId Int, CreatedDate Datetime2, ModifiedDate Datetime2, Latency INT, IsDone BIT, SubName Sysname, SubDatabase Sysname)

	INSERT INTO @Result
	SELECT rs.*
	FROM @RepToken rs
		LEFT JOIN #tmpPubExceptionSetting s
			ON rs.PubName = s.PubName
	WHERE 1 = 
			CASE 
				WHEN s.PubName IS NULL AND rs.Latency > @Threshold THEN 1
				WHEN s.PubName IS NOT NULL AND @currTime BETWEEN s.FromTime AND s.ToTime AND rs.Latency > s.Threshold THEN 1
				WHEN s.pubName IS NOT NULL AND @currTime NOT BETWEEN s.FromTime AND s.ToTime AND rs.Latency > @Threshold THEN 1
				ELSE 0
			END

	--check to send mail/skype here
	IF EXISTS (SELECT 1 FROM @Result r )
	BEGIN
		IF @IsEmail = 1
		BEGIN
			SET @MessageInfo = (
					N'<H1>Replication Latency Report</H1>' + N'<table border="1">' + N'<tr><th>PubId</th><th>PubName</th>' + N'<th>PubDatabase</th>' + N'<th>TraceTokenId</th><th>SubName</th><th>Sub Database</th><th>Latency (Seconds)</th></tr>' + CAST((
							SELECT td = c.PubId,'',
								td = c.PubName,'',
								td = c.PubDatabase,'',
								td = c.TraceTokenId,'',
								td = c.SubName,'',
								td = c.SubDatabase,'',
								td = c.Latency
							FROM @Result c
							FOR XML PATH('tr'),
								TYPE
							) AS NVARCHAR(MAX)) + N'</table>'
					);

			IF @IsDebug = 1
				PRINT @MessageInfo

			EXEC msdb.dbo.sp_send_dbmail @recipients = 'sol.le@starixsoft.com',
				@subject = 'Local TEST - Replication Latency Alert - Please check',
				@body = @MessageInfo,
				@body_format = 'HTML'
		END

		ELSE
		BEGIN

			SELECT @MessageInfo = @MessageInfo + concat(@@SERVERNAME, '.[', r.PubDatabase,']: ', r.PubName,' -> [', r.SubName, '].[', r.SubDatabase, '] ==> ', r.Latency, ' (s)','{{NewLine}}')
			FROM @Result r
			ORDER BY r.PubDatabase, r.PubName, r.SubName, r.SubDatabase

			IF @IsDebug = 1
				PRINT @MessageInfo

			----un-comment when deploy to dbtp
			--EXECUTE	DBNOTI.NotificationDB.dbo.DBA_Letstalk_NewJobMessage 
			--	@ServerName = N'PONTUS'
			--	, @JobId = NULL, @JobName = N'Custom Message'
			--	, @Message = @MessageInfo
			--	, @CaseId = 1;

			--send noti to DB JOB MONITOR chat group in TEAMS
			EXECUTE	DBNOTI.NotificationDB.dbo.DBA_Letstalk_NewJobMessage 
				@ServerName = N'DBJOBMonitor'
				, @JobId = NULL, @JobName = N'Custom Message'
				, @Message = @MessageInfo
				, @CaseId = 1;

			--send noti to [TW] Standby Alert Notification group in skype
			EXECUTE  DBNOTI.NotificationDB.dbo.DBA_Letstalk_NewJobMessage 
        		@ServerName = N'STANDBY'
        		, @JobId = 'F5D39AC2-A660-4722-AA9F-7E6E431B17BA', @JobName = N'Standby Alert'
        		, @Message = @MessageInfo
        		, @CaseId = 2;

		END
	END;

	---update to main table
	UPDATE r	
		SET r.ModifiedDate = rr.ModifiedDate,
			r.IsDone = rr.IsDone,
			r.Latency = rr.Latency
	FROM MonDB.dbo.RepTokens r
		INNER JOIN @RepToken rr
			ON r.PubId = rr.PubId AND r.TraceTokenId = rr.TraceTokenId AND r.PubDatabase = rr.PubDatabase
			AND r.PubName = rr.PubName AND r.SubName = rr.SubName AND r.SubDatabase = rr.SubDatabase

END;



GO

