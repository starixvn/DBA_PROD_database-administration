/*
	Creator:	20200228@Billy
	Task:		Add SITDB055 subscriptions - [Redmine: #128261]
	Server:		SITDBTRANS
*/

SET NOCOUNT ON;

--	BEGIN STEP 1:
--		Add subscriptions
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	bodb02;

-- DBTrans_Bet --
BEGIN;
	EXECUTE	sys.sp_addsubscription
				@publication = N'DBTrans_Bet'
			,	@article = N'all'
			,	@subscriber = N'SITDB055'
			,	@destination_db = N'bodb02'
			,	@sync_type = N'replication support only'
			,	@subscription_type = N'Push'
			,	@update_mode = N'read only'
			,	@subscriber_type = 0
			;

	EXECUTE	sys.sp_addpushsubscription_agent
				@publication = N'DBTrans_Bet'
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

-- DBTrans_Bet14 --
BEGIN;
	EXECUTE	sys.sp_addsubscription
				@publication = N'DBTrans_Bet14'
			,	@article = N'all'
			,	@subscriber = N'SITDB055'
			,	@destination_db = N'bodb02'
			,	@sync_type = N'replication support only'
			,	@subscription_type = N'Push'
			,	@update_mode = N'read only'
			,	@subscriber_type = 0
			;

	EXECUTE	sys.sp_addpushsubscription_agent
				@publication = N'DBTrans_Bet14'
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

-- DBTrans_ExecRep --
BEGIN;
	EXECUTE	sys.sp_addsubscription
				@publication = N'DBTrans_ExecRep'
			,	@article = N'all'
			,	@subscriber = N'SITDB055'
			,	@destination_db = N'bodb02'
			,	@sync_type = N'replication support only'
			,	@subscription_type = N'Push'
			,	@update_mode = N'read only'
			,	@subscriber_type = 0
			;

	EXECUTE	sys.sp_addpushsubscription_agent
				@publication = N'DBTrans_ExecRep'
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

-- DBTrans_ExecRep_UAT --
BEGIN;
	EXECUTE	sys.sp_addsubscription
				@publication = N'DBTrans_ExecRep_UAT'
			,	@article = N'all'
			,	@subscriber = N'SITDB055'
			,	@destination_db = N'bodb02'
			,	@sync_type = N'replication support only'
			,	@subscription_type = N'Push'
			,	@update_mode = N'read only'
			,	@subscriber_type = 0
			;

	EXECUTE	sys.sp_addpushsubscription_agent
				@publication = N'DBTrans_ExecRep_UAT'
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

-- DBTrans_ExecRepAcc --
BEGIN;
	EXECUTE	sys.sp_addsubscription
				@publication = N'DBTrans_ExecRepAcc'
			,	@article = N'all'
			,	@subscriber = N'SITDB055'
			,	@destination_db = N'bodb02'
			,	@sync_type = N'replication support only'
			,	@subscription_type = N'Push'
			,	@update_mode = N'read only'
			,	@subscriber_type = 0
			;

	EXECUTE	sys.sp_addpushsubscription_agent
				@publication = N'DBTrans_ExecRepAcc'
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

-- DBTrans_Vendor --
BEGIN;
	EXECUTE	sys.sp_addsubscription
				@publication = N'DBTrans_Vendor'
			,	@article = N'all'
			,	@subscriber = N'SITDB055'
			,	@destination_db = N'bodb02'
			,	@sync_type = N'replication support only'
			,	@subscription_type = N'Push'
			,	@update_mode = N'read only'
			,	@subscriber_type = 0
			;

	EXECUTE	sys.sp_addpushsubscription_agent
				@publication = N'DBTrans_Vendor'
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

USE	MonDB;

-- Joy_byDeleteTicket --
BEGIN;
	EXECUTE	sys.sp_addsubscription
				@publication = N'Joy_byDeleteTicket'
			,	@article = N'all'
			,	@subscriber = N'SITDB055'
			,	@destination_db = N'MonDB'
			,	@sync_type = N'replication support only'
			,	@subscription_type = N'Push'
			,	@update_mode = N'read only'
			,	@subscriber_type = 0
			;

	EXECUTE	sys.sp_addpushsubscription_agent
				@publication = N'Joy_byDeleteTicket'
			,	@subscriber = N'SITDB055'
			,	@subscriber_db = N'MonDB'
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
/*<info serverAlias="SITDBTRANS" executers="" viewers="" isFunction="0" isNested="0"></info>*/