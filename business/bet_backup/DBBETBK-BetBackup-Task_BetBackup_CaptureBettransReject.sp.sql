SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.Task_BetBackup_CaptureBettransReject
AS
/*
	Creator:	20190724@Billy
	Task:		Capture rejected tickets in bettrans for BetBackup - [Redmine: #116270]
	Database:	DBBETBK.BetBackup

	Revisions:
		- 20190724@Billy:	Initial - [Redmine: #116270]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET NOCOUNT ON;

	INSERT INTO	dbo.bettransReject
		(	transid, custid, transdate, oddsid, hdp1, hdp2, odds, stake, status, tpositiontaking, livehomescore, liveawayscore, liveindicator, betteam, winlostdate, matchid, ruben, bettype, currency, transdesc, BackupDate)
	SELECT	transid, custid, transdate, oddsid, hdp1, hdp2, odds, stake, status, tpositiontaking, livehomescore, liveawayscore, liveindicator, betteam, winlostdate, matchid, ruben, bettype, currency, transdesc, GETDATE()
	FROM	bodb02.dbo.bettrans AS b WITH (NOLOCK)
	WHERE	b.statusID IN (101, 102)
		AND	NOT EXISTS (SELECT 1 FROM dbo.bettransReject AS br WITH (NOLOCK) WHERE b.transid = br.transid);
END;
GO
/*<info serverAlias="DBBETBK-BetBackup" executers="" viewers="" isFunction="0" isNested="0"></info>*/