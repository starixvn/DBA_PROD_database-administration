SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.Task_Archive_SelectBettrans14
AS
/*
Set of SP
	Task_Archive_SelectBettrans14_Init 
	Task_Archive_SelectBettrans14      : read data
	Task_Archive_SelectBettrans14_Done
*/

DECLARE @rn INT
DECLARE @wldate DATETIME, @c1 BIGINT, @c2 BIGINT


SELECT TOP 1 @rn = rn, @wldate = wldate, @c1 = c1, @c2 = c2
FROM dbo.tmp_Task_Archive_Bettrans14
ORDER BY rn

-- to DB06.bodb_Archive.dbo.bettrans_bk
SELECT 
	CONVERT(varchar(50), [betcheck]) BetCheck,
	CONVERT(varchar(1),  [betfrom]) BetFrom,
	CONVERT(varchar(10), [betteam]) BetTeam,
	CONVERT(varchar(15), [ip]) IP,
	CONVERT(varchar(10), [status]) [Status],

	[acomm],[actual_stake],[actualrate],[adiscount],[apositiontaking],[awinlost],
	[balance],[betdaqid],[betid],[bettype],
	[checktime],[comm],[comstatus],[creator],[currency],[currency2],[custid],
	[discount],[hdp1],[hdp2],[liveawayscore],[livehomescore],[liveindicator],
	[matchid],[modds],[mpositiontaking],[mrecommend],[mwinlost],[odds],[oddsid],[oddsspread],[oddstype],
	[playercomm],[playerdiscount],[recommend],[refno],[ruben],
	[scomm],[sdiscount],[SecAcceptFlag],[spositiontaking],[srecommend],[stake],[statusID],[statuswinlost],[swinlost],
	[tpositiontaking],[transdate],[transdesc],b.[transid],[transid2],[tstamp],
	[virtualrate],[winlost],b.[winlostdate]
	,IP.countryShort countryCode ,ExtraInfo, b.WalletType, b.BonusID, b.RefCode
FROM dbo.bettrans14 b WITH (NOLOCK)
	INNER JOIN dbo.Task_bettrans14_IP2Country IP WITH (NOLOCK)
	ON b.transid = IP.transid AND IP.winlostdate = @wldate
WHERE b.winlostdate = @wldate
	--AND custid BETWEEN @c1 AND @c2
GO
/*<info serverAlias="DBTXN-bodb02" executers="" viewers="" isFunction="0" isNested="0"></info>*/