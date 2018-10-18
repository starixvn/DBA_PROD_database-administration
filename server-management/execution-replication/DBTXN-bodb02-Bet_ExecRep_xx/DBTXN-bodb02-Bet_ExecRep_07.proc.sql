SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE [dbo].[Bet_ExecRep_07] 
	@target varchar(10),
	@matchid varchar(2000),
	@btList varchar(4000),
	@AcceptTime datetime,

	@minTransID bigint OUTPUT,
	@maxTransID bigint OUTPUT,
	@ticketCount int = 0 OUTPUT,

	@minTransIDm bigint OUTPUT,
	@maxTransIDm bigint OUTPUT,
	@ticketCountm int = 0 OUTPUT,

	@AcceptedMatch varchar(2000) = '' OUTPUT,
	@minTransIDs varchar(2000) = '' OUTPUT,
	@maxTransIDs varchar(2000) = '' OUTPUT,
	@ticketCounts varchar(2000) = '' OUTPUT,
	@minTransIDms varchar(2000) = '' OUTPUT,
	@maxTransIDms varchar(2000) = '' OUTPUT,
	@ticketCountms varchar(2000) = '' OUTPUT
AS

IF @matchid IS NULL RETURN

/*
accept bet using execrep
should call from Dot_Admin_BettransUpd_LiveAccept
20101103@Joe : new option with @target parameter
20110530@Joe : add AcceptBet log for DB04/042
20110817@Joe :
	1.remove add AcceptBet log for DB04/042
	2.add multiple accept and include live parlay
20130826@EdwardLee : add parlay ticket count by matchid
20140227@Lukas: push a command to LASDB for accept/reject their tickets
20150504@Martin:expand @btList length to receive more bettype list,ex info site odds.
20170807@Martin:parlay betid to bigint and output parlay max/min betid
20171016@Martin:hotfix @Sum table schema
20180430@Martin:extend match list to varchar(1000)
20180824@Martin:add bettrans.trandate <= accepttime, bettransm.checktime = acceptime
20180908@Martin:add @ticketCountm update @minTransIDm , @maxTransIDm
*/

IF @@SERVERNAME in ('DBTRANS','SITDBTRANS','TDBTRANS') AND (@target = 'DBTRANS')
BEGIN
	Declare @AcceptedTicket TABLE (matchid int, transid bigint)
	Declare @AcceptedTicketm TABLE (matchid int, transid bigint)

	SELECT
		@minTransID = 9223372036854775807, @maxTransID = 0, @ticketCount = 0,
		@minTransIDm= 2147483647, @maxTransIDm= 0, @ticketCountm= 0

	UPDATE dbo.bettrans with (rowlock, updlock)
	SET status=N'running', statusID=0, checktime=@AcceptTime
		--,@minTransID=CASE WHEN [transid]<@minTransID THEN [transid] ELSE @minTransID END
		--,@maxTransID=CASE WHEN [transid]>@maxTransID THEN [transid] ELSE @maxTransID END
		--,@ticketCount=@ticketCount+1
	OUTPUT INSERTED.matchid, INSERTED.transid INTO @AcceptedTicket
	FROM dbo.bettrans with (index=CIX_matchid_bettype)
	WHERE matchid   IN ( SELECT val FROM dbo.strSplit(@matchid, ',') )
		AND bettype IN ( SELECT val FROM dbo.strSplit(@btList,  ',') )
		AND statusID = 1	-- waiting
		AND transdate <= @AcceptTime
		
	SET @ticketCount=@@ROWCOUNT
	
	IF (@ticketCount>0)
	BEGIN
		SELECT 
			@minTransID = MIN(transid),
			@maxTransID = MAX(transid)
		FROM @AcceptedTicket
	END
	
	UPDATE dbo.bettransm with (rowlock, updlock)
	SET status=N'running', statusID=0, checktime=@AcceptTime
		--,@minTransIDm = CASE WHEN [transid]<@minTransIDm THEN [transid] ELSE @minTransIDm END
		--,@maxTransIDm = CASE WHEN [transid]>@maxTransIDm THEN [transid] ELSE @maxTransIDm END
		--,@ticketCountm = @ticketCountm+1
	OUTPUT INSERTED.matchid, INSERTED.transid INTO @AcceptedTicketm
	FROM dbo.bettransm with (index=IX_matchid)
	WHERE matchid   IN ( SELECT val FROM dbo.strSplit(@matchid, ',') )
		AND bettype IN ( SELECT val FROM dbo.strSplit(@btList,  ',') )
		AND statusID = 1	-- waiting
		AND transdate <= @AcceptTime

	SET @ticketCountm=@@ROWCOUNT
	
	IF (@ticketCountm>0)
	BEGIN
		SELECT 
			@minTransIDm = MIN(transid),
			@maxTransIDm = MAX(transid)
		FROM @AcceptedTicketm
	END
	
	Declare @Sub TABLE (matchid int PRIMARY KEY, minTransID bigint, maxTransID bigint, ticketCount int)
	INSERT INTO @Sub
	SELECT matchid, min(transid), max(transid), COUNT(*)
	FROM @AcceptedTicket
	GROUP BY matchid

	Declare @Subm TABLE (matchid int PRIMARY KEY, minTransIDm bigint, maxTransIDm bigint, ticketCountm int)
	INSERT INTO @Subm
	SELECT matchid, min(transid), max(transid), COUNT(*)
	FROM @AcceptedTicketm
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

	SET @AcceptedMatch	= (  SELECT CAST(matchid     as varchar(20)) + ',' FROM @Sum ORDER BY matchid FOR XML PATH('')  )
	SET @minTransIDs	= (  SELECT CAST(minTransID  as varchar(20)) + ',' FROM @Sum ORDER BY matchid FOR XML PATH('')  )
	SET @maxTransIDs	= (  SELECT CAST(maxTransID  as varchar(20)) + ',' FROM @Sum ORDER BY matchid FOR XML PATH('')  )
	SET @ticketCounts	= (  SELECT CAST(ticketCount as varchar(20)) + ',' FROM @Sum ORDER BY matchid FOR XML PATH('')  )
	SET @ticketCountms	= (  SELECT CAST(ticketCountm as varchar(20)) + ',' FROM @Sum ORDER BY matchid FOR XML PATH('')  )
	SET @minTransIDms	= (  SELECT CAST(minTransIDm  as varchar(20)) + ',' FROM @Sum ORDER BY matchid FOR XML PATH('')  )
	SET @maxTransIDms	= (  SELECT CAST(maxTransIDm  as varchar(20)) + ',' FROM @Sum ORDER BY matchid FOR XML PATH('')  )

	SELECT
		@AcceptedMatch = SUBSTRING(@AcceptedMatch, 1, LEN(@AcceptedMatch)-1),
		@minTransIDs = SUBSTRING(@minTransIDs, 1, LEN(@minTransIDs)-1),
		@maxTransIDs = SUBSTRING(@maxTransIDs, 1, LEN(@maxTransIDs)-1),
		@ticketCounts = SUBSTRING(@ticketCounts, 1, LEN(@ticketCounts)-1),
		@ticketCountms = SUBSTRING(@ticketCountms, 1, LEN(@ticketCountms)-1),
		@minTransIDms = SUBSTRING(@minTransIDms, 1, LEN(@minTransIDms)-1),
		@maxTransIDms = SUBSTRING(@maxTransIDms, 1, LEN(@maxTransIDms)-1)

