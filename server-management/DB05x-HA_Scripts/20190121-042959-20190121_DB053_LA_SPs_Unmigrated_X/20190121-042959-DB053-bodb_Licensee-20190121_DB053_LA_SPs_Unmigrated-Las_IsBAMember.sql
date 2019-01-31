
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Las_IsBAMember    Script Date: 1/21/2019 4:30:08 AM ******/
/****** Object:  Stored Procedure dbo.Las_IsBAMember    Script Date: 8/14/2014 10:54:03 AM ******/
CREATE PROCEDURE [dbo].[Las_IsBAMember] (@LicenseeId INT
	, @CustId INT
	, @IsBAMember BIT = 0 OUTPUT
)
AS
/*
Created: 20140717@Patrick
Task : Check member is BA or not
DB: DBLIC/bodb_licensee
Original:

Revisions:
Param's Explanation:
	
*/
BEGIN
	SET NOCOUNT ON
	SET @IsBAMember = 0

	SELECT @IsBAMember = 1 
	FROM dbo.LicenseeBAHistory
	WHERE LicenseeId = @LicenseeId 
		AND CustId = @CustId 
		AND Status = 'Running'
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[Las_IsBAMember] TO [bodbLicenseeNet]
GO 
 GRANT EXECUTE ON [dbo].[Las_IsBAMember] TO [Dot_Member]
GO 
