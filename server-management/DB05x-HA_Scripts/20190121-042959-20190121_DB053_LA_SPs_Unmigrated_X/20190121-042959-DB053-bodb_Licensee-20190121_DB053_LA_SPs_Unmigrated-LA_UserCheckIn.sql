
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_UserCheckIn    Script Date: 1/21/2019 4:30:07 AM ******/
/****** Object:  Stored Procedure dbo.LA_UserCheckIn    Script Date: 15/10/2014 16:43:23 PM ******/

CREATE PROCEDURE [dbo].[LA_UserCheckIn]
	@CustID INT,
	@NetSessionID VARCHAR(30),
	@On_UserID INT OUTPUT,
	@IP VARCHAR(15) = ''
AS

/*
	Creator:  20140820@Florent
	Task: CheckIN
	DB: DB052.bodb_Licensee	
*/

SET NOCOUNT ON
BEGIN
    UPDATE LA_OnUser with (ROWLOCK,UPDLOCK) SET IsKickedout=1 WHERE CustID = @CustID
    	
    INSERT INTO dbo.LA_OnUser
	    (custid, NetSessionID, IsKickedout, IP)
    VALUES
	    (@custid, @NetSessionid, 0, @IP)

    SELECT @On_UserID = SCOPE_IDENTITY()
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_UserCheckIn] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_UserCheckIn] TO [vnteam]
GO 
