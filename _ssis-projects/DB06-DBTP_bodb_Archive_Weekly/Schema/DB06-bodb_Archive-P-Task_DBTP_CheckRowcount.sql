USE bodb_archive
GO

ALTER PROCEDURE	dbo.Task_DBTP_CheckRowcount
AS
/*
	Creator:	20170427@Billy
	Task:		Check bodb_Archive tables' rowcount - [Redmine: #00000]
	Database:	DB06.bodb_Archive
		
	Revisions:
		- 20170627@Billy:	Add table type 5: MatchEventDate - [Redmine: #79047]
*/
BEGIN
	SET NOCOUNT ON;
		
		
END;
BEGIN
	SET NOCOUNT ON;

	DECLARE	@18months		DATETIME
		,	@tablename		NVARCHAR(128)
		,	@winlostdate	DATETIME
		,	@fromdate		DATETIME
		,	@todate			DATETIME
		,	@type			INT
		,	@query			NVARCHAR(MAX)
		;

	CREATE TABLE	#DBTP (
						tablename		NVARCHAR(128)
					,	winlostdate		DATETIME
					,	DBTP_rowcount	BIGINT
					,	timetype		VARCHAR(10)
					);

	CREATE TABLE	#DB06 (
						tablename		NVARCHAR(128)
					,	winlostdate		DATETIME
					,	DB06_rowcount	BIGINT
					,	timetype		VARCHAR(10)
					);

	-- Truncate rowcount table --
	TRUNCATE TABLE	Task_DBTP_ArchiveCheckRowcount;

	-- Select 18 months ago date --
	SELECT	@18months = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 17, 0);

	-- Import data from DBTP --
	INSERT INTO	#DBTP (tablename, winlostdate, DBTP_rowcount, timetype)
	SELECT	tablename, winlostdate, DBTP_rowcount, timetype
	FROM	OPENQUERY(DBTP, 'EXECUTE bodb_Archive.dbo.Task_DBTP_CheckRowcount_Child @step = 1;')
	WHERE	ISNULL(winlostdate, @18months) >= @18months;

	INSERT INTO #DB06 (tablename, winlostdate, DB06_rowcount, timetype)
	SELECT	'tablename'		= tbl.name
		,	'winlostdate'	= pt.right_value
		,	'DB06_rowcount'	= p.rows
		,	'timetype'		= CAST('MONTH' AS VARCHAR(10))
	FROM		bodb_Archive.dbo.Task_DBTP_ArchiveTables at WITH (NOLOCK)
	INNER JOIN	sys.tables tbl WITH (NOLOCK)
			ON	at.name = tbl.name
			AND	at.db = DB_NAME()
	INNER JOIN	sys.indexes idx WITH (NOLOCK)
			ON	tbl.object_id = idx.object_id
			AND	idx.type = 1 -- Clustered Index
	INNER JOIN	sys.partitions p WITH (NOLOCK)
			ON	idx.object_id = p.object_id
			AND	idx.index_id = p.index_id
	LEFT JOIN	sys.partition_schemes ps WITH (NOLOCK)
			ON	idx.data_space_id = ps.data_space_id
	LEFT JOIN	sys.partition_range_values rvr WITH (NOLOCK)
			ON	ps.function_id = rvr.function_id
			AND	p.partition_number = rvr.boundary_id
	OUTER APPLY	(
		SELECT	'right_value'	= DATEADD(MONTH, DATEDIFF(MONTH, 0, CAST(rvr.value AS DATETIME)), 0)
	) pt
	WHERE	ISNULL(pt.right_value, @18months) >= @18months;

	-- Insert value to rowcount table --
	INSERT INTO	Task_DBTP_ArchiveCheckRowcount (tablename, winlostdate, DB06_rowcount, DBTP_rowcount, timetype)
	SELECT	ISNULL(_06.tablename, _tp.tablename)
		,	ISNULL(_06.winlostdate, _tp.winlostdate)
		,	ISNULL(_06.DB06_rowcount, 0)
		,	ISNULL(_tp.DBTP_rowcount, 0)
		,	ISNULL(_06.timetype, _tp.timetype)
	FROM			#DB06 _06
	FULL OUTER JOIN	#DBTP _tp
				ON	_06.tablename = _tp.tablename
				AND	ISNULL(_06.winlostdate, 0) = ISNULL(_tp.winlostdate, 0)
				AND	_06.timetype = _tp.timetype;

	-- Keep only mismatch result --
	DELETE	tbl
	FROM	Task_DBTP_ArchiveCheckRowcount tbl
	WHERE	tbl.DB06_rowcount = tbl.DBTP_rowcount;

	-- Clear temp table data --
	TRUNCATE TABLE	#DBTP;
	TRUNCATE TABLE	#DB06;

	-- Count number of rows --
	WHILE	0 = 0
	BEGIN
		SELECT	@tablename		= NULL
			,	@winlostdate	= NULL
			;

		SELECT	TOP(1)
				@tablename		= tablename
			,	@winlostdate	= winlostdate
		FROM	Task_DBTP_ArchiveCheckRowcount WITH (NOLOCK)
		WHERE	timetype		= 'PROCESSING';

		IF	@tablename IS NULL AND @winlostdate IS NULL
		BEGIN
			UPDATE	TOP(1) Task_DBTP_ArchiveCheckRowcount
			SET		@tablename		= tablename
				,	@winlostdate	= winlostdate
				,	timetype		= 'PROCESSING'
			WHERE	timetype		= 'MONTH';
		END;

		IF	@tablename IS NULL AND @winlostdate IS NULL
			BREAK;

		INSERT INTO	#DBTP (tablename, winlostdate, DBTP_rowcount, timetype)
		SELECT	tablename, winlostdate, DBTP_rowcount, timetype
		FROM	OPENQUERY(DBTP, 'EXECUTE bodb_Archive.dbo.Task_DBTP_CheckRowcount_Child @step = 2;');

		SELECT	@type		= tabletype
		FROM	bodb_Archive.dbo.Task_DBTP_ArchiveTables t WITH (NOLOCK)
		WHERE	t.name	= @tablename
			AND	t.db	= DB_NAME();

		IF	@winlostdate IS NULL
		BEGIN
			SELECT	@fromdate	= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 17, 0)
				,	@todate		= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 12, 0)
				;
		END;
		ELSE
		BEGIN
			SELECT	@fromdate	= @winlostdate
				,	@todate		= DATEADD(MONTH, 1, @winlostdate)
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
	,	DB06_rowcount	= COUNT(1)
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
	,	DB06_rowcount	= COUNT(1)
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
	,	DB06_rowcount	= COUNT(1)
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
			SELECT	@fromdate	= DATEADD(MONTH, -2, @winlostdate)
				,	@todate		= DATEADD(MONTH, 1, @winlostdate)
				;

			SELECT	@query = N'';
			SELECT	@query = @query + N'
