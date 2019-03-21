/*<info serverAlias="DBARC-bodb02" executers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE	[dbo].[Task_Archive_Event]
						@winlostdate	DATETIME
					,	@Action			VARCHAR(10)		= NULL -- copy / delete / subtask	
					,	@DeletedTarget	VARCHAR(100)	= ''
AS
/*
	Created: 20190318@Helen
	Database: DBARC.bodb_archive
	Original: DBPRO/bodb02/Task_Archive_Event 
	
	Revisions:
		- 20190318@Helen: Initialize - archive event timeout issue [Redimine:110447]
 */
BEGIN
	SET NOCOUNT ON;
	DECLARE @query NVARCHAR(MAX) = ''
	
	IF @Action = 'copy'
	BEGIN
		---------------Table 1: odds_bk --------------------
		SELECT	@query = N'
INSERT INTO dbo.odds_bk
	(	oddsid, matchid, bettype, switch, hdp1, hdp2, odds1a, odds2a, odds1b, odds2b, odds1c, odds2c, odds1e, odds2e, odds1f, odds2f, odds1d, odds2d, odds1hka, odds2hka, odds1hkb, odds2hkb, odds1hkc
	,	odds2hkc, odds1hke, odds2hke, odds1hkf, odds2hkf, odds1hkd, odds2hkd, oddsspreada, oddsspreadb, oddsspreadd, oddsspreade, oddsspreadf, oddsspreadc, autobookie, gapodds1, gapodds2, maxstake1
	,	maxstake2, minstake1, minstake2, diffbalance, maxodds, minodds, oddsstatus, liveindicator, changetime, risk, stakerange, newoffersetup, livehomescore, liveawayscore, creator, com1, comx, com2
	,	cs00, cs01, cs10, cs11, cs02, cs12, cs22, cs21, cs20, cs30, cs31, cs32, cs33, cs23, cs13, cs03, cs43, cs42, cs41, cs40, cs44, cs14, cs24, cs04, cs34, cs50, cs05, comstatus, csstatus, commaxbet
	,	csmaxbet, com1total, comxtotal, com2total, bal00, bal10, bal11, bal01, bal20, bal21, bal22, bal12, bal02, bal30, bal31, bal32, bal33, bal23, bal13, bal03, bal40, bal41, bal42, bal43, bal44
	,	bal34, bal24, bal14, bal04, bal50, bal05, maxbet, ht, autoreject, allowance, autosuspend, multiple, stakerange2, risk2, allowance2, site2, site3, site4, hometotal, awaytotal, sporttype
	,	tstamp, Resourceid, ResultKey, cs99, bal99)
SELECT oddsid, matchid, bettype, switch, hdp1, hdp2, odds1a, odds2a, odds1b, odds2b, odds1c, odds2c, odds1e, odds2e, odds1f, odds2f, odds1d, odds2d, odds1hka, odds2hka, odds1hkb, odds2hkb, odds1hkc
	,	odds2hkc, odds1hke, odds2hke, odds1hkf, odds2hkf, odds1hkd, odds2hkd, oddsspreada, oddsspreadb, oddsspreadd, oddsspreade, oddsspreadf, oddsspreadc, autobookie, gapodds1, gapodds2, maxstake1
	,	maxstake2, minstake1, minstake2, diffbalance, maxodds, minodds, oddsstatus, liveindicator, changetime, risk, stakerange, newoffersetup, livehomescore, liveawayscore, creator, com1, comx, com2
	,	cs00, cs01, cs10, cs11, cs02, cs12, cs22, cs21, cs20, cs30, cs31, cs32, cs33, cs23, cs13, cs03, cs43, cs42, cs41, cs40, cs44, cs14, cs24, cs04, cs34, cs50, cs05, comstatus, csstatus, commaxbet
	,	csmaxbet, com1total, comxtotal, com2total, bal00, bal10, bal11, bal01, bal20, bal21, bal22, bal12, bal02, bal30, bal31, bal32, bal33, bal23, bal13, bal03, bal40, bal41, bal42, bal43, bal44
	,	bal34, bal24, bal14, bal04, bal50, bal05, maxbet, ht, autoreject, allowance, autosuspend, multiple, stakerange2, risk2, allowance2, site2, site3, site4, hometotal, awaytotal, sporttype
	,	tstamp, Resourceid, ResultKey, cs99, bal99 
