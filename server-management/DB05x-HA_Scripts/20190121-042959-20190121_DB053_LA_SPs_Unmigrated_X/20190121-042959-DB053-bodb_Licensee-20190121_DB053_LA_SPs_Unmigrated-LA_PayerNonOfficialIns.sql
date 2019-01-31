
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_PayerNonOfficialIns    Script Date: 1/21/2019 4:30:06 AM ******/
/****** Object:  Stored Procedure dbo.LA_PayerNonOfficialIns    Script Date: 12/9/2016 2:20:08 PM ******/

CREATE PROCEDURE [dbo].[LA_PayerNonOfficialIns]
	@BrandName		VARCHAR (100)	= ''
	, @CompanyName		NVARCHAR (100)	= ''
	, @Description		NVARCHAR (255)	= ''
	, @AttnName			NVARCHAR (125)	= ''
	, @Address1			NVARCHAR (255)	= ''
	, @Address2			NVARCHAR (255)	= ''
	, @PayerName		VARCHAR (50)
	, @BaseCurrencyId	INT
	, @IsActive			BIT				= 1
	, @IsDeposit		BIT				= 1
	, @PayerId			INT				= 0  OUTPUT
	, @UserID			INT
	, @LoginIP			VARCHAR (50)	= ''
	, @ErrCode			INT				= 0  OUTPUT
	, @ErrMsg			NVARCHAR(1000)	= '' OUTPUT
AS
/*
	Created: 20161109@bruce.bui
	Task : Insert non official payer
	DB: DB052.bodb_Licensee

	Revisions:
	- 20161124@scofield: check unique BrandName
*/
BEGIN

	SET NOCOUNT ON

	-- For writing log
	DECLARE @startRun	DATETIME
		, @endRun		DATETIME
		, @duration		INT
		, @xml			XML
	-- Time start
	SET @startRun = GETDATE()

	IF EXISTS (
		SELECT 1 FROM dbo.OAS_Party WITH(NOLOCK)
		WHERE PartyType IN (1,5) AND PartyName = @PayerName
	) BEGIN
		SELECT @ErrCode = 101,@ErrMsg = 'Payer Name is existed in the system, please try again!'
		RETURN
	END
	
	IF EXISTS (
		SELECT 1 FROM dbo.OAS_PartyDetail WITH(NOLOCK)
		WHERE @BrandName != '' AND BrandName = @BrandName
	) BEGIN
		SELECT @ErrCode = 101,@ErrMsg = 'Payer Brand Name is existed in the system, please try again!'
		RETURN
	END

	INSERT INTO dbo.OAS_Party(PartyName, Description, PartyType) VALUES (@PayerName, 'Non-Official', 5)
	SET @PayerId = SCOPE_IDENTITY()

	INSERT INTO dbo.OAS_PartyDetail(PartyId, BrandName, CompanyName, AttnName, Description, Address1, Address2, BaseCurrencyId, IsAllowedMemberComm, IsDeposit, StatusId)
	VALUES(@PayerId, @BrandName, @CompanyName, @AttnName, @Description, @Address1, @Address2, @BaseCurrencyId, 0, @IsDeposit , @IsActive)

	SET @xml = (
		SELECT	p.PartyID			AS '@pid'
				, p.PartyName		AS '@pn'
				, pd.StatusId		AS '@s'
				, pd.IsDeposit		AS '@isd'
				, pd.BrandName		AS '@bn'
				, pd.CompanyName	AS '@cn'
				, pd.AttnName		AS '@an'
				, pd.Description	AS '@des'
				, pd.Address1		AS '@a1'
				, pd.Address2		AS '@a2'
				, pd.BaseCurrencyId	AS '@bc'
		FROM dbo.OAS_Party p WITH (NOLOCK)
			INNER JOIN dbo.OAS_PartyDetail pd WITH (NOLOCK) ON p.PartyID = pd.PartyID
		WHERE p.PartyID = @PayerId
		FOR XML PATH('z'), ROOT('r')
	)

	SET @endRun = GETDATE()
	SET @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	--Write Log
	DECLARE @ActionID INT = 0
	DECLARE @SPName VARCHAR(50) = 'LA_PayerNonOfficialIns'

	SELECT @ActionID = ActionId
	FROM bodb_CustomerLog.dbo.LogAction_Lic WITH (NOLOCK)
	WHERE SPName = @SPName

	BEGIN TRY
		EXEC bodb_CustomerLog.dbo.NAP_SpecialCustSetting_WriteLog 
			@UserId = @UserID
			, @IP = @LoginIP
			, @LicenseeID = 0
			, @CurrencyID = 0
			, @SPName = @SPName
			, @CustId = 0
			, @ActionId = @ActionID
			, @Duration = @duration
			, @Data = @xml
			, @OldData = ''
	END TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID
			, @CustID = 0
			, @ActionID = @ActionID
			, @TrackingValue = @xml
			, @TrackingValue2 = ''
			, @duration = @duration
	END CATCH	
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_PayerNonOfficialIns] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_PayerNonOfficialIns] TO [vnteam]
GO 
