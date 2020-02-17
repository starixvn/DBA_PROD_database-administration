SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	chksum.Task_CheckCustomerData
						@Debug				BIT				= 0
AS
/*
	Creator:	20200123@Billy
	Task:		Perform checking data of customers - [Redmine: #127620]
	Database:	DBDCHK.CheckDataDB

	Revisions:
		- 20200123@Billy:	Initial - [Redmine: #127620]

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

	-- Table Variables --
	DECLARE	@TableList AS TABLE (
				SchName			NVARCHAR(128)
			,	TblName			NVARCHAR(128)
			,	PRIMARY KEY CLUSTERED (SchName, TblName)
			);


	-- Determine check time --
	SELECT	@CheckTime		= GETDATE()
		,	@MaxCreatedDate	= DATEADD(HOUR, DATEDIFF(HOUR, 0, GETDATE()) - 1, 0)
		;

	-- Insert history record --
	INSERT INTO	chksum.CheckHistory (ChkDate)
	VALUES	(@CheckTime);

	-- Get max CustId to prevent mismatch on the last batch --
	BEGIN;
		SELECT	@Query = N'';
		SELECT	@Query += N'\
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
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
[@CheckTime]		= ' + CONVERT(NVARCHAR, @CheckTime, 121) + N'
[@MaxCreatedDate]	= ' + CONVERT(NVARCHAR, @MaxCreatedDate, 121) + N'
[@MaxCustId]		= ' + CONVERT(NVARCHAR, @MaxCustId) + REPLICATE(N'
', 2);
		RAISERROR(@Msg, 0, 0) WITH NOWAIT;
	END;


	-- Get list of tables to be checked --
	INSERT INTO	@TableList (SchName, TblName)
	SELECT	tbl.SchName, tbl.TblName
	FROM	chksum.TableConfigs AS tbl WITH (NOLOCK);

	WHILE	0 = 0
	BEGIN;
		SELECT	TOP(1)
				@Schema		= tbl.SchName
			,	@Table		= tbl.TblName
		FROM	@TableList AS tbl;

		IF	@@ROWCOUNT = 0
			BREAK;

		IF	@Debug = 1
		BEGIN;
			SELECT	@Msg = N'\
[VERBOSE]	Task_CheckCustomerData:
			Checking data			(%s.%s)';
			RAISERROR(@Msg, 0, 0, @Schema, @Table) WITH NOWAIT;
		END;

		EXECUTE	chksum.Task_CheckTableData
					@Schema				= @Schema
				,	@Table				= @Table
				,	@CheckTime			= @CheckTime
				,	@MaxPartitionValue	= @MaxCustId
				,	@Debug				= @Debug
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

	WHILE	EXISTS (SELECT 1 FROM chksum.CheckResults WITH (NOLOCK) WHERE ChkDate = @CheckTime AND (SrcDuration IS NULL OR DstDuration IS NULL))
	BEGIN;
		WAITFOR DELAY '00:01:00.000';

		DELETE	chksum.CheckResults WITH (PAGLOCK)
		WHERE	ChkDate = @CheckTime
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

	WAITFOR DELAY '00:01:00.000';

	-- Mark done in history --
	UPDATE	chksum.CheckHistory WITH (ROWLOCK)
	SET		isFinished = 1
	WHERE	ChkDate = @CheckTime;
END;
GO
/*<info serverAlias="DBDCHK-CheckDataDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/