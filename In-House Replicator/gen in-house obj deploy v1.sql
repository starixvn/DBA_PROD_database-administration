/*
	Task: generate scripts/steps to prepare objects for In-house replication
	Run on Main DB server/DB that contains the table to be added to in-house replication, then copy script parts run relevant servers

*/

DECLARE @SrcDBName VARCHAR(50) = 'CustDB'
DECLARE @TargetDBName VARCHAR(50) = 'bodb02'
DECLARE @RepGroup tinyint = 1
DECLARE @tbl_name VARCHAR(50) = 'BetSetting_Member' --Dep_CustBetSetting_Agent, Dep_ChargeInfoSetting

DECLARE @sql VARCHAR(MAX) = ''
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

----debug 1
--select * from @PK_cols

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


SELECT @SQL = ' --============================================================================================================================
-- 1. Prepare a table for Adding to in-house Replication - Run on Main server & relevant replicated servers
USE ' + @SrcDBName + '
GO

'
PRINT @SQL

SELECT @SQL = 'ALTER TABLE [' + @tbl_name + ']	
	ADD [RepUpdateTime] [datetime2](7) NULL,
	 [isDeleted] [bit] NULL
GO
ALTER TABLE [dbo].' + @tbl_name + ' ADD  CONSTRAINT [DF_' + @tbl_name + '_isDeleted]  DEFAULT ((0)) FOR [isDeleted]
GO
ALTER TABLE [dbo].' + @tbl_name + ' ADD  CONSTRAINT [DF_' + @tbl_name + '_RepUpdateTime]  DEFAULT (sysdatetime()) FOR [RepUpdateTime]
GO   

--Init value for new column [RepUpdateTime], [isDeleted] to default
declare @currDT datetime2 = getdate()
while(1=1)
begin
	update top(5000) ' + @tbl_name + ' with (rowlock)
		set RepUpdateTime = @currDT, isDeleted = 0
	where RepUpdateTime is null and isDeleted is null

	if (@@ROWCOUNT = 0) break
end


--alter table not allow null for [RepUpdateTime], [isDeleted]
ALTER TABLE ' + @tbl_name + ' ALTER COLUMN RepUpdateTime [datetime2](7) NOT NULL
GO
ALTER TABLE ' + @tbl_name + ' ALTER COLUMN [isDeleted] [bit] NOT NULL

--create index for column RepUpdateTime - may skip on replicated server when it''s not used for re-publishing (2nd repl)
CREATE NONCLUSTERED INDEX [IX_' + @tbl_name + '_RepUpdateTime] ON [dbo].[' + @tbl_name + ']
(
	[RepUpdateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [' + @filegroup + ']
GO'
+ case when @HasIdentity = 1 then 
	CHAR(13) + CHAR(13) + '--grant alter table for identity insert - Run on Targets only
USE ' + @TargetDBName + '
GO
' + 'GRANT ALTER ON [dbo].[' + @tbl_name + '] TO [repl_ap] AS [dbo]
GO'
  else '' end + '

'
PRINT @SQL


SELECT @SQL = ' --============================================================================================================================
-- 2. Deploy repl objects on Source server
USE ' + @SrcDBName + '
GO

'
PRINT @SQL

SELECT @SQL = 'CREATE PROCEDURE [dbo].[Repl_Get' + @tbl_name + ']
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
    DECLARE @__time_upperbound DATETIME2 = DATEADD(MILLISECOND, -@back_fix, SYSDATETIME());

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
		select REPLICATE(CHAR(9),4) + ',[' + name +']' + CHAR(13) from
		(
			select * FROM @PK_cols
			union all select * FROM @NonPK_cols
		) cc
		where cc.name not IN('RepUpdateTime', 'IsDeleted')
		order by ord
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 5, CHAR(9) + '')
	+ '				,[RepUpdateTime]				,[isDeleted]                ,SYSDATETIME() AS [_FetchedTime]
        FROM [dbo].[' + @tbl_name + ']  WITH (NOLOCK, INDEX = IX_' + @tbl_name + '_RepUpdateTime)
        WHERE [RepUpdateTime] > @__time_start AND [RepUpdateTime] <= @__time_end
        ORDER BY [RepUpdateTime];
    END;
END
GO
GRANT EXECUTE ON [dbo].[Repl_Get' + @tbl_name + '] TO [repl_ap] AS [dbo]
GO


'
PRINT @SQL

SELECT @SQL = ' --============================================================================================================================
-- 3. Deploy repl objects on target servers
USE ' + @TargetDBName + '
GO

'
print @SQL

SELECT @SQL = 'CREATE TYPE  [dbo].[TVP_Repl' + @tbl_name + '] AS TABLE' + CHAR(13) + '(' + CHAR(13) + STUFF((
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
    WHERE c.[object_id] = OBJECT_ID(@tbl_name) AND c.name NOT IN('RepUpdateTime', 'IsDeleted')
    ORDER BY c.column_id
    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, CHAR(9) + ' ')
	+ '	,[RepUpdateTime] [datetime2](7) NOT NULL
	,[isDeleted] [bit] NOT NULL
	,[_FetchedTime] [datetime2](7) NULL
)
GO
GRANT EXECUTE ON TYPE::[dbo].[TVP_Repl' + @tbl_name + '] TO [repl_ap] AS [dbo]
GO'
print @SQL

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
GRANT EXECUTE ON [dbo].[Repl_Put' + @tbl_name + '] TO [repl_ap] AS [dbo]
GO


'
print @SQL

SELECT @SQL = ' --============================================================================================================================
-- 4. Insert repl setting - run on all replicated servers
USE ' + @TargetDBName + '
GO

'
print @SQL


SELECT @SQL = '
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
	,''Repl_Get' + @tbl_name + '''
	,''Repl_Put' + @tbl_name + '''
	,1000
	,10
	,60000'
print @SQL


