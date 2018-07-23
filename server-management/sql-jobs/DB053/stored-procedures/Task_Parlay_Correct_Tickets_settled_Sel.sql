USE [bodb02]
GO

ALTER PROCEDURE [dbo].[Task_Parlay_Correct_Tickets_settled_Sel] @LastDateTime datetime = null
AS
/*
	20180718 @ Patrick
	DBAGE.bodb02
	Task: Correct winlostdate for parlay main tickets 
*/
begin
	set nocount on
	select substring(message_body, charindex('@matchid = ', message_body, 0) + 11, 8) as matchid
		, creationTime 
	into #__MatchIds
	from sb.CalculationLogs with(nolock)
	where creationTime >= @LastDateTime
		and duration is not null
		and message_body like 'EXEC dbo.NAP_Admin_Calculate_MP_broker%'
	
	delete from #__MatchIds where isnumeric(matchid) = 0
	declare @LastDateTimeOutput datetime
	select @LastDateTimeOutput = max(creationTime) from #__MatchIds

	select b.transid into #__TransIds
	from dbo.bettrans b with(nolock)
		inner join dbo.bettransm bm with(nolock) on b.refno = bm.refno
	where b.matchid = 29 and b.bettype = 29
		and bm.matchid in (select t.matchid from #__MatchIds t)

	select transid, winlostdate
	into #__ParlayTickets
	from dbo.bettrans with(nolock)
	where matchid = 29 and bettype = 29
		and transid in (select t.transid from #__TransIds t)
	
	select b.winlostdate, b.transid, @LastDateTimeOutput as LastDateTimeOutput
	from dbo.bettrans b with(nolock)
		inner join #__ParlayTickets t on b.transid = t.transid
	group by b.winlostdate, b.transid
end
