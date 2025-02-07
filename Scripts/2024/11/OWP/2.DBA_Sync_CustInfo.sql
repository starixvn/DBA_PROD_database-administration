USE [bodb02]
GO
/****** Object:  StoredProcedure [dbo].[DBA_Sync_CustInfo]    Script Date: 11/11/2024 4:50:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBTP10C-bodb02" executers="" viewers="" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[DBA_Sync_CustInfo]
AS
/*
	Created by:	Evan
	Date:		20241111
	Database:	DBTP10C.bodb02
	Revisions:
		- 20240925@Evan: initial sp - [Redmine: #209152]
		
*/
BEGIN
	
	--declare temp table section
	CREATE TABLE #tmp_List_CustId (CustId INT PRIMARY KEY);
	CREATE TABLE #tmp_batch_IDs (CustId INT PRIMARY KEY)

	--declare section
	DECLARE @LastCustId INT = NULL,
		@LastUpdateTime DATETIME = NULL,
		@CurrentTime DATETIME
	DECLARE @batchSize INT = 1000;
	DECLARE @runningCustId INT = 0

	--get lastcustid from systemsettings
	SELECT 
		@LastCustId = CASE WHEN s.vname = 'LastOWPCustId' THEN CAST(VValue AS INT) ELSE @LastCustId END,
		@LastUpdateTime = CASE WHEN s.vname = 'LastOWPUpdateTime' THEN CAST(VValue AS DATETIME) ELSE @LastUpdateTime END
	FROM SystemSettings s WITH (NOLOCK)
	WHERE s.VName IN ('LastOWPCustId',	'LastOWPUpdateTime')

	IF (@LastCustId IS NULL OR @LastUpdateTime IS NULL)
	BEGIN
		RAISERROR ('Invalid settings. Please check!!!',	16,	1)
	END

	--get new list custid
	INSERT INTO #tmp_List_CustId (CustId)
	SELECT custid
	FROM bodb02.dbo.custinfo c WITH (NOLOCK)
	WHERE c.custid > @LastCustId
		AND c.roleid > 4

	--begin to insert new cust
	IF (@@ROWCOUNT > 0)
	BEGIN
		WHILE (1 = 1)
		BEGIN
			--truncate batch temp table
			TRUNCATE TABLE #tmp_batch_IDs

			--get ids need to delete
			DELETE TOP (@batchSize) t
				OUTPUT deleted.CustId INTO #tmp_batch_IDs(CustId)
			FROM #tmp_List_CustId t

			--break if no row to delete anymore
			IF @@ROWCOUNT = 0 BREAK;

			--delete existing custid of target table in temp table
			DELETE
			FROM #tmp_batch_IDs
			WHERE custid IN (
					SELECT custid
					FROM custInfo_OWP c WITH (NOLOCK)
					)

			--insert new cust
			INSERT INTO custInfo_OWP (
				username,
				custid,
				currency,
				roleid,
				srecommend,
				mrecommend,
				recommend,
				dangercust,
				autosuspend,
				reject,
				credit,
				closed,
				MatchLimit,
				VirtualMultiplier,
				Enabled,
				danger,
				danger2,
				danger3,
				DisableOutright,
				Abnormal,
				DoubleCommLosing,
				autosuspend2,
				DisableEsports,
				DisableSuperLive,
				LockUpd,
				BonusWalletFlag,
				CreditUpdatedDate,
				DangerLevel,
				CustomerClass,
				Danger4,
				Danger5,
				CCSoccer,
				CCBasketball,
				CCEsports,
				CCOtherSports,
				CCNonSports,
				autosuspend3,
				RepUpdateTime
				)
			SELECT username,
				custid,
				currency,
				roleid,
				srecommend,
				mrecommend,
				recommend,
				dangercust,
				autosuspend,
				reject,
				credit,
				closed,
				MatchLimit,
				VirtualMultiplier,
				Enabled,
				danger,
				danger2,
				danger3,
				DisableOutright,
				Abnormal,
				DoubleCommLosing,
				autosuspend2,
				DisableEsports,
				DisableSuperLive,
				LockUpd,
				BonusWalletFlag,
				CreditUpdatedDate,
				DangerLevel,
				CustomerClass,
				Danger4,
				Danger5,
				CCSoccer,
				CCBasketball,
				CCEsports,
				CCOtherSports,
				CCNonSports,
				autosuspend3,
				RepUpdateTime
			FROM bodb02.dbo.custinfo c WITH (NOLOCK)
			WHERE c.custid IN (
					SELECT custid
					FROM #tmp_batch_IDs
					)

			--get temporary max running custid
			SELECT @runningCustId = MAX(custid)
			FROM #tmp_batch_IDs
			 
			--update lastcustid
			UPDATE dbo.SystemSettings
			SET VValue = @runningCustId
			WHERE VName = 'LastOWPCustId'
		END
	END
	ELSE --print message info and continuous to update part
	BEGIN
		RAISERROR ('Info: NO new Cust to INSERT.', 0, 1) WITH NOWAIT;
	END

	--begin update phase
	SET @CurrentTime = CONVERT(VARCHAR(500),GETDATE(), 121);

	--truncate temp table
	TRUNCATE TABLE #tmp_List_CustId

	--get new list custid for update
	INSERT INTO #tmp_List_CustId (CustId)
	SELECT distinct c.CustId
	FROM bodb_CustHistory.dbo.CustInfo_History c WITH (NOLOCK)
	WHERE c.UpdateTime >= @LastUpdateTime
		AND c.UpdateTime <= @CurrentTime
		AND c.roleid > 4

	--begin to update new cust
	IF (@@ROWCOUNT > 0)
	BEGIN
		WHILE (1 = 1)
		BEGIN
			--truncate batch temp table
			TRUNCATE TABLE #tmp_batch_IDs

			--get ids need to delete
			DELETE TOP (@batchSize) t
				OUTPUT deleted.CustId INTO #tmp_batch_IDs(CustId)
			FROM #tmp_List_CustId t

			--break if no row to delete anymore
			IF @@ROWCOUNT = 0 BREAK;

			--select into new temp table
			SELECT username,
				custid,
				currency,
				roleid,
				srecommend,
				mrecommend,
				recommend,
				dangercust,
				autosuspend,
				reject,
				credit,
				closed,
				MatchLimit,
				VirtualMultiplier,
				Enabled,
				danger,
				danger2,
				danger3,
				DisableOutright,
				Abnormal,
				DoubleCommLosing,
				autosuspend2,
				DisableEsports,
				DisableSuperLive,
				LockUpd,
				BonusWalletFlag,
				CreditUpdatedDate,
				DangerLevel,
				CustomerClass,
				Danger4,
				Danger5,
				CCSoccer,
				CCBasketball,
				CCEsports,
				CCOtherSports,
				CCNonSports,
				autosuspend3,
				RepUpdateTime
			INTO #tmp_update
			FROM bodb02.dbo.custinfo c WITH (NOLOCK)
			WHERE c.custid IN (
					SELECT custid
					FROM #tmp_batch_IDs
					)

			--insert new cust
			UPDATE c
			SET c.username = u.username,
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
			FROM custInfo_OWP c WITH(ROWLOCK)
			INNER JOIN #tmp_update u WITH (NOLOCK) ON c.custid = u.custid

			--drop temp table
			DROP TABLE #tmp_update

			--update lastcustid
			UPDATE dbo.SystemSettings
			SET VValue = CONVERT(VARCHAR(500),GETDATE(), 121)
			WHERE VName = 'LastOWPUpdateTime'

		END

		----update lastcustid
		--UPDATE dbo.SystemSettings
		--SET VValue = CONVERT(VARCHAR(500),@CurrentTime, 121)
		--WHERE VName = 'LastOWPUpdateTime'
	END
	ELSE --print message info and exit at the end of SP
	BEGIN
		RAISERROR ('Info: NO new Cust to UPDATE.', 0, 1) WITH NOWAIT;
	END

	--update lastcustid
	UPDATE dbo.SystemSettings
	SET VValue = CONVERT(VARCHAR(500),@CurrentTime, 121)
	WHERE VName = 'LastOWPUpdateTime'

	--drop temp table
	DROP TABLE #tmp_batch_IDs

	DROP TABLE #tmp_List_CustId
END
GO