
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_SelBaseCurrency    Script Date: 1/21/2019 4:30:07 AM ******/
/****** Object:  Stored Procedure dbo.LA_SelBaseCurrency    Script Date: 12/21/2017 2:31:31 PM ******/

CREATE PROCEDURE [dbo].[LA_SelBaseCurrency]	
	@BaseCurrencyDefault	VARCHAR(10) = 'EUR'
AS
/*
	Created: 20150312@Florent
	Task : Get all BaseCurrency
	DB: DB052.bodb_licensee
	Revison:
		- 20150703@Florent: add currency MYR
		- 20171220@Parsons: increase length for variables [#88197]

	Revisions:
	Param's Explanation:
*/
SET NOCOUNT ON

BEGIN
	
	SELECT CurrencyId, CurrencyName
	FROM (
			SELECT e.exchangeid AS CurrencyId
				, e.Code AS CurrencyName
				, CASE e.Code WHEN @BaseCurrencyDefault THEN 1 ELSE 0 END AS [Default]
			FROM bodb02.dbo.Exchange e WITH (NOLOCK)
			WHERE e.Code IN 
							(
								  'CNY' -- ExchangeID = 13
								, 'EUR' -- ExchangeID = 6		
								, 'GBP' -- ExchangeID = 12
								, 'USD' -- ExchangeID = 3	
								, 'MYR'	-- ExchangeID = 2	
							)
								AND e.exchangeid IN
							(
								  2
								, 3
								, 6
								, 12
								, 13
							)						
		) c
	ORDER BY [Default] DESC
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_SelBaseCurrency] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[LA_SelBaseCurrency] TO [vnteam]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_SelBaseCurrency] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[LA_SelBaseCurrency] TO [bodbLicenseeNet]
GO 