FROM OPENQUERY(DBPRO,''
DECLARE	@winlostdate SMALLDATETIME = ''''' + CONVERT(NVARCHAR(MAX), @winlostdate, 121) + ''''';
SELECT	oddsid, matchid, bettype, switch, hdp1, hdp2, odds1a, odds2a, odds1b, odds2b, odds1c, odds2c, odds1e, odds2e, odds1f, odds2f, odds1d, odds2d, odds1hka, odds2hka, odds1hkb, odds2hkb, odds1hkc
	,	odds2hkc, odds1hke, odds2hke, odds1hkf, odds2hkf, odds1hkd, odds2hkd, oddsspreada, oddsspreadb, oddsspreadd, oddsspreade, oddsspreadf, oddsspreadc, autobookie, gapodds1, gapodds2, maxstake1
	,	maxstake2, minstake1, minstake2, diffbalance, maxodds, minodds, oddsstatus, liveindicator, changetime, risk, stakerange, newoffersetup, livehomescore, liveawayscore, creator, com1, comx, com2
	,	cs00, cs01, cs10, cs11, cs02, cs12, cs22, cs21, cs20, cs30, cs31, cs32, cs33, cs23, cs13, cs03, cs43, cs42, cs41, cs40, cs44, cs14, cs24, cs04, cs34, cs50, cs05, comstatus, csstatus, commaxbet
	,	csmaxbet, com1total, comxtotal, com2total, bal00, bal10, bal11, bal01, bal20, bal21, bal22, bal12, bal02, bal30, bal31, bal32, bal33, bal23, bal13, bal03, bal40, bal41, bal42, bal43, bal44
	,	bal34, bal24, bal14, bal04, bal50, bal05, maxbet, ht, autoreject, allowance, autosuspend, multiple, stakerange2, risk2, allowance2, site2, site3, site4, hometotal, awaytotal, sporttype
	,	tstamp, Resourceid, ResultKey, cs99, bal99
FROM	bodb02.dbo.odds14 AS t1 WITH (NOLOCK)
WHERE EXISTS (SELECT 1 FROM bodb02.dbo.match14 AS t2 WITH (NOLOCK) WHERE t1.matchid = t2.matchid AND t2.eventdate = @winlostdate);'')'

		EXECUTE	sys.sp_executesql @query
		
		---------------Table 2: match_bk --------------------
		SELECT	@query = N'
INSERT INTO dbo.match_bk(matchid, leagueid, homeid, awayid, eventdate, eventstatus, betstatus, livehomescore, liveawayscore,
				finalhomescore, finalawayscore, creator, matchcode, kickofftime, closedtime, showtime,
				hthomescore, htawayscore, ruben, multiple, yenbet, exrisk, sporttype, tstamp,
				homeid2, awayid2, DisplayMode, LeaguePatternID, HomeDisplayPatternID, AwayDisplayPatternID, IsNeutral, GoalRecord, GlobalShowTime, ParentID)
				
SELECT matchid, leagueid, homeid, awayid, eventdate, eventstatus, betstatus, livehomescore, liveawayscore,
				finalhomescore, finalawayscore, creator, matchcode, kickofftime, closedtime, showtime,
				hthomescore, htawayscore, ruben, multiple, yenbet, exrisk, sporttype, tstamp,
				homeid2, awayid2, DisplayMode, LeaguePatternID, HomeDisplayPatternID, AwayDisplayPatternID, IsNeutral, GoalRecord, GlobalShowTime, ParentID 
