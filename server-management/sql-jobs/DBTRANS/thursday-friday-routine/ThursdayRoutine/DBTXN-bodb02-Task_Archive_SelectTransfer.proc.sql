SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.Task_Archive_SelectTransfer
AS
/*
	Created: 
	Task:	Process will archive
			- DB06.bodb_Archive.dbo.Transfer_BK
	Database: DBTXN.bodb02

	Revisions:
		- 20110516@Henry:	change bettype to new range
		- 20150514@Viet:	adding lock type
*/
	Declare @BU_Date datetime -- Next BalanceUp Date  
	Declare @CurrentBU_Date datetime  

	SELECT @BU_Date = DATEADD(day, 1, MAX(winlostdate))
	FROM dbo.Task_ArchiveDate

	SELECT TOP 1 @CurrentBU_Date = winlostdate  
	FROM dbo.bettrans with (nolock)  
	WHERE matchid = 0 AND bettype = 20000  

-- Transfer Archive  
--INSERT INTO DB06.bodb_Archive.dbo.Transfer_BK  
--	(transid, custid, transdate, Debit, Credit, TransDesc, winlostdate, recommend, mrecommend, srecommend, bettype, currency, refno, creator)  
SELECT  
	transid, 
	custid, 
	transdate, 
	actual_stake as Debit, 
	winlost as Credit, 
	TransDesc, 
	winlostdate, 
	recommend, 
	mrecommend, 
	srecommend, 
	bettype, 
	currency, 
	refno, 
	creator  
FROM dbo.bettrans WITH(NOLOCK)
WHERE
	ruben = 1 AND
	matchid = 0 AND bettype > 20000  
	--AND winlostdate >= @CurrentBU_Date 
	AND winlostdate < @BU_Date  
	AND custid <> 0
	AND (winlost + actual_stake) <> 0
GO
/*<info serverAlias="DBTXN-bodb02" executers="" viewers="" isFunction="0" isNested="0"></info>*/