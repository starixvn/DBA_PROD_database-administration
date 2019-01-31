
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.GEN_RptKPI_MTD_Viet    Script Date: 1/21/2019 4:30:02 AM ******/
CREATE PROCEDURE [dbo].[GEN_RptKPI_MTD_Viet]
    @date datetime, 
    @date2 datetime,
    @stattype tinyint = 0, -- 0:all, 1:transfer, 2:account, 3:report
    @isBA bit = 0,
	@debug bit = 0
AS
/*
Created: 20120723@Viet
Task: Generate data into GEN_RptKPI_MTD from summary tables
DB: DB052.bodb_Licensee

Revisions:

    
Param's Explanation:

*/

------------------- For a being time, set @date = '2012-06-01' ---------------
declare @tmpDate datetime
set @tmpDate = '2012-06-01'
set @date = @tmpDate
-------------------- End - For a being time, set @date = '2012-06-01' --------

declare @d datetime, @d2 datetime
SELECT @d = CONVERT(varchar(10),@date, 120), @d2 = CONVERT(varchar(10),DATEADD(day,-1,@date2), 120)

DECLARE @ExchangeDaily TABLE(ExchangeDate smalldatetime,ExchangeId int,EUR float,unique clustered (ExchangeDate,ExchangeId)) 
INSERT INTO @ExchangeDaily(ExchangeDate,ExchangeId,EUR) SELECT exchangedate,exchangeid,EUR FROM bodb02.dbo.Lrf_f_GetExchangeDaily(@d,@d2)

if @stattype IN (0,1) -- transfer
BEGIN
	DELETE FROM dbo.RptKPI_MTD_viettest WHERE rptDate between @d and @d2 AND StatID BETWEEN 1 AND 4
		
	;WITH B AS (
		SELECT rptDate, SiteID, x, val
		FROM (
			SELECT b.rptDate as rptDate
				,b.SiteID as siteID
				,convert(float, isnull(sum(FirstTransferInCount),0)) as v1 -- 1st Transfer In Count
				,convert(float, isnull(sum(FirstTransferInAmt*EUR),0)) as v2 -- 1st Transfer In Amount
				,convert(float, isnull(sum(TransferInCount),0)) as v3 -- Transfer In count
				,convert(float, isnull(sum(TransferOutCount),0)) as v4 -- Transfer Out Count		
			FROM dbo.rptKPI_Transfer b WITH(NOLOCK)
				INNER JOIN @ExchangeDaily e ON b.currencyID=e.exchangeid AND b.rptdate=e.exchangedate
			WHERE b.rptDate between @d and @d2
			GROUP BY b.rptDate,b.SiteID		
		) p
		UNPIVOT 
			(val FOR x IN (v1, v2, v3, v4)
		) as unpvt	
	)
	INSERT INTO dbo.RptKPI_MTD_viettest(rptDate, SiteID, StatID, MonthToDate)
	SELECT rptDate, SiteID, 
		case x 
			when 'v1' then 1 
			when 'v2' then 2
			when 'v3' then 3
			when 'v4' then 4
		else 0 end, 
		val 
	FROM B
	ORDER BY 1,3,2				
END

