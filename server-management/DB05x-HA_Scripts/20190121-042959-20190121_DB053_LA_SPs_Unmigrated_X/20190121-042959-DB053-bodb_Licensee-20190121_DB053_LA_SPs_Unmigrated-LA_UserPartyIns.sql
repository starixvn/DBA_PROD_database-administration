
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_UserPartyIns    Script Date: 1/21/2019 4:30:08 AM ******/
/****** Object:  Stored Procedure dbo.LA_UserPartyIns    Script Date: 02/03/2015 17:07:56 PM ******/

CREATE PROCEDURE [dbo].[LA_UserPartyIns] 
	@UserName				NVARCHAR(50)
	, @PartyName			NVARCHAR(50)	
AS
/*
	Created: 20150302@Florent
	Task : add permission for LA, User - Party
	Base : 
	DB: DB052.bodb_licensee

	Revisions:
	Param's Explanation:
*/
BEGIN	
	DECLARE @userID INT, @PartyID INT
	SELECT @userID = UserID 
	FROM dbo.LA_User WITH (NOLOCK) 
	WHERE Username = @UserName

	SELECT @PartyID = PartyID
	FROM dbo.OAS_Party WITH (NOLOCK)
	WHERE PartyName = @PartyName
		AND PartyType = 1	
	IF ISNULL(@userID,0) = 0 OR ISNULL(@PartyID,0) = 0		
	BEGIN
		SELECT 'Error!!! Data error, please check :', @UserName AS '@UserName', @userID AS '@userID', @PartyName AS '@PartyName', @PartyID AS '@PartyID'
		RETURN
	END

	---
	IF NOT EXISTS (SELECT 1 FROM dbo.LA_UserParty WITH (NOLOCK) WHERE UserID = @userID AND PartyID = @PartyID)
	BEGIN
		INSERT INTO LA_UserParty (UserID, PartyID, Modifydate, Modifier, StatusID)
			(
				SELECT @userID, @PartyID, GETDATE(), @userID, 1
			)
	END
	ELSE 
	BEGIN	
		SELECT 'Error!!! Permission exists, please check :', @UserName AS '@UserName', @userID AS '@userID', @PartyName AS '@PartyName', @PartyID AS '@PartyID'	
	END
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_UserPartyIns] TO [vnteam]
GO 
