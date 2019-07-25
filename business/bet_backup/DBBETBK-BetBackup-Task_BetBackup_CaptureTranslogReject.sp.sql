SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.Task_BetBackup_CaptureTranslogReject
AS
/*
	Creator:	20190724@Billy
	Task:		Capture rejected tickets in translog for BetBackup - [Redmine: #116270]
	Database:	DBBETBK.BetBackup

	Revisions:
		- 20190724@Billy:	Initial - [Redmine: #116270]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET NOCOUNT ON;

	INSERT INTO	dbo.translogReject
		(	translogid, custid, transdate, odds, stake, status, tpositiontaking, winlostdate, currency, transdesc, productID, gameID, eventID, vendorID, GameId3rd, TranId3rd, custom1, custom2, custom3, LiveIndicator, BackupDate)
	SELECT	translogid, custid, transdate, odds, stake, status, tpositiontaking, winlostdate, currency, transdesc, productID, gameID, eventID, vendorID, GameId3rd, TranId3rd, custom1, custom2, custom3, LiveIndicator, GETDATE()
	FROM	bodb02.dbo.translog AS t WITH (NOLOCK)
	WHERE	t.statusID IN (101, 102)
		AND	NOT EXISTS (SELECT 1 FROM dbo.translogReject AS tr WITH (NOLOCK) WHERE t.translogid = tr.translogid);
END;
GO
/*<info serverAlias="DBBETBK-BetBackup" executers="" viewers="" isFunction="0" isNested="0"></info>*/