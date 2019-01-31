
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_InvoiceSettingModify    Script Date: 1/21/2019 4:30:05 AM ******/
/****** Object:  Stored Procedure dbo.LA_InvoiceSettingModify    Script Date: 12/13/2016 11:26:28 PM ******/
/****** Object:  Stored Procedure dbo.LA_InvoiceSettingModify    Script Date: 12/9/2016 2:18:08 PM ******/

CREATE PROCEDURE [dbo].[LA_InvoiceSettingModify] 
	@BillerID				INT				
	, @PayerID				INT
	, @BankId				INT				= NULL
	, @isEdit				BIT
	, @InvoiceSettingXML	VARCHAR (5000)
	, @UserID				INT
	, @LoginIP				VARCHAR (50)	= ''
	, @ErrCode				INT				= 0		OUTPUT
	, @ErrMsg				NVARCHAR(1000)	= ''	OUTPUT
AS
/*  
	 Created: 20150414@Florent
	 Task : Create new Biller
	 DB: DB052.bodb_Licensee  
   
	 Revisions:     
		+ @Bravo-2016.08.08: Hosting fees
		+ @Bruce-2016.11.15: Adding setup fees
	 Params:
		+ @IsEdit:	0 : Case Insert
					1 : Case Edit
		+ @InvoiceSettingXML: '<InvoiceSettings>
									<InvoiceSetting>
										<InvoiceTypeId>1</InvoiceTypeId>  
										<InvoiceTemplateId>1</InvoiceTemplateId>
										<ActiveAddress>1</ActiveAddress>
										<ProductIds ProductId = "1"></ProductIds>
										<ProductIds ProductId = "3"></ProductIds>
										<ProductIds ProductId = "5"></ProductIds>
									</InvoiceSetting>
							
									<InvoiceSetting>
										<InvoiceTypeId>2</InvoiceTypeId>  
										<InvoiceTemplateId>1</InvoiceTemplateId>
										<ActiveAddress>1</ActiveAddress>
										<ProductIds />
									</InvoiceSetting>
							
									<InvoiceSetting>
										<InvoiceTypeId>3</InvoiceTypeId>  
										<InvoiceTemplateId>3</InvoiceTemplateId>
										<ActiveAddress>1</ActiveAddress>
										<ProductIds />
									</InvoiceSetting>
								</InvoiceSettings>'
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @startRun DATETIME, @endRun	DATETIME, @duration INT, @logSPData VARCHAR(5000), @logSPDataOld VARCHAR(5000),	@xml XML
	
	IF ISNULL(@BankId, 0) = 0
		SET @BankId = 0

	SET @startRun = GETDATE()
	DECLARE @ProductListByPayer AS TABLE (ProductId INT)
	-- parse XML
	DECLARE @InvoiceSetting AS TABLE (InvoiceTypeId INT, InvoiceTemplateId INT, ActiveAddress INT, ProductId INT)
	DECLARE @idoc AS INT
	EXEC sp_xml_preparedocument @idoc OUTPUT, @InvoiceSettingXML

	INSERT INTO @InvoiceSetting( InvoiceTypeId, InvoiceTemplateId, ActiveAddress, ProductId)
	SELECT InvoiceTypeId, InvoiceTemplateId, ActiveAddress, ProductId
	FROM OPENXML(@idoc, 'InvoiceSettings/InvoiceSetting/ProductIds')
	WITH (
		InvoiceTypeId VARCHAR(10) '../InvoiceTypeId',
		InvoiceTemplateId VARCHAR(10) '../InvoiceTemplateId',
		ActiveAddress VARCHAR(10) '../ActiveAddress',
		ProductId VARCHAR(10) '@ProductId'
	)
	EXEC sp_xml_removedocument @idoc
	
	--get list product offered to Payer
	INSERT INTO @ProductListByPayer
	SELECT c.ProductID
	FROM dbo.OAS_Party p WITH (NOLOCK)
		INNER JOIN dbo.OAS_ChargeInfo c WITH (NOLOCK) ON p.PartyID = c.FromParty
		INNER JOIN dbo.LA_ChargeInfo_SystemMapping cs WITH (NOLOCK) ON c.ChargeID = cs.ChargeID AND cs.SystemID = 2
	WHERE (@PayerId = 0 OR p.PartyID = @PayerId)
	GROUP BY c.ProductID

	--reset product for invoice type: horse racing, hosting fee, fee type
	--UPDATE @InvoiceSetting
	--SET ProductId = NULL --dummy product
	--WHERE InvoiceTypeId IN (1,2)

	-- Case Insert New setting
	IF @IsEdit = 0
	BEGIN
		IF NOT EXISTS (SELECT 1 
						FROM dbo.LA_InvoiceSetting i WITH (NOLOCK) 
						WHERE i.FromPartyId = @PayerID AND i.ToPartyId = @BillerID)
			BEGIN
				SET @IsEdit = 0
			END
			ELSE 
			BEGIN
				SELECT @ErrMsg = CASE WHEN @IsEdit = 0 THEN 'Insert failed. Please try again.' ELSE 'Update failed. Please try again.' END
					, @ErrCode = CASE WHEN @IsEdit = 0 THEN 130	ELSE 131 END
				RETURN
			END
	END
	--case Edit
	ELSE
	BEGIN
		IF EXISTS (SELECT 1 
						FROM dbo.LA_InvoiceSetting i WITH (NOLOCK) 
						WHERE i.FromPartyId = @PayerID AND i.ToPartyId = @BillerID)
			BEGIN
				SET @IsEdit = 1
			END
			ELSE 
			BEGIN
				SELECT @ErrMsg = CASE WHEN @IsEdit = 0 THEN 'Insert failed. Please try again.' ELSE 'Update failed. Please try again.' END
					, @ErrCode = CASE WHEN @IsEdit = 0 THEN 140	ELSE 141 END
				RETURN
			END
	END
	
	--check invalid product
	IF EXISTS (SELECT 1 FROM @InvoiceSetting i 
		WHERE i.ProductId NOT IN( SELECT ProductID FROM @ProductListByPayer) AND i.ProductId IS NOT NULL)
	BEGIN
		SELECT @ErrMsg = CASE WHEN @IsEdit = 0 THEN 'Insert failed. Please try again.' ELSE 'Update failed. Please try again.A' END
			, @ErrCode = CASE WHEN @IsEdit = 0 THEN 150	ELSE 151 END
		RETURN
	END

	--check exists Biller
	IF NOT EXISTS (SELECT 1 FROM @InvoiceSetting)
	BEGIN
		SELECT @ErrMsg = CASE WHEN @IsEdit = 0 THEN 'Insert failed. Please try again.' ELSE 'Update failed. Please try again.' END
			, @ErrCode = CASE WHEN @IsEdit = 0 THEN 160	ELSE 161 END
		RETURN
	END

	--check exists Biller
	IF NOT EXISTS (SELECT 1 
					FROM dbo.OAS_Party 
					WHERE PartyID = @BillerID AND PartyType = 4)
	BEGIN
		SELECT @ErrMsg = CASE WHEN @IsEdit = 0 THEN 'Insert failed. Please try again.' ELSE 'Update failed. Please try again.' END
			, @ErrCode = CASE WHEN @IsEdit = 0 THEN 170	ELSE 171 END
		RETURN
	END

	--check exists Payer: licensee, bopping, ow
	IF NOT EXISTS (SELECT 1 
					FROM dbo.OAS_Party 
					WHERE PartyID = @PayerID AND PartyType <> 4)
	BEGIN
		SELECT @ErrMsg = CASE WHEN @IsEdit = 0 THEN 'Insert failed. Please try again.' ELSE 'Update failed. Please try again.' END
			, @ErrCode = CASE WHEN @IsEdit = 0 THEN 180	ELSE 181 END
		RETURN
	END

	--required field
	IF EXISTS (SELECT 1 FROM @InvoiceSetting WHERE InvoiceTypeId IS NULL OR InvoiceTemplateId IS NULL OR ActiveAddress IS NULL)
	BEGIN
		SELECT @ErrMsg = CASE WHEN @IsEdit = 0 THEN 'Insert failed. Please try again.' ELSE 'Update failed. Please try again.' END
			, @ErrCode = CASE WHEN @IsEdit = 0 THEN 190	ELSE 191 END
		RETURN
	END
	
	--check duplicate PK
	IF EXISTS (SELECT 1 
				FROM @InvoiceSetting 
				GROUP BY InvoiceTypeId, ProductId
				HAVING COUNT(1) > 1)
	BEGIN
		SELECT @ErrMsg = CASE WHEN @IsEdit = 0 THEN 'Insert failed. Please try again.' ELSE 'Update failed. Please try again.' END
			, @ErrCode = CASE WHEN @IsEdit = 0 THEN 230	ELSE 231 END
		RETURN
	END
	
	--must be selected one product for invoice type is 1 (software data fees)
	IF EXISTS (SELECT 1 FROM @InvoiceSetting 
				WHERE InvoiceTypeId = 1
				GROUP BY ProductId
				HAVING COUNT(1) = 0)
	BEGIN
		SELECT @ErrMsg = CASE WHEN @IsEdit = 0 THEN 'Insert failed. Please try again.' ELSE 'Update failed. Please try again.' END
			, @ErrCode = CASE WHEN @IsEdit = 0 THEN 240	ELSE 241 END
		RETURN
	END
	
	-- Case Insert New setting
	DECLARE @ProductIdHF INT = (SELECT TOP 1 Productid FROM dbo.Product3rd WHERE ProductName = 'Hosting')
	DECLARE @InvoiceTypeHostingFeesId INT = (SELECT InvTypeId FROM dbo.LA_InvoiceType WHERE InvTypeName LIKE 'Hosting Fees')
	
	DECLARE @ProductIdSetupFees INT = (SELECT TOP 1 Productid FROM dbo.Product3rd WHERE ProductName = 'Setup Fees')
	DECLARE @InvoiceTypeSetupFeesId INT = (SELECT InvTypeId FROM dbo.LA_InvoiceType WHERE InvTypeName LIKE 'Setup Fees')

	IF @IsEdit = 0
	BEGIN
		INSERT INTO dbo.LA_InvoiceSetting(FromPartyId, ToPartyId, ProductId, InvTypeId, InvTempId, BankId, ActiveAddress)
		SELECT @PayerId, @BillerID, 
			CASE
				WHEN InvoiceTypeId = @InvoiceTypeHostingFeesId THEN @ProductIdHF
				WHEN InvoiceTypeId = @InvoiceTypeSetupFeesId THEN @ProductIdSetupFees
				ELSE ProductId
			END, 
			InvoiceTypeId, InvoiceTemplateId, @BankId, ActiveAddress
		FROM @InvoiceSetting

		IF @@ERROR <> 0
		BEGIN
			SELECT 	@ErrMsg = 'Insert failed. Please try again.', @ErrCode = 130
			RETURN
		END

		--write log
		SET @xml = (
				SELECT	@PayerId				AS '@f'
						, @BillerID				AS '@t'
						, ProductId				AS '@p'
						, InvoiceTypeId			AS '@itp'
						, InvoiceTemplateId		AS '@itm'		
						, @BankId				AS '@b'	
						, ActiveAddress			AS '@aa'		
				FROM @InvoiceSetting
				FOR XML PATH('z'), ROOT('r')			
				)
			SET @logSpData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')	

			SET @endRun = GETDATE()
			SET @duration = DATEDIFF(MILLISECOND, @startRun, @endRun) 	

	END
	-- Case Update
	ELSE
	BEGIN
		--build log string
		SET @xml = (
				SELECT	FromPartyId		AS '@f'
						, ToPartyId		AS '@t'
						, ProductId		AS '@p'
						, InvTypeId		AS '@itp'
						, InvTempId		AS '@itm'	
						, BankId		AS '@b'
						, ActiveAddress AS '@aa'				
				FROM dbo.LA_InvoiceSetting WITH (NOLOCK)
				WHERE FromPartyId = @PayerId
					AND ToPartyId = @BillerID
				FOR XML PATH('z'), ROOT('r')			
				)
		SET @logSPDataOld = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"');

		MERGE dbo.LA_InvoiceSetting WITH(ROWLOCK, UPDLOCK) AS t
		USING @InvoiceSetting AS s
		ON (FromPartyId = @PayerID AND ToPartyId = @BillerID AND t.ProductId = s.ProductId AND t.InvTypeId = s.InvoiceTypeId AND t.ActiveAddress = s.ActiveAddress) 
		WHEN NOT MATCHED BY TARGET
			THEN INSERT(FromPartyId, ToPartyId, ProductId, InvTypeId, InvTempId, BankId, ActiveAddress) 
				 VALUES(@PayerId, @BillerID,
					CASE
						WHEN InvoiceTypeId = @InvoiceTypeHostingFeesId THEN @ProductIdHF
						WHEN InvoiceTypeId = @InvoiceTypeSetupFeesId THEN @ProductIdSetupFees
						ELSE ProductId
					END, 
					s.InvoiceTypeId, s.InvoiceTemplateId, @BankId, s.ActiveAddress)
		WHEN MATCHED 
			THEN UPDATE SET InvTempId = s.InvoiceTemplateId
							, BankId = @BankId
							, ActiveAddress = s.ActiveAddress
		WHEN NOT MATCHED BY SOURCE AND FromPartyId = @PayerID AND ToPartyId = @BillerID
			THEN DELETE;
		--OUTPUT $ACTION, inserted.*, deleted.*;
		
		IF @@ERROR <> 0
		BEGIN
			SELECT 	@ErrMsg = 'Update failed. Please try again.', @ErrCode = 131	
			RETURN
		END

		--write log		
		SET @xml = (
				SELECT	@PayerId				AS '@f'
						, @BillerID				AS '@t'
						, ProductId				AS '@p'
						, InvoiceTypeId			AS '@itp'
						, InvoiceTemplateId		AS '@itm'
						, @BankId				AS '@b'		
						, ActiveAddress			AS '@aa'			
				FROM @InvoiceSetting
				FOR XML PATH('z'), ROOT('r')			
				)
			SET @logSpData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')	

			SET @endRun = GETDATE()
			SET @duration = DATEDIFF(MILLISECOND, @startRun, @endRun) 
	END

	--Write Log		
	DECLARE @ActionID INT = 0
	SELECT @ActionID = ActionId
	FROM bodb_CustomerLog.dbo.LogAction_Lic WITH (NOLOCK)
	WHERE SPName = 'LA_InvoiceSettingModify'
	
	BEGIN TRY
		EXEC bodb_CustomerLog.dbo.NAP_SpecialCustSetting_WriteLog 
			@UserId = @UserID
			, @IP = @LoginIP
			, @LicenseeID = 0
			, @CurrencyID = 0
			, @SPName = 'LA_InvoiceSettingModify'
			, @CustId = 0
			, @ActionId = @ActionID
			, @Duration = @duration
			, @Data = @logSPData
			, @OldData = @logSPDataOld
	END TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID
			, @CustID = 0
			, @ActionID = @ActionID
			, @TrackingValue = @LogSPData
			, @TrackingValue2 = @logSPDataOld
			, @duration = @duration
	END CATCH
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_InvoiceSettingModify] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_InvoiceSettingModify] TO [vnteam]
GO 
