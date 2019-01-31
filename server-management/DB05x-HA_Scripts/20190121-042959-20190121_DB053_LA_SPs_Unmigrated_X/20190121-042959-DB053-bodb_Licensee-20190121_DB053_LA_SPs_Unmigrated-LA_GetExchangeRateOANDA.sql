
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_GetExchangeRateOANDA    Script Date: 1/21/2019 4:30:03 AM ******/
/****** Object:  Stored Procedure dbo.LA_GetExchangeRateOANDA    Script Date: 5/30/2018 12:00:35 AM ******/
CREATE PROCEDURE [dbo].[LA_GetExchangeRateOANDA]
	@Fromdate DATETIME=NULL,
	@ToDate DATETIME=NULL 
AS 
/*  
 * Created by: 20180518@Scofield
 * Task  : OANDA Exchange Rate Report
 * DB   : DBLIC.bodb_Licensee  
 * Revisions :  
 *  - 20180518@Scofield: create [#94950]
 * Param's Explanation:    
	- @FromDate		: From date
	- @ToDate		: To date
 */  
	SET NOCOUNT ON 
 
	BEGIN 
		IF @Fromdate IS NULL
			SET @Fromdate = CONVERT(VARCHAR(10), CURRENT_TIMESTAMP, 120)
		IF @Todate IS NULL
			SET @ToDate = CONVERT(VARCHAR(10), CURRENT_TIMESTAMP, 120)

		SELECT 
			edo.ExchangeDate,
			CASE 
				WHEN edo.Code='VND' THEN 'INH' 
				WHEN edo.Code='MMK' THEN 'MKK' 
				WHEN edo.ExchangeId = 75 THEN 'PTU'
				WHEN edo.ExchangeId = 76 THEN 'PS'
				WHEN edo.ExchangeId = 77 THEN 'PTH'
				ELSE edo.Code 
			END CurrencyCode,
			edo.EUR,
			edo.USD,
			edo.MYR,
			edo.CNY,
			edo.IDR,
			edo.AUD,
			edo.CHF,
			edo.GBP,
			edo.SGD,
			edo.THB,
			edo.VND / 1000 AS 'INH',
			edo.KRW,
			edo.JPY,
			edo.HKD,
			edo.TWD,
			edo.PHP
		FROM bodb02.dbo.ExchangeDailyOanda edo (NOLOCK)
		WHERE 
			edo.ExchangeDate>=@fromdate AND edo.ExchangeDate<=@todate 
			AND edo.exchangeid in (select distinct currency   FROM  dbo.f_SelLicenseeCust(0) lc )
			AND exchangeid <> 20
			AND edo.ExchangeId NOT IN (43, 66) -- old THB and KeenOcean's HKD
		ORDER BY edo.ExchangeDate,edo.Code ASC 
	END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_GetExchangeRateOANDA] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_GetExchangeRateOANDA] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[LA_GetExchangeRateOANDA] TO [bodbLicenseeNet]
GO 
