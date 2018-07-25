/*
	Creator:	20180504@Billy
	Task:		Meta SP generator - stringify - [Redmine: #94602]
	Server:		[Server].StarixDB
*/

USE	StarixDB;
GO

DECLARE	@NoParams	SMALLINT		= 2000
	,	@Query		NVARCHAR(MAX)	= N''
	;

IF	OBJECT_ID('dbo.stringify') IS NOT NULL
	DROP PROCEDURE	dbo.stringify;

WITH tally AS (
	SELECT	[rn] = ROW_NUMBER() OVER(ORDER BY (SELECT NULL))
	FROM		(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) _x10(n)
	CROSS JOIN	(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) _x100(n)
	CROSS JOIN	(VALUES (0), (0), (0), (0), (0), (0), (0)) _x700(n)
	CROSS JOIN	(VALUES (0), (0), (0)) _x2100(n)
)
SELECT	@Query = @Query + N'
CREATE PROCEDURE	dbo.stringify
						@result		NVARCHAR(MAX)	OUTPUT
					,	' + params.str + N'
AS
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@tbl TABLE (col NVARCHAR(MAX));

	INSERT INTO	@tbl (col)
	SELECT	val.x
	FROM (
		VALUES	' + vals.str + N'
	) val(x)
	WHERE x IS NOT NULL;

	SELECT	@result = results.str
	FROM	(
		SELECT	col + '',''
		FROM	@tbl AS t
		FOR XML PATH ('''')
		,	TYPE
	) xresult(xml)
	CROSS APPLY	(
		SELECT	LEFT(xq.str, LEN(xq.str) - 1)
		FROM	(
			SELECT	xresult.xml.value(''.[1]'', ''NVARCHAR(MAX)'')
		) xq(str)
	) results(str);
END;
'
FROM	(
	SELECT	TOP(@NoParams)
			N'@' + CAST(rn AS NVARCHAR) + CASE WHEN rn < 100 THEN N'	' ELSE N'' END + N'		NVARCHAR(MAX)	= NULL
					,	'
	FROM	tally
	FOR XML PATH ('')
	,	TYPE
) xparam(xml)
CROSS APPLY	(
	SELECT	LEFT(xq.str, LEN(xq.str) - 8)
	FROM	(
		SELECT	xparam.xml.value('.[1]', 'NVARCHAR(MAX)')
	) xq(str)
) params(str)
CROSS APPLY	(
	SELECT	TOP(@NoParams)
			N'(@' + CAST(rn AS NVARCHAR) + N')
			,	'
	FROM	tally
	FOR XML PATH ('')
	,	TYPE
) xval(xml)
CROSS APPLY	(
	SELECT	LEFT(xq.str, LEN(xq.str) - 6)
	FROM	(
		SELECT	xval.xml.value('.[1]', 'NVARCHAR(MAX)')
	) xq(str)
) vals(str);

EXECUTE	sys.sp_executesql @Query;

GRANT EXECUTE ON dbo.stringify TO vnGrafana AS dbo;