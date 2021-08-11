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
	DECLARE @TargetThreshold SMALLMONEY, @fragmentStart SMALLMONEY
	DECLARE @fragmentInfo VARCHAR(1000), @fragmentMax SMALLMONEY, @fragmentMin SMALLMONEY
	DECLARE @IsBettransCIX bit
	DECLARE @fragment_current SMALLMONEY, @fragment_final SMALLMONEY
	DECLARE @extra_info VARCHAR(1000), @fragment_count BIGINT

	DECLARE @Debug bit, @LogMessage varchar(1000)
	DECLARE @LapseTime DATETIME

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
		@IsBettransCIX = CASE WHEN name_table = 'bettrans' AND index_type = 'C' THEN 1 ELSE 0 END, 
		@command = command,
		@TargetThreshold = FragmentTarget,
		@fragmentStart   = Fragment,
		@time_trace = time_trace,
		@Debug		= ISNULL(Debug,0)
	FROM MonDB.dbo.DBA_ReIndex_Record T 
	WHERE id_db = @id_db

	IF @@ROWCOUNT > 0 -- ok, confirmed got job to do
	BEGIN
		IF @Debug = 1 AND @@SERVERNAME NOT IN ('DBTRANS', 'DB206')
			SET @Debug = 0

		UPDATE bodb02.dbo.SystemSettings
			SET VValue = @rn
			WHERE VName = 'ReIndex_rn'
		UPDATE bodb02.dbo.SystemSettings
			SET VValue = CONVERT(nvarchar(19),CURRENT_TIMESTAMP, 120) 
			WHERE VName = N'ReIndex_RunSince'

		SET @LapseTime = CURRENT_TIMESTAMP
		SELECT
			@fragment_current = avg_fragmentation_in_percent,
			@fragment_count = fragment_count,
			@extra_info =
				--CONVERT(varchar, CAST(avg_fragmentation_in_percent AS DECIMAL(9,5)) , 1) + ' ' +
				--CONVERT(varchar, CAST(avg_fragment_size_in_pages AS DECIMAL(9,5)) , 1) + ' ' +
				CONVERT(varchar, fragment_count,1) + '/' +
				CONVERT(varchar, page_count,1)
			FROM sys.dm_db_index_physical_stats(@id_db, @id_table, @id_index, NULL, 'SAMPLED') AS fi 
			WHERE alloc_unit_type_desc = 'IN_ROW_DATA'

		IF @RunCounter = 1
		BEGIN
			-- UPDATE STATISTICS once before start job for bettrans Clustered Index, since this one might run for long period of time.
			IF @IsBettransCIX = 1
			BEGIN
				IF @Debug = 1
				BEGIN
					SET @LogMessage = 'ProcessOne:START Update-Stats'

					EXEC [MonDB].[dbo].[WriteLog_ReIndex]
							@time_trace = @time_trace,
							@record_rn = @rn,
							@RunCounter = @RunCounter,
							@doing = @LogMessage
				END

				EXEC sp_updatestats
			END

			UPDATE bodb02.dbo.SystemSettings
				SET VValue = CONVERT(varchar, cast(@fragment_current as money),1),
					@fragmentInfo = ''
				WHERE VName = 'ReIndex_Fragment'
		END
		ELSE IF @fragment_current > @TargetThreshold  -- not first run, let find out if we should continue the job
		BEGIN 
			UPDATE bodb02.dbo.SystemSettings 
				SET @fragmentInfo = VValue = CONVERT(varchar, cast(@fragment_current as money), 1) + ' ,' + LEFT(VValue, 180)
				WHERE VName = 'ReIndex_Fragment'

			IF LEN(@fragmentInfo) >= 40 AND @IsBettransCIX = 0
			BEGIN
				SELECT
					@fragmentMax = MAX(CAST(val AS MONEY)),
					@fragmentMin = MIN(CAST(val AS MONEY))
					FROM bodb02.dbo.strSplit( @fragmentInfo ,',')
					WHERE rank <= 5
				
				-- last X rounds, no significant improvement
				-- Let's stop it!
				-- we will make it look like fragment already lower than @TargetThreshold
				IF @fragmentMax - @fragmentMin < 2.00 SET @TargetThreshold = @fragment_current + 1
			END

			-- if this is extra job (allow to run when Fragment level not over Threshold, then allow to run only 2 round.
			-- else, allow 7 rounds
			-- Note : this can be either Terminator think the Fragment level is ok and stop previous job, or because Repl. delay.
			IF (@fragmentStart < @FragmentThreshold AND @RunCounter > 2) 
				OR (@IsBettransCIX = 0 AND @RunCounter > 7) 
				OR (@IsBettransCIX = 1 AND @RunCounter >= 4) -- AND @fragment_current < @FragmentThreshold)
				SET @TargetThreshold = @fragment_current + 1
		END

		-- report for duty
		UPDATE bodb02.dbo.SystemSettings 
			SET VValue = @@SPID 
			WHERE VName = N'ReIndex_spid'


		-- before extra log for more info
		IF @Debug = 1
		BEGIN
			WAITFOR DELAY '00:00:01.000' -- this will allow Terminator to Log first.

			SET @LogMessage = 'ProcessOne:' + CASE WHEN @fragment_current > @TargetThreshold THEN 'START REORGANIZE' ELSE 'SKIP' END 
					+ ' [ ' + CONVERT(varchar, cast(@fragment_current as money), 1) + '% ' + @extra_info + ' pages ]' --CONVERT(varchar,@fragment_count,1) + ' pages ]' --' ON ' 
					--+ @name_table + '.' + @name_index + @index_type + ' ('
					--+ CAST(@id_db    as varchar(20)) + ','
					--+ CAST(@id_table as varchar(20)) + ',' 
					--+ CAST(@id_index as varchar(20)) + ')'
					+ ' by spid ' + CAST(@@SPID  as varchar(20))
					+ ' pre-process ' + CONVERT(varchar,CAST(DATEDIFF(ms, @LapseTime, CURRENT_TIMESTAMP)/1000.0 AS DECIMAL(9,3)),1) + ' seconds'
					--+ ' ExtraInfo ' + @extra_info

			EXEC [MonDB].[dbo].[WriteLog_ReIndex]
				@time_trace = @time_trace,
				@record_rn = @rn,
				@RunCounter = @RunCounter,
				@doing = @LogMessage
		END
		-- go to work! go to work!
		IF @fragment_current > @TargetThreshold
			EXEC sp_executesql @command

		SELECT
			@fragment_final = avg_fragmentation_in_percent,
			@fragment_count = fragment_count,
			@extra_info =
				--CONVERT(varchar, CAST(avg_fragmentation_in_percent AS DECIMAL(9,5)) , 1) + ' ' +
				--CONVERT(varchar, CAST(avg_fragment_size_in_pages AS DECIMAL(9,5)) , 1) + ' ' +
				CONVERT(varchar, fragment_count,1) + '/' +
				CONVERT(varchar, page_count,1)

			FROM sys.dm_db_index_physical_stats(@id_db, @id_table, @id_index, NULL, 'SAMPLED') AS fi 
			WHERE alloc_unit_type_desc = 'IN_ROW_DATA'
		
		-- mark as done.
		UPDATE bodb02.dbo.SystemSettings
			SET VValue = -2
			WHERE VName = N'ReIndex_spid'

		-- log info
		IF @Debug = 1
		BEGIN
			IF @fragmentInfo IS NULL
				SELECT @fragmentInfo = VValue
				FROM bodb02.dbo.SystemSettings WITH (NOLOCK)
				WHERE VName = 'ReIndex_Fragment'

			SET @LogMessage = 'ProcessOne:DONE '
				+ ' Fragment Final [ ' +  CONVERT(varchar, cast(@fragment_final as money), 1) + '% ' + @extra_info + ' pages ]' --CONVERT(varchar,@fragment_count,1) + ' pages ]'
				+ ' from [' + CONVERT(varchar, cast(@fragmentStart as money),1) + '] ' + CONVERT(varchar, cast(@fragment_current as money),1) + '%'
				+ ' after ' + CAST(@RunCounter as varchar(1000))
				+ ' times with duration ' + CONVERT(varchar, (DATEDIFF(second, @TimeStart, CURRENT_TIMESTAMP)/60),1) 
				+ ':' + CASE WHEN DATEDIFF(second, @TimeStart, CURRENT_TIMESTAMP)%60 < 10 THEN '0' ELSE '' END + CONVERT(varchar, (DATEDIFF(second, @TimeStart, CURRENT_TIMESTAMP)%60),1) + ' minutes'
				-- + ' ExtraInfo ' + @extra_info
				+ CASE WHEN @RunCounter = 1 THEN '' ELSE ' (' + @fragmentInfo + ')' END

			EXEC [MonDB].[dbo].[WriteLog_ReIndex]
					@time_trace = @time_trace,
					@record_rn = @rn,
					@RunCounter = @RunCounter,
					@doing = @LogMessage
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
					+ ' ' + CONVERT(varchar, cast(@fragmentStart as money),1) 
					+ ' ' + CASE WHEN LEN(CONVERT(varchar, cast(@fragment_final as money),1)) < 5 THEN '0' ELSE '' END + CONVERT(varchar, cast(@fragment_final as money),1) 
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
