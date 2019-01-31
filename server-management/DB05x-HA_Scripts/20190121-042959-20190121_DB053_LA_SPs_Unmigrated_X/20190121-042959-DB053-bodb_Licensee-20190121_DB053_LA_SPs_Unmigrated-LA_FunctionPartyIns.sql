
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_FunctionPartyIns    Script Date: 1/21/2019 4:30:03 AM ******/
/****** Object:  Stored Procedure dbo.LA_FunctionPartyIns    Script Date: 02/03/2015 17:07:56 PM ******/

CREATE PROCEDURE [dbo].[LA_FunctionPartyIns] 
	@FunctionName			NVARCHAR(100)
	, @PartyName			NVARCHAR(50)	
AS
/*
	Created: 20150302@Florent
	Task : add permission for LA, Function - Party
	Base : 
	DB: DB052.bodb_licensee

	Revisions:
	Param's Explanation:
*/
BEGIN	
	DECLARE @FunctionID INT, @PartyID INT
	SELECT @FunctionID = FunctionID 
	FROM dbo.LA_Function WITH (NOLOCK) 
	WHERE FunctionName = @FunctionName

	SELECT @PartyID = PartyID
	FROM dbo.OAS_Party WITH (NOLOCK)
	WHERE PartyName = @PartyName
		AND PartyType = 1	
	IF ISNULL(@FunctionID,0) = 0 OR ISNULL(@PartyID,0) = 0		
	BEGIN
		SELECT 'Error!!! Data error, please check :', @FunctionName AS '@FunctionName', @FunctionID AS '@FunctionID', @PartyName AS '@PartyName', @PartyID AS '@PartyID'
		RETURN
	END

	---
	IF NOT EXISTS (SELECT 1 FROM dbo.LA_FunctionParty WITH (NOLOCK) WHERE FunctionID = @FunctionID AND PartyID = @PartyID)
	BEGIN
		INSERT INTO dbo.LA_FunctionParty (FunctionID, PartyID)
			(
				SELECT @FunctionID, @PartyID
			)
	END
	ELSE 
	BEGIN	
		SELECT 'Error!!! Permission exists, please check :', @FunctionName AS '@FunctionName', @FunctionID AS '@FunctionID', @PartyName AS '@PartyName', @PartyID AS '@PartyID'
	END
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_FunctionPartyIns] TO [vnteam]
GO 
