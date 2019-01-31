
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.VALIDATE_DepositData_SUMTable    Script Date: 1/21/2019 4:30:11 AM ******/
/****** Object:  Stored Procedure dbo.VALIDATE_DepositData_SUMTable    Script Date: 5/5/2014 16:30:55  ******/

CREATE PROCEDURE [dbo].[VALIDATE_DepositData_SUMTable] 
	@DrawFilter tinyint = 1
AS
/*
Created: 20140505@Francis
Task : Validate data from bettrans14 for SUM Tables

DB: bodb_Licensee
Original:

Revisions:		

Param's Explanation:

Examples:


*/
SET NOCOUNT ON

DECLARE @ToDate smalldatetime,
		@tmpDate smalldatetime

DECLARE @Result TABLE (BalanceUpDay smalldatetime, MoveBetsDay smalldatetime)
INSERT INTO @Result
EXEC bodb02.dbo.Lrf_SelBalanceUpDay

SELECT @ToDate = MoveBetsDay
FROM @Result

SELECT @tmpDate = DATEADD(day,-2,@ToDate)

WHILE (@tmpDate <= @ToDate)
BEGIN
	EXEC dbo.GET_DepositDataToValidate_Compare @Date = @tmpDate, @DrawFilter = @DrawFilter

	SET @tmpDate = DATEADD(day,1,@tmpDate)
END

SET NOCOUNT OFF
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
