
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.AffAdmin_CheckIn    Script Date: 1/21/2019 4:30:00 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_CheckIn    Script Date: 12/22/2015 4:36:51 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_CheckIn    Script Date: 12/8/2015 09:52:32 ******/
CREATE PROCEDURE [dbo].[AffAdmin_CheckIn]
	@CustID INT,
	@NetSessionID VARCHAR(30),
	@ServerID INT,
	@On_UserID INT OUTPUT,
	@IP VARCHAR(15) = ''
AS

/*
	Created: 20151013@Victor
	Task: Check in
	DB: DBLIC/bodb_Licensee
	
	Revisions:

*/

UPDATE Aff_On_User WITH (ROWLOCK) SET IsKickedOut=1 WHERE CustID = @CustID AND ServerID = @ServerID
	
INSERT INTO Aff_On_User (CustID, NetSessionID, ServerID, IsKickedOut, IP)
VALUES (@custid, @NetSessionid, @ServerID, 0, @IP)

SELECT @On_UserID = SCOPE_IDENTITY()
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[AffAdmin_CheckIn] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[AffAdmin_CheckIn] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[AffAdmin_CheckIn] TO [bodbLicenseeNet]
GO 