FROM OPENQUERY(DBPRO,''
DECLARE	@winlostdate SMALLDATETIME = ''''' + CONVERT(NVARCHAR(MAX), @winlostdate, 121) + ''''';
SELECT	matchid, leagueid, homeid, awayid, eventdate, eventstatus, betstatus, livehomescore, liveawayscore,
				finalhomescore, finalawayscore, creator, matchcode, kickofftime, closedtime, showtime,
				hthomescore, htawayscore, ruben, multiple, yenbet, exrisk, sporttype, tstamp,
				homeid2, awayid2, DisplayMode, LeaguePatternID, HomeDisplayPatternID, AwayDisplayPatternID, IsNeutral, GoalRecord, GlobalShowTime, ParentID
FROM	bodb02.dbo.match14 AS t1  WITH (NOLOCK)
WHERE t1.eventdate = @winlostdate;'')'

		EXECUTE	sys.sp_executesql @query
			
		---------------Table 3: bingoBall_bk --------------------		
		SELECT	@query = N'
INSERT INTO dbo.bingoBall_bk([Matchid], [Seq], [Number], [UpdateTime])
SELECT	[Matchid], [Seq], [Number], [UpdateTime]
FROM OPENQUERY(DBPRO,''
DECLARE	@winlostdate SMALLDATETIME = ''''' + CONVERT(NVARCHAR(MAX), @winlostdate, 121) + ''''';
SELECT		[Matchid], [Seq], [Number], [UpdateTime]
FROM	bodb02.dbo.BingoBall14 AS t1  WITH (NOLOCK)
WHERE EXISTS (SELECT 1 FROM bodb02.dbo.match14 AS t2 WITH (NOLOCK) WHERE t1.matchid = t2.matchid AND t2.eventdate = @winlostdate);'')'

		EXECUTE	sys.sp_executesql @query

		---------------Table 4: outright_bk --------------------
		SELECT	@query = N'
INSERT INTO dbo.outright_bk(orid, leagueid, teamid, eventdate, kickofftime, oddsstatus, odds, maxbet, gapodds, matchcode, groupmatch, status, creator, bal, risk, 
			DisplayMode, PlaceOdds, Placing, IsFavor, IsSCR, ProgramID, 
			FOddsStatus, SCRTime, LeaguePatternID, TeamPatternID, ProgramDate, IsDeadHeat, autosuspend, EventID, Year)
				
SELECT orid, leagueid, teamid, eventdate, kickofftime, oddsstatus, odds, maxbet, gapodds, matchcode, groupmatch, status, creator, bal, risk, 
			DisplayMode, PlaceOdds, Placing, IsFavor, IsSCR, ProgramID, 
			FOddsStatus, SCRTime, LeaguePatternID, TeamPatternID, ProgramDate, IsDeadHeat, autosuspend, EventID, Year
FROM OPENQUERY(DBPRO,''
DECLARE	@winlostdate SMALLDATETIME = ''''' + CONVERT(NVARCHAR(MAX), @winlostdate, 121) + ''''';
SELECT	orid, leagueid, teamid, eventdate, kickofftime, oddsstatus, odds, maxbet, gapodds, matchcode, groupmatch, status, creator, bal, risk, 
			DisplayMode, PlaceOdds, Placing, IsFavor, IsSCR, ProgramID, 
			FOddsStatus, SCRTime, LeaguePatternID, TeamPatternID, ProgramDate, IsDeadHeat, autosuspend, EventID, Year
FROM	bodb02.dbo.outright14 AS t1  WITH (NOLOCK)
WHERE t1.eventdate = @winlostdate;'')'

		EXECUTE	sys.sp_executesql @query
		
		---------------Table 5: VSOutright_bk --------------------
		SELECT	@query = N'
INSERT INTO dbo.VSOutright_bk(Orid, EventID, RacerNum, IsFavor, EventDate, KickoffTime, RacerID, HumanID, WinOdds, PlaceOdds, 
			Lane, MaxBet, Placing, Creator, EventStatus)
SELECT Orid, EventID, RacerNum, IsFavor, EventDate, KickoffTime, RacerID, HumanID, WinOdds, PlaceOdds, 
			Lane, MaxBet, Placing, Creator, EventStatus
