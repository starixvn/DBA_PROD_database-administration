
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.AffAdmin_ReCheckIn    Script Date: 1/21/2019 4:30:01 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_ReCheckIn    Script Date: 12/22/2015 4:36:52 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_ReCheckIn    Script Date: 12/8/2015 09:52:32 ******/
CREATE PROCEDURE [dbo].[AffAdmin_ReCheckIn]     
	@On_UserID INT,    
	@IsKickedOut BIT = 0 OUTPUT    
AS    
SET NOCOUNT ON    


/*
	Created: 20151013@Victor
	Task: Re check in
	DB: DBLIC/bodb_Licensee
	
	Revisions:
*/
   
DECLARE @OUTPUT TABLE (IsKickedOut BIT)
DECLARE @_On_UserID INT

SET @_On_UserID = @On_UserID

UPDATE Aff_On_User with (ROWLOCK)
SET Reload_Time = GETDATE() 
OUTPUT DELETED.IsKickedOut INTO @OUTPUT
WHERE On_UserID = @_On_UserID


IF @@ROWCOUNT = 0
	SELECT @IsKickedOut = 1
ELSE IF EXISTS (SELECT 1 FROM @OUTPUT WHERE IsKickedOut = 1)
	SELECT @IsKickedOut = 1
ELSE
	SET @IsKickedOut = 0
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[AffAdmin_ReCheckIn] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[AffAdmin_ReCheckIn] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[AffAdmin_ReCheckIn] TO [bodbLicenseeNet]
GO 
