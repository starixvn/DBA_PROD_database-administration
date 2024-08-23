/*
	Task: Generate scripts/steps to prepare objects for In-house replication
	Created: Daniel@20240529
	Run on Source DB server that contains the table to be added to in-house replication, then copy script parts run relevant server Source/Distributor/Target

*/

DECLARE @SrcDBName VARCHAR(50) = 'CustDB' --Source or publisher db name
DECLARE @TargetDBName VARCHAR(50) = 'bodb02'--Target or subscriber db name
DECLARE @DistDBName VARCHAR(50) = 'ReplCustDB'--Distributor db name
DECLARE @tbl_name VARCHAR(50) = 'BetSetting_Member' --Table name Dep_CustBetSettingGame_Member, Dep_ChargeInfoSetting
DECLARE @RepGroup tinyint = 1 --RepGroup for source-target, if have dist then it's for source-distributor

DECLARE @SyncDelete BIT = 1 --hybrid(1) sync delete action, standard(0) no sync delete acion
DECLARE @HaveDist BIT = 1 -- direct(0) source-target without distributor, indirect (1) via distributor source-distributor-target
DECLARE @RepGroup_dist tinyint = 0 --RepGroup for distributor-target

DECLARE @RepAlterSchema BIT = 0 --for alter/drop related objects for schema changes (add new column, change datatype etc) - to be implemented - not available yet!

------------------------------------------------------------------------
DECLARE @sql NVARCHAR(MAX) = '', @sql2 NVARCHAR(MAX) = ''
DECLARE @sql_Source NVARCHAR(MAX) = ''
DECLARE @sql_Target NVARCHAR(MAX) = ''
DECLARE @sql_Dist NVARCHAR(MAX) = ''

DECLARE @HasIdentity bit = 0
DECLARE @PK_cols TABLE(name varchar(100), ord int)
DECLARE @NonPK_cols TABLE(name varchar(100), ord int)
DECLARE @filegroup VARCHAR(50)

SET NOCOUNT ON

--get PK columns
insert @PK_cols
SELECT COL_NAME(ic.OBJECT_ID,ic.column_id) AS ColumnName,
	IC.column_id
FROM sys.indexes AS i 
	INNER JOIN sys.index_columns AS ic ON  i.OBJECT_ID = ic.OBJECT_ID AND i.index_id = ic.index_id
WHERE i.is_primary_key = 1 
	and OBJECT_NAME(ic.OBJECT_ID) = @tbl_name

--get other columns
insert @NonPK_cols
SELECT name, colorder
FROM syscolumns
WHERE id = OBJECT_ID(@tbl_name) AND name not in(select name from @PK_cols)

--get identity status
if exists(
select 1 FROM sys.objects so INNER JOIN sys.columns sc ON so.object_id= sc.object_id 
WHERE so.Name = @tbl_name and sc.is_identity = 1
) set @HasIdentity = 1

--get filegroup
SELECT @filegroup = f.[name]
FROM sys.indexes i
	INNER JOIN sys.filegroups f ON i.data_space_id = f.data_space_id
	INNER JOIN sys.all_objects o ON i.[object_id] = o.[object_id] 
WHERE i.data_space_id = f.data_space_id
AND o.type = 'U' AND o.name = @tbl_name


select @sql = '
ALTER TABLE [' + @tbl_name + ']	
	ADD [RepUpdateTime] [datetime2](7) NULL' + case when @SyncDelete = 0 then ',
	 [isDeleted] [bit] NULL' else '' end + '
GO' + case when @SyncDelete = 0 then '
ALTER TABLE [dbo].' + @tbl_name + ' ADD  CONSTRAINT [DF_' + @tbl_name + '_isDeleted]  DEFAULT ((0)) FOR [isDeleted]
GO' else '' end + '
ALTER TABLE [dbo].' + @tbl_name + ' ADD  CONSTRAINT [DF_' + @tbl_name + '_RepUpdateTime]  DEFAULT (sysdatetime()) FOR [RepUpdateTime]
GO   

