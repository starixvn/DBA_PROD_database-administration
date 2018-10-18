SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE [dbo].[Bet_ExecRep_03]
	@target varchar(10),
	@creator int,
	@matchid varchar(1000),
	@btList varchar(4000),
	@RejectTime datetime,

	@minTransID bigint OUTPUT,
	@maxTransID bigint OUTPUT,
	@ticketCount int = 0 OUTPUT,

	@RejectedMatch varchar(2000) = '' OUTPUT,
	@minTransIDs varchar(2000) = '' OUTPUT,
	@maxTransIDs varchar(2000) = '' OUTPUT,
	@ticketCounts varchar(2000) = '' OUTPUT,

	@RejectedOdds varchar(2000) = '' OUTPUT,
	@HomeTotals varchar(2000) = '' OUTPUT,
	@AwayTotals varchar(2000) = '' OUTPUT
AS
/*
	Creator:	20111019@Joe
	Task:		Description - [Redmine: #00000]
	Database:	DBTXN.bodb02
	
	Revisions:
		- 20111019@Joe:		Initial - [Redmine: #00000]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
SET NOCOUNT ON

/*
reject bet using execrep
should call from Dot_Admin_BetTransUpdLiveReject_CP

20111019@Joe: reject SecAcceptFlag = 1 (20 seconds auto accept, when admin site click CP will reject Flag is true tickets)
20120503@Vivi: BalancePendingCredit
20150504@Martin:expand @btList length to receive more bettype list,ex info site odds.
20150910@martin(TransDB):use Dot_BalancePendingCreditIns to replace insert BalancePendingCredit table.
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

Declare @Refnos TABLE (refno bigint, custid int)
Declare @pTransID TABLE (transid bigint PRIMARY KEY)
DECLARE @TVP_BalanceList TVP_BalanceList
DECLARE @TVP_BalanceWalletChange TVP_BalanceWalletChange

IF @@SERVERNAME in ('DBTRANS','SITDBTRANS','TDBTRANS') AND @target = 'DBTRANS'
BEGIN

	SELECT
		@minTransID = 9223372036854775807, @maxTransID = 0, @ticketCount = 0
		--,@minTransIDm= 2147483647, @maxTransIDm= 0, @ticketCountm= 0

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
		AND statusID = 0	-- running
		AND checktime > @RejectTime
		AND SecAcceptFlag = 1
		AND transid > 3200000000

	--return licensee bonus balance
	INSERT INTO @TVP_BalanceWalletChange(matchid,custid,balance,balanceType,walletType,bonusId)
	SELECT matchid,custid,actual_stake,0,WalletType,BonusID
	FROM @RejectedTicket
	WHERE WalletType=1--bonus ticket
	
	IF @@ROWCOUNT > 0
		EXEC Dot_BalancePendingBonusIns @TVP_BalanceWalletChange

	-- BalancePendingCredit
	INSERT INTO @TVP_BalanceList (custID, balance)
	SELECT custid, SUM(actual_stake)
	FROM @RejectedTicket
	GROUP BY custid
	
	IF @@ROWCOUNT > 0
		EXEC Dot_BalancePendingCreditIns @TVP_BalanceList, 1
	

	Declare @Sum TABLE (matchid int PRIMARY KEY, minTransID bigint, maxTransID bigint, ticketCount int)
	INSERT INTO @Sum
	SELECT matchid, min(transid), max(transid), COUNT(*)
	FROM @RejectedTicket
	GROUP BY matchid

	SET @RejectedMatch	= (  SELECT CAST(matchid     as varchar(20)) + ',' FROM @Sum ORDER BY matchid FOR XML PATH('')  )
	SET @minTransIDs	= (  SELECT CAST(minTransID  as varchar(20)) + ',' FROM @Sum ORDER BY matchid FOR XML PATH('')  )
	SET @maxTransIDs	= (  SELECT CAST(maxTransID  as varchar(20)) + ',' FROM @Sum ORDER BY matchid FOR XML PATH('')  )
	SET @ticketCounts	= (  SELECT CAST(ticketCount as varchar(20)) + ',' FROM @Sum ORDER BY matchid FOR XML PATH('')  )

	SELECT
		@RejectedMatch = SUBSTRING(@RejectedMatch, 1, LEN(@RejectedMatch)-1),
		@minTransIDs   = SUBSTRING(@minTransIDs  , 1, LEN(@minTransIDs)-1),
		@maxTransIDs   = SUBSTRING(@maxTransIDs  , 1, LEN(@maxTransIDs)-1),
		@ticketCounts  = SUBSTRING(@ticketCounts , 1, LEN(@ticketCounts)-1)

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
ELSE IF (@@SERVERNAME not in ('DBTRANS','SITDBTRANS','TDBTRANS') AND @target = '')
BEGIN

	IF @@SERVERNAME IN ('DB054','DB052','DB231','DB232','SITDB054','SITDB052') AND EXISTS (SELECT * FROM sys.databases WHERE name ='LASDB')
	BEGIN
		--- send a message for LAS
		EXEC dbo.LAS_bettransUpdLiveTickets
			@creator = @creator,
			@matchid = @matchid,
			@btList = @btList,
			@updateTime = @RejectTime,

			@minTransID = @minTransID,
			@maxTransID = @maxTransID,

			@action = 'reject_CP'
	END

	UPDATE dbo.bettrans with (rowlock, updlock)
	SET status = 'Reject', statusID = 101, checktime=@RejectTime
		,creator = @creator, ruben = 1, winlost = actual_stake --statuswinlost=5,
		,@ticketCount=@ticketCount+1
	FROM dbo.bettrans with (index=CIX_matchid_bettype)
	WHERE matchid   IN ( SELECT val FROM dbo.strSplit(@matchid, ',') )
		AND bettype IN ( SELECT val FROM dbo.strSplit(@btList,  ',') )
		AND statusID = 0	-- running
		AND checktime > @RejectTime
		AND transid BETWEEN @minTransID AND @maxTransID
		AND SecAcceptFlag = 1
END
GO
/*<info serverAlias="DBTXN-bodb02" executers="" viewers="" isFunction="0" isNested="0"></info>*/