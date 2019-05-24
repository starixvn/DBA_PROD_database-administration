/*
	Creator:	20190524@Billy
	Task:		Check for object that calling notification SP - [Redmine: #113125]
	Server:		ALLSERVERS
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

IF	OBJECT_ID('tempdb..#Result') IS NOT NULL
	DROP TABLE	#Result;

CREATE TABLE	#Result (
					Category			NVARCHAR(16)
				,	DatabaseName		NVARCHAR(128)
				,	ObjectName			NVARCHAR(256)
				,	CallingLetstalk		BIT
				,	CallingSkype		BIT
				,	PRIMARY KEY CLUSTERED (Category, DatabaseName, ObjectName)
				);

EXECUTE	sys.sp_MSforeachdb N'USE [?];

INSERT INTO	#Result (Category, DatabaseName, ObjectName, CallingLetstalk, CallingSkype)
SELECT	[Category]			= N''PROCEDURE''
	,	[DatabaseName]		= DB_NAME()
	,	[ObjectName]		= SCHEMA_NAME(obj.schema_id) + N''.'' + obj.name
	,	[CallingLetstalk]	= CASE WHEN sm.definition LIKE ''%DBA[_]Letstalk[_]NewJobMessage%'' THEN 1 ELSE 0 END
	,	[CallingSkype]		= CASE WHEN sm.definition LIKE ''%DBA[_]Skype[_]NewMessage%'' THEN 1 ELSE 0 END
FROM		sys.sql_modules AS sm WITH (NOLOCK)
INNER JOIN	sys.objects AS obj WITH (NOLOCK)
		ON	sm.object_id = obj.object_id
WHERE	sm.definition LIKE ''%DBA[_]Letstalk[_]NewJobMessage%''
	OR	sm.definition LIKE ''%DBA[_]Skype[_]NewMessage%'';

RAISERROR(''$ Check SQL MODULES - Done %s'', 0, 0, ''?'') WITH NOWAIT;
'


INSERT INTO	#Result (Category, DatabaseName, ObjectName, CallingLetstalk, CallingSkype)
SELECT	[Category]			= N'JOB'
	,	[DatabaseName]		= DB_NAME()
	,	[ObjectName]		= N'[' + j.name + N'] - (' + CAST(js.step_id AS NVARCHAR) + N') ' + js.step_name
	,	[CallingLetstalk]	= CASE WHEN js.command LIKE '%DBA[_]Letstalk[_]NewJobMessage%' THEN 1 ELSE 0 END
	,	[CallingSkype]		= CASE WHEN js.command LIKE '%DBA[_]Skype[_]NewMessage%' THEN 1 ELSE 0 END
FROM		msdb.dbo.sysjobs AS j WITH (NOLOCK)
INNER JOIN	msdb.dbo.sysjobsteps AS js WITH (NOLOCK)
		ON	j.job_id = js.job_id
WHERE	js.command LIKE '%DBA[_]Letstalk[_]NewJobMessage%'
	OR	js.command LIKE '%DBA[_]Skype[_]NewMessage%';

RAISERROR('# Check JOB STEPS   - Done %s', 0, 0, '[msdb]') WITH NOWAIT;

SELECT	*
FROM	#Result;