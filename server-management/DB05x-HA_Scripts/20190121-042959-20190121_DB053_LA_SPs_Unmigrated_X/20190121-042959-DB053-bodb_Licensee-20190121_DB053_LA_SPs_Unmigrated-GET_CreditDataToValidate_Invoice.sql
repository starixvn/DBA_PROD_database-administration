
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.GET_CreditDataToValidate_Invoice    Script Date: 1/21/2019 4:30:02 AM ******/

CREATE PROCEDURE [dbo].[GET_CreditDataToValidate_Invoice] 
     @Date smalldatetime 
	,@DrawFilter tinyint = 1
AS
/*
Created: 20130612@Don
Task : Get credit data from table db052.bodb_Invoice.dbo.rptInvWinloss

DB: bodb_Licensee
Original:

Revisions:	
	- 20140313@daniel: exclude currency C & H
	- 20150604@Don: temporarily comment code to get data from bodb_Invoice.dbo.rptInvWinloss
	
Param's Explanation:
    @DrawFilter, 1:Normal - 2:No Draws - 3:No Draws For Turnover Only

Examples:
	DECLARE @DateChecking SMALLDATETIME
	SELECT @DateChecking =DATEADD(day, -10, GETDATE())
	exec [GET_CreditDataToValidate_Invoice] @Date=@DateChecking,@DrawFilter=1
*/

SET NOCOUNT ON


DECLARE @SbTurnover MONEY
       ,@SbCustomerWl MONEY
       ,@SbBetCount MONEY
       ,@RbTurnover MONEY
       ,@RbCustomerWl MONEY
       ,@RbBetCount MONEY
       ,@NgTurnover MONEY
       ,@NgCustomerWl MONEY
       ,@NgBetCount MONEY
       
       ,@CsTurnover MONEY
       ,@CsCustomerWl MONEY
       ,@CsBetCount MONEY
       ,@RngTurnover MONEY
       ,@RngCustomerWl MONEY
       ,@RngBetCount MONEY
       ,@VsTurnover MONEY
       ,@VsCustomerWl MONEY
       ,@VsBetCount MONEY
    
    

---- Sportbook
--SELECT @SbTurnover = SUM(
--                CASE 
--                    WHEN @DrawFilter IN (2,3) THEN 
--                        CASE WHEN b.Status = 111 THEN 0 WHEN b.Status IN (114,115) THEN 0.5 ELSE 1 END
--                    ELSE 1
--                END * ISNULL(b.Turnover,0))
--    ,@SbCustomerWl = SUM(ISNULL(b.MemberWL,0))
--    ,@SbBetCount = SUM(CASE WHEN @DrawFilter = 2 AND b.Status = 111 THEN 0 ELSE ISNULL(b.BetCount,0) END)
--FROM bodb_Invoice.dbo.rptInvWinloss b (NOLOCK)
--WHERE b.rptDate = @Date
--    AND b.ProductID = 1
--    AND b.LicenseeID NOT IN (SELECT LicenseeID FROM dbo.Licensees (NOLOCK) WHERE IsDeposit = CONVERT(bit,1)) AND b.LicenseeID > 0
--	AND b.CurrencyID NOT IN(27,28)--exclude test currency C & H
    

SELECT @SbTurnover = ISNULL (@SbTurnover, 0),
	   @SbCustomerWl = ISNULL (@SbCustomerWl, 0),
	   @SbBetCount = ISNULL (@SbBetCount, 0)

---- Racing

--SELECT @RbTurnover = ISNULL(SUM(CASE WHEN b.Status IN (114,115) THEN 0.5 ELSE 1 END * b.Turnover),0) 
--    ,@RbCustomerWl = ISNULL(SUM(b.MemberWL),0) 
--    ,@RbBetCount = ISNULL(SUM(b.BetCount),0) 
--FROM bodb_Invoice.dbo.rptInvWinloss b (NOLOCK)
--WHERE b.rptDate = @Date
--    AND b.ProductID = 2
--    AND b.LicenseeID NOT IN (SELECT LicenseeID FROM dbo.Licensees (NOLOCK) WHERE IsDeposit = CONVERT(bit,1)) AND b.LicenseeID > 0
--	AND b.CurrencyID NOT IN(27,28)--exclude test currency C & H
    

SELECT @RbTurnover = ISNULL (@RbTurnover, 0),
	   @RbCustomerWl = ISNULL (@RbCustomerWl, 0),
	   @RbBetCount = ISNULL (@RbBetCount, 0)
	   
---- Number Game

--SELECT @NgTurnover = SUM(CASE WHEN @DrawFilter IN (2,3) AND b.Status = 111 THEN 0 ELSE ISNULL(b.Turnover,0) END)
--    ,@NgCustomerWl = SUM(ISNULL(b.MemberWL,0))
--    ,@NgBetCount = SUM(CASE WHEN @DrawFilter = 2 AND b.Status = 111 THEN 0 ELSE ISNULL(b.BetCount,0) END) 
--FROM bodb_Invoice.dbo.rptInvWinloss b (NOLOCK)
--WHERE b.rptDate = @Date
--    AND b.ProductID = 3
--    AND b.LicenseeID NOT IN (SELECT LicenseeID FROM dbo.Licensees (NOLOCK) WHERE IsDeposit = CONVERT(bit,1)) AND b.LicenseeID > 0
--	AND b.CurrencyID NOT IN(27,28)--exclude test currency C & H
    