FROM OPENQUERY(DBPRO,''
DECLARE	@winlostdate SMALLDATETIME = ''''' + CONVERT(NVARCHAR(MAX), @winlostdate, 121) + ''''';
SELECT	Orid, EventID, RacerNum, IsFavor, EventDate, KickoffTime, RacerID, HumanID, WinOdds, PlaceOdds, 
			Lane, MaxBet, Placing, Creator, EventStatus
FROM	bodb02.dbo.VSOutright14 AS t1  WITH (NOLOCK)
WHERE t1.eventdate = @winlostdate;'')'

		EXECUTE	sys.sp_executesql @query
		
		---------------Table 6: match_remark -----------------------------
		SELECT	@query = N'
INSERT INTO dbo.match_remark(matchid, calculate, multiple, calrefund, refund, calStatus, IsTotalBetDenied_1, IsTotalBetDenied_3, IsTotalBetDenied_7, IsTotalBetDenied_8, LiveTimer, HomeRedCard, AwayRedCard
			,	LivePeriod, HedgeForecast, IsTotalBetDenied_20, IsTotalBetDenied_21, IsNeutral, StreamingID, IsInternal, IsHTCal, LiveDeleteChecker, HomeColor, AwayColor, ConfirmHT, ConfirmFT
			,	PausePeriod, TimerSuspend, IsPending, isUndecided, StdDelBetCheck, HomeSubstitutes, AwaySubstitutes, StartTeam, HomePenalty, AwayPenalty, HomeYellowCard, AwayYellowCard, Tier)
SELECT	matchid, calculate, multiple, calrefund, refund, calStatus, IsTotalBetDenied_1, IsTotalBetDenied_3, IsTotalBetDenied_7, IsTotalBetDenied_8, LiveTimer, HomeRedCard, AwayRedCard
			,	LivePeriod, HedgeForecast, IsTotalBetDenied_20, IsTotalBetDenied_21, IsNeutral, StreamingID, IsInternal, IsHTCal, LiveDeleteChecker, HomeColor, AwayColor, ConfirmHT, ConfirmFT
			,	PausePeriod, TimerSuspend, IsPending, isUndecided, StdDelBetCheck, HomeSubstitutes, AwaySubstitutes, StartTeam, HomePenalty, AwayPenalty, HomeYellowCard, AwayYellowCard, Tier
FROM OPENQUERY(DBPRO,''
DECLARE	@winlostdate SMALLDATETIME = ''''' + CONVERT(NVARCHAR(MAX), @winlostdate, 121) + ''''';
SELECT		matchid, calculate, multiple, calrefund, refund, calStatus, IsTotalBetDenied_1, IsTotalBetDenied_3, IsTotalBetDenied_7, IsTotalBetDenied_8, LiveTimer, HomeRedCard, AwayRedCard
			,	LivePeriod, HedgeForecast, IsTotalBetDenied_20, IsTotalBetDenied_21, IsNeutral, StreamingID, IsInternal, IsHTCal, LiveDeleteChecker, HomeColor, AwayColor, ConfirmHT, ConfirmFT
			,	PausePeriod, TimerSuspend, IsPending, isUndecided, StdDelBetCheck, HomeSubstitutes, AwaySubstitutes, StartTeam, HomePenalty, AwayPenalty, HomeYellowCard, AwayYellowCard, Tier
FROM	bodb02.dbo.match_remark AS t1  WITH (NOLOCK)
WHERE EXISTS (SELECT 1 FROM bodb02.dbo.match14 AS t2 WITH (NOLOCK) WHERE t1.matchid = t2.matchid AND t2.eventdate = @winlostdate);'')'

		EXECUTE	sys.sp_executesql @query
	
		---------------Table 7: MatchMaxbet_bk -----------------------------
		SELECT	@query = N'
INSERT INTO dbo.MatchMaxbet_bk(MatchId, BetType, Maxbet, OperatorId, Spread)
SELECT	MatchId, BetType, Maxbet, OperatorId, Spread
FROM OPENQUERY(DBPRO,''
DECLARE	@winlostdate SMALLDATETIME = ''''' + CONVERT(NVARCHAR(MAX), @winlostdate, 121) + ''''';
SELECT	MatchId, BetType, Maxbet, OperatorId, Spread
FROM	bodb02.dbo.matchMaxbet14 AS t1  WITH (NOLOCK)
WHERE EXISTS (SELECT 1 FROM bodb02.dbo.match14 AS t2 WITH (NOLOCK) WHERE t1.matchid = t2.matchid AND t2.eventdate = @winlostdate);'')'

		EXECUTE	sys.sp_executesql @query
		
		---------------Table 8:  ResultDetail_bk -----------------------------
		SELECT	@query = N'
