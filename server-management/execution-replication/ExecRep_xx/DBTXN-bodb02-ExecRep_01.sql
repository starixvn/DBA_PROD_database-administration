USE	bodb02;
GO

ALTER PROCEDURE [dbo].[ExecRep_01] 
	@Target VARCHAR(30) = 'DBTRANS' -- DBTRANS/REPLICATED
AS
BEGIN
	IF @Target NOT IN ('DBTRANS', 'REPLICATED') RETURN
	IF @Target = 'DBTRANS' AND @@SERVERNAME <> 'DBTRANS' RETURN
	IF @Target = 'REPLICATED' AND @@SERVERNAME = 'DBTRANS' RETURN

	if NOT exists (select * from dbo.sysobjects where name = 'bettrans')
	BEGIN
		RETURN
	END
	if NOT exists (select * from dbo.sysobjects where name = 'bettrans14')
	BEGIN
		RETURN
	END

	select * into #tmp from bettrans14 
	where matchid = 25899834 and statusid = 0
		and transid not in(select transid from bettrans with (nolock) where matchid = 25899834)
	
	if (@@rowcount = 0) RETURN

	set identity_insert bettrans on
	insert bettrans(transid, custid, transdate, oddsid, hdp1, hdp2, odds, stake, status, winlost, awinlost, mwinlost, playercomm, comm, acomm, apositiontaking, mpositiontaking, tpositiontaking, playerdiscount, discount, 
							 adiscount, livehomescore, liveawayscore, liveindicator, betteam, creator, refno, comstatus, winlostdate, betfrom, betcheck, checktime, oddsspread, actualrate, matchid, recommend, mrecommend, ruben, betid, 
							 statuswinlost, modds, bettype, betdaqid, actual_stake, currency, ip, transdesc, sdiscount, scomm, spositiontaking, swinlost, srecommend, Username, CurrencyName, virtualrate, oddstype, statusID, 
							 currency2, balance, SecAcceptFlag, transid2, recommdate, ExtraInfo, WalletType, BonusID, RefCode)

	select transid, custid, transdate, oddsid, hdp1, hdp2, odds, stake, status, winlost, awinlost, mwinlost, playercomm, comm, acomm, apositiontaking, mpositiontaking, tpositiontaking, playerdiscount, discount, 
							 adiscount, livehomescore, liveawayscore, liveindicator, betteam, creator, refno, comstatus, '2018-07-09', betfrom, betcheck, checktime, oddsspread, actualrate, matchid, recommend, mrecommend, ruben, betid, 
							 statuswinlost, modds, bettype, betdaqid, actual_stake, currency, ip, transdesc, sdiscount, scomm, spositiontaking, swinlost, srecommend, Username, CurrencyName, virtualrate, oddstype, statusID, 
							 currency2, balance, SecAcceptFlag, transid2, recommdate, ExtraInfo, WalletType, BonusID, RefCode
	from #tmp
	set identity_insert bettrans off

	delete bettrans14 with (rowlock) where transid in(select transid from #tmp) and matchid = 25899834
end
GO

