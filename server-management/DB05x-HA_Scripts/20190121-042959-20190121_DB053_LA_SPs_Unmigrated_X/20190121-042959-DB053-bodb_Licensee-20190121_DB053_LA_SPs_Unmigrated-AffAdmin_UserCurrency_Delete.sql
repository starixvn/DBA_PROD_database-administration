
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.AffAdmin_UserCurrency_Delete    Script Date: 1/21/2019 4:30:01 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_UserCurrency_Delete    Script Date: 12/22/2015 4:36:47 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_UserCurrency_Delete    Script Date: 12/8/2015 09:52:32 ******/
CREATE PROCEDURE [dbo].[AffAdmin_UserCurrency_Delete]
(
	@UserID	INT,
	@LicenseeID INT
)
/*
	Created: 20151111@Victor
	DB: DBLIC/bodb_licensee
	Remark: Delete User's Currency data
	Revision:
*/
AS
BEGIN
	DECLARE @System INT
	SELECT @System = id FROM dbo.Systems WITH (NOLOCK) WHERE SystemName LIKE 'AFF'

	DELETE FROM dbo.CurrencyUser 
	WHERE SystemID = @System -- Affiliate
		AND UsrID = @UserID
		AND LicenseeID = @LicenseeID
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[AffAdmin_UserCurrency_Delete] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[AffAdmin_UserCurrency_Delete] TO [vnteam]
GO 