INSERT INTO dbo.ResultDetail_bk(MatchId, ResourceId, HomeValue, AwayValue, ResultStatusID, SettlementStatusID, CreateDate, LastModifyDate, CreateBy, LastModifyBy, OtherInfo)
SELECT	MatchId, ResourceId, HomeValue, AwayValue, ResultStatusID, SettlementStatusID, CreateDate, LastModifyDate, CreateBy, LastModifyBy, OtherInfo
FROM OPENQUERY(DBPRO,''
DECLARE	@winlostdate SMALLDATETIME = ''''' + CONVERT(NVARCHAR(MAX), @winlostdate, 121) + ''''';
SELECT		MatchId, ResourceId, HomeValue, AwayValue, ResultStatusID, SettlementStatusID, CreateDate, LastModifyDate, CreateBy, LastModifyBy, OtherInfo
FROM	bodb02.dbo.ResultDetail14 AS t1  WITH (NOLOCK)
WHERE EXISTS (SELECT 1 FROM bodb02.dbo.match14 AS t2 WITH (NOLOCK) WHERE t1.matchid = t2.matchid AND t2.eventdate = @winlostdate);'')'

		EXECUTE	sys.sp_executesql @query
		
		---------------Table 9:  ResultDetail3rd_bk -----------------------------
		SELECT	@query = N'
INSERT INTO dbo.ResultDetail3rd_bk(ResultID, VendorID, MatchID, GameID, Custom1, Custom2, Custom3, ResultStatusID, SettlementStatusID, GameResult, OtherInfo, CreateBy, CreateDate, LastModifyBy, LastModifyDate, ResourceId)
SELECT	ResultID, VendorID, MatchID, GameID, Custom1, Custom2, Custom3, ResultStatusID, SettlementStatusID, GameResult, OtherInfo, CreateBy, CreateDate, LastModifyBy, LastModifyDate, ResourceId
FROM OPENQUERY(DBPRO,''
DECLARE	@winlostdate SMALLDATETIME = ''''' + CONVERT(NVARCHAR(MAX), @winlostdate, 121) + ''''';
SELECT		ResultID, VendorID, MatchID, GameID, Custom1, Custom2, Custom3, ResultStatusID, SettlementStatusID, GameResult, OtherInfo, CreateBy, CreateDate, LastModifyBy, LastModifyDate, ResourceId
FROM	bodb02.dbo.ResultDetail3rd14 AS t1  WITH (NOLOCK)
WHERE EXISTS (SELECT 1 FROM bodb02.dbo.match14 AS t2 WITH (NOLOCK) WHERE t1.matchid = t2.matchid AND t2.eventdate = @winlostdate);'')'

		EXECUTE	sys.sp_executesql @query
		
		---------------Table 10:  EventInfo3rd_bk -----------------------------
		SELECT	@query = N'
INSERT INTO dbo.EventInfo3rd_bk(EventInfo3rdId,ArenaID,FightNo,EventDate,HomeOwner,AwayOwner)
SELECT	EventInfo3rdId,ArenaID,FightNo,EventDate,HomeOwner,AwayOwner
FROM OPENQUERY(DBPRO,''
DECLARE	@winlostdate SMALLDATETIME = ''''' + CONVERT(NVARCHAR(MAX), @winlostdate, 121) + ''''';
SELECT	EventInfo3rdId,ArenaID,FightNo,EventDate,HomeOwner,AwayOwner
FROM	bodb02.dbo.EventInfo3rd14 AS t1  WITH (NOLOCK)
WHERE t1.eventdate = @winlostdate;'')'

		EXECUTE	sys.sp_executesql @query
		
		---------------Table 11:  AutoPayoutResult_bk -----------------------------
		SELECT	@query = N'
