/*<info serverAlias="DBCONSISTENCY-bodb_Consistency"></info>*/
ALTER PROCEDURE [dbo].[DBA_Consistency_CheckSum_ArchiveTable]		
	@IsViewOnly BIT = 0,
	@LimitShowError INT = 10, 
	@SourceServer VARCHAR(100) = '',
	@TargetServer VARCHAR(100) = '',
	@Database	VARCHAR(100) = '',
	@TableNames VARCHAR(MAX) = ''

AS
--================== Compare Data Table ==================--
/*
	Created: 20240508@Evan
	DB: DBCONSISTENCY-bodb_Consistency

	Revisions:
		- 20240503@Evan: Initialize Jobs Compare data KBT vs KL [Redmine: #204816]
		- 20241126@Evan: add ExclusionColumn, delete old data [Redmine: #204816]

	Param's Explanation:   
		@IsViewOnly: For checking, non send notify
		@LimitShowError: 0: Show all
			
*/

BEGIN
	SET NOCOUNT ON
	
	
	DECLARE @Msg VARCHAR (500), @RowCount BIGINT
	SET @Msg =   'Starting...'
	RAISERROR (@Msg , 0, 1) WITH NOWAIT

	DROP TABLE IF EXISTS #tmpCheckSumResult
	DROP TABLE IF EXISTS #tmpLstKey_Diff
	DROP TABLE IF EXISTS #tmpTrackingTable
	DROP TABLE IF EXISTS #CheckSumDataSource
	DROP TABLE IF EXISTS #CheckSumDataTarget

	CREATE TABLE #CheckSumDataSource (ID INT IDENTITY (1, 1),CheckSumData BIGINT)
	CREATE TABLE #CheckSumDataTarget (ID INT IDENTITY (1, 1),CheckSumData BIGINT)
	CREATE TABLE #tmpTrackingTable (
			  ID INT
			, TableName VARCHAR(100)
			, TableId INT
			, FilterColumn VARCHAR(100)
			, FilterValue VARCHAR(100)
			, StartTime DATETIME
			, FinishTime DATETIME
			, CountDiff INT
			, ErrorMsg VARCHAR(MAX)
		)	
	CREATE TABLE #tmpLstKey_Diff (ID INT IDENTITY (1, 1))
	CREATE TABLE #tmpCheckSumResult (ID INT IDENTITY (1, 1), TableName VARCHAR(100), CountDiff INT, ExtraInfo VARCHAR(MAX), ExtraInfo1 VARCHAR(MAX), 
	KeyColumns VARCHAR(1000) , OtherColumns VARCHAR(8000) , FilterColumn VARCHAR(100) , FilterValue VARCHAR(100))

	DECLARE @MBBU TABLE (BalanceUpDay SMALLDATETIME, MoveBetsDay SMALLDATETIME)
	INSERT INTO @MBBU (BalanceUpDay, MoveBetsDay)
	EXEC bodb02.dbo.Age_SelBalanceUpDay
	DECLARE @MoveBetDate SMALLDATETIME, @BalanceUpDate SMALLDATETIME
	SELECT  @MoveBetDate = MoveBetsDay, @BalanceUpDate = BalanceUpDay FROM @MBBU

	DECLARE @tbTableColumn TABLE (
			  TableName VARCHAR(100)
		  	, TableId INT
			, IndexColumns VARCHAR(1000)
			, OtherColumns VARCHAR(8000)
			, IsCheck BIT DEFAULT (0)
		)
	DECLARE @tbKeyColumn TABLE (
		  ColumnName VARCHAR(100)
		, TypeCName VARCHAR(100)
		, TypeCLength VARCHAR(100)
		, TableName VARCHAR(100)
	)

	DECLARE @DBA_ArchiveTable TABLE (
		  ID INT IDENTITY (1, 1)
		, SourceServer VARCHAR(100)
		, TargetServer VARCHAR(100)
		, SourceDB VARCHAR(100)
		, TargetDB VARCHAR(100)
		, TableNames VARCHAR(MAX)
		, IsCheck BIT DEFAULT (0)
		, ErrorMsg VARCHAR(8000)
	);

	INSERT INTO @DBA_ArchiveTable (SourceServer, TargetServer, SourceDB, TargetDB, TableNames)
	SELECT SourceServer, TargetServer, SourceDB, TargetDB, STRING_AGG(a.TableName, ',') WITHIN GROUP (ORDER BY a.TableName)  AS TableNames
	FROM dbo.DBA_ArchiveTable a WITH (NOLOCK) INNER JOIN dbo.DBA_CheckSumTable b WITH(NOLOCK) ON a.TableName = b.TableName
	WHERE 
		(SourceServer = @SourceServer OR @SourceServer = '' )AND
		(TargetServer = @TargetServer OR @TargetServer = '' ) AND
		(SourceDB = @Database OR @Database = '' ) AND
		(TargetDB = @Database OR @Database = '' ) AND
		(a.TableName IN (SELECT VALUE FROM STRING_SPLIT(@TableNames,',')) OR @TableNames = '' )
	GROUP BY SourceServer, TargetServer, SourceDB, TargetDB
	
	IF  @@ROWCOUNT = 0	AND @TableNames <> '' AND @SourceServer <> '' AND @TargetServer <> '' AND @Database <> ''
	BEGIN
        INSERT INTO @DBA_ArchiveTable (SourceServer, TargetServer, SourceDB, TargetDB, TableNames)
		SELECT @SourceServer , @TargetServer , @Database , @Database , @TableNames
    END
	
	DECLARE @ErrorMessage VARCHAR(MAX), @CurrentDate DATE
	SELECT  @CurrentDate = CONVERT(DATE, CURRENT_TIMESTAMP, 112)
	DECLARE @tbErrMsgTab AS TABLE (NoID SMALLINT IDENTITY (1,1), ErrMsg VARCHAR(MAX))

	DECLARE @sqlCMD NVARCHAR(MAX)
		  , @_TableNames VARCHAR(MAX)
		  , @_SourceServer VARCHAR(100) = ''
		  , @_TargetServer VARCHAR(100) = ''
		  , @_TableName VARCHAR(100)
		  , @_TableId INT
		  , @_SourceDB VARCHAR(100)
		  , @_TargetDB VARCHAR(100)
		  , @ID INT
		  , @FilterColumn VARCHAR(100)
		  , @FilterValue VARCHAR(100)
		  , @KeyColumns VARCHAR(MAX)
		  , @KeyColumnNoFilter VARCHAR(MAX)
		  , @OtherColumns VARCHAR(MAX)

	WHILE EXISTS (SELECT 1 FROM @DBA_ArchiveTable WHERE IsCheck = 0)
	BEGIN
	BEGIN TRY
		SELECT TOP 1 @ID = ID
					, @_SourceServer = SourceServer
					, @_TargetServer = TargetServer
					, @_TableNames = TableNames
					, @_SourceDB = SourceDB
					, @_TargetDB = TargetDB
		FROM @DBA_ArchiveTable
		WHERE IsCheck = 0

		SET @Msg =  'Compare Data Table:  ' +@_TableNames + ' from '+@_SourceServer+ '.' +@_SourceDB+ ' to '+@_TargetServer+ '.' +@_TargetDB
		RAISERROR (@Msg , 0, 1) WITH NOWAIT

		SET @sqlCMD = '
		SELECT TableName, IndexColumns,OtherColumns
		FROM OPENQUERY('+@_SourceServer+','' 
			;WITH cte_tableInfo AS
			(
			SELECT o.name TableName, o.object_id,i.index_id,i.type
					, (SELECT STRING_AGG(value,'''','''') FROM STRING_SPLIT(STRING_AGG(IIF(ic.column_id is not null,col.name,''''''''), '''','''') WITHIN GROUP (ORDER BY ic.key_ordinal),'''','''') WHERE value <> '''''''') AS IndexColumns
			FROM '+@_SourceDB+'.sys.indexes i
				INNER JOIN '+@_SourceDB+'.sys.objects o ON i.object_id = o.object_id
				INNER JOIN '+@_SourceDB+'.sys.columns col ON o.object_id = col.object_id
				LEFT JOIN '+@_SourceDB+'.sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id AND ic.column_id = col.column_id
			WHERE o.name IN (
					SELECT value
					FROM STRING_SPLIT('''''+@_TableNames+''''', '''','''')
				) AND ISNULL(ic.is_included_column,0) = 0
			GROUP BY o.name,o.object_id,i.index_id,i.type
			), cte_result AS (
			SELECT	*,
					ROW_NUMBER() OVER (PARTITION BY object_id ORDER BY CASE WHEN IndexColumns LIKE ''''%date%'''' THEN 1 WHEN IndexColumns IS NULL THEN 99 ELSE 2 END) AS ROWn
			FROM cte_tableInfo
			
			)
			SELECT  a.TableName, a.IndexColumns, b.OtherColumns
			FROM cte_result a 
			CROSS APPLY 
			(
				SELECT STRING_AGG(ISNULL(b.COLUMN_NAME, ''''''''), '''','''')  AS OtherColumns 
				FROM  '+@_SourceDB+'.INFORMATION_SCHEMA.COLUMNS b
				WHERE a.TableName = b.TABLE_NAME AND b.COLUMN_NAME NOT IN (SELECT value FROM STRING_SPLIT(a.IndexColumns,'''','''')) --AND b.COLUMN_NAME NOT IN (''''RecordID'''')
			) b 
			WHERE ROWn = 1
		'' ) AS a  
		ORDER BY TableName'
		
		INSERT INTO @tbTableColumn (TableName, IndexColumns, OtherColumns)
		EXEC sp_executesql @sqlCMD

		UPDATE a
		SET a.TableId = b.ID
		FROM @tbTableColumn a
			INNER JOIN dbo.DBA_ArchiveTable b WITH (NOLOCK) ON a.TableName = b.TableName
		WHERE b.SourceServer = @_SourceServer
			AND b.TargetServer = @_TargetServer
			AND SourceDB = @_SourceDB
			AND TargetDB = @_TargetDB
		
		WHILE EXISTS (SELECT TableName FROM @tbTableColumn WHERE IsCheck = 0)
		BEGIN
		BEGIN TRY
			SELECT TOP 1 @_TableName = a.TableName, @_TableId = a.TableId
						, @KeyColumns = ISNULL(b.KeyColumn,a.IndexColumns)
						, @OtherColumns = CASE WHEN b.KeyColumn IS NOT NULL THEN c.OtherColumns ELSE a.OtherColumns END
						, @FilterColumn = b.FilterColumn
						, @FilterValue =
										CASE
											WHEN CHARINDEX('BU_DATE',b.FilterValue) <> 0 THEN CONVERT(VARCHAR(20), DATEADD(DAY, CAST(REPLACE(b.FilterValue, 'BU_DATE', '') AS INT), @BalanceUpDate), 112)
											WHEN CHARINDEX('MB_DATE',b.FilterValue) <> 0  THEN CONVERT(VARCHAR(20), DATEADD(DAY, CAST(REPLACE(b.FilterValue, 'MB_DATE', '') AS INT), @MovebetDate), 112)
											WHEN CHARINDEX('TODAY',b.FilterValue) <> 0 THEN CONVERT(VARCHAR(20), DATEADD(DAY, CAST(REPLACE(b.FilterValue, 'TODAY', '') AS INT), @CurrentDate), 112)
											ELSE FilterValue
										END
			FROM @tbTableColumn a LEFT JOIN dbo.DBA_CheckSumTable b WITH(NOLOCK) ON a.TableName = b.TableName
			OUTER APPLY (
							SELECT STRING_AGG(value,',') OtherColumns
							FROM STRING_SPLIT(CONCAT_WS(',', a.IndexColumns, a.OtherColumns), ',') f
							WHERE f.value NOT IN (
									SELECT value
									FROM STRING_SPLIT(CONCAT_WS(',',b.KeyColumn,b.ExclusionColumn), ',')
								)
						) c
			WHERE IsCheck = 0 
			ORDER BY a.TableName

			INSERT INTO #tmpTrackingTable (ID,TableName,TableId,FilterColumn,FilterValue,StartTime)
			SELECT @ID, @_TableName,@_TableId, @FilterColumn, @FilterValue, CURRENT_TIMESTAMP
			
			SET @sqlCMD = '
				SELECT *
				FROM OPENQUERY('+@_SourceServer+',''
					SELECT sc.name as ColumnName, st.name as TypeCName,sc.Length as TypeCLength, so.name as TableName
					FROM '+@_SourceDB+'.dbo.sysobjects so
						INNER JOIN '+@_SourceDB+'.dbo.syscolumns sc ON sc.id = so.id
						INNER JOIN '+@_SourceDB+'.dbo.systypes st ON st.xusertype = sc.xusertype
					WHERE so.name = '''''+@_TableName+''''' AND sc.name IN (SELECT value FROM STRING_SPLIT('''''+@KeyColumns+''''','''',''''))
					ORDER BY sc.ColID '')
				AS t'
			
			INSERT INTO @tbKeyColumn (ColumnName, TypeCName, TypeCLength, TableName)
			EXEC sp_executesql @sqlCMD
			
			SELECT @sqlCMD = 'ALTER TABLE #tmpLstKey_Diff ' + CHAR(10) + 'ADD '
			SELECT @sqlCMD = @sqlCMD + ' [' + ColumnName + '] ' +
				CASE WHEN TypeCName in ('smalldatetime','datetime') THEN 'date' ELSE  TypeCName END
						 +
							CASE
								WHEN TypeCName IN ('nvarchar','varchar', 'varchar', 'char', 'nchar','varbinary','binary') THEN '(' + CAST(IIF(TypeCLength = -1,'MAX',TypeCLength) AS VARCHAR) + ') '
								ELSE ' '
							END  + ',' 
			FROM @tbKeyColumn 

			SELECT @sqlCMD = SUBSTRING(@sqlCMD, 1, LEN(@sqlCMD) - 2)
			
			EXEC sp_executesql @sqlCMD
			SET @sqlCMD =  REPLACE(@sqlCMD,'#tmpLstKey_Diff','#CheckSumDataSource')
			EXEC sp_executesql @sqlCMD

			SET @sqlCMD =  REPLACE(@sqlCMD,'#CheckSumDataSource','#CheckSumDataTarget')
			EXEC sp_executesql @sqlCMD

			SET  @sqlCMD = 
			N'  WITH cte_SourceData AS (
				SELECT t.* 
				FROM OPENQUERY('+@_SourceServer+',''
				SELECT '+@KeyColumns+'
						, CHECKSUM_AGG(CHECKSUM(CONCAT_WS(''''|'''', '+ISNULL(@OtherColumns,@KeyColumns)+','''''''',''''''''))) AS CheckSumData
				FROM '+@_SourceDB+'.dbo.'+@_TableName+' a WITH(NOLOCK)'
				+	CASE WHEN ISNULL(@FilterColumn,'') <> '' THEN ' WHERE a.'+@FilterColumn+' = '''''+@FilterValue+'''''' ELSE '' END
				+	' GROUP BY '+@KeyColumns+
				''') AS t 
				)
				INSERT INTO #CheckSumDataSource (CheckSumData,'+@KeyColumns+')
				SELECT CheckSumData AS CheckSumData,'+@KeyColumns+'
				FROM cte_SourceData a 
			'
			EXEC sp_executesql @sqlCMD
			
			SET  @sqlCMD = 
			N'  WITH cte_SourceData AS (
				SELECT t.* 
				FROM OPENQUERY('+@_TargetServer+',''
				SELECT '+@KeyColumns+'
						, CHECKSUM_AGG(CHECKSUM(CONCAT_WS(''''|'''', '+ISNULL(@OtherColumns,@KeyColumns)+','''''''',''''''''))) AS CheckSumData
				FROM '+@_TargetDB+'.dbo.'+@_TableName+' a WITH(NOLOCK)'
				+	CASE WHEN ISNULL(@FilterColumn,'') <> '' THEN ' WHERE a.'+@FilterColumn+' = '''''+@FilterValue+'''''' ELSE '' END
				+	' GROUP BY '+@KeyColumns+
				''') AS t 
				)
				INSERT INTO #CheckSumDataTarget (CheckSumData,'+@KeyColumns+')
				SELECT CheckSumData AS CheckSumData,'+@KeyColumns+'
				FROM cte_SourceData a 
			'
			EXEC sp_executesql @sqlCMD

			SET @sqlCMD = 'INSERT INTO #tmpLstKey_Diff ('+@KeyColumns+' ) 
							SELECT DISTINCT '+@KeyColumns+' 
							FROM (SELECT '+@KeyColumns+', CheckSumData as CheckSumData FROM #CheckSumDataSource
								UNION ALL
								SELECT '+@KeyColumns+', CheckSumData FROM #CheckSumDataTarget) a
							GROUP BY '+@KeyColumns+', CheckSumData HAVING COUNT(*)=1'
			
			EXEC sp_executesql @sqlCMD
			 
			SET @RowCount = @@rowcount
			SET @Msg =  @_TableName + ' ==> ' + CAST(@rowCount AS VARCHAR(50)) + ' rows affected'
			RAISERROR (@Msg , 0, 1) WITH NOWAIT
			SET @KeyColumnNoFilter = NULL
			IF CHARINDEX(@FilterColumn,@KeyColumns) <> 0
			BEGIN
				SELECT @KeyColumnNoFilter = STRING_AGG(value,',') from string_split(@KeyColumns,',') where value <> @FilterColumn
			END
			
			IF EXISTS (SELECT TOP 1 1 FROM #tmpLstKey_Diff)
			BEGIN
				SET @sqlCMD = 'SELECT '''+@_TableName+''' AS tablename, (SELECT TOP '+CAST(@LimitShowError AS VARCHAR(10))+' '+ISNULL(@KeyColumnNoFilter,@KeyColumns)+' FROM #tmpLstKey_Diff FOR JSON AUTO,WITHOUT_ARRAY_WRAPPER ) AS ExtraInfo,
				 (SELECT TOP 1000 '+ISNULL(@KeyColumnNoFilter,@KeyColumns)+' FROM #tmpLstKey_Diff FOR JSON AUTO,WITHOUT_ARRAY_WRAPPER ) AS ExtraInfo1'

				INSERT INTO #tmpCheckSumResult (TableName,ExtraInfo,ExtraInfo1)
				EXEC sp_executesql @sqlCMD
			END

			UPDATE #tmpCheckSumResult 
			SET KeyColumns = @KeyColumns, OtherColumns = @OtherColumns, 
				FilterColumn = @FilterColumn, FilterValue = @FilterValue,CountDiff = @RowCount
			WHERE TableName = @_TableName

			TRUNCATE TABLE #tmpLstKey_Diff
			EXEC ('ALTER TABLE #tmpLstKey_Diff DROP COLUMN '+@KeyColumns)

			TRUNCATE TABLE #CheckSumDataSource
			EXEC ('ALTER TABLE #CheckSumDataSource DROP COLUMN '+@KeyColumns)
			
			TRUNCATE TABLE #CheckSumDataTarget
			EXEC ('ALTER TABLE #CheckSumDataTarget DROP COLUMN '+@KeyColumns)

			DELETE FROM @tbKeyColumn

			UPDATE @tbTableColumn SET IsCheck = 1 WHERE TableName = @_TableName
			
			UPDATE a SET FinishTime=CURRENT_TIMESTAMP, CountDiff = @RowCount, ErrorMsg = CASE WHEN a.FilterColumn IS NOT NULL THEN a.FilterColumn + '= ''' + a.FilterValue+'''' + CHAR(13) ELSE '' END + b.ExtraInfo1
			FROM #tmpTrackingTable a LEFT JOIN #tmpCheckSumResult b ON a.TableName = b.TableName
			WHERE a.TableName = @_TableName AND a.ID = @ID

			END TRY
			BEGIN CATCH
				SELECT @ErrorMessage = ERROR_MESSAGE() + '- Step check data at @tbTableColumn where TableName = ' + @_TableName
				INSERT INTO @TbErrMsgTab (ErrMsg) SELECT @ErrorMessage

				-- end loop
				TRUNCATE TABLE #tmpLstKey_Diff
				EXEC ('ALTER TABLE #tmpLstKey_Diff DROP COLUMN '+@KeyColumns)
				DELETE FROM @tbKeyColumn
				UPDATE @tbTableColumn SET IsCheck = 1 WHERE TableName = @_TableName
				UPDATE #tmpTrackingTable SET FinishTime=CURRENT_TIMESTAMP , ErrorMsg = @ErrorMessage WHERE TableName = @_TableName

			END CATCH
		END

		SET @ErrorMessage = '';
		IF EXISTS (SELECT TOP 1 1 FROM #tmpCheckSumResult) 
		BEGIN
		
			SELECT @ErrorMessage 
						= 'Compare CheckSum **'+@_SourceServer+'('+@_SourceDB+')** vs **'+@_TargetServer+'('+@_TargetDB+')** run on ['+ CONVERT(VARCHAR(20),@CurrentDate) + '].' +CHAR(13)
			SELECT @ErrorMessage = @ErrorMessage +
								( SELECT  CAST(a.ID AS VARCHAR(10))  + '. Table Name: **' + a.TableName + '**'+CHAR(13)
											+ '- Different rows: '+ CAST(FORMAT(a.CountDiff, '#,#') AS VARCHAR(30)) + CHAR(13)
											+ '- Key Column: '+ a.KeyColumns + CHAR(13)
											+ CASE WHEN a.FilterColumn IS NULL THEN '' ELSE
											+ '- Filter Column: '+ a.FilterColumn + ' = '+a.FilterValue +CHAR(13) END
											+ '- Key Difference: ' + REPLACE(a.ExtraInfo,'"','''') 
											+ CASE WHEN a.CountDiff > @LimitShowError THEN '...' ELSE '' END + CHAR(13)
										FROM #tmpCheckSumResult a 
										FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)')
			
			IF @IsViewOnly = 0	-- Send Notification		
			BEGIN
				EXEC DBNOTI.NotificationDB.dbo.DBA_Skype_NewMessage @ServerName = N'PONTUS'
																   , @JobId = NULL
																   , @JobName = N'Custom MessageBot'
																   , @Message = @ErrorMessage
																   , @CaseId = 1;
				
				

            	INSERT INTO DBA_CheckDataLogs (LogDate, TableName, TableId, CheckType, RowDiff, LogDesc, StartTime, EndTime)
				SELECT @CurrentDate , TableName , TableId , 'CheckSum' , CountDiff , ErrorMsg , StartTime , FinishTime
				FROM #tmpTrackingTable WHERE ID = @ID AND CountDiff <> 0
            END

		END

		TRUNCATE TABLE #tmpCheckSumResult
		----------------------------------------------------------

		UPDATE @DBA_ArchiveTable SET IsCheck = 1, ErrorMsg=@ErrorMessage WHERE ID = @ID
		DELETE FROM @tbTableColumn


	END TRY
	BEGIN CATCH
			SELECT @ErrorMessage = ERROR_MESSAGE() + '- Step check data at @DBA_ArchiveTable where SourceServer = ' + @_SourceServer+' AND SourceDB ' + @_SourceDB +'AND ID = ' + CAST(@ID as VARCHAR(10))
			INSERT INTO @TbErrMsgTab (ErrMsg) SELECT @ErrorMessage
			UPDATE @DBA_ArchiveTable SET ErrorMsg = @ErrorMessage, IsCheck = 1 WHERE ID = @ID
			DELETE FROM @tbTableColumn	
	END CATCH
		
	END
	
	IF EXISTS (SELECT 1 FROM @tbErrMsgTab)
	BEGIN
		SELECT * FROM @tbErrMsgTab
	END
	
	IF @IsViewOnly = 1 
	BEGIN
		SELECT * FROM @DBA_ArchiveTable

		SELECT ID, TableName, FilterColumn, FilterValue, StartTime, FinishTime, 
			CountDiff,
			'Durations in [Hours: ' + cast(DATEDIFF(HOUR,StartTime,FinishTime) AS VARCHAR(10)) 
			+ '/Minutes: ' + CAST(DATEDIFF(MINUTE,StartTime,FinishTime) % 60 AS VARCHAR(10))  
			+ '/Seconds: ' + CAST(DATEDIFF(SECOND,StartTime,FinishTime) % 60 AS VARCHAR(10)) + ']. ' AS Durations, 
			ErrorMsg 
		FROM #tmpTrackingTable	
    END

	-- Delete old data log:DBA_CheckDataLogs
	DECLARE @cutOffDate DATE = DATEADD(MONTH,-2,@CurrentDate)
	DELETE
	FROM DBA_CheckDataLogs WITH(ROWLOCK)
	WHERE LogDate < @cutOffDate
	

	DROP TABLE IF EXISTS #tmpCheckSumResult
	DROP TABLE IF EXISTS #tmpLstKey_Diff
	DROP TABLE IF EXISTS #tmpTrackingTable
	DROP TABLE IF EXISTS #CheckSumDataSource
	DROP TABLE IF EXISTS #CheckSumDataTarget

END