END
ELSE IF @@SERVERNAME not in ('DBTRANS','SITDBTRANS','TDBTRANS') AND (@target = '')
BEGIN

/*
	IF @@SERVERNAME IN ('DB054','DB052','DB231','DB232') AND EXISTS (SELECT * FROM sys.databases WHERE name ='LASDB')
	BEGIN
		--- send a message for LAS
		EXEC dbo.LAS_bettransUpdLiveTickets
			@matchid = @matchid,
			@btList = @btList,
			@updateTime = @AcceptTime,

			@minTransID = @minTransID,
			@maxTransID = @maxTransID,

			@minTransIDm = @minTransIDm,
			@maxTransIDm = @maxTransIDm,
			@action = 'accept'
	END
*/
	IF @maxTransID > 0
		UPDATE dbo.bettrans with (rowlock, updlock)
		SET status=N'running', statusID=0, checktime=@AcceptTime
			--,@ticketCount=@ticketCount+1
		FROM dbo.bettrans with (index=CIX_matchid_bettype)
		WHERE matchid   IN ( SELECT val FROM dbo.strSplit(@matchid, ',') )
			AND bettype IN ( SELECT val FROM dbo.strSplit(@btList,  ',') )
			AND statusID = 1	-- waiting
			AND transid BETWEEN @minTransID AND @maxTransID

	IF @maxTransIDm > 0
		UPDATE dbo.bettransm with (rowlock, updlock)
		SET status=N'running', statusID=0
			--,@ticketCountm = @ticketCountm+1
		FROM dbo.bettransm with (index=IX_matchid)
		WHERE matchid   IN ( SELECT val FROM dbo.strSplit(@matchid, ',') )
			AND bettype IN ( SELECT val FROM dbo.strSplit(@btList,  ',') )
			AND statusID = 1	-- waiting
			AND transid BETWEEN @minTransIDm AND @maxTransIDm

	-- perform extra log
	/*
	IF @@SERVERNAME IN (N'DB04', N'DB042')
	BEGIN
		Declare @transdate datetime
		SELECT @transdate = transdate FROM dbo.bettrans with (nolock) WHERE transid = @maxTransID

		INSERT INTO dbo.UserLog_AcceptBet (MatchID, minTransID, maxTransID, maxTransDate, btList)
		VALUES ( @matchid, @minTransID, @maxTransID, @transdate, @btList )
	END
	*/
END
GO
/*<info serverAlias="DBTXN-bodb02" executers="" viewers="" isFunction="0" isNested="0"></info>*/