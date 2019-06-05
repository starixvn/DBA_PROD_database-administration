SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
USE	msdb;
GO
CREATE PROCEDURE	dbo.Task_Job_InstantResultNotification
						@JobName	NVARCHAR(128)
AS
/*
	Creator:	20190419@Billy
	Task:		Send out instant notification about a done job - [Redmine: #111418]
	Database:	DBARC.msdb

	Revisions:
		- 20190419@Billy:	Initial - [Redmine: #111418]
		- 20190524@Billy:	Change Letstalk linked server - [Redmine: #113125]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE	@Time		BIGINT
		,	@msg		NVARCHAR(MAX)
		;

	BEGIN TRY
		SELECT	@Time = DATEDIFF(MILLISECOND, jc.start_execution_date, GETDATE())
		FROM		dbo.sysjobs AS j
		CROSS APPLY (
			SELECT	TOP(1)
					ja.start_execution_date, ja.stop_execution_date
			FROM	dbo.sysjobactivity AS ja
			WHERE	ja.job_id = j.job_id
			ORDER BY ja.session_id DESC
		) jc
		WHERE	j.name = @JobName
			AND	jc.start_execution_date IS NOT NULL
			AND	jc.stop_execution_date IS NULL
		ORDER BY j.name;
	END TRY
	BEGIN CATCH
		SELECT	@Time = DATEDIFF(SECOND, jc.start_execution_date, GETDATE()) * 1000
		FROM	dbo.sysjobs j
		CROSS APPLY (
			SELECT	TOP(1)
					ja.start_execution_date, ja.stop_execution_date
			FROM	dbo.sysjobactivity AS ja
			WHERE	ja.job_id = j.job_id
			ORDER BY ja.session_id DESC
		) jc
		WHERE	j.name = @JobName
			AND	jc.start_execution_date IS NOT NULL
			AND	jc.stop_execution_date IS NULL
		ORDER BY j.name;
	END CATCH;

	SELECT	@msg	= N'Job completed.
	Duration: '		+ CASE WHEN @Time / 1000 / 60 / 60 / 24 = 0 THEN '' ELSE CAST(@Time / 1000 / 60 / 60 / 24 AS NVARCHAR) + ' d ' END
					+ CASE WHEN @Time / 1000 / 60 / 60 % 60 < 10 THEN '0' + CAST(@Time / 1000 / 60 / 60 % 60 AS NVARCHAR) ELSE CAST(@Time / 1000 / 60 / 60 % 60 AS NVARCHAR) END
	+ ':'			+ CASE WHEN @Time / 1000 / 60 % 60 < 10 THEN '0' + CAST(@Time / 1000 / 60 % 60 AS NVARCHAR) ELSE CAST(@Time / 1000 / 60 % 60 AS NVARCHAR) END
	+ ':'			+ CASE WHEN @Time / 1000 % 60 < 10 THEN '0' + CAST(@Time / 1000 % 60 AS NVARCHAR) ELSE CAST(@Time / 1000 % 60 AS NVARCHAR) END
	+ '.'			+ CASE WHEN @Time % 1000 < 10 THEN '00' + CAST(@Time % 1000 AS NVARCHAR) WHEN @Time % 1000 < 100 THEN '0' + CAST(@Time % 1000 AS NVARCHAR) ELSE CAST(@Time % 1000 AS NVARCHAR) END
	;

	EXECUTE DBNOTI.NotificationDB.dbo.DBA_Letstalk_NewJobMessage
				@ServerName	= @@SERVERNAME
			,	@JobId		= NULL
			,	@JobName	= @JobName
			,	@Message	= @msg
			;
END;
GO
/*<info serverAlias="DBARC-bodb_Archive" executers="" viewers="" isFunction="0" isNested="0"></info>*/