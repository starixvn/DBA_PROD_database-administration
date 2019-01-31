
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.AffAdmin_UserCurrency_Insert    Script Date: 1/21/2019 4:30:01 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_UserCurrency_Insert    Script Date: 12/22/2015 4:36:48 AM ******/
/****** Object:  Stored Procedure dbo.AffAdmin_UserCurrency_Insert    Script Date: 12/8/2015 09:52:32 ******/
CREATE PROCEDURE [dbo].[AffAdmin_UserCurrency_Insert]
(
	@UserID			INT,
	@LicenseeID		INT,
	@currencyIDs	VARCHAR(1000),
	@IsActive		INT = 1
)
/*
	Created: 20151118@Victor
	DB: DBLIC/bodb_licensee
	Remark: Insert User's Currency
	Revision:
*/
AS
BEGIN
	DECLARE @System INT
	SELECT @System = id FROM dbo.Systems WITH (NOLOCK) WHERE SystemName LIKE 'AFF'

	DECLARE @CurrencyList TABLE (CurrencyID INT)
	INSERT INTO @CurrencyList (CurrencyID)
	SELECT CAST(val AS INT) FROM bodb02.dbo.Lrf_f_StringSplit(@currencyIDs, ',')
	
	INSERT INTO dbo.CurrencyUser (usrID, LicenseeID, CurrencyID, SystemID, isActive)
	SELECT @UserID, @LicenseeID, CurrencyID, @System, @IsActive -- Affiliate
	FROM @CurrencyList

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[AffAdmin_UserCurrency_Insert] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[AffAdmin_UserCurrency_Insert] TO [vnteam]
GO 
