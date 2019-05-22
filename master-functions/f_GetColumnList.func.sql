SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE FUNCTION	dbo.f_GetColumnList (
					@table		NVARCHAR(128)
				,	@style		NVARCHAR(128)
				,	@alias		NVARCHAR(128)		= NULL
				)
RETURNS	NVARCHAR(MAX)
AS
/*
	Creator:	20190506@Billy
	Task:		Get column list - [Redmine: #000000]

	Revisions:
		- 20190506@Billy:	Initial - [Redmine: #000000]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	DECLARE	@result	NVARCHAR(MAX);

	IF	@style IN (N'SELECT')
		SELECT	@result = LEFT(cls.str, LEN(cls.str) - 1)
		FROM	(
			SELECT	ISNULL(@alias + N'.', N'') + N'[' + col.name + N'], '
			FROM		sys.tables AS tbl WITH (NOLOCK)
			INNER JOIN	sys.columns AS col WITH (NOLOCK)
					ON	tbl.object_id = col.object_id
			WHERE	tbl.name = @table
				AND	col.is_computed = 0
				AND	col.system_type_id <> 189
			ORDER BY col.column_id
			FOR XML PATH ('')
			,	TYPE
		) AS clx(xml)
		CROSS APPLY	(
			SELECT	clx.xml.value('.[1]', 'NVARCHAR(MAX)')
		) AS cls(str);

	IF	@style IN (N'SELECT ALL')
		SELECT	@result = LEFT(cls.str, LEN(cls.str) - 1)
		FROM	(
			SELECT	ISNULL(@alias + N'.', N'') + N'[' + col.name + N'], '
			FROM		sys.tables AS tbl WITH (NOLOCK)
			INNER JOIN	sys.columns AS col WITH (NOLOCK)
					ON	tbl.object_id = col.object_id
			WHERE	tbl.name = @table
			ORDER BY col.column_id
			FOR XML PATH ('')
			,	TYPE
		) AS clx(xml)
		CROSS APPLY	(
			SELECT	clx.xml.value('.[1]', 'NVARCHAR(MAX)')
		) AS cls(str);

	IF	@style IN (N'PK', N'PRIMARY', N'PRIMARY KEY')
		SELECT	@result = LEFT(cls.str, LEN(cls.str) - 1)
		FROM	(
			SELECT	ISNULL(@alias + N'.', N'') + N'[' + col.name + N'], '
			FROM		sys.tables AS tbl WITH (NOLOCK)
			INNER JOIN	sys.indexes AS idx WITH (NOLOCK)
					ON	tbl.object_id = idx.object_id
			INNER JOIN	sys.index_columns AS ic WITH (NOLOCK)
					ON	idx.object_id = ic.object_id
					AND	idx.index_id = ic.index_id
			INNER JOIN	sys.columns AS col WITH (NOLOCK)
					ON	ic.object_id = col.object_id
					AND	ic.column_id = col.column_id
			WHERE	tbl.name = @table
				AND	idx.is_primary_key = 1
				AND	ic.is_included_column = 0
			ORDER BY ic.partition_ordinal, ic.key_ordinal
			FOR XML PATH ('')
			,	TYPE
		) AS clx(xml)
		CROSS APPLY	(
			SELECT	clx.xml.value('.[1]', 'NVARCHAR(MAX)')
		) AS cls(str);

	IF	@style IN (N'CLS', N'CLUSTERED', N'CIX', N'CLUSTERED INDEX', N'CLUSTERED INDEX KEY')
		SELECT	@result = LEFT(cls.str, LEN(cls.str) - 1)
		FROM	(
			SELECT	ISNULL(@alias + N'.', N'') + N'[' + col.name + N'], '
			FROM		sys.tables AS tbl WITH (NOLOCK)
			INNER JOIN	sys.indexes AS idx WITH (NOLOCK)
					ON	tbl.object_id = idx.object_id
			INNER JOIN	sys.index_columns AS ic WITH (NOLOCK)
					ON	idx.object_id = ic.object_id
					AND	idx.index_id = ic.index_id
			INNER JOIN	sys.columns AS col WITH (NOLOCK)
					ON	ic.object_id = col.object_id
					AND	ic.column_id = col.column_id
			WHERE	tbl.name = @table
				AND	idx.type = 1
				AND	ic.is_included_column = 0
			ORDER BY ic.partition_ordinal, ic.key_ordinal
			FOR XML PATH ('')
			,	TYPE
		) AS clx(xml)
		CROSS APPLY	(
			SELECT	clx.xml.value('.[1]', 'NVARCHAR(MAX)')
		) AS cls(str);

	RETURN	@result;
END;
GO