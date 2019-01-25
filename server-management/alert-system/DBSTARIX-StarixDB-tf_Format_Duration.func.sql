SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE FUNCTION	dbo.tf_Format_Duration (
					@duration	INT
				,	@type		SMALLINT		= 0
				)
RETURNS TABLE
AS
/*
	Creator:	20190125@Billy
	Task:		Duration Format Function - [Redmine: #107814]
	Database:	DBSTARIX.StarixDB
	
	Revisions:
		- 20190125@Billy:	Initial - [Redmine: #107814]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
RETURN (
	SELECT	[duration] = CASE WHEN @duration IS NULL OR @type = -1 THEN NULL ELSE t.duration END
	FROM	(
		SELECT	[duration]		= CASE @type WHEN 2 THEN '[' ELSE '' END
								+ CASE WHEN	_t.h > 0 THEN CAST(_t.h AS VARCHAR) + 'h' ELSE '' END
								+ CASE WHEN _t.m >= 10 OR (ISNULL(_t.h, 0) = 0 AND _t.m IS NOT NULL) THEN CAST(_t.m AS VARCHAR) + 'm' WHEN _t.m >= 0 AND _t.h > 0 THEN '0' + CAST(_t.m AS VARCHAR) + 'm' ELSE '' END
								+ CASE WHEN _t.s >= 10 OR (ISNULL(_t.h, 0) = 0 AND ISNULL(_t.m, 0) = 0) THEN CAST(ISNULL(_t.s, 0) AS VARCHAR) + 's' ELSE '0' + CAST(ISNULL(_t.s, 0) AS VARCHAR) + 's' END
								+ CASE @type WHEN 1 THEN '...' WHEN 2 THEN ']' ELSE '' END
		FROM	(
			SELECT	[h]				= NULLIF(FLOOR(@duration / 60 / 60), 0)
				,	[m]				= NULLIF(FLOOR((@duration % 3600) / 60), 0)
				,	[s]				= @duration % 60
		) AS _t
	) AS t
);
GO
/*<info serverAlias="DBSTARIX-StarixDB" executers="" viewers="" isFunction="1" isNested="0"></info>*/