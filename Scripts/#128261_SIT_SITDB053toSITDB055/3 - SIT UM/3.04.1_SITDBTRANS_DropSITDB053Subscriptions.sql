/*
	Creator:	20200227@Billy
	Task:		Drop SITDB053 Subcriptions - [Redmine: #128261]
	Server:		SITDBTRANS
*/

SET NOCOUNT ON;

--	BEGIN STEP 1:
--		Drop SITDB053 subscriptions in bodb02
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	bodb02;

EXECUTE	sys.sp_dropsubscription
			@publication = N'DBTrans_Bet'
		,	@article = N'all'
		,	@subscriber = N'SITDB053'
		;

EXECUTE	sys.sp_dropsubscription
			@publication = N'DBTrans_Bet14'
		,	@article = N'all'
		,	@subscriber = N'SITDB053'
		;

EXECUTE	sys.sp_dropsubscription
			@publication = N'DBTrans_ExecRep'
		,	@article = N'all'
		,	@subscriber = N'SITDB053'
		;

EXECUTE	sys.sp_dropsubscription
			@publication = N'DBTrans_ExecRep_UAT'
		,	@article = N'all'
		,	@subscriber = N'SITDB053'
		;

EXECUTE	sys.sp_dropsubscription
			@publication = N'DBTrans_ExecRepAcc'
		,	@article = N'all'
		,	@subscriber = N'SITDB053'
		;

EXECUTE	sys.sp_dropsubscription
			@publication = N'DBTrans_Vendor'
		,	@article = N'all'
		,	@subscriber = N'SITDB053'
		;

EXECUTE	sys.sp_dropsubscription
			@publication = N'DBTrans_Vendor14'
		,	@article = N'all'
		,	@subscriber = N'SITDB053'
		;
GO


--	BEGIN STEP 2:
--		Drop SITDB053 subscriptions in MonDB
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	MonDB;

EXECUTE	sys.sp_dropsubscription
			@publication = N'Joy_byDeleteTicket'
		,	@article = N'all'
		,	@subscriber = N'SITDB053'
		;
GO
/*<info serverAlias="SITDBTRANS-master" executers="" viewers="" isFunction="0" isNested="0"></info>*/