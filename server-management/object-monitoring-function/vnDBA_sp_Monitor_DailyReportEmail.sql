ALTER PROCEDURE	dbo.vnDBA_sp_Monitor_DailyReportEmail
						@to				VARCHAR(MAX)	= 'lukas.luu@starixsoft.com;daniel.truong@starixsoft.com;patrick.pham@starixsoft.com'
					,	@cc				VARCHAR(MAX)	= ''
					,	@bcc			VARCHAR(MAX)	= ''
AS
/*
	Created:	20160915@Billy
	Task:		Daily report of monitored objects - [Redmine: #58941]
	Database:	DBTP.MonDB
	
	Revisions:
		- 20160915@Billy:	v2.02	*start tracking*
		- 20160928@Billy:	v2.03	Change timezone from GMT-04:00 to GMT+07:00
*/
BEGIN
	SET NOCOUNT ON;

	IF	OBJECT_ID('tempdb..#report') IS NOT NULL
		DROP TABLE	#report;

	DECLARE	@checkdate		DATETIME
		,	@checkdate_vn	DATETIME
		;

	DECLARE	@html			NVARCHAR(MAX)
		,	@subject		NVARCHAR(255)
		;

	DECLARE	@format_th		NVARCHAR(256)
		,	@format_td1		NVARCHAR(256)
		,	@format_td2		NVARCHAR(256)
		,	@format_td3		NVARCHAR(256)
		,	@format_td4		NVARCHAR(256)
		;
		
	SELECT	@format_th		= N'background: #00407A; color: white; padding: 3px;'
		,	@format_td1		= N'background: #B6D2EC;'
		,	@format_td2		= N'background: #B6ECE4;'
		,	@format_td3		= N'background: #ECBCB6;'
		,	@format_td4		= N'background: #ECB6D7;'
		;

	SELECT	@checkdate_vn	= DATEADD(DAY, DATEDIFF(DAY, 1, DATEADD(HOUR, 11, GETDATE())), 0)
		,	@checkdate		= DATEADD(HOUR, -11, @checkdate_vn)
		;

	CREATE TABLE	#report	(
						report_group		VARCHAR(64)
					,	report_date			DATETIME
					,	server_name			NVARCHAR(128)
					,	database_name		NVARCHAR(128)
					,	object_type			VARCHAR(64)
					,	object_name			NVARCHAR(128)
					,	report_type			VARCHAR(64)
					);

	INSERT INTO	#report
		(	report_group, report_date, server_name, database_name, object_type, object_name, report_type)
	SELECT	[Group]				= 'UNRESOLVED'
		,	[Date]				= MIN(DATEADD(HOUR, 11, r.verify_date))
		,	[Server]			= r.server_name
		,	[Database]			= r.database_name
		,	[Type]				= r.object_type
		,	[Object]			= r.object_name
		,	[Modification]		= r.report_type
	FROM	dbo.vnDBA_Monitor_Report r WITH (NOLOCK)
	WHERE	r.database_name <> N'CheckCustDB'
		AND	r.object_name <> 'dbo.DBA_GrantPermissions'
		AND	r.object_name NOT LIKE 'dbo.sp[_]%'
	GROUP BY r.server_name, r.database_name, r.object_type, r.object_name, r.report_type;

	INSERT INTO	#report
		(	report_group, report_date, server_name, database_name, object_type, object_name, report_type)
	SELECT	[Group]				= 'YESTERDAY'
		,	[Date]				= MIN(DATEADD(HOUR, 11, r.verify_date))
		,	[Server]			= r.server_name
		,	[Database]			= r.database_name
		,	[Type]				= r.object_type
		,	[Object]			= r.object_name
		,	[Modification]		= r.report_type
	FROM	(
		SELECT	verify_date, report_type, server_name, database_name, object_name, object_type
		FROM	dbo.vnDBA_Monitor_Report WITH (NOLOCK)
		WHERE	verify_date BETWEEN @checkdate AND @checkdate + 1
		UNION ALL
		SELECT	verify_date, report_type, server_name, database_name, object_name, object_type
		FROM	dbo.vnDBA_Monitor_Report_bk WITH (NOLOCK)
		WHERE	verify_date BETWEEN @checkdate AND @checkdate + 1
	) r
	WHERE	r.database_name <> N'CheckCustDB'
		AND	r.object_name <> 'dbo.DBA_GrantPermissions'
		AND	r.object_name NOT LIKE 'dbo.sp[_]%'
	GROUP BY r.server_name, r.database_name, r.object_type, r.object_name, r.report_type;

	WITH section AS (
		SELECT	DISTINCT
				report_group		= report_group
			,	group_description	= CASE report_group	WHEN 'UNRESOLVED'	THEN 'Un-resolved Object Modifications'
														WHEN 'YESTERDAY'	THEN 'Yesterday Object Modifications (' + CONVERT(NVARCHAR, @checkdate_vn, 111) + ')'
									  END
		FROM	#report
	)
	SELECT	@html = (
		SELECT	TOP 1
				'@style'	= 'width:100%'
			,	'h1/@align'	= 'center'
			,	'h1'		= 'Daily Object Monitoring Report'
			,	'h4/@align'	= 'center'
			,	'h4'		= 'Current time: ' + CONVERT(NVARCHAR, DATEADD(HOUR, 11, GETDATE()), 121) + ' (GMT+07:00)'
			,	(	SELECT	'div/@style'	= 'width: 95%'
						,	'div'			= html.x
					FROM	section
					CROSS APPLY (
						SELECT	(
							SELECT	'h3'	= section.group_description
								,	(	SELECT	'@border'	= 2
											,	'@style'	= 'width: 100%; text-align: center;'
											,	(	SELECT	TOP 1
															'col/@style'	= 'width: 18%'
														,	NULL
														,	'col/@style'	= 'width: 12%'
														,	NULL
														,	'col/@style'	= 'width: 18%'
														,	NULL
														,	'col/@style'	= 'width: 12%'
														,	NULL
														,	'col/@style'	= 'width: 28%'
														,	NULL
														,	'col/@style'	= 'width: 12%'
														,	NULL
														,	'th/@style'		= @format_th
														,	'th'			= 'Monitor Date'
														,	NULL
														,	'th/@style'		= @format_th
														,	'th'			= 'Server'
														,	NULL
														,	'th/@style'		= @format_th
														,	'th'			= 'Database'
														,	NULL
														,	'th/@style'		= @format_th
														,	'th'			= 'Type'
														,	NULL
														,	'th/@style'		= @format_th
														,	'th'			= 'Object'
														,	NULL
														,	'th/@style'		= @format_th
														,	'th'			= 'Action'
													FOR XML PATH ('tr')
													,	TYPE
												)
											,	(	SELECT	'@style'		= CASE r.server_name WHEN 'DBCUST' THEN @format_td3 WHEN 'DBTRANS' THEN @format_td4 ELSE CASE c.rn % 2 WHEN 0 THEN @format_td1 ELSE @format_td2 END END
																			+ CASE r.report_type WHEN 'DELETED' THEN N' color: #380000;' WHEN 'CREATED' THEN N' color: #020038;' ELSE N'' END
														,	'td/@style'		= 'text-align: left; padding: 3px;'
														,	'td'			= CONVERT(NVARCHAR, r.report_date, 120)
														,	NULL
														,	'td/@style'		= 'text-align: left; padding: 3px;'
														,	'td'			= r.server_name
														,	NULL
														,	'td/@style'		= 'text-align: left; padding: 3px;'
														,	'td'			= r.database_name
														,	NULL
														,	'td/@style'		= 'text-align: left; padding: 3px;'
														,	'td'			= r.object_type
														,	NULL
														,	'td/@style'		= 'text-align: left; padding: 3px;'
														,	'td'			= r.object_name
														,	NULL
														,	'td'			= r.report_type
													FROM		#report r
													INNER JOIN (
														SELECT	s.server_name, rn = ROW_NUMBER() OVER(ORDER BY CASE WHEN s.server_name IN ('DBCUST', 'DBTRANS') THEN 1 ELSE 2 END, s.server_name)
														FROM	(
															SELECT	DISTINCT
																	ir.server_name
															FROM	#report ir
															WHERE	ir.report_group = section.report_group
														) s
													) c
															ON	c.server_name = r.server_name
													WHERE	r.report_group = section.report_group
													ORDER BY CASE WHEN r.server_name IN ('DBCUST', 'DBTRANS') THEN 1 ELSE 2 END, r.server_name, r.database_name, r.object_type, r.report_type, r.report_date
													FOR XML PATH ('tr')
													,	TYPE
												)
										FOR XML PATH ('table')
										,	TYPE
									)
							FOR XML PATH ('')
							,	TYPE
						)
					) html(x)
					ORDER BY CASE report_group WHEN 'YESTERDAY' THEN 1 ELSE 2 END
					FOR XML PATH ('')
					,	TYPE
				)
		FROM	#report
		FOR XML PATH ('body')
		,	ROOT ('html')
	);

	SELECT	@subject	= N'Daily Object Monitoring Report'
		,	@to			= 'billy.bui@starixsoft.com;' + ISNULL(@to, '')
		;
		
	EXECUTE	msdb.dbo.sp_send_dbmail
				@profile_name			= DEFAULT
			,	@recipients				= @to
			,	@copy_recipients		= @cc
			,	@blind_copy_recipients	= @bcc
			,	@subject				= @subject
			,	@body					= @html
			,	@body_format			= 'HTML'
			;

	DROP TABLE	#report;
END;