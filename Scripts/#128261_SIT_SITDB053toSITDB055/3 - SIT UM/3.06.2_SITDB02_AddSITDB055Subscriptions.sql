/*
	Creator:	20200228@Billy
	Task:		Add SITDB055 subscriptions - [Redmine: #128261]
	Server:		SITDB02
*/

SET NOCOUNT ON;

--	BEGIN STEP 1:
--		Add subscriptions
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	bodb02;

-- DB02_event14 --
BEGIN;
	EXECUTE	sys.sp_addsubscription
				@publication = N'DB02_event14'
			,	@article = N'all'
			,	@subscriber = N'SITDB055'
			,	@destination_db = N'bodb02'
			,	@sync_type = N'replication support only'
			,	@subscription_type = N'Push'
			,	@update_mode = N'read only'
			,	@subscriber_type = 0
			;

	EXECUTE	sys.sp_addpushsubscription_agent
				@publication = N'DB02_event14'
			,	@subscriber = N'SITDB055'
			,	@subscriber_db = N'bodb02'
			,	@subscriber_security_mode = 1
			,	@job_login = NULL
			,	@job_password = NULL
			,	@frequency_type = 64
			,	@frequency_interval = 0
			,	@frequency_relative_interval = 0
			,	@frequency_recurrence_factor = 0
			,	@frequency_subday = 0
			,	@frequency_subday_interval = 0
			,	@active_start_time_of_day = 0
			,	@active_end_time_of_day = 235959
			,	@active_start_date = 20191211
			,	@active_end_date = 99991231
			,	@enabled_for_syncmgr = N'False'
			,	@dts_package_location = N'Distributor'
			;
END;

-- DB02_Odds_3rd --
BEGIN;
	EXECUTE	sys.sp_addsubscription
				@publication = N'DB02_Odds_3rd'
			,	@article = N'all'
			,	@subscriber = N'SITDB055'
			,	@destination_db = N'bodb02'
			,	@sync_type = N'replication support only'
			,	@subscription_type = N'Push'
			,	@update_mode = N'read only'
			,	@subscriber_type = 0
			;

	EXECUTE	sys.sp_addpushsubscription_agent
				@publication = N'DB02_Odds_3rd'
			,	@subscriber = N'SITDB055'
			,	@subscriber_db = N'bodb02'
			,	@subscriber_security_mode = 1
			,	@job_login = NULL
			,	@job_password = NULL
			,	@frequency_type = 64
			,	@frequency_interval = 0
			,	@frequency_relative_interval = 0
			,	@frequency_recurrence_factor = 0
			,	@frequency_subday = 0
			,	@frequency_subday_interval = 0
			,	@active_start_time_of_day = 0
			,	@active_end_time_of_day = 235959
			,	@active_start_date = 20191211
			,	@active_end_date = 99991231
			,	@enabled_for_syncmgr = N'False'
			,	@dts_package_location = N'Distributor'
			;
END;

-- DB02_Odds_Info --
BEGIN;
	EXECUTE	sys.sp_addsubscription
				@publication = N'DB02_Odds_Info'
			,	@article = N'all'
			,	@subscriber = N'SITDB055'
			,	@destination_db = N'bodb02'
			,	@sync_type = N'replication support only'
			,	@subscription_type = N'Push'
			,	@update_mode = N'read only'
			,	@subscriber_type = 0
			;

	EXECUTE	sys.sp_addpushsubscription_agent
				@publication = N'DB02_Odds_Info'
			,	@subscriber = N'SITDB055'
			,	@subscriber_db = N'bodb02'
			,	@subscriber_security_mode = 1
			,	@job_login = NULL
			,	@job_password = NULL
			,	@frequency_type = 64
			,	@frequency_interval = 0
			,	@frequency_relative_interval = 0
			,	@frequency_recurrence_factor = 0
			,	@frequency_subday = 0
			,	@frequency_subday_interval = 0
			,	@active_start_time_of_day = 0
			,	@active_end_time_of_day = 235959
			,	@active_start_date = 20191211
			,	@active_end_date = 99991231
			,	@enabled_for_syncmgr = N'False'
			,	@dts_package_location = N'Distributor'
			;
END;

-- DB02_Odds_Odds --
BEGIN;
	EXECUTE	sys.sp_addsubscription
				@publication = N'DB02_Odds_Odds'
			,	@article = N'all'
			,	@subscriber = N'SITDB055'
			,	@destination_db = N'bodb02'
			,	@sync_type = N'replication support only'
			,	@subscription_type = N'Push'
			,	@update_mode = N'read only'
			,	@subscriber_type = 0
			;

	EXECUTE	sys.sp_addpushsubscription_agent
				@publication = N'DB02_Odds_Odds'
			,	@subscriber = N'SITDB055'
			,	@subscriber_db = N'bodb02'
			,	@subscriber_security_mode = 1
			,	@job_login = NULL
			,	@job_password = NULL
			,	@frequency_type = 64
			,	@frequency_interval = 0
			,	@frequency_relative_interval = 0
			,	@frequency_recurrence_factor = 0
			,	@frequency_subday = 0
			,	@frequency_subday_interval = 0
			,	@active_start_time_of_day = 0
			,	@active_end_time_of_day = 235959
			,	@active_start_date = 20191211
			,	@active_end_date = 99991231
			,	@enabled_for_syncmgr = N'False'
			,	@dts_package_location = N'Distributor'
			;
END;
GO
/*<info serverAlias="SITDB02" executers="" viewers="" isFunction="0" isNested="0"></info>*/