/*
	Creator:	20200228@Billy
	Task:		Add SITDB055 subscriptions - [Redmine: #128261]
	Server:		SITDBCUST
*/

SET NOCOUNT ON;

--	BEGIN STEP 1:
--		Add subscriptions
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	CustDB;

-- CustDB_Customer_Info --
BEGIN;
	EXECUTE	sys.sp_addsubscription
				@publication = N'CustDB_Customer_Info'
			,	@article = N'all'
			,	@subscriber = N'SITDB055'
			,	@destination_db = N'CustDB'
			,	@sync_type = N'replication support only'
			,	@subscription_type = N'Push'
			,	@update_mode = N'read only'
			,	@subscriber_type = 0
			;

	EXECUTE	sys.sp_addpushsubscription_agent
				@publication = N'CustDB_Customer_Info'
			,	@subscriber = N'SITDB055'
			,	@subscriber_db = N'CustDB'
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

-- CustDB_ExchangeDaily --
BEGIN;
	EXECUTE	sys.sp_addsubscription
				@publication = N'CustDB_ExchangeDaily'
			,	@article = N'all'
			,	@subscriber = N'SITDB055'
			,	@destination_db = N'CustDB'
			,	@sync_type = N'replication support only'
			,	@subscription_type = N'Push'
			,	@update_mode = N'read only'
			,	@subscriber_type = 0
			;

	EXECUTE	sys.sp_addpushsubscription_agent
				@publication = N'CustDB_ExchangeDaily'
			,	@subscriber = N'SITDB055'
			,	@subscriber_db = N'CustDB'
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

-- CustDB_ExecRepAcc_Cust --
BEGIN;
	EXECUTE	sys.sp_addsubscription
				@publication = N'CustDB_ExecRepAcc_Cust'
			,	@article = N'all'
			,	@subscriber = N'SITDB055'
			,	@destination_db = N'CustDB'
			,	@sync_type = N'replication support only'
			,	@subscription_type = N'Push'
			,	@update_mode = N'read only'
			,	@subscriber_type = 0
			;

	EXECUTE	sys.sp_addpushsubscription_agent
				@publication = N'CustDB_ExecRepAcc_Cust'
			,	@subscriber = N'SITDB055'
			,	@subscriber_db = N'CustDB'
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

-- CustDB_Login_Exchange --
BEGIN;
	EXECUTE	sys.sp_addsubscription
				@publication = N'CustDB_Login_Exchange'
			,	@article = N'all'
			,	@subscriber = N'SITDB055'
			,	@destination_db = N'CustDB'
			,	@sync_type = N'replication support only'
			,	@subscription_type = N'Push'
			,	@update_mode = N'read only'
			,	@subscriber_type = 0
			;

	EXECUTE	sys.sp_addpushsubscription_agent
				@publication = N'CustDB_Login_Exchange'
			,	@subscriber = N'SITDB055'
			,	@subscriber_db = N'CustDB'
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

USE	bodb_Licensee;

-- CustDB_bodb_Licensee_BA --
BEGIN;
	EXECUTE	sys.sp_addsubscription
				@publication = N'CustDB_bodb_Licensee_BA'
			,	@article = N'all'
			,	@subscriber = N'SITDB055'
			,	@destination_db = N'bodb_Licensee'
			,	@sync_type = N'replication support only'
			,	@subscription_type = N'Push'
			,	@update_mode = N'read only'
			,	@subscriber_type = 0
			;

	EXECUTE	sys.sp_addpushsubscription_agent
				@publication = N'CustDB_bodb_Licensee_BA'
			,	@subscriber = N'SITDB055'
			,	@subscriber_db = N'bodb_Licensee'
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
/*<info serverAlias="SITDBCUST" executers="" viewers="" isFunction="0" isNested="0"></info>*/