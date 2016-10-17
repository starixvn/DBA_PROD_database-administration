ALTER PROCEDURE	dbo.vnDBA_sp_Monitor_SendEmail
						@email		VARCHAR(MAX)	= ''
					,	@bcc_email	VARCHAR(MAX)	= ''
AS
/*
	Creator:	20160803@Billy
	Task:		Objects monitoring function - Send email - [Redmine: #58941]
	Database:	DBTP.MonDB
	
	Revisions:
		- 20160803@Billy:	v2.01	*start tracking*
*/
BEGIN
    SET NOCOUNT ON;

	DECLARE	@subject			NVARCHAR(255)
		,	@email_body			NVARCHAR(MAX)
		,	@section_header		NVARCHAR(MAX)
		,	@section_body		NVARCHAR(MAX)
		;

	DECLARE	@report_type		VARCHAR(50);

	CREATE TABLE	#report (
						report_type		VARCHAR(50)
					,	is_done			BIT				DEFAULT 0
					);

	INSERT INTO	#report
		(	    report_type, is_done)
	SELECT	DISTINCT
			mr.report_type, 0
	FROM	dbo.vnDBA_Monitor_Report AS mr WITH (NOLOCK)
	WHERE	mr.is_notified = 0;

	IF	@@ROWCOUNT = 0
		RETURN;

	SELECT	@email_body = '<html><body>';

	WHILE	0 = 0
	BEGIN
		UPDATE	TOP (1) r
		SET		@report_type = r.report_type
			,	r.is_done = 1
		FROM	#report AS r
		WHERE	r.is_done = 0;

		IF	@@ROWCOUNT = 0
			BREAK;

		SELECT	@section_header =	(	SELECT	'H2' =	CASE @report_type	WHEN 'DELETED'		THEN 'Object(s) that have been deleted'
																			WHEN 'CREATED'		THEN 'Object(s) that have been created'
																			WHEN 'DISABLED'		THEN 'Object(s) that have been disabled compared to last status'
																			WHEN 'ENABLED'		THEN 'Object(s) that have been enabled compared to last status'
																			WHEN 'RENAMED'		THEN 'Object(s) that have its name changed'
														END
										FOR XML PATH ('')
									);

		SELECT	@section_body =		(	SELECT	'td' =	CONVERT(NVARCHAR(50), mr.verify_date, 120)
											,	NULL
											,	'td' =	CAST(mr.server_name AS NVARCHAR(128))
											,	NULL
											,	'td' =	CAST(mr.database_name AS NVARCHAR(128))
											,	NULL
											,	'td' =	CAST(mr.object_type AS NVARCHAR(64))
											,	NULL
											,	'td' =	CAST(mr.object_name AS NVARCHAR(128))
										FROM	dbo.vnDBA_Monitor_Report AS mr WITH (NOLOCK)
										WHERE	mr.report_type = @report_type
											AND	mr.is_notified = 0
										ORDER BY	mr.server_name		ASC
												,	mr.database_name	ASC
												,	mr.object_type		ASC
												,	mr.object_name		ASC
										FOR XML PATH ('tr')
										,	ELEMENTS
									);

		UPDATE	mr
		SET		mr.is_notified = 1
		FROM	dbo.vnDBA_Monitor_Report AS mr
		WHERE	mr.report_type = @report_type
			AND	mr.is_notified = 0;

		SELECT	@section_body	=	'<table border=1><tr><th>Date</th><th>Server</th><th>Database</th><th>Object Type</th><th>Object Name</th></tr>'
								+	@section_body
								+	'</table>'
								;

		SELECT	@email_body = @email_body + '<div>' + @section_header + @section_body + '<br/></div>';
	END;

	SELECT	@email_body = @email_body + '</body></html>';

	SELECT	@email_body;

	IF	EXISTS (SELECT 1 FROM #report AS r)
	BEGIN
		SELECT	@subject	= N'Objects Monitoring Report'
							+ CASE @@SERVERNAME	WHEN 'DB233'	THEN N' - LOCAL'
												WHEN 'SITDB06'	THEN N' - SIT'
												WHEN 'DB06'		THEN N' - MNL'
												WHEN 'DBTP'		THEN N' - KBT'
												ELSE N''
							  END;

		EXECUTE	msdb.dbo.sp_send_dbmail
					@profile_name			= DEFAULT
				,	@recipients				= 'billy.bui@starixsoft.com;lukas.luu@starixsoft.com;daniel.truong@starixsoft.com,patrick.pham@starixsoft.com'
				,	@copy_recipients		= @email
				,	@blind_copy_recipients	= @bcc_email
				,	@subject				= @subject
				,	@body					= @email_body
				,	@body_format			= 'HTML';
	END;

	DROP TABLE	#report;

END;