DECLARE	@from	DATETIME = ''' + CONVERT(NVARCHAR, @fromdate, 121) + N'''
	,	@to		DATETIME = ''' + CONVERT(NVARCHAR, @todate, 121) + N'''
;

SELECT	tablename		= CAST(''' + @tablename + N''' AS NVARCHAR(128))
	,	winlostdate		= DATEADD(DAY, DATEDIFF(DAY, 0, tbl.transtime), 0)
	,	DB06_rowcount	= COUNT(1)
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
	,	DB06_rowcount	= COUNT(1)
	,	timetype		= CAST(''DAY'' AS VARCHAR(10))
FROM	bodb_Archive.dbo.' + @tablename + ' tbl WITH (NOLOCK)
WHERE	tbl.MatchEventDate >= @from
AND	tbl.MatchEventDate <= @to
GROUP BY tbl.MatchEventDate;
';
		END;

		INSERT INTO	#DB06 (tablename, winlostdate, DB06_rowcount, timetype)
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
	,	DB06_rowcount	= COUNT(1)
	,	timetype		= CAST(''DAY'' AS VARCHAR(10))
FROM		bodb_Archive.dbo.' + @tablename + ' tbl WITH (NOLOCK)
INNER JOIN	bodb02.dbo.match14 m WITH (NOLOCK)
	ON	tbl.matchid = m.matchid
WHERE	m.eventdate >= @from
AND	m.eventdate <= @to
GROUP BY m.eventdate;
';
			INSERT INTO	#DB06 (tablename, winlostdate, DB06_rowcount, timetype)
			EXECUTE	(@query);
		END;

		UPDATE	TOP(1) Task_DBTP_ArchiveCheckRowcount
		SET		timetype	= NULL
		WHERE	timetype	= 'PROCESSING'
			AND	tablename	= @tablename
			AND	ISNULL(winlostdate, 0) = ISNULL(@winlostdate, 0);
	END;

	-- Delete processed data --
	DELETE	tbl
	FROM	Task_DBTP_ArchiveCheckRowcount tbl
	WHERE	timetype IS NULL;
	
	-- Insert day level rowcount --
	INSERT INTO	Task_DBTP_ArchiveCheckRowcount (tablename, winlostdate, DB06_rowcount, DBTP_rowcount, timetype)
	SELECT	ISNULL(_06.tablename, _tp.tablename)
		,	ISNULL(_06.winlostdate, _tp.winlostdate)
		,	ISNULL(_06.DB06_rowcount, 0)
		,	ISNULL(_tp.DBTP_rowcount, 0)
		,	ISNULL(_06.timetype, _tp.timetype)
	FROM			#DB06 _06
	FULL OUTER JOIN	#DBTP _tp 
				ON	_06.tablename = _tp.tablename
				AND	ISNULL(_06.winlostdate, 0) = ISNULL(_tp.winlostdate, 0)
				AND	_06.timetype = _tp.timetype;

	-- Keep only mismatch result --
	DELETE	tbl
	FROM	Task_DBTP_ArchiveCheckRowcount tbl
	WHERE	tbl.DB06_rowcount = tbl.DBTP_rowcount;
END;
