USE [bodb02]
GO
/*<info serverAlias="DBKLC1-bodb02" executers="" viewers="" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[DBA_Sync_CustInfo_OWP]
AS
/*
	Created by:	Evan
	Date:		20241111
	Database:	DBKLC1.bodb02
	Revisions:
		- 20241111@Evan: initial sp - [Redmine: #209152]
		
*/
BEGIN
	SET NOCOUNT ON

	--declare temp table section
	CREATE TABLE #tmp_List_CustId (CustId INT, tstamp BINARY(8));
	CREATE TABLE #tmp_batch_IDs (CustId INT PRIMARY KEY, tstamp BINARY(8))
	CREATE TABLE #custInfo_OWP
	(
				[username] [nvarchar](50)
				, [custid] [int]
				, [currency] [int]
				, [roleid] [tinyint]
				, [srecommend] [int]
				, [mrecommend] [int]
				, [recommend] [int]
				, [dangercust] [bit]
				, [autosuspend] [bit]
				, [reject] [bit]
				, [credit] [money]
				, [closed] [bit]
				, [MatchLimit] [smallmoney]
				, [VirtualMultiplier] [smallmoney]
				, [Enabled] [bit]
				, [danger] [tinyint]
				, [danger2] [tinyint]
				, [danger3] [tinyint]
				, [DisableOutright] [bit]
				, [Abnormal] [tinyint]
				, [DoubleCommLosing] [bit]
				, [autosuspend2] [bit]
				, [DisableEsports] [bit]
				, [DisableSuperLive] [bit]
				, [LockUpd] [bit]
				, [BonusWalletFlag] [bit]
				, [CreditUpdatedDate] [smalldatetime]
				, [DangerLevel] [int]
				, [CustomerClass] [smallint]
				, [Danger4] [tinyint]
				, [Danger5] [tinyint]
				, [CCSoccer] [smallint]
				, [CCBasketball] [smallint]
				, [CCEsports] [smallint]
				, [CCOtherSports] [smallint]
				, [CCNonSports] [smallint]
				, [autosuspend3] [bit]
				, [RepUpdateTime] [datetime2](7)
	)
	--declare section
	DECLARE @Last_tstamp_owp BINARY(8) = NULL
	DECLARE @batchSize INT = 1000;
	DECLARE @running_tstamp BIGINT = 0

	--get lastcustid from systemsettings
	SELECT 
		@Last_tstamp_owp = CAST(CAST(VValue AS BIGINT) AS BINARY(8))
	FROM SystemSettings s WITH (NOLOCK)
	WHERE s.VName IN ('tstamp_owp')

	IF (@Last_tstamp_owp IS NULL)
	BEGIN
		RAISERROR ('Invalid settings. Please check!!!',	16,	1)
	END

	--get new list custid
	INSERT INTO #tmp_List_CustId (CustId,tstamp)
	SELECT custid,tstamp
	FROM DBTP10C.bodb02.dbo.custinfo_OWP c WITH (NOLOCK)
	WHERE c.tstamp > @Last_tstamp_owp
	

	--begin to insert new cust
	IF (@@ROWCOUNT > 0)
	BEGIN
		CREATE CLUSTERED INDEX [cl__tstamp] ON #tmp_List_CustId ( tstamp );

		WHILE (1 = 1)
		BEGIN
			--truncate batch temp table
			TRUNCATE TABLE #tmp_batch_IDs
			TRUNCATE TABLE #custInfo_OWP

			--get ids need to delete
			DELETE TOP (@batchSize) t
				OUTPUT deleted.CustId, deleted.tstamp INTO #tmp_batch_IDs(CustId,tstamp)
			FROM #tmp_List_CustId t

			--break if no row to delete anymore
			IF @@ROWCOUNT = 0 BREAK;

			INSERT INTO #custInfo_OWP (username, custid, currency, roleid, srecommend, mrecommend, recommend, dangercust, autosuspend, reject, credit, closed, MatchLimit, VirtualMultiplier, Enabled, danger, danger2, danger3, DisableOutright, Abnormal, DoubleCommLosing, autosuspend2, DisableEsports, DisableSuperLive, LockUpd, BonusWalletFlag, CreditUpdatedDate, DangerLevel, CustomerClass, Danger4, Danger5, CCSoccer, CCBasketball, CCEsports, CCOtherSports, CCNonSports, autosuspend3, RepUpdateTime)
			SELECT c.username, c.custid, c.currency, c.roleid, c.srecommend, c.mrecommend, c.recommend, c.dangercust, c.autosuspend, c.reject, c.credit, c.closed, c.MatchLimit, c.VirtualMultiplier, c.Enabled, c.danger, c.danger2, c.danger3, c.DisableOutright, c.Abnormal, c.DoubleCommLosing, c.autosuspend2, c.DisableEsports, c.DisableSuperLive, c.LockUpd, c.BonusWalletFlag, c.CreditUpdatedDate, c.DangerLevel, c.CustomerClass, c.Danger4, c.Danger5, c.CCSoccer, c.CCBasketball, c.CCEsports, c.CCOtherSports, c.CCNonSports, c.autosuspend3, c.RepUpdateTime 
			FROM DBTP10C.bodb02.dbo.custinfo_OWP c WITH(NOLOCK) 
				INNER JOIN #tmp_batch_IDs tbi ON c.custid = tbi.CustId
			
			--MEGRE diff rows

			UPDATE c 
			SET  c.username = u.username,
					c.currency = u.currency,
					c.roleid = u.roleid,
					c.srecommend = u.srecommend,
					c.mrecommend = u.mrecommend,
					c.recommend = u.recommend,
					c.dangercust = u.dangercust,
					c.autosuspend = u.autosuspend,
					c.reject = u.reject,
					c.credit = u.credit,
					c.closed = u.closed,
					c.MatchLimit = u.MatchLimit,
					c.VirtualMultiplier = u.VirtualMultiplier,
					c.[Enabled] = u.[Enabled],
					c.danger = u.danger,
					c.danger2 = u.danger2,
					c.danger3 = u.danger3,
					c.DisableOutright = u.DisableOutright,
					c.Abnormal = u.Abnormal,
					c.DoubleCommLosing = u.DoubleCommLosing,
					c.autosuspend2 = u.autosuspend2,
					c.DisableEsports = u.DisableEsports,
					c.DisableSuperLive = u.DisableSuperLive,
					c.LockUpd = u.LockUpd,
					c.BonusWalletFlag = u.BonusWalletFlag,
					c.CreditUpdatedDate = u.CreditUpdatedDate,
					c.DangerLevel = u.DangerLevel,
					c.CustomerClass = u.CustomerClass,
					c.Danger4 = u.Danger4,
					c.Danger5 = u.Danger5,
					c.CCSoccer = u.CCSoccer,
					c.CCBasketball = u.CCBasketball,
					c.CCEsports = u.CCEsports,
					c.CCOtherSports = u.CCOtherSports,
					c.CCNonSports = u.CCNonSports,
					c.autosuspend3 = u.autosuspend3,
					c.RepUpdateTime = u.RepUpdateTime
			FROM DBOWP.bodb02.dbo.custInfo c WITH(ROWLOCK) INNER JOIN #custInfo_OWP u ON c.custid = u.custid
			 
			INSERT INTO DBOWP.bodb02.dbo.custInfo (username, custid, currency, roleid, srecommend, mrecommend, recommend, dangercust, autosuspend, reject, credit, closed, MatchLimit, VirtualMultiplier, Enabled, danger, danger2, danger3, DisableOutright, Abnormal, DoubleCommLosing, autosuspend2, DisableEsports, DisableSuperLive, LockUpd, BonusWalletFlag, CreditUpdatedDate, DangerLevel, CustomerClass, Danger4, Danger5, CCSoccer, CCBasketball, CCEsports, CCOtherSports, CCNonSports, autosuspend3, RepUpdateTime)
			SELECT c.username, c.custid, c.currency, c.roleid, c.srecommend, c.mrecommend, c.recommend, c.dangercust, c.autosuspend, c.reject, c.credit, c.closed, c.MatchLimit, c.VirtualMultiplier, c.Enabled, c.danger, c.danger2, c.danger3, c.DisableOutright, c.Abnormal, c.DoubleCommLosing, c.autosuspend2, c.DisableEsports, c.DisableSuperLive, c.LockUpd, c.BonusWalletFlag, c.CreditUpdatedDate, c.DangerLevel, c.CustomerClass, c.Danger4, c.Danger5, c.CCSoccer, c.CCBasketball, c.CCEsports, c.CCOtherSports, c.CCNonSports, c.autosuspend3, c.RepUpdateTime  
			FROM #custInfo_OWP c 
				LEFT JOIN DBOWP.bodb02.dbo.custInfo b WITH (NOLOCK) ON c.custid = b.custid
			WHERE b.custid IS NULL

			--get temporary max running custid
			SELECT @running_tstamp = MAX(tstamp)
			FROM #tmp_batch_IDs
			 
			--update lastcustid
			UPDATE dbo.SystemSettings
			SET VValue = @running_tstamp
			WHERE VName = 'tstamp_owp'

		END
	END
	ELSE --print message info and continuous to update part
	BEGIN
		RAISERROR ('Info: NO new Cust to INSERT.', 0, 1) WITH NOWAIT;
	END

	--truncate temp table
	TRUNCATE TABLE #tmp_List_CustId

	--drop temp table
	DROP TABLE #tmp_batch_IDs

	DROP TABLE #tmp_List_CustId
END
GO

INSERT INTO SystemSettings (VName, VValue)
VALUES ('tstamp_owp', 0)
GO