--create index for column RepUpdateTime
CREATE NONCLUSTERED INDEX [IX_' + @tbl_name + '_RepUpdateTime] ON [dbo].[' + @tbl_name + ']
(
	[RepUpdateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [' + @filegroup + ']
GO'
+ case when @HasIdentity = 1 then 
	CHAR(13) + CHAR(13) + '--grant alter table for identity insert
' + 'GRANT ALTER ON [dbo].[' + @tbl_name + '] TO [repl_ap] AS [dbo]
GO'
  else '' end + '

' 

select @sql2 = case when @SyncDelete = 1 then 
'--create table for storing deleted data for sync-ing to sub
CREATE TABLE [dbo].[' + @tbl_name + '_Del_InHouse](
' + STUFF((
    SELECT CHAR(9) + ',[' + c.name + '] ' + 
        UPPER(tp.name) + 
                CASE WHEN tp.name IN ('varchar', 'char', 'varbinary', 'binary', 'text')
                       THEN '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length AS VARCHAR(5)) END + ')'
                     WHEN tp.name IN ('nvarchar', 'nchar', 'ntext')
                       THEN '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length / 2 AS VARCHAR(5)) END + ')'
                     WHEN tp.name IN ('datetime2', 'time2', 'datetimeoffset') 
                       THEN '(' + CAST(c.scale AS VARCHAR(5)) + ')'
                    WHEN tp.name IN ('decimal', 'numeric')
                       THEN '(' + CAST(c.[precision] AS VARCHAR(5)) + ',' + CAST(c.scale AS VARCHAR(5)) + ')'
                    ELSE ''
                END +
                CASE WHEN c.is_nullable = 1 THEN ' NULL' ELSE ' NOT NULL' END + CHAR(13)
    FROM sys.columns c WITH (NOWAIT) JOIN sys.types tp WITH (NOWAIT) ON c.user_type_id = tp.user_type_id
		LEFT JOIN sys.computed_columns cc WITH (NOWAIT) ON c.[object_id] = cc.[object_id] AND c.column_id = cc.column_id
    WHERE c.[object_id] = OBJECT_ID(@tbl_name) AND c.name IN(select [name] from @PK_cols)
    ORDER BY c.column_id
    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, CHAR(9) + ' ')
	+ '	,[RepUpdateTime] [datetime2](7) NOT NULL
	) ON [' + @filegroup + ']
GO

CREATE CLUSTERED INDEX [IX_' + @tbl_name + '_Del_InHouse] ON [dbo].[' + @tbl_name + '_Del_InHouse]
(
	[RepUpdateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [' + @filegroup + ']
GO' else '' end

SELECT @sql_Source  = ' --============================================================================================================================
-- 1. Prepare table on Source
USE ' + @SrcDBName + '
GO' + @SQL + @sql2

select CONVERT(XML, (SELECT N' --' + char(13) + CONVERT(NVARCHAR(MAX), @sql_Source) + char(13) + N'--' AS [processing-instruction(query)] FOR XML PATH(''))) [1. Prepare table on Source]
PRINT @sql_Source

if @HaveDist = 1
BEGIN
	select @sql2 = '
CREATE TABLE ' + @tbl_name + CHAR(13) + '(' + CHAR(13) + STUFF((
		SELECT CHAR(9) + ', [' + c.name + '] ' + 
			UPPER(tp.name) + 
					CASE WHEN tp.name IN ('varchar', 'char', 'varbinary', 'binary', 'text')
						   THEN '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length AS VARCHAR(5)) END + ')'
						 WHEN tp.name IN ('nvarchar', 'nchar', 'ntext')
						   THEN '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length / 2 AS VARCHAR(5)) END + ')'
						 WHEN tp.name IN ('datetime2', 'time2', 'datetimeoffset') 
						   THEN '(' + CAST(c.scale AS VARCHAR(5)) + ')'
						WHEN tp.name IN ('decimal', 'numeric')
						   THEN '(' + CAST(c.[precision] AS VARCHAR(5)) + ',' + CAST(c.scale AS VARCHAR(5)) + ')'
						ELSE ''
					END +          
					CASE WHEN c.is_nullable = 1 OR pc.name is null THEN ' NULL' ELSE ' NOT NULL' END
					+ CASE WHEN ic.is_identity = 1 THEN ' IDENTITY(' + convert(varchar(10), ISNULL(ic.seed_value, 0)) + ',' + CAST(ISNULL(ic.increment_value, '1') AS CHAR(1)) + ')' ELSE '' END
					 + CHAR(13)
		FROM sys.columns c WITH (NOWAIT)
			INNER JOIN sys.types tp WITH (NOWAIT) ON c.user_type_id = tp.user_type_id
			LEFT JOIN sys.default_constraints dc WITH (NOWAIT) ON c.default_object_id != 0 AND c.[object_id] = dc.parent_object_id AND c.column_id = dc.parent_column_id
			LEFT JOIN sys.identity_columns ic WITH (NOWAIT) ON c.is_identity = 1 AND c.[object_id] = ic.[object_id] AND c.column_id = ic.column_id
			LEFT JOIN @PK_cols pc on c.name = pc.name
		WHERE c.[object_id] = OBJECT_ID(@tbl_name) AND c.name NOT IN('RepUpdateTime', 'IsDeleted')
		ORDER BY c.column_id
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, CHAR(9) + ' ')
		+ '	, [RepUpdateTime] [datetime2](7) NULL
	, [isDeleted] [bit] NULL
