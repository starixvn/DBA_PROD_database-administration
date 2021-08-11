/*<info serverAlias="DBTXN-bodb02" executers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[DBA_ReIndex_Terminator]
	@TimeAllow int = 600,
	@MinRunTime int = 90,
	@MaxHour SMALLMONEY = 4
	--,@publication AS sysname = NULL
	--,@tokenID_out AS int = NULL OUTPUT
	--	,
	--	@DelayFor int = 30 -- after stop, delay for @DelayFor seconds : DBTrans will check for Replication Delay instead
	,@Debug bit = NULL
AS
/*
	Created:	20210708@Joe
	Task:		20210708 - re-structure how the thing work
	DB:			DBTXN.bodb02

	Revisions:
	- 20210708@Joe : re-structure how the thing work
		--    allow REORGANIZE to run as long as need to, unless it cause replication delay or condition met
		--    (1) start when replication delay less than 15 seconds ( included WAITFOR DELAY )
		--    (2) stop  when replication delay more than 30 seconds & run over @MinRunTime
		--    (3) after run exceed @TimeAllow, will stop if Fragment lower than @TargetThreshold
		-- @TimeAllow       BUT NOT BEFORE running this much @TimeAllow second
		-- @MinRunTime      if replication delay, will stop after run this much @MinRunTime second
		-- @MaxHour         no more Index to reorganize, once run pass @MaxHour
		-- working flow chart is at end of SP
	- 20210719@Bobby : re-format coding and logging enhancement
*/
BEGIN
	DECLARE @EndTime DATETIME
	SET @EndTime = DATEADD(minute, @MaxHour*60.0, CURRENT_TIMESTAMP)

	DECLARE @ReIndex_spid INT
	DECLARE @RunSince DATETIME
	DECLARE @LogMessage NVARCHAR(300)

	DECLARE @LastStatusUpdate datetime
	DECLARE @id_db BIGINT, @id_table BIGINT, @id_index BIGINT
	DECLARE @name_table varchar(500), @name_index varchar(500)
	DECLARE @TargetThredhold SMALLMONEY, @fragment SMALLMONEY, @page_count BIGINT
	DECLARE @fragmentInfo VARCHAR(200), @fragmentMax SMALLMONEY, @fragmentMin SMALLMONEY
	DECLARE @NotContinue tinyint
	DECLARE @IsBettransCIX BIT
	DECLARE @IsProcessOneRunning BIT
	DECLARE @rn INT = 0, @rn_current INT = -1

	DECLARE @TimeDebug DATETIME2
	DECLARE @time_offset MONEY
	DECLARE @Token_Insert_Time datetime2, @Tracer_Time_Taken INT, @Max_Tracer_Time INT = 0, @CheckCount INT
	DECLARE @tracer_commit_time datetime
	DECLARE @min_replication_delay INT = 5
	DECLARE @max_replication_delay INT = 20

	DECLARE @time_trace DATETIME,
		@RunCounter INT

	SELECT @id_db = DB_ID()

	-- SET DEBUG mode
	SELECT @Debug = CONVERT(BIT, VValue)
	FROM bodb02.dbo.SystemSettings WITH(NOLOCK)
	WHERE VName = 'ReIndex_Debug'
		AND @Debug IS NULL

	SET @Debug = ISNULL(@Debug, 0)
	IF @Debug = 1 -- calculate offset of time between DBTrans <-> DBDIST
	BEGIN
		SELECT @time_offset = 0

		EXEC DBDIST.distribution.dbo.[DBA_ReIndex_TraceStatus] @tracer_id = 0, @isDelay = 0, @committime = @tracer_commit_time OUTPUT, @ServerName = 'GETTIME'
		SET @time_offset = @time_offset + DATEDIFF(ms, @tracer_commit_time, GETDATE())
		WAITFOR DELAY '00:00:01.000'

		EXEC DBDIST.distribution.dbo.[DBA_ReIndex_TraceStatus] @tracer_id = 0, @isDelay = 0, @committime = @tracer_commit_time OUTPUT, @ServerName = 'GETTIME'
		SET @time_offset = @time_offset + DATEDIFF(ms, @tracer_commit_time, GETDATE())
		WAITFOR DELAY '00:00:01.000'

		EXEC DBDIST.distribution.dbo.[DBA_ReIndex_TraceStatus] @tracer_id = 0, @isDelay = 0, @committime = @tracer_commit_time OUTPUT, @ServerName = 'GETTIME'
		SET @time_offset = @time_offset + DATEDIFF(ms, @tracer_commit_time, GETDATE())

		SET @time_offset = (@time_offset / 3)
	END

	/*	
		DECLARE @waitfor_command NVARCHAR(100)

		SET @DelayFor = CASE 
			WHEN @DelayFor >= 3600 THEN 3599
			WHEN @DelayFor <  20 THEN 20 
			ELSE @DelayFor
			END
	
		SET @waitfor_command = 'WAITFOR DELAY ''000:' + CAST( (@DelayFor / 60) AS NVARCHAR(10) ) + ':' + CAST( (@DelayFor % 60) AS NVARCHAR(10) ) + '.000'''
	*/

	DECLARE @publication AS sysname;
	DECLARE @tokenID AS int;
	DECLARE @isDelay bit

	/*
	IF @publication IS NOT NULL
	BEGIN
		EXEC sys.sp_posttracertoken @publication = @publication, @tracer_token_id = @tokenID_out OUTPUT;
		RETURN
	END
	*/
	SET @publication = CASE @@SERVERNAME
		WHEN N'DBTRANS' THEN N'DBTrans_Bet'
		WHEN N'DB206'	THEN N'DBTrans_Bet'
		WHEN N'DB06'    THEN N'DB06_Bet_n_ExecRep'
		END

	-- try Stop it, if job already run
	EXEC msdb.dbo.sp_start_job @job_name = N'DBA_Reorg_JobControl',@step_name = N'Stop'
	WAITFOR DELAY '00:00:06.000'

	UPDATE bodb02.dbo.SystemSettings
		SET VValue = 0 
		WHERE VName = N'ReIndex_spid'
		
	-- Disable ReCompile job, to prevent conflict with ReOrganize
	IF @@SERVERNAME IN ('DBTRANS', 'DB206') EXEC msdb.dbo.sp_update_job @job_name = N'DBTRANS : recompile all' , @enabled = 0	

	SET @Tracer_Time_Taken = 99
	WHILE(  EXISTS (SELECT 1 FROM MonDB.dbo.DBA_ReIndex_Record WITH (NOLOCK) WHERE id_db = @id_db )  ) -- Keep loop until finished all Task
	BEGIN
		-------------------------------------------------
		-- PRE-CHECK : Delay must less than 15 seconds --
		-------------------------------------------------
		-- note : next loop will not check, unless earlier loop exit with @Tracer_Time_Taken > 15
		--
		SELECT @IsProcessOneRunning = dbo.[f_CheckJobRunning]('DBA_Reorg_ProcessOne')

		SET @CheckCount = 0
		WHILE (@Tracer_Time_Taken > @min_replication_delay) -- wait until Replication Delay less than 15 seconds, before continue
		BEGIN
			IF @IsProcessOneRunning = 1 -- ReIndex still running, so skip 'no more delay' check
				BREAK --WHILE (@Tracer_Time_Taken > @min_replication_delay)

			SELECT @isDelay = 1, @Token_Insert_Time = SYSDATETIME(), @tracer_commit_time = NULL
			-- check replication delay.
			IF @@SERVERNAME IN ('DBTRANS', 'DB206')
			BEGIN
				-- Insert a new tracer token in the publication database.
				--EXEC dbo.DBA_ReIndex_Terminator_Joe_Test @publication = @publication, @tokenID_out = @tokenID OUTPUT;
				--for calling on Subscriber, will need to create SP on publisher server for both post & delete tracer
				EXEC sys.sp_posttracertoken @publication = @publication, @tracer_token_id = @tokenID OUTPUT;
			
				WHILE(@isDelay=1)
				BEGIN
					WAITFOR DELAY '00:00:03.000' -- wait 05 seconds
					-- call DBDIST.distribution SP
					-- Joe :: if got error that SP doesn't exists, code to create SP TraceStatus is right down below
					-- send @@SERVERNAME, if check as Subscriber, if run this ReIndex on server other than DBTRANS
					-- this will check if replication to this server was delay, which might  cause by index REORGANIZE
					exec DBDIST.distribution.dbo.DBA_ReIndex_TraceStatus @tracer_id=@tokenID, @isDelay=@isDelay OUTPUT, @committime = @tracer_commit_time OUTPUT --, @ServerName = @@SERVERNAME
				END
			END
			SELECT @Tracer_Time_Taken = DATEDIFF(second, @Token_Insert_Time, DATEADD(ms, @time_offset, @tracer_commit_time))

			IF DATEDIFF(ms, @Token_Insert_Time, DATEADD(ms, @time_offset, @tracer_commit_time)) > @Max_Tracer_Time
				SET @Max_Tracer_Time = DATEDIFF(ms, @Token_Insert_Time, DATEADD(ms, @time_offset, @tracer_commit_time))

			-- remove this Used tracer token, so TracerHisoty in Replication monitor not flush with it.
			EXEC sys.sp_deletetracertokenhistory @publication = @publication, @tracer_id = @tokenID

			IF @Tracer_Time_Taken > 60  -- if delay is over 60 seconds, delay XX seconds before start next Tracer Insert
				WAITFOR DELAY '00:00:15.000'

			-- perform check for 3 times, before confirmed as no delay and EXISTS
			IF @Tracer_Time_Taken > @min_replication_delay
				SELECT @CheckCount = 0
			ELSE
				SELECT @CheckCount = @CheckCount + 1, @Tracer_Time_Taken = @min_replication_delay + 1

			IF @CheckCount = 3
				BREAK --WHILE (@Tracer_Time_Taken > 5)
		END

		----------------------
		-- Start JobControl --
		----------------------
		SELECT @ReIndex_spid = VValue FROM bodb02.dbo.SystemSettings WITH (NOLOCK) WHERE VName = N'ReIndex_spid'
		SELECT @RunSince     = CONVERT(datetime, VValue, 120) FROM bodb02.dbo.SystemSettings WITH (NOLOCK) WHERE VName = N'ReIndex_RunSince'

		--IF @ReIndex_spid <= 0     -- not have job running? alright, try start it.
		IF @IsProcessOneRunning = 0 -- not have job running? alright, try start it.
		BEGIN
			SET @ReIndex_spid = -1
			SET @RunSince     = CURRENT_TIMESTAMP
			-- Marker that Job already call for start
			-- so, can try stop in it next loop, in case job failed to stop earlier.
			UPDATE bodb02.dbo.SystemSettings 
				SET VValue = -1 
				WHERE VName = N'ReIndex_spid'
		
			EXEC msdb.dbo.sp_start_job @job_name = N'DBA_Reorg_JobControl', @step_name = N'Start'
			--WAITFOR DELAY '00:00:06.000'
		END

		------------------------
		-- Terminator Handler --
		------------------------
		SET @LastStatusUpdate = CURRENT_TIMESTAMP
		SET @NotContinue = 0
		WHILE (1=1)
		BEGIN
			WHILE (@ReIndex_spid <= 0) -- wait for ProcessOne reported for duty. (by update VValue from -1 to Positive Number)
			BEGIN
				SELECT @ReIndex_spid = VValue FROM bodb02.dbo.SystemSettings WITH (NOLOCK) WHERE VName = N'ReIndex_spid'
				SELECT @IsProcessOneRunning = dbo.[f_CheckJobRunning]('DBA_Reorg_ProcessOne')

				IF ((@ReIndex_spid = -2) OR 
					(DATEDIFF(second, @LastStatusUpdate, CURRENT_TIMESTAMP) > 60) AND @IsProcessOneRunning = 0)
				BEGIN
					-- if spid = -2 :: job is done !!
					-- if time exceed 60 seconds, something wrong.
					SET @NotContinue =  1
				
					if @ReIndex_spid <> -2
					BEGIN -- stop job again for safety
						EXEC msdb.dbo.sp_start_job @job_name = N'DBA_Reorg_JobControl',@step_name = N'Stop'
						WAITFOR DELAY '00:00:06.000'
					END
					ELSE
						WAITFOR DELAY '00:00:03.000'

					-- reset value
					UPDATE bodb02.dbo.SystemSettings
						SET VValue = 0 
						WHERE VName = N'ReIndex_spid'

					BREAK --(@ReIndex_spid <= 0)
				END

				--WAITFOR DELAY '00:00:01.00'
			END --WHILE (@ReIndex_spid <= 0)

			IF (@NotContinue = 1)
				BREAK --WHILE (1=1)

			-- retrieve info of current running task
			SELECT @rn = VValue FROM bodb02.dbo.SystemSettings WITH (NOLOCK) WHERE VName = 'ReIndex_rn'
			IF  @rn <> @rn_current
			BEGIN
				SELECT
					@id_db = id_db, @id_table = id_table, @id_index = id_index, 
					@name_table = name_table, @name_index = name_index,
					@IsBettransCIX = CASE WHEN name_table = 'bettrans' AND index_type = 'C' THEN 1 ELSE 0 END,
					@TargetThredhold = FragmentTarget, @page_count = page_count,
					@fragment = Fragment, @fragmentInfo = CONVERT(varchar, CAST(Fragment AS money), 1), --(Fragment,'00.00'),
					@time_trace = time_trace, @RunCounter=RunCounter
					FROM MonDB.dbo.DBA_ReIndex_Record WITH (NOLOCK) 
					WHERE rn = @rn

				IF @Debug = 1
				BEGIN
					IF @RunCounter > 1
						SELECT @fragmentInfo = LEFT(VValue,5)
							FROM bodb02.dbo.SystemSettings WITH (NOLOCK)
							WHERE VName = 'ReIndex_Fragment'

					SET @LogMessage = 'Terminator:START [' + @name_table + '].[' + @name_index + '] ( ' + CONVERT(varchar, CAST(@id_db AS int),1) + ' , ' + CONVERT(varchar, CAST(@id_table AS int),1) + ' , ' + CONVERT(varchar, CAST(@id_index AS int),1) + ' )'
						+ ' Previous Tracer Max Delay ' + CONVERT(varchar, CAST(@Max_Tracer_Time/1000.0 AS MONEY),1) + ' seconds'
						+ CASE WHEN @RunCounter = 1
						THEN ' Started Fragment ' + CONVERT(varchar, CAST(@fragment AS money), 1)--CONVERT(varchar, CAST(@fragment AS money),1)
						--+ CONVERT(varchar, CAST(@page_count AS int),1) + ' pages'
						ELSE ' Fragment Last Known = ' + @fragmentInfo END
				
					EXEC [MonDB].[dbo].[WriteLog_ReIndex]
						@time_trace = @time_trace,
						@record_rn = @rn,
						@RunCounter = @RunCounter,
						@doing = @LogMessage
				END

				SET @rn_current = @rn
				SET @Max_Tracer_Time   = 0
			END

			--------------------------------
			-- BEGIN : Tracer Delay Check --
			--------------------------------
			SET    @Tracer_Time_Taken = 0
			WHILE (@Tracer_Time_Taken <= @max_replication_delay) -- check for Replication Delay
			BEGIN
				SELECT @ReIndex_spid = VValue FROM bodb02.dbo.SystemSettings WITH (NOLOCK) WHERE VName = N'ReIndex_spid'
				IF (@ReIndex_spid = -2)
				BEGIN
					WAITFOR DELAY '00:00:02.000'
					BREAK --WHILE (@Tracer_Time_Taken <= max_replication_delay) :: value become -2 --> current index already done it task
				END
				IF (SELECT bodb02.dbo.f_CheckJobRunning('DBA_Reorg_ProcessOne')) = 0
				BEGIN
					SET @ReIndex_spid = -2 -- set value to help escape from loop

					WAITFOR DELAY '00:00:02.000'
					BREAK --WHILE (@Tracer_Time_Taken <= max_replication_delay) :: job no longer run, without status report, it might become DeadLock victim already
				END

				-- check replication delay.
				SELECT @isDelay = 1, @Token_Insert_Time = SYSDATETIME(), @tracer_commit_time = NULL
				EXEC sys.sp_posttracertoken @publication = @publication, @tracer_token_id = @tokenID OUTPUT; -- Insert a new tracer token in the publication database.
			
				WHILE(@isDelay=1)
				BEGIN
					WAITFOR DELAY '00:00:03.000' -- wait 05 seconds
					-- call DBDIST.distribution SP
					-- Joe :: if got error that SP doesn't exists, code to create SP TraceStatus is right down below
					exec DBDIST.distribution.dbo.DBA_ReIndex_TraceStatus @tracer_id=@tokenID, @isDelay=@isDelay OUTPUT, @committime = @tracer_commit_time OUTPUT --, @ServerName = @@SERVERNAME

					IF @isDelay = 1 AND DATEDIFF(second, @Token_Insert_Time,CURRENT_TIMESTAMP) > @max_replication_delay
					BEGIN
						SET @tracer_commit_time = DATEADD(ms, @time_offset, DATEADD(second, @max_replication_delay + 2, @Token_Insert_Time))
						BREAK --WHILE(@isDelay=1) :: ignore Tracer Status, as time already exceed target
					END

					IF @isDelay = 0 AND DATEDIFF(ms, @Token_Insert_Time, DATEADD(ms, @time_offset, @tracer_commit_time)) > @Max_Tracer_Time
						SET @Max_Tracer_Time = DATEDIFF(ms, @Token_Insert_Time, DATEADD(ms, @time_offset, @tracer_commit_time))
				END --WHILE(@isDelay=1)

				SELECT @Tracer_Time_Taken = DATEDIFF(second, @Token_Insert_Time, DATEADD(ms, @time_offset, @tracer_commit_time))

				-- remove this Used tracer token, so TracerHisoty in Replication monitor not flush with it.
				EXEC sys.sp_deletetracertokenhistory @publication = @publication, @tracer_id = @tokenID


				-- update and check Fragment movement, if not move at all, stop going further
				-- default at 5 minutes
				-- give extra time 1 minute for every 350000 pages, because more page need more time to look for data to re-arrange.
				IF  @Tracer_Time_Taken <= @max_replication_delay -- no need to check for Fragment Level if Repl. Delay
					AND DATEDIFF(second, @LastStatusUpdate, CURRENT_TIMESTAMP) >= 300 + (@page_count / 350000 * 60)
				BEGIN 
					-- check current Fragment level
					SET @TimeDebug = SYSDATETIME()
					SELECT @fragment = MAX(avg_fragmentation_in_percent)
						FROM sys.dm_db_index_physical_stats(@id_db, @id_table, @id_index, NULL, 'LIMITED') AS fi 
						--WHERE alloc_unit_type_desc = 'IN_ROW_DATA'
					
					IF @Debug = 1
					BEGIN
						SET @LogMessage = 'Terminator:STATUS Check-Fragment using ' + CONVERT(varchar, CAST(DATEDIFF(ms, @TimeDebug, CURRENT_TIMESTAMP)/1000.0 AS DECIMAL(9,3)),1) + ' seconds' 
							+ ' Fragment ' + CONVERT(varchar, CAST(@fragment AS money),1)
							+ ' (after run ' + CONVERT(varchar, CAST((DATEDIFF(second, @LastStatusUpdate, CURRENT_TIMESTAMP)/60.0) AS DECIMAL(9,2)),1) + '/' 
							+ CONVERT(varchar, CAST((DATEDIFF(second, @RunSince, CURRENT_TIMESTAMP)/60.0) AS DECIMAL(9,2)),1) + ' minutes)'
							+ ' Last Tracer ' + CONVERT(varchar, CAST(((DATEDIFF(millisecond, @Token_Insert_Time, ISNULL(DATEADD(ms, @time_offset, @tracer_commit_time), @TimeDebug))/1000.0)) AS DECIMAL(9,3)),1) + ' seconds (' 
							+ CONVERT(varchar, CAST(@tokenID AS int),1) + ')'
						
						EXEC [MonDB].[dbo].[WriteLog_ReIndex]
							@time_trace = @time_trace,
							@record_rn = @rn,
							@RunCounter = @RunCounter,
							@doing = @LogMessage
					END

					UPDATE bodb02.dbo.SystemSettings SET VValue = CONVERT(varchar, CAST(@fragment AS money),1)
						WHERE VName = 'ReIndex_Status'
					UPDATE bodb02.dbo.SystemSettings SET @fragmentInfo = VValue = CONVERT(varchar, CAST(@fragment AS money),1) + ' ,' + LEFT(VValue, 180)
						WHERE VName = 'ReIndex_Fragment'

					IF (LEN(@fragmentInfo) >= 40) AND @IsBettransCIX = 0 -- already more than 6 Rounds :: exclude Bettrans Clustered Index
					BEGIN
						SELECT
							@fragmentMax = MAX(CAST(val AS MONEY)),
							@fragmentMin = MIN(CAST(val AS MONEY))
							FROM bodb02.dbo.strSplit( @fragmentInfo ,',')
							WHERE rank <= 5

						-- value of last 5 rounds, not help Fragement change much
						IF @fragmentMax - @fragmentMin < 2.00 AND DATEDIFF(second, @RunSince, CURRENT_TIMESTAMP) > @TimeAllow
						BEGIN
							SET @NotContinue = 1

							IF @Debug = 1
							BEGIN
								SET @LogMessage = 'Terminator:STOP Fragment-Not-Improve after ' + CONVERT(varchar,cast(DATEDIFF(second, @RunSince, CURRENT_TIMESTAMP) as int),1) + ' seconds (Allow ' + CONVERT(varchar, CAST(@TimeAllow AS int),1) + ')'
									+ ' Fragment Last/Min/Max = ' + CONVERT(varchar, CAST(@fragment AS money),1) + '/' + CONVERT(varchar, CAST(@fragmentMin AS money),1) + '/' + CONVERT(varchar, CAST(@fragmentMax AS money),1) 
									+ ' Fragment Info = ' + @fragmentInfo
								
								EXEC [MonDB].[dbo].[WriteLog_ReIndex]
									@time_trace = @time_trace,
									@record_rn = @rn,
									@RunCounter = @RunCounter,
									@doing = @LogMessage
							END
						END
					END

					SET @LastStatusUpdate = CURRENT_TIMESTAMP
				END

				-- running exceed @TimeAllow and Fragment drop below Threshold
				-- stop active REORGANIZE process
				-- 20210712@Joe : add special case for table with page > 500000, not stop before check 3 times, since value of 2nd/3rd check seem often not inconsistent
				IF  @Tracer_Time_Taken <= @max_replication_delay
					AND DATEDIFF(second, @RunSince, CURRENT_TIMESTAMP) > @TimeAllow 
					AND @fragment < @TargetThredhold 
					AND	(@page_count <= 500000 OR (@page_count > 500000 AND LEN(@fragmentInfo) >= 26))
				BEGIN
					SET @NotContinue = 1

					IF @Debug = 1
					BEGIN
						SET @LogMessage = 'Terminator:STOP Fragment-Below-Target after ' + CONVERT(varchar, (DATEDIFF(second, @RunSince, CURRENT_TIMESTAMP)), 1) + ' seconds (Allow ' + CONVERT(varchar, @TimeAllow, 1) + ')'
							+ ' Fragment Last/Target = ' + CONVERT(varchar, CAST(@fragment AS money),1) + '/' + CONVERT(varchar, cast(@TargetThredhold as int),1)
							+ ' Fragment Info = ' + @fragmentInfo
						EXEC [MonDB].[dbo].[WriteLog_ReIndex]
							@time_trace = @time_trace,
							@record_rn = @rn,
							@RunCounter = @RunCounter,
							@doing = @LogMessage
					END
				END

				IF (@NotContinue = 1)
				BEGIN
					EXEC msdb.dbo.sp_start_job @job_name = N'DBA_Reorg_JobControl',@step_name = N'Stop'
					WAITFOR DELAY '00:00:06.000'

					-- to make it look like Job Done.
					SET @ReIndex_spid = -2

					-- reset value
					UPDATE bodb02.dbo.SystemSettings
						SET VValue = 0 
						WHERE VName = N'ReIndex_spid'
					
					BREAK --(@Tracer_Time_Taken <= max_replication_delay) :: exit for current WHILE loop
				END

				IF @Tracer_Time_Taken < 10 -- take a little rest before continue to work
					WAITFOR DELAY '00:00:05.000'

			END --WHILE (@Tracer_Time_Taken <= @max_replication_delay)
			------------------------------
			-- END : Tracer Delay Check --
			------------------------------

			-- why out from loop, is job done?
			IF @ReIndex_spid = -2
				BREAK --WHILE (1=1)
			
			IF @Tracer_Time_Taken > @max_replication_delay -- delay exceed target?
			BEGIN
				-- verify if job still run/not finish
				IF (SELECT VValue FROM bodb02.dbo.SystemSettings WITH (NOLOCK) WHERE VName = N'ReIndex_spid') = -2
					OR
				   (SELECT bodb02.dbo.f_CheckJobRunning('DBA_Reorg_ProcessOne')) = 0
					BREAK --WHILE (1=1)

				--IF DATEDIFF(SECOND, @RunSince, CURRENT_TIMESTAMP) > @MinRunTime -- is it run long enough yet?
				BEGIN
					-- give extra time for it to do the work before stop.
					IF @IsBettransCIX = 1 --AND @RunCounter = 9 -- last round for bettrans CIX, give more time than normal.
						WAITFOR DELAY '00:01:00.000'
					ELSE
						WAITFOR DELAY '00:00:30.000'

					EXEC msdb.dbo.sp_start_job @job_name = N'DBA_Reorg_JobControl',@step_name = N'Stop'
					WAITFOR DELAY '00:00:06.000'

					-- reset status before leaving.
					UPDATE bodb02.dbo.SystemSettings
					SET VValue = 0
					WHERE VName = N'ReIndex_spid'

					SET @rn_current = -1

					IF @Debug = 1
					BEGIN
						SET @LogMessage = 'Terminator:STOP Tracer-Delay-Exceed ' + CONVERT(varchar, @max_replication_delay, 1) + ' seconds after running for ' + CONVERT(varchar, DATEDIFF(second, @RunSince, CURRENT_TIMESTAMP),1) + ' seconds ' --(MinRunTime ' + CONVERT(varchar, @MinRunTime,1) + ')'
							--+ ' Last Tracer ' + CONVERT(varchar, cast((DATEDIFF(millisecond, @Token_Insert_Time, DATEADD(ms, @time_offset, @tracer_commit_time))/1000.0) as money),1) + ' seconds (' + CONVERT(varchar, @tokenID,1) + ')'
							+ ' Fragment Last Known = ' + @fragmentInfo --CONVERT(varchar, CAST(@fragment AS money),1)
						EXEC [MonDB].[dbo].[WriteLog_ReIndex]
							@time_trace = @time_trace,
							@record_rn = @rn,
							@RunCounter = @RunCounter,
							@doing = @LogMessage
					END

					BREAK --WHILE (1=1) :: since it's run long enough, and we already stop it, exit the loop to start over again.
				END
			END

			-- run out of process time?
			IF DATEDIFF(minute, @EndTime, CURRENT_TIMESTAMP) > 1
				BREAK --WHILE (1=1)

		END --WHILE (1=1)

		-- if running pass @EndTime, let current index be the last
		IF DATEDIFF(minute, @EndTime, CURRENT_TIMESTAMP) > 1
		BEGIN
			-- record info for this last task
			IF @@SERVERNAME IN ('DBTRANS')
			BEGIN
				SELECT @fragmentInfo = LEFT(VValue, 5)
					FROM bodb02.dbo.SystemSettings WITH (NOLOCK)
					WHERE VName = 'ReIndex_Fragment'

				INSERT INTO MonDB.dbo.[Mon_ReIndex_List] ([TableName],IndexName,[Type_desc],[Time_Start],[Time_End])
				SELECT name_table, name_index,
					CASE index_type WHEN 'C' THEN 'C' ELSE 'N' END + CAST(@RunCounter as varchar(20))
					+ ' ' + CONVERT(varchar, Fragment,1) + ' ' + @fragmentInfo
					+ ' ' + CONVERT(varchar, (DATEDIFF(minute,TimeStart, CURRENT_TIMESTAMP)),1),
					TimeStart, GETDATE()
				FROM MonDB.dbo.DBA_ReIndex_Record
				WHERE rn = @rn
			END
			
			-- clear all task
			DECLARE @delete_count INT
			DELETE FROM MonDB.dbo.DBA_ReIndex_Record WHERE id_db = @id_db --AND rn <> @rn
			SET @delete_count = @@ROWCOUNT

			IF @Debug = 1
			BEGIN
				SET @LogMessage = 'Terminator:ENDTIME MaxHour = ' + CONVERT(varchar, @MaxHour,1) + ' remove ' + CONVERT(varchar, @delete_count, 1) + ' task items'
				EXEC [MonDB].[dbo].[WriteLog_ReIndex]
					@time_trace = @time_trace,
					@record_rn = @rn,
					@RunCounter = @RunCounter,
					@doing = @LogMessage
			END

		END

	END --WHILE(  EXISTS (SELECT 1 FROM MonDB.dbo.DBA_ReIndex_Record WITH (NOLOCK))  )

	-- stop task again, to prevent conflict with UpdateStats, in case, by whatever reason, job still run
	--EXEC msdb.dbo.sp_start_job @job_name = N'DBA_Reorg_JobControl',@step_name = N'Stop'
	--WAITFOR DELAY '000:00:10.000'

	UPDATE bodb02.dbo.SystemSettings
		SET VValue = 0 
		WHERE VName = N'ReIndex_spid'

	IF @Debug = 1
	BEGIN
		SET @LogMessage = 'Terminator:START Update-Stats'
		EXEC [MonDB].[dbo].[WriteLog_ReIndex]
			@time_trace = @time_trace,
			@record_rn = @rn,
			@RunCounter = @RunCounter,
			@doing = @LogMessage
	END
	
	EXEC sp_updatestats
  --DBCC DROPCLEANBUFFERS	
  --ALTER DATABASE bodb02 SET AUTO_UPDATE_STATISTICS ON
  
  	-- Enable back ReCompile job
	IF @@SERVERNAME IN ('DBTRANS', 'DB206') EXEC msdb.dbo.sp_update_job @job_name = N'DBTRANS : recompile all' , @enabled = 1

	IF @Debug = 1
	BEGIN
		SET @LogMessage = 'Terminator:FINISHED'
		EXEC [MonDB].[dbo].[WriteLog_ReIndex]
			@time_trace = @time_trace,
			@record_rn = @rn,
			@RunCounter = @RunCounter,
			@doing = @LogMessage
	END

END
GO