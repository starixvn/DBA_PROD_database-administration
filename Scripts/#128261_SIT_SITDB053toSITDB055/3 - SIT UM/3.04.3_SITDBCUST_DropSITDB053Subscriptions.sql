/*
	Creator:	20200227@Billy
	Task:		Drop SITDB053 Subcriptions - [Redmine: #128261]
	Server:		SITDBCUST
*/

SET NOCOUNT ON;

--	BEGIN STEP 1:
--		Drop SITDB053 subscriptions in CustDB
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	CustDB;

EXECUTE	sys.sp_dropsubscription
			@publication = N'CustDB_Customer_Info'
		,	@article = N'all'
		,	@subscriber = N'SITDB053'
		;

EXECUTE	sys.sp_dropsubscription
			@publication = N'CustDB_ExchangeDaily'
		,	@article = N'all'
		,	@subscriber = N'SITDB053'
		;

EXECUTE	sys.sp_dropsubscription
			@publication = N'CustDB_ExecRepAcc_Cust'
		,	@article = N'all'
		,	@subscriber = N'SITDB053'
		;

EXECUTE	sys.sp_dropsubscription
			@publication = N'CustDB_Login_Exchange'
		,	@article = N'all'
		,	@subscriber = N'SITDB053'
		;


--	BEGIN STEP 2:
--		Drop SITDB053 subscriptions in bodb_Licensee
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	bodb_Licensee;

EXECUTE	sys.sp_dropsubscription
			@publication = N'bodb_Licensee'
		,	@article = N'all'
		,	@subscriber = N'SITDB053'
		;

EXECUTE	sys.sp_dropsubscription
			@publication = N'bodb_Licensee_BA'
		,	@article = N'all'
		,	@subscriber = N'SITDB053'
		;
GO
/*<info serverAlias="SITDBCUST-master" executers="" viewers="" isFunction="0" isNested="0"></info>*/