INSERT INTO dbo.AutoPayoutResult_bk(AutoPayoutResultId, MatchId, CalculationType, SourceId, HomeValue, AwayValue, StatusId, TryCount, CreatedDate, ModifiedDate)
SELECT	AutoPayoutResultId, MatchId, CalculationType, SourceId, HomeValue, AwayValue, StatusId, TryCount, CreatedDate, ModifiedDate
FROM OPENQUERY(DBPRO,''
DECLARE	@winlostdate SMALLDATETIME = ''''' + CONVERT(NVARCHAR(MAX), @winlostdate, 121) + ''''';
SELECT AutoPayoutResultId, MatchId, CalculationType, SourceId, HomeValue, AwayValue, StatusId, TryCount, CreatedDate, ModifiedDate
FROM	bodb02.dbo.AutoPayoutResult14 AS t1  WITH (NOLOCK)
WHERE EXISTS (SELECT 1 FROM bodb02.dbo.match14 AS t2 WITH (NOLOCK) WHERE t1.matchid = t2.matchid AND t2.eventdate = @winlostdate);'')'

		EXECUTE	sys.sp_executesql @query
		
		---------------Table 12:  ProviderResultDetail_bk -----------------------------
		SELECT	@query = N'
INSERT INTO dbo.ProviderResultDetail_bk(ProviderResultDetailId, MatchId, SourceId, TypeId, HomeValue, AwayValue, CreatedDate, IsConfirmed)
SELECT	ProviderResultDetailId, MatchId, SourceId, TypeId, HomeValue, AwayValue, CreatedDate, IsConfirmed
FROM OPENQUERY(DBPRO,''
DECLARE	@winlostdate SMALLDATETIME = ''''' + CONVERT(NVARCHAR(MAX), @winlostdate, 121) + ''''';
SELECT ProviderResultDetailId, MatchId, SourceId, TypeId, HomeValue, AwayValue, CreatedDate, IsConfirmed
FROM	bodb02.dbo.ProviderResultDetail14 AS t1  WITH (NOLOCK)
WHERE EXISTS (SELECT 1 FROM bodb02.dbo.match14 AS t2 WITH (NOLOCK) WHERE t1.matchid = t2.matchid AND t2.eventdate = @winlostdate);'')'

		EXECUTE	sys.sp_executesql @query
		
		---------------Table 13:  Odds3rd_bk -----------------------------
		SELECT	@query = N'
INSERT INTO dbo.Odds3rd_bk(oddsid, matchid, odds3rdid, bettype, hdp1, hdp2, odds1a, odds2a, oddsstatus, changetime, creator, com1, comx, com2, cs00, cs01, cs10, cs11, cs02, cs12, cs22, cs21, cs20, cs30, cs31, cs32, cs33, cs23, cs13, cs03, cs99, sporttype, cs04, cs05, Resourceid)
SELECT	oddsid, matchid, odds3rdid, bettype, hdp1, hdp2, odds1a, odds2a, oddsstatus, changetime, creator, com1, comx, com2, cs00, cs01, cs10, cs11, cs02, cs12, cs22, cs21, cs20, cs30, cs31, cs32, cs33, cs23, cs13, cs03, cs99, sporttype, cs04, cs05, Resourceid
FROM OPENQUERY(DBPRO,''
DECLARE	@winlostdate SMALLDATETIME = ''''' + CONVERT(NVARCHAR(MAX), @winlostdate, 121) + ''''';
SELECT oddsid, matchid, odds3rdid, bettype, hdp1, hdp2, odds1a, odds2a, oddsstatus, changetime, creator, com1, comx, com2, cs00, cs01, cs10, cs11, cs02, cs12, cs22, cs21, cs20, cs30, cs31, cs32, cs33, cs23, cs13, cs03, cs99, sporttype, cs04, cs05, Resourceid
FROM	bodb02.dbo.Odds3rd14 AS t1  WITH (NOLOCK)
WHERE EXISTS (SELECT 1 FROM bodb02.dbo.match14 AS t2 WITH (NOLOCK) WHERE t1.matchid = t2.matchid AND t2.eventdate = @winlostdate);'')'

		EXECUTE	sys.sp_executesql @query
		
		---------------Table 14:  Intg_OddsFeed_SettlementAction_bk -----------------------------
		SELECT	@query = N'
