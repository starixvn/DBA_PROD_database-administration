
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.DBA_BackupData_Support_12443    Script Date: 1/21/2019 4:30:01 AM ******/

CREATE PROCEDURE [dbo].[DBA_BackupData_Support_12443] 
	@CustIDList		VARCHAR(8000)
AS 
/*
Created		: 20140304@Don
Task		: Backup data
DB			: DBLIC.bodb_Licensee

Revisions:
		
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Customers TABLE(custid int)

	INSERT INTO @Customers
		SELECT VAL FROM bodb02.dbo.strSplit(@CustIDList, ',')

	IF (@@ROWCOUNT > 0)
	BEGIN

		--
		INSERT INTO dbo.Customer_Support_12443
			SELECT * FROM bodb02.dbo.Customer WITH(NOLOCK) WHERE custid IN (SELECT custid FROM @Customers)

		--
		INSERT INTO dbo.Dep_CustSetting_Support_12443
			SELECT * FROM bodb02.dbo.Dep_CustSetting WITH(NOLOCK) WHERE custid IN (SELECT custid FROM @Customers) AND bettype IN (1,2,3,7,8)

	END
END	




GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT VIEW DEFINITION ON [dbo].[DBA_BackupData_Support_12443] TO [vnteam]
GO 
