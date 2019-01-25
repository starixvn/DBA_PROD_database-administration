SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE FUNCTION	dbo.tf_SplitString (
					@string		NVARCHAR(MAX)
				,	@splitter	NVARCHAR(MAX)
				,	@id			INT				= NULL
				)
RETURNS TABLE
AS
/*
	Creator:	20190125@Billy
	Task:		Split String Function - Inline Table Value Version - [Redmine: #107814]
	Database:	DBSTARIX.StarixDB
	
	Revisions:
		- 20190125@Billy:	Initial - [Redmine: #107814]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
RETURN (
	WITH cte AS (
				SELECT	[start]		= CAST(1 AS INT)
					,	[finish]	= CASE WHEN CHARINDEX(@splitter, @string, 1) = 0 THEN LEN(@string) + 1 ELSE CHARINDEX(@splitter, @string, 1) END
					,	[id]		= 1
				UNION ALL
				SELECT	[start]		= CAST(cte.finish + LEN(@splitter) AS INT)
					,	[finish]	= CASE WHEN CHARINDEX(@splitter, @string, cte.finish + LEN(@splitter)) = 0 THEN LEN(@string) + 1 ELSE CHARINDEX(@splitter, @string, cte.finish + LEN(@splitter)) END
					,	[id]		= cte.id + 1
				FROM	cte
				WHERE	cte.finish < LEN(@string)
			)
	SELECT	[id]	= cte.id
		,	[val]	= LTRIM(RTRIM(SUBSTRING(@string, cte.start, cte.finish - cte.start)))
	FROM	cte
	WHERE	cte.id = ISNULL(@id, cte.id)
);
GO
/*<info serverAlias="DBSTARIX-StarixDB" executers="" viewers="" isFunction="1" isNested="0"></info>*/