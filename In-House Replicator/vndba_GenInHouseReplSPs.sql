ALTER PROCEDURE vndba_GenInHouseReplSPs
	@SrcDBName VARCHAR(50), --Source or publisher db name
	@TargetDBName VARCHAR(50), --Target or subscriber db name
	@tbl_name VARCHAR(50),  --Table name Dep_CustBetSettingGame_Member, Dep_ChargeInfoSetting
	@SyncDelete BIT = 1, -- sync delete action to Target
	@LogDelete BIT = 0, --log deleted rows to _Del tables on Target - used for DR Sync to main DB

	@GetSPName VARCHAR(50) = NULL,
	@PutSPName VARCHAR(50) = NULL,

	@Source_SQL NVARCHAR(MAX) = NULL OUTPUT,
	@Target_SQL NVARCHAR(MAX) = NULL OUTPUT
AS
/*
	Task: Generate scripts/steps to prepare objects for In-house replication
	Created: Daniel@20240529
	DB: Run this sp at Source DB server that contains the table to be added to in-house replication, then copy script parts run relevant server Source/Distributor/Target
	
	Sample run:
	exec vndba_GenInHouseReplSPs
		 @SrcDBName = 'CustDB', --Source or publisher db name
		 @TargetDBName = 'bodb02',--Target or subscriber db name
		 @DistDBName = 'ReplCustDB',--Distributor db name
		 @tbl_name = 'BetSetting_Member', --Table name Dep_CustBetSettingGame_Member, Dep_ChargeInfoSetting
		 @SyncDelete = 1, --sync delete action to Target
		 @LogDelete = 0, --log deleted rows to _Del tables on Target - used for DR Sync to main DB


*/
BEGIN

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


	SELECT @SQL = ' --============================================================================================================================
--  Deploy SP get on Source server
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
	select CONVERT(XML, (SELECT N' --' + char(13) + CONVERT(NVARCHAR(MAX), @sql_Source) + char(13) + N'--' AS [processing-instruction(query)] FOR XML PATH('')))  [Deploy SP get on Source]
	PRINT CHAR(13) + @sql_Source




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

	if (@LogDelete = 0)
	BEGIN
		select @SQL = @SQL + '

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
		+ '' + case when @SyncDelete = 0 then '[isDeleted] = [tvp].[isDeleted]						,' else '' end + '[RepUpdateTime]	= CASE WHEN [tvp].[RepUpdateTime] > ISNULL([t].RepUpdateTime,'''') THEN [tvp].[RepUpdateTime] ELSE [t].[RepUpdateTime] END
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
		+ '' + case when @SyncDelete = 0 then '[isDeleted] = [tvp].[isDeleted]						,' else '' end + '[RepUpdateTime]	= CASE WHEN [tvp].[RepUpdateTime] > ISNULL([t].RepUpdateTime,'''') THEN [tvp].[RepUpdateTime] ELSE [t].[RepUpdateTime] END
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
	END
	ELSE
	BEGIN

		SELECT @sql =  @SQL + '

ALTER PROCEDURE [dbo].[DR_Repl_Put' + @tbl_name + '_Dist]
	@tvp_param TVP_Repl' + @tbl_name + ' READONLY
AS
/*
	Created: by Patrick	
	Task: rep In-House
	DB: KL DBCUST-CustDB
	
	Revisions:
		- 20240730@Patrick: Scale out DBCUST [RedmineID: #199915]

	Example:
				
*/
BEGIN
	SET NOCOUNT ON;'
		+ case when @HasIdentity = 1 then CHAR(13) + CHAR(13) + '	SET IDENTITY_INSERT [dbo].[' + @tbl_name + '] ON;' + CHAR(13) else '' end + '
INSERT INTO [dbo].[' + @tbl_name + '_Del_InHouse](
'+ STUFF ((
				select CHAR(9) + CHAR(9) + ',[' + name +']' + CHAR(13) from @PK_cols
				where name NOT IN('RepUpdateTime', 'IsDeleted')
				order by ord
				FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 3, CHAR(9) + CHAR(9))
			+ '		,[RepUpdateTime]
	)
	SELECT
