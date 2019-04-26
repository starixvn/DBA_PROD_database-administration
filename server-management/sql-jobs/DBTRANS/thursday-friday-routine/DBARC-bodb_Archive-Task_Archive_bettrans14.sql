SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.Task_Archive_bettrans14
AS

INSERT INTO dbo.bettrans_bk (
	BetCheck, BetFrom, BetTeam, IP, [Status],

	[acomm],[actual_stake],[actualrate],[adiscount],[apositiontaking],[awinlost],
	[balance],[betdaqid],[betid],[bettype],
	[checktime],[comm],[comstatus],[creator],[currency],[currency2],[custid],
	[discount],[hdp1],[hdp2],[liveawayscore],[livehomescore],[liveindicator],
	[matchid],[modds],[mpositiontaking],[mrecommend],[mwinlost],[odds],[oddsid],[oddsspread],[oddstype],
	[playercomm],[playerdiscount],[recommend],[refno],[ruben],
	[scomm],[sdiscount],[SecAcceptFlag],[spositiontaking],[srecommend],[stake],[statusID],[statuswinlost],[swinlost],
	[tpositiontaking],[transdate],[transdesc],[transid],[transid2],[tstamp],
	[virtualrate],[winlost],[winlostdate],
	countryCode, ExtraInfo, WalletType, BonusID, RefCode
	)
SELECT 
	BetCheck, BetFrom, BetTeam, IP, [Status],

	[acomm],[actual_stake],[actualrate],[adiscount],[apositiontaking],[awinlost],
	[balance],[betdaqid],[betid],[bettype],
	[checktime],[comm],[comstatus],[creator],[currency],[currency2],[custid],
	[discount],[hdp1],[hdp2],[liveawayscore],[livehomescore],[liveindicator],
	[matchid],[modds],[mpositiontaking],[mrecommend],[mwinlost],[odds],[oddsid],[oddsspread],[oddstype],
	[playercomm],[playerdiscount],[recommend],[refno],[ruben],
	[scomm],[sdiscount],[SecAcceptFlag],[spositiontaking],[srecommend],[stake],[statusID],[statuswinlost],[swinlost],
	[tpositiontaking],[transdate],[transdesc],[transid],[transid2],[tstamp],
	[virtualrate],[winlost],[winlostdate],
	countryCode, ExtraInfo, WalletType, BonusID, RefCode
FROM
	OPENQUERY(DBTRANS,'EXEC bodb02.dbo.Task_Archive_SelectBettrans14')


IF @@ROWCOUNT = 0
BEGIN
	-- raiserror here to continue to next step of jobs
	RAISERROR ('* no more data *', -- Message text.
               16, -- Severity.
               1 -- State.
               );
END
GO
/*<info serverAlias="DBARC-bodb_Archive" executers="" viewers="" isFunction="0" isNested="0"></info>*/