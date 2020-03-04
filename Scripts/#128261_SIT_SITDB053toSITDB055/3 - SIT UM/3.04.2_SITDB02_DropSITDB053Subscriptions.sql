/*
	Creator:	20200227@Billy
	Task:		Drop SITDB053 Subcriptions - [Redmine: #128261]
	Server:		SITDB02
*/

SET NOCOUNT ON;

--	BEGIN STEP 1:
--		Drop SITDB053 subscriptions in bodb02
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	bodb02;

EXECUTE	sys.sp_dropsubscription
			@publication = N'DB02_Dot'
		,	@article = N'all'
		,	@subscriber = N'SITDB053'
		;

EXECUTE	sys.sp_dropsubscription
			@publication = N'DB02_event14'
		,	@article = N'all'
		,	@subscriber = N'SITDB053'
		;

EXECUTE	sys.sp_dropsubscription
			@publication = N'DB02_Odds_3rd'
		,	@article = N'all'
		,	@subscriber = N'SITDB053'
		;

EXECUTE	sys.sp_dropsubscription
			@publication = N'DB02_Odds_Info'
		,	@article = N'all'
		,	@subscriber = N'SITDB053'
		;

EXECUTE	sys.sp_dropsubscription
			@publication = N'DB02_Odds_Odds'
		,	@article = N'all'
		,	@subscriber = N'SITDB053'
		;
GO
/*<info serverAlias="SITDB02-master" executers="" viewers="" isFunction="0" isNested="0"></info>*/