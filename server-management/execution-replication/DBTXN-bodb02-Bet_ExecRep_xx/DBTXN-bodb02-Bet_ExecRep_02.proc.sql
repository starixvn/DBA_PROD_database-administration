SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE [dbo].[Bet_ExecRep_02]
	@target varchar(10),
	@creator int,
	@matchid varchar(1000),
	@btList varchar(4000),
	@RejectTime datetime,

	@minTransID bigint OUTPUT,
	@maxTransID bigint OUTPUT,
	@ticketCount int = 0 OUTPUT,

	@minTransIDm bigint OUTPUT,
	@maxTransIDm bigint OUTPUT,
	@ticketCountm int = 0 OUTPUT,

	@RejectedMatch varchar(2000) = '' OUTPUT,
	@minTransIDs varchar(2000) = '' OUTPUT,
	@maxTransIDs varchar(2000) = '' OUTPUT,
	@ticketCounts varchar(2000) = '' OUTPUT,
	@minTransIDms varchar(2000) = '' OUTPUT,
	@maxTransIDms varchar(2000) = '' OUTPUT,
	@ticketCountms varchar(2000) = '' OUTPUT,

	@RejectedOdds varchar(2000) = '' OUTPUT,
	@HomeTotals varchar(2000) = '' OUTPUT,
	@AwayTotals varchar(2000) = '' OUTPUT
AS
SET NOCOUNT ON

IF @matchid IS NULL RETURN

/*
accept bet using execrep
should call from Dot_Admin_BettransUpd_LiveAccept
20101103@Joe : new option with @target parameter
20110530@Joe : add AcceptBet log for DB04/042
20110817@Joe : add multiple reject and include live parlay(update bettransm)
20111206@Vivi: update bettransm.winlostdate=bettransm.matchdate
20120503@Joe/Vivi: BalancePendingCredit
20130826@EdwardLee : add parlay ticket count by matchid
20140227@Lukas: push a command to LASDB for accept/reject their tickets
20150504@Martin:expand @btList length to receive more bettype list,ex info site odds.
20150910@martin(TransDB):use Dot_BalancePendingCreditIns to replace insert BalancePendingCredit table.
20160613@Cooper(TransDB):add statusID = 0 in update bettransm table to avoid return twice balance 
20170807@Martin:parlay betid to bigint and output parlay max/min betid
20170816@Martin:for Licensee Bonus System,reject ticket return bonus/cash
20180226@Martin:ready to go-live for lic bonus  porject
20180430@Martin:extend match list to varchar(1000)
*/

DECLARE @RejectedTicket TABLE (
		custid int, 
		matchid int, 
		transid bigint, 
		oddsid int,
		betteam varchar(10), 
		stake money, 
		actual_stake money, 
		odds money,
		tpositiontaking money, 
		virtualrate float,
		BonusID int,
		WalletType tinyint)

DECLARE @Refnos TABLE (refno bigint, custid int, matchid int, transid bigint)
DECLARE @pTransID TABLE (transid bigint PRIMARY KEY)

DECLARE @RejectedTicketParlay TABLE (custid int, actual_stake money)
DECLARE @TVP_BalanceList TVP_BalanceList
DECLARE @TVP_BalanceListParlay TVP_BalanceList
DECLARE @TVP_BalanceWalletChange TVP_BalanceWalletChange

