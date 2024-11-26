/*<info serverAlias="DBCONSISTENCY-bodb_Consistency"></info>*/
ALTER PROCEDURE DBA_Consistency_CheckTicketCount_ArchiveTable		
	@IsViewOnly BIT = 0,
	@SourceServer VARCHAR(100) = '',
	@TargetServer VARCHAR(100) = '',
	@Database	VARCHAR(100) = '',
	@TableNames VARCHAR(MAX) = ''
AS
--================== Compare RowCount Table ==================--
/*
	Created: 20240508@Evan
	DB: DBCONSISTENCY-bodb_Consistency

	Revisions:
		- 20240503@Evan: Initialize Jobs Compare data KBT vs KL [Redmine: #204816]
		
	Param's Explanation:   
		@IsViewOnly: For checking, non send notify
*/

BEGIN

	SET NOCOUNT ON

	DECLARE @Msg VARCHAR (500),@RowCount BIGINT
	SET @Msg =   'Starting...'
	RAISERROR (@Msg , 0, 1) WITH NOWAIT

	DROP TABLE IF EXISTS #tmpRowCountSource
	DROP TABLE IF EXISTS #tmpRowCountTarget
	DROP TABLE IF EXISTS #tmpRowCountResult

	CREATE TABLE #tmpRowCountSource (TableName VARCHAR(100),Cnt BIGINT )
	CREATE TABLE #tmpRowCountTarget (TableName VARCHAR(100),Cnt BIGINT )

	CREATE TABLE #tmpRowCountResult(
		  ID INT IDENTITY (1, 1)
		, RowNum INT 
		, TableName VARCHAR(100)
		, TableId INT
		, SourceServer VARCHAR(100)
		, TargetServer VARCHAR(100)
		, SourceDB VARCHAR(100)
		, TargetDB VARCHAR(100)
		, RowCount_Source BIGINT
		, RowCount_Target BIGINT
		, Diff BIGINT
		, StartTime DATETIME
		, IsUpdate BIT DEFAULT (0)
	)
	DECLARE @tbErrMsgTab AS TABLE (NoID SMALLINT IDENTITY (1,1), ErrMsg VARCHAR(MAX))
	
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
	SELECT SourceServer, TargetServer, SourceDB, TargetDB, STRING_AGG(TableName, ',') WITHIN GROUP (ORDER BY TableName)  AS TableNames
	FROM dbo.DBA_ArchiveTable WITH (NOLOCK)
	WHERE 
		(SourceServer = @SourceServer OR @SourceServer = '' )AND
		(TargetServer = @TargetServer OR @TargetServer = '' ) AND
		(SourceDB = @Database OR @Database = '' ) AND
		(TargetDB = @Database OR @Database = '' ) AND
		(TableName IN (SELECT VALUE FROM STRING_SPLIT(@TableNames,',')) OR @TableNames = '' )
	GROUP BY SourceServer, TargetServer, SourceDB, TargetDB
	
	IF  @@ROWCOUNT = 0	AND @TableNames <> '' AND @SourceServer <> '' AND @TargetServer <> '' AND @Database <> '' AND @TableNames <> ''
	BEGIN
        INSERT INTO @DBA_ArchiveTable (SourceServer, TargetServer, SourceDB, TargetDB, TableNames)
		SELECT @SourceServer , @TargetServer , @Database , @Database , @TableNames
    END
	
	
	DECLARE @ErrorMessage VARCHAR(MAX), @CurrentDate DATE
  
	SELECT  @CurrentDate = CONVERT(DATE, CURRENT_TIMESTAMP, 112)

	DECLARE @sqlCMD NVARCHAR(MAX)
		  , @_TableNames VARCHAR(MAX)
		  , @_SourceServer VARCHAR(100) = ''
		  , @_TargetServer VARCHAR(100) = ''
		  , @_TableName VARCHAR(100)
		  , @_SourceDB VARCHAR(100)
		  , @_TargetDB VARCHAR(100)
		  , @StartTime DATETIME
		  , @EndTime DATETIME
		  , @ID INT;

	--
	WHILE EXISTS (SELECT 1 FROM @DBA_ArchiveTable WHERE IsCheck = 0)
    BEGIN
	BEGIN TRY
		SET @StartTime = CURRENT_TIMESTAMP
		SELECT TOP 1 @ID = ID
				   , @_SourceServer = SourceServer
				   , @_TargetServer = TargetServer
				   , @_TableNames = TableNames
				   , @_SourceDB = SourceDB
				   , @_TargetDB = TargetDB
		FROM @DBA_ArchiveTable
		WHERE IsCheck = 0

		SET @Msg =  'Compare RowCount Table:  ' +@_TableNames + ' from '+@_SourceServer+ '.' +@_SourceDB+ ' to '+@_TargetServer+ '.' +@_TargetDB
		RAISERROR (@Msg , 0, 1) WITH NOWAIT

		--SourceDB
		SET @sqlCMD = N'\
			;WITH cte_CountKBT AS (
				SELECT t.*
				FROM OPENQUERY('+@_SourceServer+',
					''SELECT b.name as TableName
							, SUM(rows) AS cnt
					FROM '+@_SourceDB+'.sys.partitions a 
						INNER JOIN '+@_SourceDB+'.sys.objects b ON a.object_id = b.object_id
					WHERE b.name IN (SELECT value FROM STRING_SPLIT('''''+@_TableNames+''''','''',''''))
						AND index_id = 1
					GROUP BY b.name''
				) AS t
			)
			INSERT INTO #tmpRowCountSource (TableName,Cnt)
			SELECT TableName,Cnt
			FROM cte_CountKBT;\
		';
		
		EXEC sp_executesql @sqlCMD
			
		--TargetDB
		SET @sqlCMD = N'\
			;WITH cte_CountKBT AS (
				SELECT t.*
				FROM OPENQUERY('+@_TargetServer+',
					''SELECT b.name as TableName
							, SUM(rows) AS cnt
					FROM '+@_TargetDB+'.sys.partitions a 
						INNER JOIN '+@_TargetDB+'.sys.objects b ON a.object_id = b.object_id
					WHERE b.name IN (SELECT value FROM STRING_SPLIT('''''+@_TableNames+''''','''',''''))
						AND index_id = 1
					GROUP BY b.name''
				) AS t
			)
			INSERT INTO #tmpRowCountTarget (TableName,Cnt)
			SELECT TableName,Cnt
			FROM cte_CountKBT;\
		';

		EXEC sp_executesql @sqlCMD

		INSERT INTO #tmpRowCountResult(RowNum,TableName,SourceServer, TargetServer, SourceDB, TargetDB, RowCount_Source ,RowCount_Target,Diff,StartTime)
		SELECT ROW_NUMBER()OVER (ORDER BY a.TableName) ID, a.TableName, @_SourceServer , @_TargetServer , @_SourceDB , @_TargetDB, a.cnt AS Row_Count_KBT, b.cnt AS Row_Count_KL, a.cnt-b.cnt AS Diff, @StartTime 
		FROM #tmpRowCountSource a 
			INNER JOIN #tmpRowCountTarget b ON a.TableName = b.TableName
		WHERE a.cnt-b.cnt <> 0
			
		SET @RowCount = @@rowcount
		SET @Msg =  '==> ' + CAST(@rowCount AS VARCHAR(50)) + ' rows affected'
		RAISERROR (@Msg , 0, 1) WITH NOWAIT

		UPDATE a
		SET a.TableId = b.ID
		FROM #tmpRowCountResult a
			INNER JOIN dbo.DBA_ArchiveTable b WITH (NOLOCK) ON a.TableName = b.TableName
		WHERE b.SourceServer = @_SourceServer
			AND b.TargetServer = @_TargetServer
			AND a.SourceDB = @_SourceDB
			AND a.TargetDB = @_TargetDB

		UPDATE @DBA_ArchiveTable SET IsCheck = 1 WHERE ID = @ID	

		END TRY
		BEGIN CATCH
				SELECT @ErrorMessage = ERROR_MESSAGE()
				INSERT INTO @TbErrMsgTab (ErrMsg) SELECT @ErrorMessage

				UPDATE @DBA_ArchiveTable SET IsCheck = 1 WHERE ID = @ID	
		END CATCH
		
		SET @ErrorMessage = '';

		IF EXISTS (SELECT 1 FROM #tmpRowCountResult WHERE IsUpdate = 0 )
		BEGIN
			
			SELECT @ErrorMessage 
						= 'Compare RowCount **'+@_SourceServer+'('+@_SourceDB+')** vs **'+@_TargetServer+'('+@_TargetDB+')** run on ['+ CONVERT(VARCHAR(20),@CurrentDate) + '].' + CHAR(13)

			SELECT @ErrorMessage = @ErrorMessage +
								( SELECT  CAST(a.RowNum AS VARCHAR(10))  + '. Table Name: **' + a.TableName + '**' + CHAR(13)
											+ '- Different rows: '+ CAST(FORMAT(a.Diff, '#,#') AS VARCHAR(30)) +  CHAR(13)
											+ '- '+@_SourceServer+'('+@_SourceDB+')'+' RowCount: '+ CAST(FORMAT(a.RowCount_Source, '#,#') AS VARCHAR(30)) + CHAR(13)
											+ '- '+@_TargetServer+'('+@_TargetDB+')'+' RowCount: '+ CAST(FORMAT(a.RowCount_Target, '#,#') AS VARCHAR(30)) + CHAR(13)
										FROM #tmpRowCountResult a WHERE a.IsUpdate = 0 
										FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)')

			IF @IsViewOnly = 0	-- Send Notification			
			BEGIN
				SET @EndTime = CURRENT_TIMESTAMP
            	EXEC DBNOTI.NotificationDB.dbo.DBA_Skype_NewMessage @ServerName = N'PONTUS'
																   , @JobId = NULL
																   , @JobName = N'Custom MessageBot'
																   , @Message = @ErrorMessage
																   , @CaseId = 1;
				INSERT INTO DBA_CheckDataLogs (LogDate, TableName, TableId, CheckType, RowDiff, LogDesc, StartTime, EndTime)
				SELECT @CurrentDate , TableName , TableId , 'CheckRowCount' , Diff 
				, '- '	+@_SourceServer+'('+@_SourceDB+')'+' RowCount: '+ CAST(FORMAT(RowCount_Source, '#,#') AS VARCHAR(30)) + CHAR(13)
						+ '- '+@_TargetServer+'('+@_TargetDB+')'+' RowCount: '+ CAST(FORMAT(RowCount_Target, '#,#') AS VARCHAR(30)) + CHAR(13) 
				, StartTime , @EndTime
				FROM #tmpRowCountResult WHERE IsUpdate = 0  
            END
		END	

		UPDATE @DBA_ArchiveTable SET IsCheck = 1, ErrorMsg=@ErrorMessage WHERE ID = @ID
		UPDATE #tmpRowCountResult SET IsUpdate = 1 WHERE IsUpdate = 0

		TRUNCATE TABLE #tmpRowCountSource
		TRUNCATE TABLE #tmpRowCountTarget
		 
		
    END

	IF EXISTS (SELECT 1 FROM @tbErrMsgTab)
	BEGIN
		SELECT * FROM @tbErrMsgTab
	END

	IF @IsViewOnly = 1 
	BEGIN

		SELECT * FROM @DBA_ArchiveTable
		SELECT ID, TableName, SourceServer, TargetServer, SourceDB, TargetDB, RowCount_Source, RowCount_Target, Diff
		FROM #tmpRowCountResult	  
		ORDER BY ABS(Diff) DESC
    END

DROP TABLE IF EXISTS #tmpRowCountSource
DROP TABLE IF EXISTS #tmpRowCountTarget
DROP TABLE IF EXISTS #tmpRowCountResult
END

GO


