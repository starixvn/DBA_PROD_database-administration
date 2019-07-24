/*
	Creator:	20190723@Billy
	Task:		Triggers for BetBackup - [Redmine: #116270]
	Server:		DBBETBK.bodb02
*/


--	BEGIN STEP 1:
--		Trigger for bettrans
----------------------------------------------------------------------------------------------------

USE	bodb02;
GO
CREATE TRIGGER	dbo.Tr_bettrans_AfterInsert_BetBackup ON dbo.bettrans
AFTER INSERT
AS
/*
	Creator:	20190723@Billy
	Task:		Insert BetBackup for bettrans - [Redmine: #116270]
	Database:	DBBETBK.bodb02

	Revisions:
		- 20190723@Billy:	Initial - [Redmine: #116270]
*/
BEGIN;
	SET NOCOUNT ON;

	INSERT INTO	BetBackup.dbo.bettrans
		(	transid, custid, transdate, oddsid, hdp1, hdp2, odds, stake, status, winlost, awinlost, mwinlost, playercomm, comm
		,	acomm, apositiontaking, mpositiontaking, tpositiontaking, playerdiscount, discount, adiscount, livehomescore, liveawayscore
		,	liveindicator, betteam, creator, refno, comstatus, winlostdate, betfrom, betcheck, checktime, oddsspread, actualrate
		,	matchid, recommend, mrecommend, ruben, betid, statuswinlost, modds, bettype, betdaqid, currency, transdesc
		,	sdiscount, scomm, spositiontaking, srecommend, ExtraInfo, WalletType, BonusID, RefCode
		,	BackupDate
		)
	SELECT	transid, custid, transdate, oddsid, hdp1, hdp2, odds, stake, status, winlost, awinlost, mwinlost, playercomm, comm
		,	acomm, apositiontaking, mpositiontaking, tpositiontaking, playerdiscount, discount, adiscount, livehomescore, liveawayscore
		,	liveindicator, betteam, creator, refno, comstatus, winlostdate, betfrom, betcheck, checktime, oddsspread, actualrate
		,	matchid, recommend, mrecommend, ruben, betid, statuswinlost, modds, bettype, betdaqid, currency, transdesc
		,	sdiscount, scomm, spositiontaking, srecommend, ExtraInfo, WalletType, BonusID, RefCode
		,	BackupDate = GETDATE()
	FROM	Inserted
	WHERE	bettype < 19999;
END;
GO


--	BEGIN STEP 2:
--		Trigger for bettransm
----------------------------------------------------------------------------------------------------

USE	bodb02;
GO
CREATE TRIGGER	dbo.Tr_bettransm_AfterInsert_BetBackup ON dbo.bettransm
AFTER INSERT
AS
/*
	Creator:	20190723@Billy
	Task:		Insert BetBackup for bettransm - [Redmine: #116270]
	Database:	DBBETBK.bodb02

	Revisions:
		- 20190723@Billy:	Initial - [Redmine: #116270]
*/
BEGIN;
	SET NOCOUNT ON;

	INSERT INTO	BetBackup.dbo.bettransm
		(	transid, custid, transdate, oddsid, hdp1, hdp2, odds, stake, status, winlost, livehomescore, liveawayscore, liveindicator
		,	betteam, refno, comstatus, winlostdate, betfrom, matchid, matchdate, finalodds, bettype
		,	BackupDate
		)
	SELECT	transid, custid, transdate, oddsid, hdp1, hdp2, odds, stake, status, winlost, livehomescore, liveawayscore, liveindicator
		,	betteam, refno, comstatus, winlostdate, betfrom, matchid, matchdate, finalodds, bettype
		,	BackupDate = GETDATE()
	FROM	Inserted
	WHERE	bettype < 19999;
END;
GO


--	BEGIN STEP 3:
--		Trigger for translog
----------------------------------------------------------------------------------------------------

USE	bodb02;
GO
CREATE TRIGGER	dbo.Tr_translog_AfterInsert_BetBackup ON dbo.translog
AFTER INSERT
AS
/*
	Creator:	20190723@Billy
	Task:		Insert BetBackup for translog - [Redmine: #116270]
	Database:	DBBETBK.bodb02

	Revisions:
		- 20190723@Billy:	Initial - [Redmine: #116270]
*/
BEGIN;
	SET NOCOUNT ON;

	INSERT INTO	BetBackup.dbo.translog
		(	translogid, custid, transdate, odds, stake, status, tpositiontaking, winlostdate, currency, transdesc
		,	productID, gameID, eventID, vendorID, GameId3rd, TranId3rd, custom1, custom2, custom3, LiveIndicator
		,	BackupDate
		)
	SELECT	translogid, custid, transdate, odds, stake, status, tpositiontaking, winlostdate, currency, transdesc
		,	productID, gameID, eventID, vendorID, GameId3rd, TranId3rd, custom1, custom2, custom3, LiveIndicator
		,	[BackupDate] = GETDATE()
	FROM	Inserted;
END;
GO