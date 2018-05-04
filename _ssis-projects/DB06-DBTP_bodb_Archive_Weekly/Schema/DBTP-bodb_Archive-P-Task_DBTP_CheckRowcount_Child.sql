USE bodb_Archive;
GO

ALTER PROCEDURE dbo.Task_DBTP_CheckRowcount_Child
					@step		INT
AS
/*
	Creator:	20170427@Billy
	Task:		Check bodb_Archive tables' rowcount - [Redmine: #00000]
	Database:	DBTP.bodb_Archive
		
	Revisions:
		- 20170627@Billy:	Add table type 5: MatchEventDate - [Redmine: #79047]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE	@result	TABLE (
						tablename		NVARCHAR(128)
					,	winlostdate		DATETIME
					,	DBTP_rowcount	BIGINT
					,	timetype		VARCHAR(10)
					);

	DECLARE	@query			NVARCHAR(MAX)
		,	@tablename		NVARCHAR(128)
		,	@fromdate		DATETIME
		,	@todate			DATETIME
		,	@type			INT
		;

	IF	@step = 1
	BEGIN
		INSERT INTO	@result (tablename, winlostdate, DBTP_rowcount, timetype)
		SELECT	'tablename'		= tbl.name
			,	'winlostdate'	= pt.right_value
			,	'DBTP_rowcount'	= p.rows
			,	'timetype'		= CAST('MONTH' AS VARCHAR(10))
		FROM		DB06.bodb_Archive.dbo.Task_DBTP_ArchiveTables AS at WITH (NOLOCK)
		INNER JOIN	sys.tables AS tbl WITH (NOLOCK)
				ON	at.name = tbl.name
				AND	at.db = DB_NAME()
		INNER JOIN	sys.indexes AS idx WITH (NOLOCK)
				ON	tbl.object_id = idx.object_id
				AND	idx.type = 1 -- Clustered Index
		INNER JOIN	sys.partitions AS p WITH (NOLOCK)
				ON	idx.object_id = p.object_id
				AND	idx.index_id = p.index_id
		LEFT JOIN	sys.partition_schemes AS ps WITH (NOLOCK)
				ON	idx.data_space_id = ps.data_space_id
		LEFT JOIN	sys.partition_range_values AS rvr WITH (NOLOCK)
				ON	ps.function_id = rvr.function_id
				AND	p.partition_number = rvr.boundary_id
		OUTER APPLY	(
			SELECT	'right_value'	= DATEADD(MONTH, DATEDIFF(MONTH, 0, CAST(rvr.value AS DATETIME)), 0)
		) AS pt
		ORDER BY tbl.name, p.partition_number;

		DELETE	tbl
		FROM	@result AS tbl
		WHERE	tbl.winlostdate IS NULL
			AND	EXISTS (SELECT 1 FROM @result AS r WHERE r.tablename = tbl.tablename AND r.winlostdate IS NOT NULL);
	END;
	
	IF	@step = 2
	BEGIN
		SELECT	@tablename	= tablename
			,	@fromdate	= winlostdate
			,	@type		= tabletype
		FROM	OPENQUERY(DB06, '
SELECT	rc.tablename, rc.winlostdate, t.tabletype
FROM		bodb_Archive.dbo.Task_DBTP_ArchiveCheckRowcount rc WITH (NOLOCK)
INNER JOIN	bodb_Archive.dbo.Task_DBTP_ArchiveTables t WITH (NOLOCK)
		ON	rc.tablename = t.name
		AND	t.db = ''bodb_Archive''
WHERE	rc.timetype = ''PROCESSING'';
');

		IF	@tablename IS NOT NULL AND @type IS NOT NULL
		BEGIN
			IF	@fromdate IS NULL
			BEGIN
				SELECT	@fromdate	= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 17, 0)
					,	@todate		= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 12, 0)
					;
			END;
			ELSE
			BEGIN
				SELECT	@todate		= DATEADD(MONTH, 1, @fromdate)
					;
			END;

			-- Table with winlostdate column --
			IF	@type = 1
			BEGIN
				SELECT	@query = N'';
				SELECT	@query = @query + N'
DECLARE	@from	DATETIME = ''' + CONVERT(NVARCHAR, @fromdate, 121) + N'''
	,	@to		DATETIME = ''' + CONVERT(NVARCHAR, @todate, 121) + N'''
	;

SELECT	tablename		= CAST(''' + @tablename + N''' AS NVARCHAR(128))
	,	winlostdate		= tbl.winlostdate
	,	DBTP_rowcount	= COUNT(1)
	,	timetype		= CAST(''DAY'' AS VARCHAR(10))
FROM	bodb_Archive.dbo.' + @tablename + ' tbl WITH (NOLOCK)
WHERE	tbl.winlostdate >= @from
	AND	tbl.winlostdate <= @to
GROUP BY tbl.winlostdate;
';
			END;

			-- Table with eventdate column --
			IF	@type = 2
			BEGIN
				SELECT	@query = N'';
				SELECT	@query = @query + N'
DECLARE	@from	DATETIME = ''' + CONVERT(NVARCHAR, @fromdate, 121) + N'''
	,	@to		DATETIME = ''' + CONVERT(NVARCHAR, @todate, 121) + N'''
	;

SELECT	tablename		= CAST(''' + @tablename + N''' AS NVARCHAR(128))
	,	winlostdate		= tbl.eventdate
	,	DBTP_rowcount	= COUNT(1)
	,	timetype		= CAST(''DAY'' AS VARCHAR(10))
FROM	bodb_Archive.dbo.' + @tablename + ' tbl WITH (NOLOCK)
WHERE	tbl.eventdate >= @from
	AND	tbl.eventdate <= @to
GROUP BY tbl.eventdate;
';
			END;

			-- Table with matchid column --
			IF	@type = 3
			BEGIN
				SELECT	@query = N'';
				SELECT	@query = @query + N'
DECLARE	@from	DATETIME = ''' + CONVERT(NVARCHAR, @fromdate, 121) + N'''
	,	@to		DATETIME = ''' + CONVERT(NVARCHAR, @todate, 121) + N'''
	;

SELECT	tablename		= CAST(''' + @tablename + N''' AS NVARCHAR(128))
	,	winlostdate		= m.eventdate
	,	DBTP_rowcount	= COUNT(1)
	,	timetype		= CAST(''DAY'' AS VARCHAR(10))
FROM		bodb_Archive.dbo.' + @tablename + ' tbl WITH (NOLOCK)
INNER JOIN	bodb_Archive.dbo.match_bk m WITH (NOLOCK)
		ON	tbl.matchid = m.matchid
WHERE	m.eventdate >= @from
	AND	m.eventdate <= @to
GROUP BY m.eventdate;
';
			END;

			-- Table with transtime column -- Dot_Admin_LiveLog --
			IF	@type = 4
			BEGIN
				SELECT	@fromdate	= DATEADD(MONTH, -2, @fromdate);
				SELECT	@todate		= DATEADD(MONTH, 3, @fromdate);

				SELECT	@query = N'';
				SELECT	@query = @query + N'
DECLARE	@from	DATETIME = ''' + CONVERT(NVARCHAR, @fromdate, 121) + N'''
	,	@to		DATETIME = ''' + CONVERT(NVARCHAR, @todate, 121) + N'''
	;

SELECT	tablename		= CAST(''' + @tablename + N''' AS NVARCHAR(128))
	,	winlostdate		= DATEADD(DAY, DATEDIFF(DAY, 0, tbl.transtime), 0)
	,	DBTP_rowcount	= COUNT(1)
	,	timetype		= CAST(''DAY'' AS VARCHAR(10))
FROM	bodb_Archive.dbo.' + @tablename + ' tbl WITH (NOLOCK)
WHERE	tbl.transtime >= @from
	AND	tbl.transtime <= @to
GROUP BY DATEADD(DAY, DATEDIFF(DAY, 0, tbl.transtime), 0);
';
			END;

			-- Table with MatchEventDate column --
			IF	@type = 5
			BEGIN
				SELECT	@query = N'';
				SELECT	@query = @query + N'
DECLARE	@from	DATETIME = ''' + CONVERT(NVARCHAR, @fromdate, 121) + N'''
	,	@to		DATETIME = ''' + CONVERT(NVARCHAR, @todate, 121) + N'''
	;

SELECT	tablename		= CAST(''' + @tablename + N''' AS NVARCHAR(128))
	,	winlostdate		= tbl.MatchEventDate
	,	DBTP_rowcount	= COUNT(1)
	,	timetype		= CAST(''DAY'' AS VARCHAR(10))
FROM	bodb_Archive.dbo.' + @tablename + ' tbl WITH (NOLOCK)
WHERE	tbl.MatchEventDate >= @from
	AND	tbl.MatchEventDate <= @to
GROUP BY tbl.MatchEventDate;
';
			END;

			INSERT INTO	@result (tablename, winlostdate, DBTP_rowcount, timetype)
			EXECUTE	(@query);

			IF	@tablename = N'Dot_Admin_Assignment_Operator_bk'
			BEGIN
				SELECT	@query = N'';
				SELECT	@query = @query + N'
DECLARE	@from	DATETIME = ''' + CONVERT(NVARCHAR, @fromdate, 121) + N'''
	,	@to		DATETIME = ''' + CONVERT(NVARCHAR, @todate, 121) + N'''
;

SELECT	tablename		= CAST(''' + @tablename + N''' AS NVARCHAR(128))
	,	winlostdate		= m.eventdate
	,	DBTP_rowcount	= COUNT(1)
	,	timetype		= CAST(''DAY'' AS VARCHAR(10))
FROM		bodb_Archive.dbo.' + @tablename + ' tbl WITH (NOLOCK)
INNER JOIN	bodb02.dbo.match14 m WITH (NOLOCK)
	ON	tbl.matchid = m.matchid
WHERE	m.eventdate >= @from
AND	m.eventdate <= @to
GROUP BY m.eventdate;
';
				INSERT INTO	@result (tablename, winlostdate, DBTP_rowcount, timetype)
				EXECUTE	(@query);
			END;
		END;
	END;

	SELECT	tablename, winlostdate, DBTP_rowcount, timetype
	FROM	@result;
END;