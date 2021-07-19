/*<info serverAlias="DBTXN-bodb02" executers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[DBA_ReIndex_ProcessOne]
	@FragmentThreshold smallmoney = 30
	--@TargetFragment smallmoney = 15
	-- reorganized will stop, after fragment lower than this threshold.
AS
/*
	Created:	20180629@Joe
	Task:		20180629 - SP will pick one index to perform.
				And record related information for SP DBA_ReIndex_Terminate to assist on killing
	DB:			DBTXN.bodb02

	Revisions:
		- 20180629@Joe : New ReIndex process
		- 20210710@Joe : modify together with DBA_ReIndex_Terminator
				   20210712 change dm_db_index_physical_stats scanning mode from LIMITED to SAMPLED
		- 20210719@Bobby : re-format coding and logging enhancement

*/
BEGIN
	DECLARE @rn INT, @id_db BIGINT, @id_table BIGINT, @id_index BIGINT
	DECLARE @name_table varchar(500), @name_index varchar(500), @index_type varchar(4)
	DECLARE @RunCounter INT, @TimeStart DATETIME2(6), @time_trace DATETIME
	DECLARE @command NVARCHAR(1000)
	DECLARE @TargetThreshold SMALLMONEY, @fragment SMALLMONEY, @fragmentStart SMALLMONEY, @page_count BIGINT
	DECLARE @fragmentInfo VARCHAR(1000), @fragmentMax SMALLMONEY, @fragmentMin SMALLMONEY

	DECLARE @startTrace varchar(1000), @endTrace varchar(1000), @debug bit

	SELECT @id_db = DB_ID()

	-- update RunCounter + get required variable
	UPDATE TOP (1) T WITH (ROWLOCK)
	SET
		@RunCounter = RunCounter = RunCounter + 1,
		@TimeStart  = TimeStart  = CASE WHEN TimeStart IS NULL THEN CURRENT_TIMESTAMP ELSE TimeStart END,
		@rn = rn, 
		@id_table = id_table, @id_index = id_index, 
		@name_table = name_table, @name_index = name_index, 
		@index_type = CASE index_type WHEN 'C' THEN ' (C)' ELSE '' END,
		@command = command,
		@TargetThreshold = FragmentTarget,
		@fragmentStart   = Fragment,
		@page_count = page_count,
		@time_trace = time_trace,
		@debug		= ISNULL(Debug,0)
	FROM MonDB.dbo.DBA_ReIndex_Record T 
	WHERE id_db = @id_db

	IF @@ROWCOUNT > 0 -- ok, confirmed got job to do
	BEGIN
		UPDATE bodb02.dbo.SystemSettings
			SET VValue = @rn
			WHERE VName = 'ReIndex_rn'
		UPDATE bodb02.dbo.SystemSettings
			SET VValue = CONVERT(nvarchar(19),CURRENT_TIMESTAMP, 120) 
			WHERE VName = N'ReIndex_RunSince'

		-- report for duty
		UPDATE bodb02.dbo.SystemSettings 
			SET VValue = @@SPID 
			WHERE VName = N'ReIndex_spid'

		SELECT @fragment = avg_fragmentation_in_percent
			FROM sys.dm_db_index_physical_stats(@id_db, @id_table, @id_index, NULL, 'SAMPLED') AS fi 
			WHERE alloc_unit_type_desc = 'IN_ROW_DATA'

		IF @RunCounter = 1
			UPDATE bodb02.dbo.SystemSettings
				SET VValue = CONVERT(varchar, cast(@fragment as money),1),
					@fragmentInfo = ''
				WHERE VName = 'ReIndex_Fragment'
		ELSE IF @fragment > @TargetThreshold  -- not first run, let find out if we should continue the job
		BEGIN 
			UPDATE bodb02.dbo.SystemSettings 
				SET @fragmentInfo = VValue = CONVERT(varchar, cast(@fragment as money), 1) + ' ,' + LEFT(VValue, 180)
				WHERE VName = 'ReIndex_Fragment'

			IF LEN(@fragmentInfo) >= 40
			BEGIN
				SELECT
					@fragmentMax = MAX(CAST(val AS MONEY)),
					@fragmentMin = MIN(CAST(val AS MONEY))
					FROM bodb02.dbo.strSplit( @fragmentInfo ,',')
					WHERE rank <= 5
				
				-- last X rounds, no significant improvement
				-- Let's stop it!
				-- we will make it look like fragment already lower than @TargetThreshold
				IF @fragmentMax - @fragmentMin < 2.00 SET @TargetThreshold = @fragment + 1
			END

			-- if this is extra job (allow to run when Fragment level not over Threshold, then allow to run only 2 round.
			-- else, allow 7 rounds
			-- Note : this can be either Terminator think the Fragment level is ok and stop previous job, or because Repl. delay.
			IF (@fragmentStart < @FragmentThreshold AND @RunCounter > 2) OR @RunCounter > 7 SET @TargetThreshold = @fragment + 1
		END


		SET @startTrace =	'ProcessOne:START [FROM ' + CAST('rn = ' as varchar(1000)) + CONVERT(varchar, @rn,1)
				+ CASE WHEN @fragment > @TargetThreshold THEN ' ' ELSE ' SKIP:' END 
				+ 'ORGANIZE [ ' + CONVERT(varchar, cast(@fragment as money), 1) + '% ] ON ' 
				+ @name_table + '.' + @name_index + @index_type + ' ('
				+ CAST(@id_db    as varchar(20)) + ','
				+ CAST(@id_table as varchar(20)) + ',' 
				+ CAST(@id_index as varchar(20)) + ') by spid ' + CAST(@@SPID  as varchar(20))
		
		-- before extra log for more info
		IF @@SERVERNAME IN ('DBTRANS', 'DB206') AND @debug = 1
		BEGIN
			EXEC [MonDB].[dbo].[WriteLog_ReIndex]
				@time_trace = @time_trace,
				@record_rn = @rn,
				@RunCounter = @RunCounter,
				@doing = @startTrace
		END
		-- go to work! go to work!
		IF @fragment > @TargetThreshold
			EXEC sp_executesql @command

		SELECT @fragment = avg_fragmentation_in_percent
			FROM sys.dm_db_index_physical_stats(@id_db, @id_table, @id_index, NULL, 'SAMPLED') AS fi 
			WHERE alloc_unit_type_desc = 'IN_ROW_DATA'
		
		-- mark as done.
		UPDATE bodb02.dbo.SystemSettings
			SET VValue = -2
			WHERE VName = N'ReIndex_spid'

		SET @endTrace = 'ProcessOne:DONE [FROM ' 
			+ CONVERT(varchar, cast(@fragmentStart as money),1) + ' to ' 
			+ CONVERT(varchar, cast(@fragment as money), 1) + '] after ' + CAST(@RunCounter as varchar(1000))
			+ ' times with duration ' + CONVERT(varchar, (DATEDIFF(second, @TimeStart, CURRENT_TIMESTAMP)/60),1) 
			+ ':' + CONVERT(varchar, (DATEDIFF(second, @TimeStart, CURRENT_TIMESTAMP)%60),1) + ' minutes'
			+ CASE WHEN @RunCounter = 1 THEN '' ELSE ' (' + @fragmentInfo + ')' END
			+ ' [' + CAST(@page_count AS VARCHAR(1000)) + ' pages]'
		
		-- log info
		IF @@SERVERNAME IN ('DBTRANS', 'DB206') AND @debug = 1
		BEGIN
			EXEC [MonDB].[dbo].[WriteLog_ReIndex]
					@time_trace = @time_trace,
					@record_rn = @rn,
					@RunCounter = @RunCounter,
					@doing = @endTrace
		END
		-- reach here, mean either it's done, or not get terminate
		-- therefore, can remove it.
		WAITFOR DELAY '00:00:02.000' -- delay to allow DBA_ReIndex_Terminator to catch information about this round
		DELETE FROM MonDB.dbo.DBA_ReIndex_Record WITH (ROWLOCK) WHERE rn = @rn

		-- log info into MonDB
		IF @@SERVERNAME IN ('DBTRANS')
		BEGIN
			INSERT INTO MonDB.dbo.[Mon_ReIndex_List] ([TableName],IndexName,[Type_desc],[Time_Start],[Time_End])
			SELECT @name_table, @name_index, 
				CASE @index_type WHEN ' (C)' THEN 'C' ELSE 'N' END + CAST(@RunCounter as varchar(20)) 
					+ ' ' + CONVERT(varchar, cast(@fragmentStart as money),1) + ' ' + CONVERT(varchar, cast(@fragment as money),1) 
					+ ' ' + CONVERT(varchar, (DATEDIFF(minute,@TimeStart, CURRENT_TIMESTAMP)),1),
				@TimeStart, GETDATE()
		END

	END
	ELSE
		UPDATE bodb02.dbo.SystemSettings 
			SET VValue = -2
			WHERE VName = N'ReIndex_spid'
END
GO