' + ISNULL((SELECT CHAR(9) + ', CONSTRAINT [' + k.name + '] PRIMARY KEY CLUSTERED (' + 
						(SELECT STUFF((
							 SELECT ', [' + c.name + '] ' + CASE WHEN ic.is_descending_key = 1 THEN 'DESC' ELSE 'ASC' END
							 FROM sys.index_columns ic WITH (NOWAIT)
							 JOIN sys.columns c WITH (NOWAIT) ON c.[object_id] = ic.[object_id] AND c.column_id = ic.column_id
							 WHERE ic.is_included_column = 0
								 AND ic.[object_id] = k.parent_object_id 
								 AND ic.index_id = k.unique_index_id     
							 FOR XML PATH(N''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, ''))
				+ ') ON [' + @filegroup + ']' + CHAR(13)
				FROM sys.key_constraints k WITH (NOWAIT)
				WHERE k.parent_object_id = OBJECT_ID(@tbl_name) 
					AND k.[type] = 'PK'), '') + ')'  + CHAR(13)
 
 	+ 'ON [' + @filegroup + ']
GO

ALTER TABLE [dbo].' + @tbl_name + ' ADD  CONSTRAINT [DF_' + @tbl_name + '_isDeleted]  DEFAULT ((0)) FOR [isDeleted]
GO
ALTER TABLE [dbo].' + @tbl_name + ' ADD  CONSTRAINT [DF_' + @tbl_name + '_RepUpdateTime]  DEFAULT (sysdatetime()) FOR [RepUpdateTime]
GO   

--create index for column RepUpdateTime
CREATE NONCLUSTERED INDEX [IX_' + @tbl_name + '_RepUpdateTime] ON [dbo].[' + @tbl_name + ']
(
	[RepUpdateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [' + @filegroup + ']
GO'
	+ case when @HasIdentity = 1 then 
		CHAR(13) + CHAR(13) + '--grant alter table for identity insert - Run on Targets only
' + 'GRANT ALTER ON [dbo].[' + @tbl_name + '] TO [repl_ap] AS [dbo]
GO'
	else '' end + '
'

	SELECT @sql_Dist  = ' --============================================================================================================================
-- 1. Prepare table on Distributor
USE ' + @DistDBName + '
GO' + @SQL2
	select CONVERT(XML, (SELECT N' --' + char(13) + CONVERT(NVARCHAR(MAX), @sql_Dist) + char(13) + N'--' AS [processing-instruction(query)] FOR XML PATH('')))  [1. Prepare table on Distributor]
	PRINT char(13) + @sql_Dist
END


SELECT @sql_Target  = ' --============================================================================================================================
-- 1. Prepare table on Target
--  Table need to be pre-created 1st from original
USE ' + @TargetDBName + '
GO' + @SQL

select CONVERT(XML, (SELECT N' --' + char(13) + CONVERT(NVARCHAR(MAX), @sql_Target) + char(13) + N'--' AS [processing-instruction(query)] FOR XML PATH('')))  AS [1 Prepare table on Target]
PRINT char(13) + @sql_Target


SELECT @SQL = ' --============================================================================================================================
-- 2. Deploy SP get on Source server
USE ' + @SrcDBName + '
GO

CREATE PROCEDURE [dbo].[Repl_Get' + @tbl_name + ']
	@start DATETIME2,
	@count INT,
	@back_fix INT = 0
AS
/*
	Created by Daniel 
	Task : 
	DB: 
	
	Revisions:
		
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @__time_start DATETIME2 = DATEADD(MILLISECOND, -@back_fix, @start);
	DECLARE @__time_end DATETIME2;
	DECLARE @__time_upperbound DATETIME2 = DATEADD(MILLISECOND, [dbo].[f_GetUpperBound_BackFix](), SYSDATETIME());

	SET LOCK_TIMEOUT 1000;

' + case when @SyncDelete = 0 -- regular
	then '    WITH CTE_Timestamp ([RepUpdateTime]) AS (
		SELECT TOP (@count) [RepUpdateTime]
		FROM [dbo].[' + @tbl_name + '] WITH (NOLOCK, INDEX = IX_' + @tbl_name + '_RepUpdateTime)
		WHERE [RepUpdateTime] > @start AND [RepUpdateTime] < @__time_upperbound
		ORDER BY [RepUpdateTime]
	)
	SELECT @__time_end = ISNULL(MAX([RepUpdateTime]), @start) FROM CTE_Timestamp;

	SET LOCK_TIMEOUT -1;

	IF @__time_end > @start
	BEGIN
		SELECT' 	
	+ STUFF ((
		select REPLICATE(CHAR(9),3) + ',[' + name +']' + CHAR(13) from
		(
			select * FROM @PK_cols
			union all select * FROM @NonPK_cols
		) cc
		where cc.name not IN('RepUpdateTime', 'IsDeleted')
		order by ord
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 4, CHAR(9) + '')
	+ '			,[RepUpdateTime]			,ISNULL(IsDeleted, 0) AS IsDeleted			,SYSDATETIME() AS [_FetchedTime]
		FROM [dbo].[' + @tbl_name + ']  WITH (NOLOCK, INDEX = IX_' + @tbl_name + '_RepUpdateTime)
		WHERE [RepUpdateTime] > @__time_start AND [RepUpdateTime] <= @__time_end
		ORDER BY [RepUpdateTime];
	END;
'
else -- hybrid - sync deleted data to sub
'    WITH CTE_Timestamp ([RepUpdateTime]) AS (
		SELECT TOP (@count) [RepUpdateTime]
		FROM(
			SELECT [RepUpdateTime]
			FROM [dbo].[' + @tbl_name + '] WITH (NOLOCK, INDEX = IX_' + @tbl_name + '_RepUpdateTime)
			WHERE [RepUpdateTime] > @start AND [RepUpdateTime] < @__time_upperbound
			UNION ALL 
			SELECT [RepUpdateTime]
			FROM [dbo].' + @tbl_name + '_Del_InHouse WITH (NOLOCK)
			WHERE [RepUpdateTime] > @start AND [RepUpdateTime] < @__time_upperbound	
		) t
		ORDER BY [RepUpdateTime]
	)
	SELECT @__time_end = ISNULL(MAX([RepUpdateTime]), @start) FROM CTE_Timestamp;

	SET LOCK_TIMEOUT -1;

	IF @__time_end > @start
	BEGIN		
		;WITH CTE AS(
		SELECT' 	
	+ STUFF ((
		select REPLICATE(CHAR(9),3) + ',[' + name +']' + CHAR(13) from
		(
			select * FROM @PK_cols
			union all select * FROM @NonPK_cols
		) cc
		where cc.name not IN('RepUpdateTime', 'IsDeleted')
		order by ord
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 4, CHAR(9) + '')
	+ '			,[RepUpdateTime]
			,0 AS isDeleted
		FROM [dbo].[' + @tbl_name + ']  WITH (NOLOCK, INDEX = IX_' + @tbl_name + '_RepUpdateTime)
		WHERE [RepUpdateTime] > @__time_start AND [RepUpdateTime] <= @__time_end
		)
		SELECT' 	
	+ STUFF ((
		select REPLICATE(CHAR(9),3) + ',[' + name +']' + CHAR(13) from
		(
			select * FROM @PK_cols
			union all select * FROM @NonPK_cols
		) cc
		where cc.name not IN('RepUpdateTime', 'IsDeleted')
		order by ord
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 4, CHAR(9) + '')
	+ '			,[RepUpdateTime]
			,0 AS isDeleted
			,SYSDATETIME() AS [_FetchedTime] 
		FROM CTE
		UNION ALL
		SELECT' 	
	+ STUFF ((
		select REPLICATE(CHAR(9),3) + ',[' + name +']' + CHAR(13) from @PK_cols
		order by ord
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 4, CHAR(9) + '')
	+ '	' + STUFF ((
		select REPLICATE(CHAR(9),3) + ',NULL [' + name +']' + CHAR(13) from @NonPK_cols
		where [name] not IN('RepUpdateTime', 'IsDeleted')
		order by ord
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, CHAR(9) + '')

	+ '			,MAX(RepUpdateTime) [RepUpdateTime]
			,1 AS isDeleted
			,SYSDATETIME() AS [_FetchedTime] 
		FROM [dbo].' + @tbl_name + '_Del_InHouse del WITH (NOLOCK)
		WHERE [RepUpdateTime] > @__time_start AND [RepUpdateTime] <= @__time_end
			AND NOT EXISTS( SELECT TOP 1 1 
							FROM CTE c 
							WHERE
						'
	+ STUFF ((
		select REPLICATE(CHAR(9),8) + 'AND c.[' + name +'] = del.[' + name +']' + CHAR(13) from @PK_cols
		order by ord
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 3, 10, CHAR(9))
	+ '						)
		GROUP BY
		'
	+ STUFF ((
		select REPLICATE(CHAR(9),3) + ',[' + name +']' + CHAR(13) from @PK_cols
		order by ord
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 4, CHAR(9) + '')
	+ '
		ORDER BY [RepUpdateTime]
	END;
' 
end 
+ 'END
GO
GRANT EXECUTE ON [dbo].[Repl_Get' + @tbl_name + '] TO [repl_ap] AS [dbo]
GO


'
SELECT @sql_Source = @SQL
select CONVERT(XML, (SELECT N' --' + char(13) + CONVERT(NVARCHAR(MAX), @sql_Source) + char(13) + N'--' AS [processing-instruction(query)] FOR XML PATH('')))  [2. Deploy SP get on Source]
PRINT CHAR(13) + @sql_Source


if @HaveDist = 1
BEGIN

	SELECT @SQL2 = ' --============================================================================================================================
-- 2. Deploy SP get on Distributor
USE ' + @DistDBName + '
GO

CREATE PROCEDURE [dbo].[Repl_Get' + @tbl_name + '_Dist]
	@start DATETIME2,
	@count INT,
	@back_fix INT = 0
AS
/*
	Created by Daniel 
	Task : 
	DB: 
	
	Revisions:
		
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @__time_start DATETIME2 = DATEADD(MILLISECOND, -@back_fix, @start);
	DECLARE @__time_end DATETIME2;
	DECLARE @__time_upperbound DATETIME2 = DATEADD(MILLISECOND, [dbo].[f_GetUpperBound_BackFix](), SYSDATETIME());

	SET LOCK_TIMEOUT 1000;

	WITH CTE_Timestamp ([RepUpdateTime]) AS (
		SELECT TOP (@count) [RepUpdateTime]
		FROM [dbo].[' + @tbl_name + '] WITH (NOLOCK, INDEX = IX_' + @tbl_name + '_RepUpdateTime)
		WHERE [RepUpdateTime] > @start AND [RepUpdateTime] < @__time_upperbound
		ORDER BY [RepUpdateTime]
	)
	SELECT @__time_end = ISNULL(MAX([RepUpdateTime]), @start) FROM CTE_Timestamp;

	SET LOCK_TIMEOUT -1;

	IF @__time_end > @start
	BEGIN
		SELECT' 	
	+ STUFF ((
		select REPLICATE(CHAR(9),3) + ',[' + name +']' + CHAR(13) from
		(
			select * FROM @PK_cols
			union all select * FROM @NonPK_cols
		) cc
		where cc.name not IN('RepUpdateTime', 'IsDeleted')
		order by ord
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 4, CHAR(9) + '')
	+ '			,[RepUpdateTime]			,ISNULL(IsDeleted, 0) AS IsDeleted			,SYSDATETIME() AS [_FetchedTime]
		FROM [dbo].[' + @tbl_name + ']  WITH (NOLOCK, INDEX = IX_' + @tbl_name + '_RepUpdateTime)
		WHERE [RepUpdateTime] > @__time_start AND [RepUpdateTime] <= @__time_end
		ORDER BY [RepUpdateTime];
	END;
	 
END
GO
GRANT EXECUTE ON [dbo].[Repl_Get' + @tbl_name + '_Dist] TO [repl_ap] AS [dbo]
GO


'
	SELECT @sql_dist = @SQL2
	select CONVERT(XML, (SELECT N' --' + char(13) + CONVERT(NVARCHAR(MAX), @sql_dist) + char(13) + N'--' AS [processing-instruction(query)] FOR XML PATH('')))  [2. Deploy SP get on Distributor]
	PRINT CHAR(13) + @sql_Source
END



SELECT @SQL = '
CREATE TYPE  [dbo].[TVP_Repl' + @tbl_name + '] AS TABLE' + CHAR(13) + '(' + CHAR(13) + STUFF((
    SELECT CHAR(9) + ',[' + c.name + '] ' + 
        UPPER(tp.name) + 
                CASE WHEN tp.name IN ('varchar', 'char', 'varbinary', 'binary', 'text')
                       THEN '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length AS VARCHAR(5)) END + ')'
                     WHEN tp.name IN ('nvarchar', 'nchar', 'ntext')
                       THEN '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length / 2 AS VARCHAR(5)) END + ')'
                     WHEN tp.name IN ('datetime2', 'time2', 'datetimeoffset') 
                       THEN '(' + CAST(c.scale AS VARCHAR(5)) + ')'
                    WHEN tp.name IN ('decimal', 'numeric')
                       THEN '(' + CAST(c.[precision] AS VARCHAR(5)) + ',' + CAST(c.scale AS VARCHAR(5)) + ')'
                    ELSE ''
                END +
                CASE WHEN c.is_nullable = 1 OR pc.name is null THEN ' NULL' ELSE ' NOT NULL' END + CHAR(13)
    FROM sys.columns c WITH (NOWAIT) JOIN sys.types tp WITH (NOWAIT) ON c.user_type_id = tp.user_type_id
		LEFT JOIN sys.computed_columns cc WITH (NOWAIT) ON c.[object_id] = cc.[object_id] AND c.column_id = cc.column_id
		LEFT JOIN @PK_cols pc on c.name = pc.name
    WHERE c.[object_id] = OBJECT_ID(@tbl_name) AND c.name NOT IN('RepUpdateTime', 'IsDeleted')
    ORDER BY c.column_id
    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, CHAR(9) + ' ')
	+ '	,[RepUpdateTime] [datetime2](7) NULL
	,[isDeleted] [bit] NOT NULL
	,[_FetchedTime] [datetime2](7) NULL
)
GO
GRANT EXECUTE ON TYPE::[dbo].[TVP_Repl' + @tbl_name + '] TO [repl_ap] AS [dbo]
GO'

if @HaveDist = 1
BEGIN
	SELECT @sql_Dist = ' --============================================================================================================================
-- 2. Deploy TVP on Distributor
USE ' + @DistDBName + '
GO' + @SQL
	select CONVERT(XML, (SELECT N' --' + char(13) + CONVERT(NVARCHAR(MAX), @sql_Dist) + char(13) + N'--' AS [processing-instruction(query)] FOR XML PATH('')))  AS [2. Deploy TVP on Distributor]
	PRINT char(13) + @sql_Dist
END

SELECT @sql_Target = ' --============================================================================================================================
-- 2. Deploy TVP on Target
USE ' + @TargetDBName + '
GO' + @SQL
select CONVERT(XML, (SELECT N' --' + char(13) + CONVERT(NVARCHAR(MAX), @sql_Target) + char(13) + N'--' AS [processing-instruction(query)] FOR XML PATH('')))  [2. Deploy TVP on Target]
PRINT char(13) + @sql_Target


if @HaveDist = 1
BEGIN
	select @SQL2 = '
CREATE PROCEDURE [dbo].[Repl_Put' + @tbl_name + '_Dist]
    @tvp_param TVP_Repl' + @tbl_name + ' READONLY
AS
/*
    Created by Daniel
	Task : 
	DB:
	
	Revisions:
		
*/
BEGIN
    SET NOCOUNT ON;'
	+ case when @HasIdentity = 1 then CHAR(13) + CHAR(13) + '	SET IDENTITY_INSERT [dbo].[' + @tbl_name + '] ON;' + CHAR(13) else '' end + '
    MERGE [dbo].[' + @tbl_name + '] [t]
    USING @tvp_param [tvp] ON' + 
	+ STUFF ((
				SELECT REPLICATE(CHAR(9),7)+ 'AND [t].[' + name + '] = [tvp].[' + name + ']' + CHAR(13) FROM @PK_cols
				ORDER by ord
				FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 11, CHAR(9))
	+ '	WHEN MATCHED THEN
        UPDATE SET' +
	+ iif (exists(select 1 from @NonPK_cols where name NOT IN('RepUpdateTime', 'IsDeleted')),  
		STUFF ((
				SELECT ',[' + name + '] = [tvp].[' + name + ']' + CHAR(13) + '                   ' FROM @NonPK_cols
				where name NOT IN('RepUpdateTime', 'IsDeleted')
				ORDER by ord
				FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, CHAR(9)) + ','
		, ' ')
	+ '[isDeleted] = [tvp].[isDeleted]                   ,[RepUpdateTime]	= CASE WHEN [tvp].[RepUpdateTime] > [t].[RepUpdateTime] THEN [tvp].[RepUpdateTime] ELSE [t].[RepUpdateTime] END
    WHEN NOT MATCHED THEN
        INSERT (' + CHAR(13)
	+ STUFF ((
		select CHAR(9) + CHAR(9) + ',[' + name +']' + CHAR(13) from
		(
			select * FROM @PK_cols
			union all select * FROM @NonPK_cols
		) cc
		where cc.name NOT IN('RepUpdateTime', 'IsDeleted')
		order by ord
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 3, CHAR(9) + CHAR(9))
	+ '		,[RepUpdateTime]		,[isDeleted]' + CHAR(13)
	+ ' 	  ) VALUES (' + CHAR(13)
	+ STUFF ((
		select CHAR(9) + CHAR(9) + ',[tvp].[' + name +']' + CHAR(13) from
		(
			select * FROM @PK_cols
			union all select * FROM @NonPK_cols
		) cc
		where cc.name NOT IN('RepUpdateTime', 'IsDeleted')
		order by ord
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 3, CHAR(9) + CHAR(9))
	+ '		,[tvp].[RepUpdateTime]		,[tvp].[isDeleted]' + CHAR(13)
	+ '		);'
	+ case when @HasIdentity = 1 then CHAR(13) + CHAR(13) + '	SET IDENTITY_INSERT [dbo].[' + @tbl_name + '] OFF;' + CHAR(13) else '' end + '
END
GO
GRANT EXECUTE ON [dbo].[Repl_Put' + @tbl_name + '_Dist] TO [repl_ap] AS [dbo]
GO

'

	SELECT @sql_Dist = ' --============================================================================================================================
-- 2. Deploy SP put on Distributor
USE ' + @DistDBName + '
GO' + @SQL2
	select CONVERT(XML, (SELECT N' --' + char(13) + CONVERT(NVARCHAR(MAX), @sql_Dist) + char(13) + N'--' AS [processing-instruction(query)] FOR XML PATH('')))  [2. Deploy SP put on Distributor]
	PRINT @sql_Dist
END



select @SQL = '
CREATE PROCEDURE [dbo].[Repl_Put' + @tbl_name + ']
    @tvp_param TVP_Repl' + @tbl_name + ' READONLY
AS
/*
    Created by Daniel
	Task : 
	DB:
	
	Revisions:
		
*/
BEGIN
    SET NOCOUNT ON;'
	+ case when @HasIdentity = 1 then CHAR(13) + CHAR(13) + '	SET IDENTITY_INSERT [dbo].[' + @tbl_name + '] ON;' + CHAR(13) else '' end + '
    MERGE [dbo].[' + @tbl_name + '] [t]
    USING @tvp_param [tvp] ON' + 
	+ STUFF ((
				SELECT REPLICATE(CHAR(9),7)+ 'AND [t].[' + name + '] = [tvp].[' + name + ']' + CHAR(13) FROM @PK_cols
				ORDER by ord
				FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 11, CHAR(9))
 + case when @SyncDelete = 0 -- regular
    then '	WHEN MATCHED THEN
        UPDATE SET' +
	+ iif (exists(select 1 from @NonPK_cols where name NOT IN('RepUpdateTime', 'IsDeleted')),  
		STUFF ((
				SELECT ',[' + name + '] = [tvp].[' + name + ']' + CHAR(13) + '                   ' FROM @NonPK_cols
				where name NOT IN('RepUpdateTime', 'IsDeleted')
				ORDER by ord
				FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, CHAR(9)) + ','
		, ' ')
	+ '' + case when @SyncDelete = 0 then '[isDeleted] = [tvp].[isDeleted]                   ,' else '' end + '[RepUpdateTime]	= CASE WHEN [tvp].[RepUpdateTime] > [t].[RepUpdateTime] THEN [tvp].[RepUpdateTime] ELSE [t].[RepUpdateTime] END
    WHEN NOT MATCHED THEN' 
 else -- hybrid - sync deleted data to sub
'	WHEN MATCHED AND [tvp].isDeleted = 0 THEN
        UPDATE SET' +
	+ iif (exists(select 1 from @NonPK_cols where name NOT IN('RepUpdateTime', 'IsDeleted')),  
		STUFF ((
				SELECT ',[' + name + '] = [tvp].[' + name + ']' + CHAR(13) + '                   ' FROM @NonPK_cols
				where name NOT IN('RepUpdateTime', 'IsDeleted')
				ORDER by ord
				FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, CHAR(9)) + ','
		, ' ')
	+ '' + case when @SyncDelete = 0 then '[isDeleted] = [tvp].[isDeleted]                   ,' else '' end + '[RepUpdateTime]	= CASE WHEN [tvp].[RepUpdateTime] > [t].[RepUpdateTime] THEN [tvp].[RepUpdateTime] ELSE [t].[RepUpdateTime] END
	WHEN MATCHED AND [tvp].isDeleted = 1 THEN 
		DELETE
    WHEN NOT MATCHED AND [tvp].isDeleted = 0 THEN' 	
 end + '
        INSERT (' + CHAR(13)
	+ STUFF ((
		select CHAR(9) + CHAR(9) + ',[' + name +']' + CHAR(13) from
		(
			select * FROM @PK_cols
			union all select * FROM @NonPK_cols
		) cc
		where cc.name NOT IN('RepUpdateTime', 'IsDeleted')
		order by ord
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 3, CHAR(9) + CHAR(9))
	+ '		,[RepUpdateTime]' + case when @SyncDelete = 0 then '
		,[isDeleted]' else '' end + '' + CHAR(13)
	+ ' 	  ) VALUES (' + CHAR(13)
	+ STUFF ((
		select CHAR(9) + CHAR(9) + ',[tvp].[' + name +']' + CHAR(13) from
		(
			select * FROM @PK_cols
			union all select * FROM @NonPK_cols
		) cc
		where cc.name NOT IN('RepUpdateTime', 'IsDeleted')
		order by ord
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 3, CHAR(9) + CHAR(9))
	+ '		,[tvp].[RepUpdateTime]' + case when @SyncDelete = 0 then '
		,[tvp].[isDeleted]' else '' end + '' + CHAR(13)
	+ '		);'
	+ case when @HasIdentity = 1 then CHAR(13) + CHAR(13) + '	SET IDENTITY_INSERT [dbo].[' + @tbl_name + '] OFF;' + CHAR(13) else '' end + '
END
GO
GRANT EXECUTE ON [dbo].[Repl_Put' + @tbl_name + '] TO [repl_ap] AS [dbo]
GO

'
SELECT @sql_Target = ' --============================================================================================================================
-- 2. Deploy SP put on Target
USE ' + @TargetDBName + '
GO' + @SQL
select CONVERT(XML, (SELECT N' --' + char(13) + CONVERT(NVARCHAR(MAX), @sql_Target) + char(13) + N'--' AS [processing-instruction(query)] FOR XML PATH('')))  [2. Deploy SP put on Target]
PRINT @sql_Target

-------------------------------------------------
if @HaveDist = 1
BEGIN
	SELECT @SQL2 = ' --============================================================================================================================
-- 3. Insert repl setting on Distributor
USE ' + @DistDBName + '
GO

insert into RepInfo (
	[group]
	,[name]
	,active
	,version_key
	,version_type
	,unique_key
	,get_sp
	,put_sp
	,interval
	,back_fix
	,delayed_fix
	)
select ' + convert(varchar(2), @RepGroup_dist) + '
	,''' + @tbl_name + '''
	,1
	,''RepUpdateTime''
	,0
	,'''
+ STUFF ((
		SELECT '|' + name FROM @PK_cols
		ORDER by ord
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
+ '''
	,''Repl_Get' + @tbl_name + '''
	,''Repl_Put' + @tbl_name + '_Dist''
	,1000
	,10
	,60000'

	SELECT @sql_Dist = @SQL2
	select CONVERT(XML, (SELECT N' --' + char(13) + CONVERT(NVARCHAR(MAX), @sql_Dist) + char(13) + N'--' AS [processing-instruction(query)] FOR XML PATH('')))  [3. Insert repl setting on Distributor]
	PRINT CHAR(13) + @sql_Dist
END

------------------------------------------
SELECT @SQL = ' --============================================================================================================================
-- 3. Insert repl setting on Target
USE ' + @TargetDBName + '
GO

insert into RepInfo (
	[group]
	,[name]
	,active
	,version_key
	,version_type
	,unique_key
	,get_sp
	,put_sp
	,interval
	,back_fix
	,delayed_fix
	)
select ' + convert(varchar(2), @RepGroup) + '
	,''' + @tbl_name + '''
	,1
	,''RepUpdateTime''
	,0
	,'''
+ STUFF ((
		SELECT '|' + name FROM @PK_cols
		ORDER by ord
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
+ '''
	,''Repl_Get' + @tbl_name + case when @HaveDist = 1 then '_dist''' else '''' end + '
	,''Repl_Put' + @tbl_name + '''
	,1000
	,10
	,60000'

SELECT @sql_Target = @SQL
select CONVERT(XML, (SELECT N' --' + char(13) + CONVERT(NVARCHAR(MAX), @sql_Target) + char(13) + N'--' AS [processing-instruction(query)] FOR XML PATH('')))  [3. Insert repl setting on Target]
PRINT CHAR(13) + @sql_Target


