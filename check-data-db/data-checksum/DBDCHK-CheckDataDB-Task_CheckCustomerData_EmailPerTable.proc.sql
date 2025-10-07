USE [CheckDataDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE	[chksum].[Task_CheckCustomerData_EmailPerTable]
						@Debug				BIT				= 0
					,	@MaxRetries			INT				= 3
					,	@RetryDelaySeconds	INT				= 5
AS
/*
	Creator:	20250924@Daniel
	Task:		Perform checking data of customers with per table-email basis
	Database:	DBDCHK.CheckDataDB

	Revisions:
		- 20250924@Daniel:	Clone from orginal version Task_CheckCustomerData and enhance
		- 20251005@Daniel:	Add intelligent retry mechanism - retry only discrepancies from previous runs, clean up false positives


	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	-- Dynamic query --
	DECLARE	@Query			NVARCHAR(MAX)
		,	@Param			NVARCHAR(MAX)
		,	@ExecuteSP		NVARCHAR(MAX)
		;

	-- Target Variables --
	DECLARE	@Server			NVARCHAR(128)
		,	@Database		NVARCHAR(128)
		,	@Schema			NVARCHAR(128)
		,	@Table			NVARCHAR(128)
		,	@TableID		INT
		;

	-- Debug Variables --
	DECLARE	@Msg			NVARCHAR(MAX)
		,	@Rowcount		INT
		;

	-- Variables --
	DECLARE	@CheckTime		DATETIME
		,	@MaxCustId		INT
		,	@MaxCreatedDate	DATETIME
		;

	-- Retry mechanism variables --
	DECLARE	@CurrentRetry		INT = 0
		,	@HasDiscrepancies	BIT = 0
		,	@DiscrepancyIntervals TABLE (
				IntervalFrom	BIGINT
			,	IntervalTo		BIGINT
			,	PRIMARY KEY CLUSTERED (IntervalFrom, IntervalTo)
			);

	-- Table Variables --
	DECLARE	@TableList AS TABLE (
				SchName			NVARCHAR(128)
			,	TblName			NVARCHAR(128)
			,	TableID			INT
			,	PRIMARY KEY CLUSTERED (SchName, TblName)
			);


	
	SELECT	@MaxCreatedDate	= DATEADD(HOUR, DATEDIFF(HOUR, 0, GETDATE()) - 1, 0)
		;


	-- Get max CustId to prevent mismatch on the last batch --
	BEGIN;
		SELECT	@Query = N'';
		SELECT	@Query += N'\
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT	TOP(1)
		@MaxCustId = custid
FROM	dbo.Customer WITH (NOLOCK)
WHERE	creatdate < @MaxCreatedDate
ORDER BY custid DESC;';

		SELECT	@Param = N'';
		SELECT	@Param += N'@MaxCreatedDate DATETIME, @MaxCustId INT OUTPUT';

		-- Get source target --
		SELECT	TOP(1)
				@Server			= src.TargetServer
			,	@Database		= src.TargetDatabase
		FROM		chksum.TableConfigs AS tbl WITH (NOLOCK)
		INNER JOIN	chksum.Checklist AS l WITH (NOLOCK)
				ON	tbl.TableId = l.TableId
		INNER JOIN	chksum.Targets AS t WITH (NOLOCK)
				ON	l.TargetId = t.TargetId
		INNER JOIN	chksum.Targets AS src WITH (NOLOCK)
				ON	t.SrcTarget = src.TargetId
		WHERE	tbl.SchName = N'dbo'
			AND	tbl.TblName = N'Customer'
			AND	l.isActive = 1;

		IF	@@ROWCOUNT = 0
		BEGIN;
			SELECT	@Msg = N'';
			SELECT	@Msg += N'\
[Check Customer Data]
Cannot determine source target. Exiting...';

			EXECUTE	DBNOTI.NotificationDB.dbo.Skype_SendMessage 'BILLY', @Msg;
			RAISERROR(@Msg, 16, 1) WITH NOWAIT;

			RETURN 16;
		END;

		-- Get Max CustId --
		SELECT	@ExecuteSP = QUOTENAME(@Server) + N'.' + QUOTENAME(@Database) + N'.sys.sp_executesql';
		EXECUTE	@ExecuteSP @Query, @Param, @MaxCreatedDate, @MaxCustId OUTPUT;

		-- Abort if cannot obtain the value --
		IF	@@ERROR <> 0 OR @MaxCustId IS NULL
		BEGIN;
			SELECT	@Msg = N'';
			SELECT	@Msg += N'\
[Check Customer Data]
Cannot determine MAX(CustId) to continue checking data. Exiting...';

			EXECUTE	DBNOTI.NotificationDB.dbo.Skype_SendMessage 'BILLY', @Msg;
			RAISERROR(@Msg, 16, 1) WITH NOWAIT;

			RETURN 16;
		END;
	END;

	IF	@Debug = 1
	BEGIN;
		SELECT	@Msg = N'\
[@CheckTime]		= ' + CONVERT(NVARCHAR(MAX), @CheckTime, 121) + N'
[@MaxCreatedDate]	= ' + CONVERT(NVARCHAR(MAX), @MaxCreatedDate, 121) + N'
[@MaxCustId]		= ' + CONVERT(NVARCHAR(MAX), @MaxCustId) + REPLICATE(N'
', 2);
		RAISERROR(@Msg, 0, 0) WITH NOWAIT;
	END;


	-- Get list of tables to be checked --
	INSERT INTO	@TableList (SchName, TblName, TableID)
	SELECT	tbl.SchName, tbl.TblName, TableID
	FROM	chksum.TableConfigs AS tbl WITH (NOLOCK)
    ORDER BY TableID;

	WHILE	0 = 0
	BEGIN;
		SELECT	TOP(1)
				@Schema		= tbl.SchName
			,	@Table		= tbl.TblName
			,	@TableID	= tbl.TableID
		FROM	@TableList AS tbl
        ORDER BY TableID;

		IF	@@ROWCOUNT = 0
			BREAK;

		IF	@Debug = 1
		BEGIN;
			SELECT	@Msg = N'\
[VERBOSE]	Task_CheckCustomerData:
			Checking data			(%s.%s)';
			RAISERROR(@Msg, 0, 0, @Schema, @Table) WITH NOWAIT;
		END;

		-- Determine check time --
		SELECT	@CheckTime		= GETDATE()

		-- Insert history record --
		INSERT INTO	chksum.CheckHistory (ChkDate)
		VALUES	(@CheckTime);  

		-- Reset retry variables for this table --
		SET @CurrentRetry = 0;
		SET @HasDiscrepancies = 0;
		DELETE FROM @DiscrepancyIntervals;

		-- Retry loop for this table --
		WHILE @CurrentRetry <= @MaxRetries
		BEGIN;
			SET @CurrentRetry = @CurrentRetry + 1;

			IF @CurrentRetry = 1
			BEGIN;
				-- First run - check all intervals
				EXECUTE	chksum.Task_CheckTableData
							@Schema				= @Schema
						,	@Table				= @Table
						,	@CheckTime			= @CheckTime
						,	@MaxPartitionValue	= @MaxCustId
						,	@Debug				= @Debug
						;
			END
			ELSE
			BEGIN;
				-- Retry run - only check intervals with discrepancies
				-- Get intervals that had discrepancies in the previous attempt
				DELETE FROM @DiscrepancyIntervals;
				INSERT INTO @DiscrepancyIntervals (IntervalFrom, IntervalTo)
				SELECT	DISTINCT r.IntervalFrom, r.IntervalTo
				FROM	chksum.CheckResults AS r WITH (NOLOCK)
				INNER JOIN chksum.Checklist AS l WITH (NOLOCK)
					ON r.ItemId = l.ItemId
				WHERE	r.ChkDate = @CheckTime
					AND l.TableId = @TableID
					AND (r.SrcCount <> r.DstCount 
						OR r.SrcChecksum <> r.DstChecksum 
						OR ISNULL(r.SrcStdev, 0) <> ISNULL(r.DstStdev, 0));

				-- If no discrepancies found, exit retry loop
				IF NOT EXISTS (SELECT 1 FROM @DiscrepancyIntervals)
				BEGIN;
					SELECT @Msg = N'[Check Customer Data] - ' + @Schema + N'.' + @Table + N' - Retry attempt ' + CAST(@CurrentRetry AS NVARCHAR) + N' - No discrepancies found in previous run. Data checksum OK.';
					PRINT @Msg;
					BREAK;
				END;

				SELECT @Msg = N'[Check Customer Data] - ' + @Schema + N'.' + @Table + N' - Retry attempt ' + CAST(@CurrentRetry AS NVARCHAR) + N' - Checking ' + CAST((SELECT COUNT(*) FROM @DiscrepancyIntervals) AS NVARCHAR) + N' intervals with previous discrepancies...';
				PRINT @Msg;

				-- Build discrepancy intervals string for child SP
				DECLARE @DiscrepancyIntervalsString NVARCHAR(MAX) = '';
				SELECT @DiscrepancyIntervalsString = @DiscrepancyIntervalsString + 
					CAST(IntervalFrom AS NVARCHAR) + ',' + CAST(IntervalTo AS NVARCHAR) + ';'
				FROM @DiscrepancyIntervals
				ORDER BY IntervalFrom;
				
				-- Remove trailing semicolon
				IF LEN(@DiscrepancyIntervalsString) > 0
					SET @DiscrepancyIntervalsString = LEFT(@DiscrepancyIntervalsString, LEN(@DiscrepancyIntervalsString) - 1);

				-- Call Task_CheckTableData with specific intervals
				EXECUTE	chksum.Task_CheckTableData
							@Schema				= @Schema
						,	@Table				= @Table
						,	@CheckTime			= @CheckTime
						,	@MaxPartitionValue	= @MaxCustId
						,	@Debug				= @Debug
						,	@RetryAttempt		= @CurrentRetry
						,	@DiscrepancyIntervals = @DiscrepancyIntervalsString
						;
			END;

			-- Wait for async execution to complete
			WHILE	EXISTS (
				SELECT top 1 1 FROM chksum.CheckResults r WITH (NOLOCK)
					inner join chksum.Checklist cl WITH (NOLOCK) on r.ItemId = cl.ItemId 
				WHERE ChkDate = @CheckTime
					and cl.TableId = @TableID
					AND (SrcDuration IS NULL OR DstDuration IS NULL)
				)
			BEGIN;
				WAITFOR DELAY '00:01:00.000';

				DELETE r from chksum.CheckResults r-- WITH (ROWLOCK)
					inner join chksum.Checklist cl WITH (NOLOCK) on r.ItemId = cl.ItemId 
				WHERE	ChkDate = @CheckTime
					and cl.TableId = @TableID
					AND	SrcCount = DstCount
					AND	SrcChecksum = DstChecksum
					AND	SrcStdev = DstStdev;

				SELECT	@Rowcount = @@ROWCOUNT;

				IF	@Debug = 1
					RAISERROR('\
		[VERBOSE]	Task_CheckCustomerData:
					Waiting...
					Deleted %d rows', 0, 0, @Rowcount) WITH NOWAIT;

				-- Error Handling --
				EXECUTE	async.ASyncErrorHandling
							@Pattern	= N'-- Task_CheckTableData --'
						,	@From		= @CheckTime
						,	@Debug		= @Debug
						;
			END;

			-- Check for discrepancies after this attempt
			SELECT @HasDiscrepancies = CASE 
				WHEN EXISTS (
					SELECT 1 
					FROM chksum.CheckResults AS r WITH (NOLOCK)
					INNER JOIN chksum.Checklist AS l WITH (NOLOCK)
						ON r.ItemId = l.ItemId
					WHERE r.ChkDate = @CheckTime
						AND l.TableId = @TableID
						AND (r.SrcCount <> r.DstCount 
							OR r.SrcChecksum <> r.DstChecksum 
							OR ISNULL(r.SrcStdev, 0) <> ISNULL(r.DstStdev, 0))
				) THEN 1 ELSE 0 END;

			IF @HasDiscrepancies = 0
			BEGIN;
				-- No more discrepancies - clean up previous false positives
				DELETE FROM chksum.CheckResults 
				WHERE ChkDate = @CheckTime
					AND ItemId IN (
						SELECT l.ItemId 
						FROM chksum.Checklist AS l WITH (NOLOCK)
						WHERE l.TableId = @TableID
					);
				
				SELECT @Msg = N'[Check Customer Data] - ' + @Schema + N'.' + @Table + N' - Retry attempt ' + CAST(@CurrentRetry AS NVARCHAR) + N' - No more discrepancies found. Previous false positives cleaned up. Data checksum OK.';
				PRINT @Msg;
				BREAK;
			END
			ELSE IF @CurrentRetry < @MaxRetries
			BEGIN;
				-- Still have discrepancies, continue retrying
				SELECT @Msg = N'[Check Customer Data] - ' + @Schema + N'.' + @Table + N' - Retry attempt ' + CAST(@CurrentRetry AS NVARCHAR) + N' - Discrepancies still found. Continuing retry...';
				PRINT @Msg;
				
				-- Wait before next retry
				IF @RetryDelaySeconds > 0
				BEGIN;
					SELECT @Msg = N'[Check Customer Data] - ' + @Schema + N'.' + @Table + N' - Waiting ' + CAST(@RetryDelaySeconds AS NVARCHAR) + N' seconds before retry...';
					PRINT @Msg;
					WAITFOR DELAY '00:00:05'; -- Wait 5 seconds before retry
				END;
			END
			ELSE
			BEGIN;
				-- Max retries reached, keep only the last attempt results
				SELECT @Msg = N'[Check Customer Data] - ' + @Schema + N'.' + @Table + N' - Max retries (' + CAST(@MaxRetries AS NVARCHAR) + N') reached. Data checksum FAILED.';
				PRINT @Msg;
			END;
		END;

		WAITFOR DELAY '00:01:00.000';

		-- Mark done in history --
		UPDATE	chksum.CheckHistory WITH (ROWLOCK)
		SET		isFinished = 1
		WHERE	ChkDate = @CheckTime;

		-- Report result --
		EXECUTE	chksum.Task_ReportCustomerData
						@TblName = @Table
					,	@Debug = @Debug
				;

		IF	@Debug = 1
		BEGIN;
			SELECT	@Msg = N'\
[VERBOSE]	Task_CheckCustomerData:
			Finished				(%s.%s)' + REPLICATE(N'
', 2);
			RAISERROR(@Msg, 0, 0, @Schema, @Table) WITH NOWAIT;
		END;

		DELETE	tbl
		FROM	@TableList AS tbl
		WHERE	tbl.SchName = @Schema
			AND	tbl.TblName = @Table;
	END;


END;
/*<info serverAlias="DBDCHK-CheckDataDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/  