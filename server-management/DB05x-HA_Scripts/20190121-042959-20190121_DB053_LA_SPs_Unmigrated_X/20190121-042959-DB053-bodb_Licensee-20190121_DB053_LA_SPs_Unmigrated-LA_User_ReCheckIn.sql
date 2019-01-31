
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_User_ReCheckIn    Script Date: 1/21/2019 4:30:07 AM ******/
/****** Object:  Stored Procedure dbo.LA_User_ReCheckIn    Script Date: 15/10/2014 16:43:23 PM ******/
CREATE PROCEDURE [dbo].[LA_User_ReCheckIn]     
	@On_UserID	INT,    
	@IsKickedOut	BIT = 0 OUTPUT    
AS    

/*
	Creator:  20140820@Florent
	Task: ReCheckIN
	DB: DB052.bodb_Licensee

	Revisions:
		

*/
SET NOCOUNT ON  
BEGIN
    DECLARE @OUTPUT TABLE (IsKickedOut bit)
    DECLARE @_On_UserID INT

    SET @_On_UserID = @On_UserID

    UPDATE dbo.LA_OnUser WITH (ROWLOCK)
    SET reload_time = GETDATE() 
    OUTPUT DELETED.IsKickedOut INTO @OUTPUT
    WHERE on_userid = @_On_UserID


    IF @@ROWCOUNT = 0
	    SELECT @IsKickedOut = 1
    ELSE IF EXISTS (SELECT 1 FROM @OUTPUT WHERE IsKickedOut = 1)
	    SELECT @IsKickedOut = 1
    ELSE
	    SET @IsKickedOut = 0    
    
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_User_ReCheckIn] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_User_ReCheckIn] TO [vnteam]
GO 