IF @@SERVERNAME in ('DBTRANS','SITDBTRANS','TDBTRANS') AND @target = 'DBTRANS'
BEGIN

	SELECT
		@minTransID = 9223372036854775807, @maxTransID = 0, @ticketCount = 0,
		@minTransIDm= 2147483647, @maxTransIDm= 0, @ticketCountm= 0

	UPDATE dbo.bettrans with (rowlock, updlock)
	SET status = 'Reject', statusID = 101, checktime=@RejectTime
		,creator = @creator, ruben = 1, winlost = actual_stake --statuswinlost=5,
		,@minTransID=CASE WHEN [transid]<@minTransID THEN [transid] ELSE @minTransID END
		,@maxTransID=CASE WHEN [transid]>@maxTransID THEN [transid] ELSE @maxTransID END
		,@ticketCount=@ticketCount+1
	OUTPUT
		DELETED.custid, DELETED.matchid, DELETED.transid, DELETED.oddsid,
		DELETED.betteam, DELETED.stake, DELETED.actual_stake, DELETED.odds,
		DELETED.tpositiontaking, DELETED.virtualrate, DELETED.BonusID,
		DELETED.WalletType INTO @RejectedTicket
	FROM dbo.bettrans with (index=CIX_matchid_bettype)
	WHERE matchid   IN ( SELECT val FROM dbo.strSplit(@matchid, ',') )
		AND bettype IN ( SELECT val FROM dbo.strSplit(@btList,  ',') )
		AND statusID = 1	-- waiting
		AND transid > 3200000000

	-- BalancePendingCredit
	--INSERT INTO dbo.BalancePendingCredit (custid, balance)
	--SELECT custid, SUM(actual_stake)
	--FROM @RejectedTicket
	--GROUP BY custid

	--return licensee bonus balance
	INSERT INTO @TVP_BalanceWalletChange(matchid,custid,balance,balanceType,walletType,bonusId)
	SELECT matchid,custid,actual_stake,0,WalletType,BonusID
	FROM @RejectedTicket
	WHERE WalletType=1--bonus ticket
	
	IF @@ROWCOUNT > 0
		EXEC Dot_BalancePendingBonusIns @TVP_BalanceWalletChange

	--BalancePendingCredit
	INSERT INTO @TVP_BalanceList (custID, balance)
	SELECT custid, SUM(actual_stake)
	FROM @RejectedTicket
	GROUP BY custid

	IF @@ROWCOUNT > 0
		EXEC Dot_BalancePendingCreditIns @TVP_BalanceList, 1


	UPDATE dbo.bettransm with (rowlock, updlock)
	SET status = 'Reject', statusID = 101, statuswinlost=5, winlostdate = matchdate
		,@minTransIDm = CASE WHEN [transid]<@minTransIDm THEN [transid] ELSE @minTransIDm END
		,@maxTransIDm = CASE WHEN [transid]>@maxTransIDm THEN [transid] ELSE @maxTransIDm END
		,@ticketCountm=@ticketCountm+1
	OUTPUT
		DELETED.refno, DELETED.custid, DELETED.matchid, DELETED.transid
	INTO @Refnos
	FROM dbo.bettransm with (index=IX_matchid)
	WHERE matchid   IN ( SELECT val FROM dbo.strSplit(@matchid, ',') )
		AND bettype IN ( SELECT val FROM dbo.strSplit(@btList,  ',') )
		AND statusID = 1	-- waiting

	-- reject parlay main tickets.
	IF @@ROWCOUNT > 0
	BEGIN
		INSERT INTO @pTransID
		SELECT DISTINCT B.transid
		FROM dbo.bettrans B with (nolock, index=CIX_matchid_bettype)
			INNER JOIN @Refnos R ON B.matchid IN (9,29) AND B.custid = R.custid AND B.refno = R.refno
		WHERE statusID = 0 --running

		UPDATE B
		SET status = 'Reject', statusID = 101, checktime=@RejectTime
			,creator = @creator, ruben = 1, winlost = actual_stake
		OUTPUT DELETED.custid, DELETED.actual_stake INTO @RejectedTicketParlay
		FROM dbo.bettrans B with (nolock)
			INNER JOIN @pTransID p ON B.transid = p.transid
		WHERE b.statusID = 0 --running

		-- BalancePendingCredit
		--INSERT INTO dbo.BalancePendingCredit (custid, balance)
		--SELECT custid, SUM(actual_stake)
		--FROM @RejectedTicketParlay
		--GROUP BY custid
		INSERT INTO @TVP_BalanceListParlay (custID, balance)
			SELECT custid, SUM(actual_stake)
			FROM @RejectedTicketParlay
			GROUP BY custid
	
		EXEC Dot_BalancePendingCreditIns @TVP_BalanceListParlay, 1
	END

	Declare @Sub TABLE (matchid int PRIMARY KEY, minTransID bigint, maxTransID bigint, ticketCount int)
	INSERT INTO @Sub
	SELECT matchid, min(transid), max(transid), COUNT(*)
	FROM @RejectedTicket
	GROUP BY matchid

	Declare @Subm TABLE (matchid int PRIMARY KEY, minTransIDm bigint, maxTransIDm bigint, ticketCountm int)
	INSERT INTO @Subm
	SELECT matchid, min(transid), max(transid), COUNT(*)
	FROM @Refnos
	GROUP BY matchid

	Declare @Sum TABLE (matchid int PRIMARY KEY, minTransID bigint, maxTransID bigint, ticketCount int, 
		minTransIDm bigint, maxTransIDm bigint, ticketCountm int)
	INSERT INTO @Sum
	SELECT mm.val, ISNULL(mt.minTransID, 0), ISNULL(mt.maxTransID, 0), ISNULL(mt.ticketCount, 0), 
		ISNULL(pt.minTransIDm, 0), ISNULL(pt.maxTransIDm, 0), ISNULL(pt.ticketCountm, 0)
	FROM (SELECT val FROM dbo.strSplit(@matchid, ',')) mm
	LEFT JOIN @Sub mt ON mm.val = mt.matchid
	LEFT JOIN @Subm pt ON mm.val = pt.matchid
	WHERE ISNULL(mt.ticketCount, 0) + ISNULL(pt.ticketCountm, 0) > 0

	SET @RejectedMatch	= (  SELECT CAST(matchid     as varchar(20)) + ',' FROM @Sum ORDER BY matchid FOR XML PATH('')  )
	SET @minTransIDs	= (  SELECT CAST(minTransID  as varchar(20)) + ',' FROM @Sum ORDER BY matchid FOR XML PATH('')  )
	SET @maxTransIDs	= (  SELECT CAST(maxTransID  as varchar(20)) + ',' FROM @Sum ORDER BY matchid FOR XML PATH('')  )
	SET @ticketCounts	= (  SELECT CAST(ticketCount as varchar(20)) + ',' FROM @Sum ORDER BY matchid FOR XML PATH('')  )
	SET @minTransIDms	= (  SELECT CAST(minTransIDm  as varchar(20)) + ',' FROM @Sum ORDER BY matchid FOR XML PATH('')  )
	SET @maxTransIDms	= (  SELECT CAST(maxTransIDm  as varchar(20)) + ',' FROM @Sum ORDER BY matchid FOR XML PATH('')  )
	SET @ticketCountms	= (  SELECT CAST(ticketCountm as varchar(20)) + ',' FROM @Sum ORDER BY matchid FOR XML PATH('')  )

	SELECT
		@RejectedMatch = SUBSTRING(@RejectedMatch, 1, LEN(@RejectedMatch)-1),
		@minTransIDs   = SUBSTRING(@minTransIDs  , 1, LEN(@minTransIDs)-1),
		@maxTransIDs   = SUBSTRING(@maxTransIDs  , 1, LEN(@maxTransIDs)-1),
		@ticketCounts  = SUBSTRING(@ticketCounts , 1, LEN(@ticketCounts)-1),
		@minTransIDms   = SUBSTRING(@minTransIDms  , 1, LEN(@minTransIDms)-1),
		@maxTransIDms   = SUBSTRING(@maxTransIDms  , 1, LEN(@maxTransIDms)-1),
		@ticketCountms = SUBSTRING(@ticketCountms, 1, LEN(@ticketCountms)-1)

	Declare @Total TABLE (oddsid int, homeTotal money, awayTotal money)
	INSERT INTO @Total
	SELECT oddsid,
		SUM(case when betteam='h' then (CASE WHEN ABS(odds) > 1 THEN ABS(odds) ELSE 1 END * stake * virtualrate * (1-tpositiontaking)) else 0 end),
		SUM(case when betteam='a' then (CASE WHEN ABS(odds) > 1 THEN ABS(odds) ELSE 1 END * stake * virtualrate * (1-tpositiontaking)) else 0 end)
	FROM @RejectedTicket
	GROUP BY oddsid

	SET @RejectedOdds	= (  SELECT CAST(oddsid     as varchar(20)) + ',' FROM @Total ORDER BY oddsid FOR XML PATH('')  )
	SET @HomeTotals		= (  SELECT CAST(homeTotal  as varchar(20)) + ',' FROM @Total ORDER BY oddsid FOR XML PATH('')  )
	SET @AwayTotals		= (  SELECT CAST(awayTotal  as varchar(20)) + ',' FROM @Total ORDER BY oddsid FOR XML PATH('')  )

	SELECT
		@RejectedOdds = SUBSTRING(@RejectedOdds, 1, LEN(@RejectedOdds)-1),
		@HomeTotals   = SUBSTRING(@HomeTotals  , 1, LEN(@HomeTotals)-1),
		@AwayTotals   = SUBSTRING(@AwayTotals  , 1, LEN(@AwayTotals)-1)

