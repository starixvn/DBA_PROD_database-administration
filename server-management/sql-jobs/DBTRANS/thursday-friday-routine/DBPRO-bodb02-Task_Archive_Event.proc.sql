SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.Task_Archive_Event
						@winlostdate	DATETIME
					,	@Action			VARCHAR(10)		= NULL -- copy / delete / subtask	
					,	@DeletedTarget	VARCHAR(100)	= ''
AS
/*
	Database:	DBPRO.bodb02
	Revisions:
		- 20101229@Viet: Add moving for data from BingoBall table
		- 20110715@Vivi(DB02): Add moving for data from outright14.ProgramDate
		- 20130520@Victor(DB02): Add moving for data from VSOutright14.eventdate
		- 20140911@Lukas: add table MatchMaxbet_bk 
		- 20141006@Lukas: remove table SS_GameState_bk
		- 20141024@Lukas: add table ResultDetail14
		- 20141225@Jamie: Add OtherInfo into ResultDetail_bk
		- 20150506@Victor(DB02): Add ParentID to Match14 and Match_BK
		- 20150626@Cooper(DB02): Add match_remark table Arcihve column 'HomeSubstitutes,AwaySubstitutes,StartTeam,HomePenalty,AwayPenalty'
		- 20150703@Cooper(DB02): Add match_remark table Arcihve column 'HomeYellowCard,AwayYellowCard'
		- 20150720@Sophia: Add ResultDetail3rd14 table
		- 20160120@Sophia: Add EventInfo3rd_bk table for Cockfighting 
		- 20160401@Sophia: Add Column Matchmaxbet.Spread [Redmind: #55115]
		- 20160421@Sophia: Add AutoPayoutResult, ProviderResultDetail tables [Redmine: #49958]
		- 20160715@Sylvia: Add column autosuspend into outright_bk
		- 20161007@Viet: Add parameter @action, to separate copy and delete process.
		- 20161024@Patrick: + Add new identity field for AutoPayoutResult_bk & ProviderResultDetail_bk [Redmine: #66157]
							+ Add new IsConfirmed field to ProviderResultDetail_bk
		- 20170721@Billy:	Add odds3rd table - [Redmine: #80382]
		- 20171012@Lukas: put event14 table into execRep SP to reduce workload on DBDIST02
		- 20171031@Lukas: add 2 tables Intg_OddsFeed_SettlementAction & Intg_OddsFeed_SettlementAction_Outright
		- 20171213@Sylvia: Add column EventID/Year in outright_bk
		- 20171221@Billy:	Add Match3rd table - [Redmine: #88506]
		- 20180122@Billy:	Add [GameResultDate] column of [Match3rd] - [Redmine: #89833]
		- 20180328@Billy:	Add [ResourceId] column of [ResultDetail3rd] - [Redmine: #91959]
		- 20180405@Billy:	Add [cs04], [cs05], [ResourceId] columns of [Odds3rd] - [Redmine: #93175]
		- 20181204@Billy:	Add [oddsES] & [ResultDetailES] tables - [Redmine: #105816]
 */
