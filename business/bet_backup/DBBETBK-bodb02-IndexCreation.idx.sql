/*
	Creator:	20190724@Billy
	Task:		Index for BetBackup Reject - [Redmine: #116270]
	Server:		DBBETBK.bodb02
*/


--	BEGIN STEP 1:
--		bettrans index
----------------------------------------------------------------------------------------------------

USE	bodb02;
GO

-- bettrans --
BEGIN;
	CREATE NONCLUSTERED INDEX	IX_bettrans_status_VoidReject ON dbo.bettrans (
									statusID	ASC
								)
								-- CIX (matchid, custid, bettype)
								INCLUDE	(	transid, transdate, oddsid, hdp1, hdp2, odds, stake, status, tpositiontaking, livehomescore, liveawayscore, liveindicator
										,	betteam, winlostdate, ruben, currency, transdesc
										)
								WHERE	statusID IN (101, 102)
								ON Bettrans_index3;
END;
GO


--	BEGIN STEP 2:
--		translog index
----------------------------------------------------------------------------------------------------

USE	bodb02;
GO

-- translog --
BEGIN;
	CREATE NONCLUSTERED INDEX	IX_translog_status_VoidReject ON dbo.translog (
									statusID	ASC
								)
								-- CIX (translogid)
								INCLUDE	(	custid, transdate, odds, stake, status, tpositiontaking, winlostdate, currency, transdesc
										,	productID, gameID, eventID, vendorID, GameId3rd, TranId3rd, custom1, custom2, custom3, LiveIndicator
										)
								WHERE	statusID IN (101, 102)
								ON translog_index;
END;
GO