END
ELSE IF @@SERVERNAME not in ('DBTRANS','SITDBTRANS','TDBTRANS') AND @target = ''
BEGIN

	IF @@SERVERNAME IN ('DB054','DB052','DB231','DB232' ,'SITDB054','SITDB052') AND EXISTS (SELECT * FROM sys.databases WHERE name ='LASDB')
	BEGIN
		--- send a message for LAS
		EXEC dbo.LAS_bettransUpdLiveTickets
			@creator = @creator,
			@matchid = @matchid,
			@btList = @btList,
			@updateTime = @RejectTime,

			@minTransID = @minTransID,
			@maxTransID = @maxTransID,

			@minTransIDm = @minTransIDm,
			@maxTransIDm = @maxTransIDm,
			@action = 'reject'
	END

	DECLARE @matchs TABLE (matchid int primary key)
	INSERT INTO @matchs
	SELECT val FROM dbo.strSplit(@matchid, ',')

	UPDATE dbo.bettrans with (rowlock, updlock)
	SET status = 'Reject', statusID = 101, checktime=@RejectTime
		,creator = @creator, ruben = 1, winlost = actual_stake --statuswinlost=5,
		,@ticketCount=@ticketCount+1
	FROM dbo.bettrans with (index=PK_bettrans) --CIX_matchid_bettype)
		INNER JOIN @matchs m ON dbo.bettrans.matchid = m.matchid
	WHERE --matchid   IN ( SELECT val FROM dbo.strSplit(@matchid, ',') )
		--AND
		bettype IN ( SELECT val FROM dbo.strSplit(@btList,  ',') )
		AND statusID = 1	-- waiting
		AND transid BETWEEN @minTransID AND @maxTransID

	IF @maxTransIDm > 0
	BEGIN
		UPDATE dbo.bettransm with (rowlock, updlock)
		SET status = 'Reject', statusID = 101, statuswinlost=5, winlostdate = matchdate
			,@ticketCountm=@ticketCountm+1
		OUTPUT
			DELETED.refno, DELETED.custid, DELETED.matchid, DELETED.transid
		INTO @Refnos
		FROM dbo.bettransm with (index=IX_matchid)
		WHERE matchid   IN ( SELECT val FROM dbo.strSplit(@matchid, ',') )
			AND bettype IN ( SELECT val FROM dbo.strSplit(@btList,  ',') )
			AND statusID = 1	-- waiting
			AND transid BETWEEN @minTransIDm AND @maxTransIDm

		-- reject parlay main tickets.
		INSERT INTO @pTransID
		SELECT DISTINCT B.transid
		FROM dbo.bettrans B with (nolock, index=CIX_matchid_bettype)
			INNER JOIN @Refnos R ON B.matchid IN (9,29) AND B.refno = R.refno
		WHERE statusID = 0 --running

		UPDATE B
		SET status = 'Reject', statusID = 101, checktime=@RejectTime
			,creator = @creator, ruben = 1, winlost = actual_stake
		FROM dbo.bettrans B with (nolock)
			INNER JOIN @pTransID p ON B.transid = p.transid
		WHERE b.statusID = 0 --running
	END

END
GO
/*<info serverAlias="DBTXN-bodb02" executers="" viewers="" isFunction="0" isNested="0"></info>*/