if @isBA = 0
BEGIN
	if @stattype IN (0,2) -- account
	BEGIN
		DELETE FROM dbo.RptKPI_MTD_viettest WHERE rptDate between @d and @d2 AND StatID BETWEEN 7 AND 23
		
		;WITH B AS (
			SELECT rptDate, SiteID, x, val
			FROM (
				SELECT b.rptDate as rptDate
					,b.SiteID as siteID
					,convert(float, isnull(sum(BetCount),0)) as v7 -- BetCount
					,convert(float, isnull(sum(turnover*EUR),0)) as v9 -- Turnover	
					,convert(float, isnull(sum(case when status in (113,115) then WinLoss*EUR else 0 end),0)) as v10 -- Winloss of player bets that loss	
					,convert(float, isnull(sum(case when status in (112,114) then WinLoss*EUR else 0 end),0)) as v11 -- Winloss of player bets that won	
					,convert(float, isnull(sum(BetCount)*TnxRate,0)) as v14 -- Sport revenue - transaction	
					,convert(float, isnull(sum(case when status in (113,115) then Betcount*TnxRate else 0 end),0)) as v15 -- Sport revenue - Player losses	
					,convert(float, isnull(sum(case when status not in (113,115) then Betcount*TnxRate else 0 end),0)) as v16 -- Sport revenue - Others	
					,convert(float, isnull(sum(case when status = 111 then 0 else BetCount end),0)) as v17 -- BetCount (no draw)	
					,convert(float, isnull(sum(case when status = 111 then 0 when status in (114,115) then 0.5*turnover*EUR else turnover*EUR end),0)) as v19 -- Turnover (no draw)	
					,convert(float, isnull(sum(case when IsLive = 1 then BetCount else 0 end),0)) as v22 -- BetCount Live	
					,convert(float, isnull(sum(case when IsLive = 1 then turnover*EUR else 0 end),0)) as v23 -- Turnover Live	
				FROM dbo.rpt_Betting b WITH(NOLOCK)
					INNER JOIN @ExchangeDaily e ON b.currencyID=e.exchangeid AND b.rptdate=e.exchangedate
					INNER JOIN (SELECT LabelID,TnxRate FROM dbo.view_kpi_labels WITH(NOLOCK) WHERE ResellerID<>3) s ON b.SiteID=s.LabelID
				WHERE b.rptDate between @d and @d2
					AND b.status NOT IN (-1,103)
					AND b.currencyID <> 20
					AND (b.bettype<31 OR (b.bettype>=121 AND b.bettype<1000))
					AND b.customercategory NOT IN (27,28)
				GROUP BY b.rptDate,b.SiteID,s.TnxRate	
			) p
			UNPIVOT 
				(val FOR x IN (v7,v9,v10,v11,v14,v15,v16,v17,v19,v22,v23)
			) as unpvt	
		)
		INSERT INTO dbo.RptKPI_MTD_viettest(rptDate, SiteID, StatID, MonthToDate)
		SELECT rptDate, SiteID, 
			case x 
				when 'v7' then 7 
				when 'v9' then 9
				when 'v10' then 10
				when 'v11' then 11
				when 'v14' then 14 
				when 'v15' then 15 
				when 'v16' then 16 
				when 'v17' then 17 
				when 'v19' then 19 
				when 'v22' then 22 
				when 'v23' then 23 
			else 0 end, 
			val 
		FROM B
		ORDER BY 1,3,2		
	END
	
	if @stattype IN (0,3) -- report
	BEGIN
		DELETE FROM dbo.RptKPI_MTD_viettest WHERE rptDate between @d and @d2 AND StatID IN (5,6)
			
		;WITH B AS (
			SELECT rptDate, SiteID, x, val
			FROM (
				SELECT b.rptDate as rptDate
					,b.SiteID as siteID
					,convert(float, sum(UniqueBettorCount)/24) as v5 -- Average Bettors during days
					,convert(float, max(PeakBettorCount)) as v6 -- Peak concurrent bettors						
				FROM dbo.rptKPI_Account b WITH(NOLOCK)
				WHERE b.rptDate between @d and @d2
				GROUP BY b.rptDate,b.SiteID	
			) p
			UNPIVOT 
				(val FOR x IN (v5,v6)
			) as unpvt	
		)
		INSERT INTO dbo.RptKPI_MTD_viettest(rptDate, SiteID, StatID, MonthToDate)
		SELECT rptDate, SiteID, 
			case x 
				when 'v5' then 5 
				when 'v6' then 6				
			else 0 end, 
			val 
		FROM B
		ORDER BY 1,3,2		
	END