BEGIN
	SET NOCOUNT ON;

	IF @Action = 'copy'
	BEGIN
		INSERT INTO DBARC.bodb_archive.dbo.odds_bk
			SELECT * FROM odds14 WHERE matchid in (select matchid from match14 where eventdate = @winlostdate)

		INSERT INTO DBARC.bodb_archive.dbo.match_bk(matchid, leagueid, homeid, awayid, eventdate, eventstatus, betstatus, livehomescore, liveawayscore,
				finalhomescore, finalawayscore, creator, matchcode, kickofftime, closedtime, showtime,
				hthomescore, htawayscore, ruben, multiple, yenbet, exrisk, sporttype, tstamp,
				homeid2, awayid2, DisplayMode, LeaguePatternID, HomeDisplayPatternID, AwayDisplayPatternID, IsNeutral, GoalRecord, GlobalShowTime, ParentID)
			SELECT
				matchid, leagueid, homeid, awayid, eventdate, eventstatus, betstatus, livehomescore, liveawayscore,
				finalhomescore, finalawayscore, creator, matchcode, kickofftime, closedtime, showtime,
				hthomescore, htawayscore, ruben, multiple, yenbet, exrisk, sporttype, tstamp,
				homeid2, awayid2, DisplayMode, LeaguePatternID, HomeDisplayPatternID, AwayDisplayPatternID, IsNeutral, GoalRecord, GlobalShowTime, ParentID
			FROM match14 WHERE eventdate = @winlostdate

		INSERT INTO DBARC.bodb_archive.dbo.bingoBall_bk
			([Matchid], [Seq], [Number], [UpdateTime])
		SELECT
			[Matchid], [Seq], [Number], [UpdateTime]
		FROM BingoBall14
		WHERE MatchID in (SELECT MatchID from Match14 where eventdate = @winlostdate)

		--INSERT INTO DB06.bodb_archive.dbo.SS_GameState_bk
		--	(Matchid, ResultKey, ResultValue)
		--SELECT
		--	Matchid, ResultKey, ResultValue
		--FROM SS_GameState14
		--WHERE MatchID in (SELECT MatchID from Match14 where eventdate = @winlostdate)

		INSERT INTO DBARC.bodb_archive.dbo.outright_bk
			(orid, leagueid, teamid, eventdate, kickofftime, oddsstatus, odds, maxbet, gapodds, matchcode, groupmatch, status, creator, bal, risk, 
			DisplayMode, PlaceOdds, Placing, IsFavor, IsSCR, ProgramID, 
			FOddsStatus, SCRTime, LeaguePatternID, TeamPatternID, ProgramDate, IsDeadHeat, autosuspend, EventID, Year)
			SELECT
				orid, leagueid, teamid, eventdate, kickofftime, oddsstatus, odds, maxbet, gapodds, matchcode, groupmatch, status, creator, bal, risk, 
				DisplayMode, PlaceOdds, Placing, IsFavor, IsSCR, ProgramID, FOddsStatus, SCRTime, LeaguePatternID, TeamPatternID, 
				ProgramDate, IsDeadHeat, autosuspend, EventID, Year
			FROM outright14 WHERE eventdate = @winlostdate


		INSERT INTO DBARC.bodb_archive.dbo.VSOutright_bk
			(Orid, EventID, RacerNum, IsFavor, EventDate, KickoffTime, RacerID, HumanID, WinOdds, PlaceOdds, 
			Lane, MaxBet, Placing, Creator, EventStatus )		
		select 	
			Orid, EventID, RacerNum, IsFavor, EventDate, KickoffTime, RacerID, HumanID, WinOdds, PlaceOdds, 
			Lane, MaxBet, Placing, Creator, EventStatus
		from VSOutright14 where eventdate = @winlostdate 

		-- IF EDIT HERE (MatchRemark)
		-- GO EDIT CODE IN LOWER SECTION, TOO (Extra Cleanup Match_Remark)
		INSERT INTO DBARC.bodb_Archive.dbo.match_remark
		(
		[matchid], [calculate], [multiple], [calrefund], [refund], [calStatus], [IsTotalBetDenied_1], [IsTotalBetDenied_3], [IsTotalBetDenied_7], [IsTotalBetDenied_8],
		[LiveTimer], [HomeRedCard], [AwayRedCard], [LivePeriod], [HedgeForecast], [IsTotalBetDenied_20], [IsTotalBetDenied_21], [IsNeutral], [StreamingID], [IsInternal], [IsHTCal],
		[LiveDeleteChecker], [HomeColor], [AwayColor], [ConfirmHT], [ConfirmFT], [PausePeriod], [TimerSuspend], [IsPending], [isUndecided], [StdDelBetCheck],
		HomeSubstitutes,AwaySubstitutes,StartTeam,HomePenalty,AwayPenalty,HomeYellowCard,AwayYellowCard
		)
		SELECT
		[matchid], [calculate], [multiple], [calrefund], [refund], [calStatus], [IsTotalBetDenied_1], [IsTotalBetDenied_3], [IsTotalBetDenied_7], [IsTotalBetDenied_8],
		[LiveTimer], [HomeRedCard], [AwayRedCard], [LivePeriod], [HedgeForecast], [IsTotalBetDenied_20], [IsTotalBetDenied_21], [IsNeutral], [StreamingID], [IsInternal], [IsHTCal],
		[LiveDeleteChecker], [HomeColor], [AwayColor], [ConfirmHT], [ConfirmFT], [PausePeriod], [TimerSuspend], [IsPending], [isUndecided], [StdDelBetCheck],
		HomeSubstitutes,AwaySubstitutes,StartTeam,HomePenalty,AwayPenalty,HomeYellowCard,AwayYellowCard
		FROM match_remark
		WHERE MatchID in (SELECT MatchID from Match14 where eventdate = @winlostdate)

		INSERT INTO DBARC.bodb_Archive.dbo.[MatchMaxbet_bk](MatchId, BetType, Maxbet, OperatorId, Spread)
		SELECT MatchId, BetType, Maxbet, OperatorId, Spread
		FROM matchMaxbet14 WITH(NOLOCK)
		WHERE matchid IN (SELECT MatchID from Match14 where eventdate = @winlostdate)

		INSERT INTO DBARC.bodb_Archive.dbo.ResultDetail_bk
			(	MatchId, ResourceId, HomeValue, AwayValue, ResultStatusID, SettlementStatusID, CreateDate, LastModifyDate, CreateBy, LastModifyBy, OtherInfo)
		SELECT	MatchId, ResourceId, HomeValue, AwayValue, ResultStatusID, SettlementStatusID, CreateDate, LastModifyDate, CreateBy, LastModifyBy, OtherInfo
		FROM	dbo.ResultDetail14 WITH (NOLOCK)
		WHERE	MatchId IN (SELECT matchid FROM dbo.match14 WHERE eventdate = @winlostdate)

			-- 20180328@Billy -- Add column [ResourceId]
		INSERT INTO	DBARC.bodb_Archive.dbo.ResultDetail3rd_bk
			(	ResultID, VendorID, MatchID, GameID, Custom1, Custom2, Custom3, ResultStatusID, SettlementStatusID, GameResult, OtherInfo, CreateBy, CreateDate, LastModifyBy, LastModifyDate, ResourceId)
		SELECT	ResultID, VendorID, MatchID, GameID, Custom1, Custom2, Custom3, ResultStatusID, SettlementStatusID, GameResult, OtherInfo, CreateBy, CreateDate, LastModifyBy, LastModifyDate, ResourceId
		FROM	dbo.ResultDetail3rd14 WITH (NOLOCK)
		WHERE	MatchId IN (SELECT matchid FROM dbo.match14 WITH (NOLOCK) WHERE eventdate = @winlostdate)

		INSERT INTO DBARC.bodb_Archive.dbo.[EventInfo3rd_bk](EventInfo3rdId,ArenaID,FightNo,EventDate,HomeOwner,AwayOwner)
		SELECT EventInfo3rdId,ArenaID,FightNo,EventDate,HomeOwner,AwayOwner
		FROM dbo.EventInfo3rd14 WITH(NOLOCK)
		WHERE EventDate = @winlostdate

		INSERT INTO DBARC.bodb_Archive.dbo.[AutoPayoutResult_bk] (AutoPayoutResultId, MatchId, CalculationType, SourceId, HomeValue, AwayValue, StatusId, TryCount, CreatedDate, ModifiedDate)
		SELECT 	AutoPayoutResultId, MatchId, CalculationType, SourceId, HomeValue, AwayValue, StatusId, TryCount, CreatedDate, ModifiedDate
		FROM 	dbo.AutoPayoutResult14 WITH(NOLOCK)
		WHERE 	matchid IN (SELECT MatchID from Match14 where eventdate = @winlostdate)

		INSERT INTO DBARC.bodb_Archive.dbo.[ProviderResultDetail_bk] (ProviderResultDetailId, MatchId, SourceId, TypeId, HomeValue, AwayValue, CreatedDate, IsConfirmed)
		SELECT  ProviderResultDetailId, MatchId, SourceId, TypeId, HomeValue, AwayValue, CreatedDate, IsConfirmed
		FROM 	dbo.ProviderResultDetail14 WITH(NOLOCK)
		WHERE 	matchid IN (SELECT MatchID from Match14 where eventdate = @winlostdate)

		-- Odds3rd: [tstamp] and [ExtraInfo] are EXCLUDED
			-- 20180405@Billy -- Add columns [cs04], [cs05], [ResourceId]	
		INSERT INTO	DBARC.bodb_Archive.dbo.Odds3rd_bk
			(	oddsid, matchid, odds3rdid, bettype, hdp1, hdp2, odds1a, odds2a, oddsstatus, changetime, creator, com1, comx, com2, cs00, cs01, cs10, cs11, cs02, cs12, cs22, cs21, cs20, cs30, cs31, cs32, cs33, cs23, cs13, cs03, cs99, sporttype, cs04, cs05, Resourceid)
		SELECT	oddsid, matchid, odds3rdid, bettype, hdp1, hdp2, odds1a, odds2a, oddsstatus, changetime, creator, com1, comx, com2, cs00, cs01, cs10, cs11, cs02, cs12, cs22, cs21, cs20, cs30, cs31, cs32, cs33, cs23, cs13, cs03, cs99, sporttype, cs04, cs05, Resourceid
		FROM	dbo.Odds3rd14 WITH (NOLOCK)
		WHERE	matchid IN (SELECT matchid FROM dbo.match14 WHERE eventdate = @winlostdate);
	
		INSERT INTO DBARC.bodb_archive.dbo.Intg_OddsFeed_SettlementAction_bk
			( ActionId, LeagueId, MatchId, ActionType, HTHomeScore, HTAwayScore, FTHomeScore, FTAwayScore, CreateTime, OtherInfo )
		SELECT  ActionId, LeagueId, MatchId, ActionType, HTHomeScore, HTAwayScore, FTHomeScore, FTAwayScore, CreateTime, OtherInfo 
		FROM dbo.Intg_OddsFeed_SettlementAction WITH(NOLOCK)
		WHERE matchid IN (SELECT matchid FROM dbo.match14 WHERE eventdate = @winlostdate);

		INSERT INTO DBARC.bodb_archive.dbo.Intg_OddsFeed_SettlementAction_Outright_bk
			(ActionId, ActionType, OrId, LeagueId, TeamId, Status, IsDeadheat, Deadheat, CreateTime)
		SELECT ActionId, ActionType, OrId, LeagueId, TeamId, Status, IsDeadheat, Deadheat, CreateTime
		FROM dbo.Intg_OddsFeed_SettlementAction_Outright WITH(NOLOCk)
		WHERE orid IN (SELECT orid FROM outright14 WITH(NOLOCK) WHERE eventdate = @winlostdate)

			-- 20171221@Billy -- New table [Match3rd_bk]
			-- 20180122@Billy -- Add column [GameResultDate]
		INSERT INTO	DBARC.bodb_Archive.dbo.Match3rd_bk
			(	Match3rdId, League3rdId, HomeId, AwayId, EventDate, SportType, VendorMatchId, MatchNo, HasLive, EventStatus, VendorEventStatus, CreateTime, UpdateTime, VendorEventDate, GameResultDate)
		SELECT	Match3rdId, League3rdId, HomeId, AwayId, EventDate, SportType, VendorMatchId, MatchNo, HasLive, EventStatus, VendorEventStatus, CreateTime, UpdateTime, VendorEventDate, GameResultDate
		FROM	dbo.Match3rd14 WITH (NOLOCK)
		WHERE	EventDate = @winlostdate;

			-- 20181204@Billy:	New table [oddsES]
		INSERT INTO	DBARC.bodb_Archive.dbo.oddsES_bk
			(	oddsid, matchid, bettype, switch, hdp1, hdp2, odds1a, odds2a, oddsspreada, autobookie, gapodds1, gapodds2, diffbalance, maxodds, minodds, oddsstatus, liveindicator, changetime, risk, stakerange
			,	newoffersetup, livehomescore, liveawayscore, creator, com1, com2, csstatus, maxbet, autosuspend, stakerange2, risk2, site3, sporttype, tstamp, HasBeenLinked, Resourceid, Category, IncreaseMaxbet
			,	odds1aH, odds2aH, IsCopyDeadball, GoalLineDiff, IsStatusIndep, ParentOddsId, RefOddsSP, RefOddsH, RefOddsA, RefTrueOdds, CurrentTrueOdds, EnableVirtualRate, TraderId)
		SELECT	oddsid, matchid, bettype, switch, hdp1, hdp2, odds1a, odds2a, oddsspreada, autobookie, gapodds1, gapodds2, diffbalance, maxodds, minodds, oddsstatus, liveindicator, changetime, risk, stakerange
			,	newoffersetup, livehomescore, liveawayscore, creator, com1, com2, csstatus, maxbet, autosuspend, stakerange2, risk2, site3, sporttype, tstamp, HasBeenLinked, Resourceid, Category, IncreaseMaxbet
			,	odds1aH, odds2aH, IsCopyDeadball, GoalLineDiff, IsStatusIndep, ParentOddsId, RefOddsSP, RefOddsH, RefOddsA, RefTrueOdds, CurrentTrueOdds, EnableVirtualRate, TraderId
		FROM	dbo.oddsES14 AS oes WITH (NOLOCK)
		WHERE	EXISTS (SELECT 1 FROM dbo.match14 AS m WITH (NOLOCK) WHERE m.matchid = oes.matchid AND m.eventdate = @winlostdate);

			-- 20181204@Billy:	New table [ResultDetailES]
		INSERT INTO	DBARC.bodb_Archive.dbo.ResultDetailES_bk
			(	MatchID, ResourceID, HomeValue, AwayValue, ResultStatusID, SettlementStatusID, CreateBy, CreateDate, LastModifyBy, LastModifyDate, OtherInfo)
		SELECT	MatchID, ResourceID, HomeValue, AwayValue, ResultStatusID, SettlementStatusID, CreateBy, CreateDate, LastModifyBy, LastModifyDate, OtherInfo
		FROM	dbo.ResultDetailES14 AS rdes WITH (NOLOCK)
		WHERE	EXISTS (SELECT 1 FROM dbo.match14 AS m WITH (NOLOCK) WHERE m.matchid = rdes.matchid AND m.eventdate = @winlostdate);
	END -- END @action = 'copy'

	IF @Action = 'delete'
	BEGIN
		DELETE FROM dbo.Intg_OddsFeed_SettlementAction 
		WHERE matchid IN (SELECT matchid FROM dbo.match14 WITH(NOLOCK) WHERE eventdate = @winlostdate);

		DELETE FROM dbo.Intg_OddsFeed_SettlementAction_Outright 
		WHERE orid IN (SELECT orid FROM outright14 WITH(NOLOCK) WHERE eventdate = @winlostdate)

		--- delete match_remark base on match14
		DELETE FROM dbo.match_Remark WHERE matchid in (select matchid from dbo.match14 where eventdate = @winlostdate)
		WAITFOR DELAY '00:00:01'


		CREATE TABLE #DeletedList (id INT PRIMARY KEY CLUSTERED,IsDone BIT)

		---### delete data for odds14
		INSERT INTO #DeletedList (id,IsDone)
		SELECT oddsid,0 
		FROM dbo.odds14  WHERE matchid IN (SELECT matchid FROM dbo.match14 WHERE eventdate = @winlostdate)

		-- call subtask for looping & deleting data on odds14
		EXEC [dbo].[Task_Archive_Event] @winlostdate = @winlostdate ,@Action = 'subtask', @DeletedTarget = 'odds14'

		---### delete data for BingoBall14
		TRUNCATE TABLE #DeletedList
		INSERT INTO #DeletedList (id,IsDone)
		SELECT DISTINCT Matchid,0 
		FROM dbo.BingoBall14 WITH(NOLOCK) WHERE matchid IN (SELECT matchid FROM dbo.match14 WITH(NOLOCK) WHERE eventdate = @winlostdate)

		-- call subtask for looping & deleting data on BingoBall14
		EXEC [dbo].[Task_Archive_Event] @winlostdate = @winlostdate ,@Action = 'subtask', @DeletedTarget = 'BingoBall14'

		---### delete data for matchMaxbet14
		TRUNCATE TABLE #DeletedList
		INSERT INTO #DeletedList (id,IsDone)
		SELECT DISTINCT Matchid,0 
		FROM dbo.matchMaxbet14 WITH(NOLOCK) WHERE matchid IN (SELECT matchid FROM dbo.match14 WITH(NOLOCK) WHERE eventdate = @winlostdate)

		-- call subtask for looping & deleting data on matchMaxbet14
		EXEC [dbo].[Task_Archive_Event] @winlostdate = @winlostdate ,@Action = 'subtask', @DeletedTarget = 'matchMaxbet14'

		---### delete data for ResultDetail14
		TRUNCATE TABLE #DeletedList
		INSERT INTO #DeletedList (id,IsDone)
		SELECT DISTINCT Matchid,0 
		FROM dbo.ResultDetail14 WITH(NOLOCK) WHERE matchid IN (SELECT matchid FROM dbo.match14 WITH(NOLOCK) WHERE eventdate = @winlostdate)

		-- call subtask for looping & deleting data on matchMaxbet14
		EXEC [dbo].[Task_Archive_Event] @winlostdate = @winlostdate ,@Action = 'subtask', @DeletedTarget = 'ResultDetail14'

		---### delete data for ResultDetail3rd14  ###---
		TRUNCATE TABLE #DeletedList
		INSERT INTO #DeletedList (id,IsDone)
		SELECT ResultID,0 
		FROM dbo.ResultDetail3rd14 WITH(NOLOCK) WHERE matchid IN (SELECT matchid FROM dbo.match14 WITH(NOLOCK) WHERE eventdate = @winlostdate)

		-- call subtask for looping & deleting data on ResultDetail3rd14
		EXEC [dbo].[Task_Archive_Event] @winlostdate = @winlostdate ,@Action = 'subtask', @DeletedTarget = 'ResultDetail3rd14'

		---### delete data for AutoPayoutResult14
		TRUNCATE TABLE #DeletedList
		INSERT INTO #DeletedList (id,IsDone)
		SELECT DISTINCT matchid,0 
		FROM dbo.AutoPayoutResult14 WITH(NOLOCK) WHERE matchid IN (SELECT matchid FROM dbo.match14 WITH(NOLOCK) WHERE eventdate = @winlostdate)

		-- call subtask for looping & deleting data on AutoPayoutResult14
		EXEC [dbo].[Task_Archive_Event] @winlostdate = @winlostdate ,@Action = 'subtask', @DeletedTarget = 'AutoPayoutResult14'
		
		---### delete data for ProviderResultDetail14
		TRUNCATE TABLE #DeletedList
		INSERT INTO #DeletedList (id,IsDone)
		SELECT DISTINCT matchid,0 
		FROM dbo.ProviderResultDetail14 WITH(NOLOCK) WHERE matchid IN (SELECT matchid FROM dbo.match14 WITH(NOLOCK) WHERE eventdate = @winlostdate)

		-- call subtask for looping & deleting data on ProviderResultDetail14
		EXEC [dbo].[Task_Archive_Event] @winlostdate = @winlostdate ,@Action = 'subtask', @DeletedTarget = 'ProviderResultDetail14'

		---### delete data for Odds3rd14
		TRUNCATE TABLE #DeletedList
		INSERT INTO #DeletedList (id,IsDone)
		SELECT oddsID,0 
		FROM dbo.Odds3rd14 WITH(NOLOCK) WHERE matchid IN (SELECT matchid FROM dbo.match14 WITH(NOLOCK) WHERE eventdate = @winlostdate)

		-- call subtask for looping & deleting data on Odds3rd14
		EXEC [dbo].[Task_Archive_Event] @winlostdate = @winlostdate ,@Action = 'subtask', @DeletedTarget = 'Odds3rd14'


		---### delete data for outright14
		TRUNCATE TABLE #DeletedList
		INSERT INTO #DeletedList (id,IsDone)
		SELECT orid,0 
		FROM dbo.outright14 WITH(NOLOCK) WHERE eventdate = @winlostdate 

		-- call subtask for looping & deleting data on outright14
		EXEC [dbo].[Task_Archive_Event] @winlostdate = @winlostdate ,@Action = 'subtask', @DeletedTarget = 'outright14'

		---### delete data for VSOutright14
		TRUNCATE TABLE #DeletedList
		INSERT INTO #DeletedList (id,IsDone)
		SELECT orid,0 
		FROM dbo.VSOutright14 WITH(NOLOCK) WHERE eventdate = @winlostdate 

		-- call subtask for looping & deleting data on VSOutright14
		EXEC [dbo].[Task_Archive_Event] @winlostdate = @winlostdate ,@Action = 'subtask', @DeletedTarget = 'VSOutright14'

		---### delete data for EventInfo3rd14
		TRUNCATE TABLE #DeletedList
		INSERT INTO #DeletedList (id,IsDone)
		SELECT EventInfo3rdID,0 
		FROM dbo.EventInfo3rd14 WITH(NOLOCK) WHERE eventdate = @winlostdate 

		-- call subtask for looping & deleting data on EventInfo3rd14
		EXEC [dbo].[Task_Archive_Event] @winlostdate = @winlostdate ,@Action = 'subtask', @DeletedTarget = 'EventInfo3rd14'


		---### Delete data for Match3rd14
			-- 20171221@Billy -- New table Match3rd14
		TRUNCATE TABLE	#DeletedList;
		INSERT INTO	#DeletedList (id, IsDone)
		SELECT	Match3rdId, 0
		FROM	dbo.Match3rd14 WITH (NOLOCK)
		WHERE	eventdate = @winlostdate;

		-- Call subtask for looping & deleting data on Match3rd14
			-- 20171221@Billy -- New table Match3rd14
		EXECUTE	dbo.Task_Archive_Event @winlostdate = @winlostdate, @Action = 'subtask', @DeletedTarget = 'Match3rd14';


		---### Delete data for oddsES14
			-- 20181204@Billy -- New table oddsES14
		TRUNCATE TABLE	#DeletedList;
		INSERT INTO	#DeletedList (id, IsDone)
		SELECT	oes.oddsid, 0
		FROM	dbo.oddsES14 AS oes WITH (NOLOCK)
		WHERE	EXISTS (SELECT 1 FROM dbo.match14 AS m WITH (NOLOCK) WHERE oes.matchid = m.matchid AND m.eventdate = @winlostdate);

		-- Call subtask for looping & deleting data on oddsES14
			-- 20181204@Billy -- New table oddsES14
		EXECUTE	dbo.Task_Archive_Event @winlostdate = @winlostdate, @Action = 'subtask', @DeletedTarget = 'oddsES14';


		---### Delete data for ResultDetailES14
			-- 20181204@Billy -- New table ResultDetailES14
		TRUNCATE TABLE	#DeletedList;
		INSERT INTO	#DeletedList (id, IsDone)
		SELECT	rdes.MatchID, 0
		FROM	dbo.ResultDetailES14 AS rdes WITH (NOLOCK)
		WHERE	EXISTS (SELECT 1 FROM dbo.match14 AS m WITH (NOLOCK) WHERE rdes.matchid = m.matchid AND m.eventdate = @winlostdate);

		-- Call subtask for looping & deleting data on ResultDetailES14
			-- 20181204@Billy -- New table ResultDetailES14
		EXECUTE	dbo.Task_Archive_Event @winlostdate = @winlostdate, @Action = 'subtask', @DeletedTarget = 'ResultDetailES14';


		---### delete data for match14
		TRUNCATE TABLE #DeletedList
		INSERT INTO #DeletedList (id,IsDone)
		SELECT matchid,0 
		FROM dbo.match14 WITH(NOLOCK) WHERE eventdate = @winlostdate

		-- call subtask for looping & deleting data on match14
		EXEC [dbo].[Task_Archive_Event] @winlostdate = @winlostdate ,@Action = 'subtask', @DeletedTarget = 'match14'

		-- Extra Cleanup for Match_Remark
		IF DATEPART(dw, @winlostdate) = 5
		BEGIN
			-- get list
			SELECT matchid AS mid INTO #m FROM match_remark

			-- remove matchid which is current, only data left is good to remove
			DELETE #m FROM dbo.match m   WHERE #m.mid = m.matchid
			DELETE #m FROM dbo.match14 m WHERE #m.mid = m.matchid

			-- remove it
			DELETE match_Remark FROM #m WHERE match_remark.matchid = #m.mid
		END
	END -- end @action = 'delete'
	IF @Action = 'subtask'
	BEGIN
		DECLARE @ids VARCHAR(MAX), @rowcount INT = 0, @topn INT = 1000
		CREATE TABLE #output (id INT)	

		SET @rowcount = 1
		WHILE @rowcount <> 0
		BEGIN
			TRUNCATE TABLE #output
			SET @ids = NULL

			DELETE TOP(@topn) t
			OUTPUT deleted.id INTO #output(id)
			FROM #DeletedList t	
			SET @rowcount = @@ROWCOUNT 

			SELECT @ids = COALESCE(@ids + '^' + CAST(id AS VARCHAR(50)), CAST(id AS VARCHAR(50)))
			FROM #output  

			EXEC [dbo].[ExecRep_APL_03] @winlostdate = @winlostdate, @DeletedTarget = @DeletedTarget, @ids = @ids
		END
		DROP TABLE #output
	END
END
GO
GRANT VIEW DEFINITION ON dbo.Task_Archive_Event TO vnteam AS dbo;
GO
/*<info serverAlias="DBPRO-bodb02" executers="" viewers="vnteam" isFunction="0" isNested="0"></info>*/