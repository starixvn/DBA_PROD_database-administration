
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.GET_DepositDataToValidate_Invoice    Script Date: 1/21/2019 4:30:02 AM ******/




CREATE PROCEDURE [dbo].[GET_DepositDataToValidate_Invoice]-- '2014-3-6'
    @Date smalldatetime = null
	,@DrawFilter tinyint = 1
AS
/*
Created: 20130612@Don
Task : Get deposit data from table db052.bodb_Invoice.dbo.rptInvWinloss

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
	EXEC [GET_DepositDataToValidate_Invoice] @Date=@DateChecking,@DrawFilter=1
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
       ,@BaTurnover MONEY
       ,@BaCustomerWl MONEY
       ,@BaBetCount MONEY
       ,@CsTurnover MONEY
       ,@CsCustomerWl MONEY
       ,@CsBetCount MONEY
    
---- Sportbook
--SELECT @SbTurnover=SUM(CASE 
--                    WHEN @DrawFilter IN (2,3) THEN 
--                        CASE WHEN b.Status = 111 THEN 0 WHEN b.Status IN (114,115) THEN 0.5 ELSE 1 END
--                    ELSE 1
--                END * b.Turnover)
--    ,@SbCustomerWl=SUM(b.MemberWL)
--    ,@SbBetCount=SUM(CASE WHEN @DrawFilter=2 AND b.Status = 111 THEN 0 ELSE b.BetCount END)
--FROM bodb_Invoice.dbo.rptInvWinloss b (NOLOCK)
--    INNER JOIN dbo.Licensees lic (NOLOCK) ON b.LicenseeID=lic.LicenseeID AND IsDeposit=CONVERT(bit,1)
--WHERE b.rptDate=@Date
--    AND b.ProductID = 1 
--	AND b.isBA = 0
--	AND b.CurrencyID NOT IN(27,28)--exclude test currency C & H

SELECT @SbTurnover = ISNULL (@SbTurnover, 0),
	   @SbCustomerWl = ISNULL (@SbCustomerWl, 0),
	   @SbBetCount = ISNULL (@SbBetCount, 0)

---- Racing

--SELECT @RbTurnover = SUM(CASE WHEN b.Status IN (114,115) THEN 0.5 ELSE 1 END * b.Turnover) 
--    ,@RbCustomerWl = SUM(b.MemberWL)
--    ,@RbBetCount = SUM(b.BetCount)
--FROM bodb_Invoice.dbo.rptInvWinloss b (NOLOCK)
--    INNER JOIN dbo.Licensees lic (NOLOCK) ON b.LicenseeID=lic.LicenseeID AND IsDeposit=CONVERT(bit,1)
--WHERE b.rptDate=@Date
--    AND b.ProductID = 2
--   	AND b.CurrencyID NOT IN(27,28)--exclude test currency C & H


SELECT @RbTurnover = ISNULL (@RbTurnover, 0),
	   @RbCustomerWl = ISNULL (@RbCustomerWl, 0),
	   @RbBetCount = ISNULL (@RbBetCount, 0)
        
---- Number Game

--SELECT @NgTurnover=SUM(CASE WHEN @DrawFilter IN (2,3) AND b.Status = 111 THEN 0 ELSE b.Turnover END)
--    ,@NgCustomerWl=SUM(b.MemberWL)
--    ,@NgBetCount=SUM(CASE WHEN @DrawFilter=2 AND b.Status = 111 THEN 0 ELSE b.BetCount END) 
--FROM bodb_Invoice.dbo.rptInvWinloss b (NOLOCK)
--    INNER JOIN dbo.Licensees lic (NOLOCK) ON b.LicenseeID=lic.LicenseeID AND IsDeposit=CONVERT(bit,1)
--WHERE b.rptDate=@Date
--    AND b.ProductID = 3
--	AND b.CurrencyID NOT IN(27,28)--exclude test currency C & H
   

SELECT @NgTurnover = ISNULL (@NgTurnover, 0),
	   @NgCustomerWl = ISNULL (@NgCustomerWl, 0),
	   @NgBetCount = ISNULL (@NgBetCount, 0)
	   
-- Ba

--SELECT @BaTurnover=SUM(CASE 
--                    WHEN @DrawFilter IN (2,3) THEN 
--                        CASE WHEN b.Status = 111 THEN 0 WHEN b.Status IN (114,115) THEN 0.5 ELSE 1 END
--                    ELSE 1
--                END * b.Turnover)
--    ,@BaCustomerWl=SUM(b.MemberWL) 
--    ,@BaBetCount=SUM(CASE WHEN @DrawFilter=2 AND b.Status = 111 THEN 0 ELSE b.BetCount END) 
--FROM bodb_Invoice.dbo.rptInvWinloss b (NOLOCK)
--    INNER JOIN dbo.Licensees lic (NOLOCK) ON b.LicenseeID=lic.LicenseeID AND IsDeposit=CONVERT(bit,1)
--WHERE b.rptDate=@Date
--	AND b.ProductID = 1 
--	AND b.isBA = 1
--	AND b.CurrencyID NOT IN(27,28)--exclude test currency C & H
	

SELECT @BaTurnover = ISNULL (@BaTurnover, 0),
	   @BaCustomerWl = ISNULL (@BaCustomerWl, 0),
	   @BaBetCount = ISNULL (@BaBetCount, 0)
	   
---- Live Casino

--SELECT @CsTurnover=SUM(CASE WHEN @DrawFilter IN (2,3) AND b.Status = 111 THEN 0 ELSE b.Turnover END)
--    ,@CsCustomerWl=SUM(b.MemberWL)
--    ,@CsBetCount=SUM(CASE WHEN @DrawFilter=2 AND b.Status = 111 THEN 0 ELSE b.BetCount END) 
--FROM bodb_Invoice.dbo.rptInvWinloss b (NOLOCK)
--    INNER JOIN dbo.Licensees lic (NOLOCK) ON b.LicenseeID=lic.LicenseeID AND IsDeposit=CONVERT(bit,1)
--WHERE b.rptDate=@Date
--    AND b.ProductID = 5
--	AND b.CurrencyID NOT IN(27,28)--exclude test currency C & H
    

SELECT @CsTurnover = ISNULL (@CsTurnover, 0),
	   @CsCustomerWl = ISNULL (@CsCustomerWl, 0),
	   @CsBetCount = ISNULL (@CsBetCount, 0)


-- Result

SELECT 1 AS Id, @SbTurnover AS Sb, @RbTurnover AS Rb, @NgTurnover AS Ng, @BaTurnover AS Ba, @CsTurnover AS Cs
UNION
SELECT 2, @SbCustomerWl, @RbCustomerWl, @NgCustomerWl, @BaCustomerWl, @CsCustomerWl
UNION
SELECT 3, @SbBetCount, @RbBetCount, @NgBetCount, @BaBetCount, @CsBetCount


SET NOCOUNT OFF








GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT VIEW DEFINITION ON [dbo].[GET_DepositDataToValidate_Invoice] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[GET_DepositDataToValidate_Invoice] TO [bodbLicenseeNet]
GO 
