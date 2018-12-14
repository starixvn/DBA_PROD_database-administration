SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
USE master;
GO
IF	OBJECT_ID('dbo.sp_starix_tblspaceused') IS NOT NULL
	DROP PROCEDURE	dbo.sp_starix_tblspaceused;
GO
CREATE PROCEDURE	dbo.sp_starix_tblspaceused
						@show_as_pages			BIT = 0
					,	@include_queue			BIT = 0
					,	@include_internal		BIT = 0
					,	@include_system			BIT = 0
WITH EXECUTE AS CALLER
AS
/*
	Creator:	20181214@Billy
	Task:		Query all table space usage - [Redmine: #000000]
	Database:	master
	
	Revisions:
		- 20181214@Billy:	Initial - [Redmine: #000000]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@result AS TABLE (
				name			NVARCHAR(128)
			,	type			CHAR(2)
			,	type_desc		NVARCHAR(60)
			,	reserved_pages	BIGINT
			,	used_pages		BIGINT
			,	pages			BIGINT
			,	row_count		BIGINT
			);

	INSERT INTO @result (name, type, type_desc, reserved_pages, used_pages, pages, row_count)
	SELECT	[name]				= ISNULL(pobj.name, obj.name)
		,	[type]				= ISNULL(pobj.type, obj.type)
		,	[type_desc]			= ISNULL(pobj.type_desc, obj.type_desc)
		,	[reserved_pages]	= SUM(ps.reserved_page_count)
		,	[used_pages]		= SUM(ps.used_page_count)
		,	[pages]				= SUM(CASE WHEN ps.index_id < 2 THEN ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count ELSE 0 END)
		,	[row_count]			= SUM(CASE WHEN ps.index_id < 2 THEN ps.row_count ELSE 0 END)
	FROM		sys.all_objects AS pobj WITH (NOLOCK)
	RIGHT JOIN	sys.all_objects AS obj WITH (NOLOCK)
			ON	pobj.object_id = obj.parent_object_id
	INNER JOIN	sys.dm_db_partition_stats AS ps WITH (NOLOCK)
			ON	obj.object_id = ps.object_id
	GROUP BY	pobj.name, obj.name
			,	pobj.type, obj.type
			,	pobj.type_desc, obj.type_desc;

	IF	@show_as_pages = 1
	BEGIN;
		SELECT	[name]				= r.name
			,	[type]				= r.type
			,	[type_desc]			= r.type_desc
			,	[rows]				= r.row_count
			,	[reserved_pages]	= r.reserved_pages
			,	[data_pages]		= r.pages
			,	[index_pages]		= CASE WHEN r.used_pages > r.pages THEN r.used_pages - r.pages ELSE 0 END
			,	[unused_pages]		= CASE WHEN r.reserved_pages > r.used_pages THEN r.reserved_pages - r.used_pages ELSE 0 END
		FROM	@result AS r
		WHERE	r.type <> CASE @include_queue WHEN 1 THEN '' ELSE 'SQ' END
			AND	r.type <> CASE @include_internal WHEN 1 THEN '' ELSE 'IT' END
			AND	r.type <> CASE @include_system WHEN 1 THEN '' ELSE 'S' END
		ORDER BY r.type, r.name;
	END;
	ELSE
	BEGIN;
		SELECT	[name]				= r.name
			,	[type]				= r.type
			,	[type_desc]			= r.type_desc
			,	[rows]				= r.row_count
			,	[reserved_kb]		= r.reserved_pages * 8
			,	[data_kb]			= r.pages * 8
			,	[index_kb]			= CASE WHEN r.used_pages > r.pages THEN r.used_pages - r.pages ELSE 0 END * 8
			,	[unused_kb]			= CASE WHEN r.reserved_pages > r.used_pages THEN r.reserved_pages - r.used_pages ELSE 0 END * 8
		FROM	@result AS r
		WHERE	r.type <> CASE @include_queue WHEN 1 THEN '' ELSE 'SQ' END
			AND	r.type <> CASE @include_internal WHEN 1 THEN '' ELSE 'IT' END
			AND	r.type <> CASE @include_system WHEN 1 THEN '' ELSE 'S' END
		ORDER BY r.type, r.name;
	END;
END;
GO
GRANT EXECUTE ON dbo.sp_starix_tblspaceused TO PUBLIC AS dbo;
GO
EXECUTE	sys.sp_MS_marksystemobject @objname = 'dbo.sp_starix_tblspaceused';
GO