END
ELSE IF @isBA = 1
BEGIN	
	if @stattype IN (0,2) -- account
	BEGIN
		DELETE FROM dbo.RptKPI_MTD_BA_viettest WHERE rptDate between @d and @d2 AND StatID BETWEEN 7 AND 23
		
		;WITH B AS (
			SELECT rptDate, SiteID, x, val
			FROM (
				SELECT b.rptDate as rptDate
					,b.SiteID as siteID
					,convert(float, isnull(sum(BetCount),0)) as v7 -- BetCount
					,convert(float, isnull(sum(turnover*EUR),0)) as v9 -- Turnover	
					,convert(float, isnull(sum(case when status in (113,115) then WinLoss*EUR else 0 end),0)) as v10 -- Winloss of player bets that loss	
					,convert(float, isnull(sum(case when status in (112,114) then WinLoss*EUR else 0 end),0)) as v11 -- Winloss of player bets that won	
					,convert(float, isnull(sum(BetCount)*TnxRate,0)) as v14 -- Sport revenue - transaction	
					,convert(float, isnull(sum(case when status in (113,115) then Betcount*TnxRate else 0 end),0)) as v15 -- Sport revenue - Player losses	
					,convert(float, isnull(sum(case when status not in (113,115) then Betcount*TnxRate else 0 end),0)) as v16 -- Sport revenue - Others	
					,convert(float, isnull(sum(case when status = 111 then 0 else BetCount end),0)) as v17 -- BetCount (no draw)	
					,convert(float, isnull(sum(case when status = 111 then 0 when status in (114,115) then 0.5*turnover*EUR else turnover*EUR end),0)) as v19 -- Turnover (no draw)	
					,convert(float, isnull(sum(case when IsLive = 1 then BetCount else 0 end),0)) as v22 -- BetCount Live	
					,convert(float, isnull(sum(case when IsLive = 1 then turnover*EUR else 0 end),0)) as v23 -- Turnover Live	
				FROM dbo.rpt_Betting_BA b WITH(NOLOCK)
					INNER JOIN @ExchangeDaily e ON b.currencyID=e.exchangeid AND b.rptdate=e.exchangedate
					INNER JOIN (SELECT LabelID,TnxRate FROM dbo.view_kpi_labels WITH(NOLOCK) WHERE ResellerID=3) s ON b.SiteID=s.LabelID
				WHERE b.rptDate between @d and @d2
					AND b.status NOT IN (-1,103)
					AND b.currencyID <> 20
					AND (b.bettype<31 OR (b.bettype>=121 AND b.bettype<1000))					
				GROUP BY b.rptDate,b.SiteID,s.TnxRate	
			) p
			UNPIVOT 
				(val FOR x IN (v7,v9,v10,v11,v14,v15,v16,v17,v19,v22,v23)
			) as unpvt	
		)
		INSERT INTO dbo.RptKPI_MTD_BA_viettest(rptDate, SiteID, StatID, MonthToDate)
		SELECT rptDate, SiteID, 
			case x 
				when 'v7' then 7 
				when 'v9' then 9
				when 'v10' then 10
				when 'v11' then 11
				when 'v14' then 14 
				when 'v15' then 15 
				when 'v16' then 16 
				when 'v17' then 17 
				when 'v19' then 19 
				when 'v22' then 22 
				when 'v23' then 23 
			else 0 end, 
			val 
		FROM B
		ORDER BY 1,3,2		
	END
	
	if @stattype IN (0,3) -- report
	BEGIN
		DELETE FROM dbo.RptKPI_MTD_BA_viettest WHERE rptDate between @d and @d2 AND StatID IN (5,6)
			
		;WITH B AS (
			SELECT rptDate, SiteID, x, val
			FROM (
				SELECT b.rptDate as rptDate
					,b.SiteID as siteID
					,convert(float, sum(UniqueBettorCount)/24) as v5 -- Average Bettors during days
					,convert(float, max(PeakBettorCount)) as v6 -- Peak concurrent bettors						
				FROM dbo.rptKPI_Account_BA b WITH(NOLOCK)
				WHERE b.rptDate between @d and @d2
				GROUP BY b.rptDate,b.SiteID	
			) p
			UNPIVOT 
				(val FOR x IN (v5,v6)
			) as unpvt	
		)
		INSERT INTO dbo.RptKPI_MTD_BA_viettest(rptDate, SiteID, StatID, MonthToDate)
		SELECT rptDate, SiteID, 
			case x 
				when 'v5' then 5 
				when 'v6' then 6				
			else 0 end, 
			val 
		FROM B
		ORDER BY 1,3,2		
	END
END

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