'	+ STUFF ((
				select CHAR(9) + CHAR(9) + ',[' + name +']' + CHAR(13) from @PK_cols
				where name NOT IN('RepUpdateTime', 'IsDeleted')
				order by ord
				FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 3, CHAR(9) + CHAR(9))
		+ '		,[RepUpdateTime]
	FROM (
		MERGE [dbo].[' + @tbl_name + '] [t]
		USING @tvp_param [tvp] ON' + 
		+ STUFF ((
					SELECT REPLICATE(CHAR(9),7)+ 'AND [t].[' + name + '] = [tvp].[' + name + ']' + CHAR(13) FROM @PK_cols
					ORDER by ord
					FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 11, CHAR(9)) + '		WHEN MATCHED AND [tvp].isDeleted = 0 THEN
		UPDATE SET' +
		+ iif (exists(select 1 from @NonPK_cols where name NOT IN('RepUpdateTime', 'IsDeleted')),  
			STUFF ((
					SELECT ',[' + name + '] = [tvp].[' + name + ']' + CHAR(13) + '                   ' FROM @NonPK_cols
					where name NOT IN('RepUpdateTime', 'IsDeleted')
					ORDER by ord
					FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, CHAR(9)) + ','
			, ' ') + '[RepUpdateTime]	= CASE WHEN [tvp].[RepUpdateTime] > ISNULL([t].RepUpdateTime,'''') THEN [tvp].[RepUpdateTime] ELSE [t].[RepUpdateTime] END
		WHEN MATCHED AND [tvp].isDeleted = 1 THEN 
			DELETE
		WHEN NOT MATCHED AND [tvp].isDeleted = 0 THEN
			INSERT(
'	+ STUFF ((
			select CHAR(9)+CHAR(9)+CHAR(9)+ CHAR(9)+ ',[' + name +']' + CHAR(13) from
			(
				select * FROM @PK_cols
				union all select * FROM @NonPK_cols
			) cc
			where cc.name NOT IN('RepUpdateTime', 'IsDeleted')
			order by ord
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 3, 3, CHAR(9)+CHAR(9))
		+ '				,[RepUpdateTime]
			)
			VALUES (
'	+ STUFF ((
			select CHAR(9)+CHAR(9)+CHAR(9)+ CHAR(9)+ ',tvp.[' + name +']' + CHAR(13) from
			(
				select * FROM @PK_cols
				union all select * FROM @NonPK_cols
			) cc
			where cc.name NOT IN('RepUpdateTime', 'IsDeleted')
			order by ord
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 3, 3, CHAR(9)+CHAR(9))
		+ '				,tvp.[RepUpdateTime]
				)

		OUTPUT $action
		' + STUFF ((
			select REPLICATE(CHAR(9),3) + ',deleted.[' + name +']' + CHAR(13) from @PK_cols
			order by ord
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 3, CHAR(9) + '') + '			,tvp.[RepUpdateTime]
	) AS __deleting(
		[Action]
	' + STUFF ((
			select REPLICATE(CHAR(9),2) + ',[' + name +']' + CHAR(13) from @PK_cols
			order by ord
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, CHAR(9) + '') + '		,[RepUpdateTime]
		)
	WHERE [Action] = ''DELETE''; --only capture deleted $action'
	+ case when @HasIdentity = 1 then CHAR(13) + CHAR(13) + '	SET IDENTITY_INSERT [dbo].[' + @tbl_name + '] OFF;' + CHAR(13) else '' end + '
END
GO
GRANT EXECUTE ON [dbo].[DR_Repl_Put' + @tbl_name + '] TO [repl_ap] AS [dbo]
GO

	'
	END

	SELECT @sql_Target = ' --============================================================================================================================
--  Deploy SP put on Target
USE ' + @TargetDBName + '
GO' + @SQL
	select CONVERT(XML, (SELECT N' --' + char(13) + CONVERT(NVARCHAR(MAX), @sql_Target) + char(13) + N'--' AS [processing-instruction(query)] FOR XML PATH('')))  [Deploy SP put on Target]
	PRINT @sql_Target
END