INSERT INTO dbo.Intg_OddsFeed_SettlementAction_bk(ActionId, LeagueId, MatchId, ActionType, HTHomeScore, HTAwayScore, FTHomeScore, FTAwayScore, CreateTime, OtherInfo)
SELECT	ActionId, LeagueId, MatchId, ActionType, HTHomeScore, HTAwayScore, FTHomeScore, FTAwayScore, CreateTime, OtherInfo
FROM OPENQUERY(DBPRO,''
DECLARE	@winlostdate SMALLDATETIME = ''''' + CONVERT(NVARCHAR(MAX), @winlostdate, 121) + ''''';
SELECT ActionId, LeagueId, MatchId, ActionType, HTHomeScore, HTAwayScore, FTHomeScore, FTAwayScore, CreateTime, OtherInfo
FROM	bodb02.dbo.Intg_OddsFeed_SettlementAction AS t1  WITH (NOLOCK)
WHERE EXISTS (SELECT 1 FROM bodb02.dbo.match14 AS t2 WITH (NOLOCK) WHERE t1.matchid = t2.matchid AND t2.eventdate = @winlostdate);'')'

		EXECUTE	sys.sp_executesql @query
	
		---------------Table 15:  Intg_OddsFeed_SettlementAction_Outright_bk -----------------------------
		SELECT	@query = N'
INSERT INTO dbo.Intg_OddsFeed_SettlementAction_Outright_bk(ActionId, ActionType, OrId, LeagueId, TeamId, Status, IsDeadheat, Deadheat, CreateTime)
SELECT	ActionId, ActionType, OrId, LeagueId, TeamId, Status, IsDeadheat, Deadheat, CreateTime
FROM OPENQUERY(DBPRO,''
DECLARE	@winlostdate SMALLDATETIME = ''''' + CONVERT(NVARCHAR(MAX), @winlostdate, 121) + ''''';
SELECT ActionId, ActionType, OrId, LeagueId, TeamId, Status, IsDeadheat, Deadheat, CreateTime
FROM	bodb02.dbo.Intg_OddsFeed_SettlementAction_Outright AS t1  WITH (NOLOCK)
WHERE EXISTS (SELECT 1 FROM bodb02.dbo.outright14 AS t2 WITH (NOLOCK) WHERE t1.orid = t2.orid AND t2.eventdate = @winlostdate);'')'

		EXECUTE	sys.sp_executesql @query
		
		---------------Table 16:  Match3rd_bk -----------------------------
		SELECT	@query = N'
INSERT INTO dbo.Match3rd_bk(Match3rdId, League3rdId, HomeId, AwayId, EventDate, SportType, VendorMatchId, MatchNo, HasLive, EventStatus, VendorEventStatus, CreateTime, UpdateTime, VendorEventDate, GameResultDate)
SELECT	Match3rdId, League3rdId, HomeId, AwayId, EventDate, SportType, VendorMatchId, MatchNo, HasLive, EventStatus, VendorEventStatus, CreateTime, UpdateTime, VendorEventDate, GameResultDate
FROM OPENQUERY(DBPRO,''
DECLARE	@winlostdate SMALLDATETIME = ''''' + CONVERT(NVARCHAR(MAX), @winlostdate, 121) + ''''';
SELECT Match3rdId, League3rdId, HomeId, AwayId, EventDate, SportType, VendorMatchId, MatchNo, HasLive, EventStatus, VendorEventStatus, CreateTime, UpdateTime, VendorEventDate, GameResultDate
FROM	bodb02.dbo.Match3rd14 AS t1  WITH (NOLOCK)
WHERE t1.eventdate = @winlostdate;'')'

		EXECUTE	sys.sp_executesql @query
		
		---------------Table 17:  oddsES_bk -----------------------------
		SELECT	@query = N'
