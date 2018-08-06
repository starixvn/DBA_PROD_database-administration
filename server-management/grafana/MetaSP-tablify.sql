/*
	Creator:	20180504@Billy
	Task:		Meta SP generator - tablify - [Redmine: #94602]
	Server:		[Server].StarixDB
*/


--	BEGIN STEP 1:
--		User-defined Table Type: STRINGTABLE
----------------------------------------------------------------------------------------------------

USE	StarixDB;
GO

IF	TYPE_ID('dbo.STRINGTABLE') IS NOT NULL
	DROP TYPE	dbo.STRINGTABLE;
GO

CREATE TYPE	dbo.STRINGTABLE
AS TABLE (
	str		NVARCHAR(MAX)	NOT NULL
);
GO

GRANT EXECUTE ON TYPE::dbo.STRINGTABLE TO vnGrafana AS dbo;
GO


--	BEGIN STEP 2:
--		Stored Procedure: tablify
----------------------------------------------------------------------------------------------------

USE	StarixDB;
GO

DECLARE	@NoParams	SMALLINT		= 2000
	,	@Query		NVARCHAR(MAX)	= N''
	;

IF	OBJECT_ID('dbo.tablify') IS NOT NULL
	DROP PROCEDURE	dbo.tablify;

WITH tally AS (
	SELECT	[rn] = ROW_NUMBER() OVER(ORDER BY (SELECT NULL))
	FROM		(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) _x10(n)
	CROSS JOIN	(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) _x100(n)
	CROSS JOIN	(VALUES (0), (0), (0), (0), (0), (0), (0)) _x700(n)
	CROSS JOIN	(VALUES (0), (0), (0)) _x2100(n)
)
SELECT	@Query = @Query + N'
CREATE PROCEDURE	dbo.tablify
						' + params.str + N'
AS
BEGIN;
	SET NOCOUNT ON;

	SELECT	[str]	= val.x
	FROM (
		VALUES	' + vals.str + N'
	) val(x)
	WHERE x IS NOT NULL;
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

GRANT EXECUTE ON dbo.tablify TO vnGrafana AS dbo;