SELECT @NgTurnover = ISNULL (@NgTurnover, 0),
	   @NgCustomerWl = ISNULL (@NgCustomerWl, 0),
	   @NgBetCount = ISNULL (@NgBetCount, 0)
	   
---- Live Casino

--SELECT @CsTurnover = SUM(CASE WHEN @DrawFilter IN (2,3) AND b.Status = 111 THEN 0 ELSE ISNULL(b.Turnover,0) END)
--    ,@CsCustomerWl = SUM(ISNULL(b.MemberWL,0))
--    ,@CsBetCount = SUM(CASE WHEN @DrawFilter = 2 AND b.Status = 111 THEN 0 ELSE ISNULL(b.BetCount,0) END) 
--FROM bodb_Invoice.dbo.rptInvWinloss b (NOLOCK)
--WHERE b.rptDate = @Date
--    AND b.ProductID = 5
--    AND b.LicenseeID NOT IN (SELECT LicenseeID FROM dbo.Licensees (NOLOCK) WHERE IsDeposit = CONVERT(bit,1)) AND b.LicenseeID > 0
--	AND b.CurrencyID NOT IN(27,28)--exclude test currency C & H
    

SELECT @CsTurnover = ISNULL (@CsTurnover, 0),
	   @CsCustomerWl = ISNULL (@CsCustomerWl, 0),
	   @CsBetCount = ISNULL (@CsBetCount, 0)
	   
---- RNG Casino

--SELECT @RngTurnover = SUM(CASE WHEN @DrawFilter IN (2,3) AND b.Status = 111 THEN 0 ELSE ISNULL(b.Turnover,0) END)
--    ,@RngCustomerWl = SUM(ISNULL(b.MemberWL,0))
--    ,@RngBetCount = SUM(CASE WHEN @DrawFilter = 2 AND b.Status = 111 THEN 0 ELSE ISNULL(b.BetCount,0) END) 
--FROM bodb_Invoice.dbo.rptInvWinloss b (NOLOCK)
--WHERE b.rptDate = @Date
--    AND b.ProductID = 7
--    AND b.LicenseeID NOT IN (SELECT LicenseeID FROM dbo.Licensees (NOLOCK) WHERE IsDeposit = CONVERT(bit,1)) AND b.LicenseeID > 0
--	AND b.CurrencyID NOT IN(27,28)--exclude test currency C & H
    

SELECT @RngTurnover = ISNULL (@RngTurnover, 0),
	   @RngCustomerWl = ISNULL (@RngCustomerWl, 0),
	   @RngBetCount = ISNULL (@RngBetCount, 0)
	   
---- Virtual Sport

--SELECT @VsTurnover = SUM(CASE WHEN @DrawFilter IN (2,3) AND b.Status = 111 THEN 0 ELSE ISNULL(b.Turnover,0) END)
--    ,@VsCustomerWl = SUM(ISNULL(b.MemberWL,0))
--    ,@VsBetCount = SUM(CASE WHEN @DrawFilter = 2 AND b.Status = 111 THEN 0 ELSE ISNULL(b.BetCount,0) END) 
--FROM bodb_Invoice.dbo.rptInvWinloss b (NOLOCK)
--WHERE b.rptDate = @Date
--    AND b.ProductID = 6
--    AND b.LicenseeID NOT IN (SELECT LicenseeID FROM dbo.Licensees (NOLOCK) WHERE IsDeposit = CONVERT(bit,1)) AND b.LicenseeID > 0
--	AND b.CurrencyID NOT IN(27,28)--exclude test currency C & H
    

SELECT @VsTurnover = ISNULL (@VsTurnover, 0),
	   @VsCustomerWl = ISNULL (@VsCustomerWl, 0),
	   @VsBetCount = ISNULL (@VsBetCount, 0)
	
	
-- Result

SELECT 1 AS Id, @SbTurnover AS Sb, @RbTurnover AS Rb, @NgTurnover AS Ng, @CsTurnover AS Cs, @RngTurnover AS Rng, @VsTurnover AS Vs
UNION
SELECT 2, @SbCustomerWl, @RbCustomerWl, @NgCustomerWl, @CsCustomerWl, @RngCustomerWl, @VsCustomerWl
UNION
SELECT 3, @SbBetCount, @RbBetCount, @NgBetCount, @CsBetCount, @RngBetCount, @VsBetCount

SET NOCOUNT OFF







GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT VIEW DEFINITION ON [dbo].[GET_CreditDataToValidate_Invoice] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[GET_CreditDataToValidate_Invoice] TO [bodbLicenseeNet]
GO 