INSERT INTO dbo.oddsES_bk(oddsid, matchid, bettype, switch, hdp1, hdp2, odds1a, odds2a, oddsspreada, autobookie, gapodds1, gapodds2, diffbalance, maxodds, minodds, oddsstatus, liveindicator, changetime, risk, stakerange
			,	newoffersetup, livehomescore, liveawayscore, creator, com1, com2, csstatus, maxbet, autosuspend, stakerange2, risk2, site3, sporttype, HasBeenLinked, Resourceid, Category, IncreaseMaxbet
			,	odds1aH, odds2aH, IsCopyDeadball, GoalLineDiff, IsStatusIndep, ParentOddsId, RefOddsSP, RefOddsH, RefOddsA, RefTrueOdds, CurrentTrueOdds, EnableVirtualRate, TraderId)
SELECT	oddsid, matchid, bettype, switch, hdp1, hdp2, odds1a, odds2a, oddsspreada, autobookie, gapodds1, gapodds2, diffbalance, maxodds, minodds, oddsstatus, liveindicator, changetime, risk, stakerange
			,	newoffersetup, livehomescore, liveawayscore, creator, com1, com2, csstatus, maxbet, autosuspend, stakerange2, risk2, site3, sporttype, HasBeenLinked, Resourceid, Category, IncreaseMaxbet
			,	odds1aH, odds2aH, IsCopyDeadball, GoalLineDiff, IsStatusIndep, ParentOddsId, RefOddsSP, RefOddsH, RefOddsA, RefTrueOdds, CurrentTrueOdds, EnableVirtualRate, TraderId
FROM OPENQUERY(DBPRO,''
DECLARE	@winlostdate SMALLDATETIME = ''''' + CONVERT(NVARCHAR(MAX), @winlostdate, 121) + ''''';
SELECT oddsid, matchid, bettype, switch, hdp1, hdp2, odds1a, odds2a, oddsspreada, autobookie, gapodds1, gapodds2, diffbalance, maxodds, minodds, oddsstatus, liveindicator, changetime, risk, stakerange
			,	newoffersetup, livehomescore, liveawayscore, creator, com1, com2, csstatus, maxbet, autosuspend, stakerange2, risk2, site3, sporttype, HasBeenLinked, Resourceid, Category, IncreaseMaxbet
			,	odds1aH, odds2aH, IsCopyDeadball, GoalLineDiff, IsStatusIndep, ParentOddsId, RefOddsSP, RefOddsH, RefOddsA, RefTrueOdds, CurrentTrueOdds, EnableVirtualRate, TraderId
FROM	bodb02.dbo.oddsES14 AS t1  WITH (NOLOCK)
WHERE EXISTS (SELECT 1 FROM bodb02.dbo.match14 AS t2 WITH (NOLOCK) WHERE t1.matchid = t2.matchid AND t2.eventdate = @winlostdate);'')'

		EXECUTE	sys.sp_executesql @query
		
		---------------Table 18:  ResultDetailES_bk -----------------------------
		SELECT	@query = N'
INSERT INTO dbo.ResultDetailES_bk(MatchID, ResourceID, HomeValue, AwayValue, ResultStatusID, SettlementStatusID, CreateBy, CreateDate, LastModifyBy, LastModifyDate, OtherInfo)
SELECT	MatchID, ResourceID, HomeValue, AwayValue, ResultStatusID, SettlementStatusID, CreateBy, CreateDate, LastModifyBy, LastModifyDate, OtherInfo
FROM OPENQUERY(DBPRO,''
DECLARE	@winlostdate SMALLDATETIME = ''''' + CONVERT(NVARCHAR(MAX), @winlostdate, 121) + ''''';
SELECT MatchID, ResourceID, HomeValue, AwayValue, ResultStatusID, SettlementStatusID, CreateBy, CreateDate, LastModifyBy, LastModifyDate, OtherInfo
FROM	bodb02.dbo.ResultDetailES14 AS t1  WITH (NOLOCK)
WHERE EXISTS (SELECT 1 FROM bodb02.dbo.match14 AS t2 WITH (NOLOCK) WHERE t1.matchid = t2.matchid AND t2.eventdate = @winlostdate);'')'

		EXECUTE	sys.sp_executesql @query
		
	END	
END

GO