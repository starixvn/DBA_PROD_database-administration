
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_BillerModify    Script Date: 1/21/2019 4:30:02 AM ******/
/****** Object:  Stored Procedure dbo.LA_BillerModify    Script Date: 3/2/2017 5:29:36 AM ******/
/****** Object:  Stored Procedure dbo.LA_BillerModify    Script Date: 3/1/2017 3:47:05 PM ******/

CREATE PROCEDURE [dbo].[LA_BillerModify] 
	@BillerID							INT				
	, @BillerName						NVARCHAR (50)	
	, @BillerFullName					NVARCHAR (50)	= ''
	, @StatusId							TINYINT			
	, @CompanyName						NVARCHAR (100)	= ''
	, @Address1							NVARCHAR (255)	= ''
	, @Address2							NVARCHAR (255)	= ''
	, @Description						NVARCHAR (255)	= ''
	, @BankInfoXML						NVARCHAR (MAX)
	, @UserID							INT
	, @LoginIP							VARCHAR (50)	= ''
	, @ErrCode							INT				= 0		OUTPUT
	, @ErrMsg							NVARCHAR(1000)	= ''	OUTPUT
	, @BillerIdOut						INT	= 0	OUTPUT
AS
/*  
	 Created: 20150408@Florent
	 Task : Create new Biller
	 DB: DB052.bodb_Licensee  
   
	 Revisions:  
		- 20150917@Victor: Support Chinese on settings
		- 20170227@bruce: dont need to save logo path, consider to remove this column [RedmineID: #72187]

	 Param:@BankInfoXML:
			<BankInfo>
			  <Bank>
				<BankId>1</BankId>
				<AccountNumber>3424</AccountNumber>
				<BankName>bank</BankName>
				<BankAddress>bank address</BankAddress>
				<IBAN>IBAN</IBAN>
				<BeneficiaryName>name</BeneficiaryName>
				<SwiftCode>1266</SwiftCode>
				<CorrespondentBank>Ban</CorrespondentBank>
				<CorrespondentAccountNumber>245145515841266</CorrespondentAccountNumber>
				<CorrespondentAddress>ca</CorrespondentAddress>
				<CorrespondentSwiftCode>1241</CorrespondentSwiftCode>
			  </Bank>
			</BankInfo>

*/
BEGIN
SET NOCOUNT ON
-- For writing log
	DECLARE 
		@startRun		DATETIME,
		@endRun			DATETIME,
		@duration		INT,
		@logSPData		NVARCHAR(MAX),
		@logSPDataOld	NVARCHAR(MAX),
		@xml			XML

	-- Time start
	SET @startRun = GETDATE()

	DECLARE @ConstantName VARCHAR(20) = 'Invoice System'
	--check exist
	IF ISNULL(@BillerName, '') = ''
		RETURN

	IF ISNULL(@BankInfoXML, '') = ''
		RETURN
	-- parse XML
	SELECT @BankInfoXML = REPLACE(@BankInfoXML,N'&',N'&amp;')

	DECLARE @BankInfo AS TABLE (PartyId INT, BankId INT, AccountNumber NVARCHAR (50), BankName NVARCHAR (125), BankAddress NVARCHAR (255), IBAN NVARCHAR (50), BeneficiaryName NVARCHAR (125), SwiftCode NVARCHAR (50), CorrespondentBank NVARCHAR (100), CorrespondentAccountNumber NVARCHAR (50)
	, CorrespondentAddress NVARCHAR (255), CorrespondentSwiftCode NVARCHAR (50)) 	
	DECLARE @idoc AS INT
	EXEC sp_xml_preparedocument @idoc OUTPUT, @BankInfoXML

	INSERT INTO @BankInfo(PartyId, BankId, AccountNumber, BankName, BankAddress, IBAN, BeneficiaryName, SwiftCode, CorrespondentBank, CorrespondentAccountNumber, CorrespondentAddress, CorrespondentSwiftCode)
	SELECT @BillerID, BankId, AccountNumber, BankName, BankAddress, IBAN, BeneficiaryName, SwiftCode, CorrespondentBank, CorrespondentAccountNumber, CorrespondentAddress, CorrespondentSwiftCode
	FROM OPENXML(@idoc, 'BankInfo/Bank')
	WITH (
		BankId							INT				'BankId'
		, AccountNumber					NVARCHAR(50)	'AccountNumber'
		, BankName						NVARCHAR(125)	'BankName'
		, BankAddress					NVARCHAR(255)	'BankAddress'
		, IBAN							NVARCHAR(50)	'IBAN'
		, BeneficiaryName				NVARCHAR(125)	'BeneficiaryName'
		, SwiftCode						NVARCHAR(50)	'SwiftCode'
		, CorrespondentBank				NVARCHAR(100)	'CorrespondentBank'
		, CorrespondentAccountNumber	NVARCHAR(50)	'CorrespondentAccountNumber'
		, CorrespondentAddress			NVARCHAR(255)	'CorrespondentAddress'
		, CorrespondentSwiftCode		NVARCHAR(50)	'CorrespondentSwiftCode'

	)
	EXEC sp_xml_removedocument @idoc


	IF NOT EXISTS (SELECT 1 FROM dbo.OAS_Party p WITH (NOLOCK) WHERE p.PartyID = @BillerID AND p.PartyType = 4)
	--Insert New Biller
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM dbo.OAS_Party p WITH (NOLOCK) 
						INNER JOIN dbo.LA_BillerInfo b WITH (NOLOCK) ON p.PartyId = b.PartyID 
					 WHERE b.BillerName = @BillerName AND p.PartyType = 4)
		BEGIN
			INSERT INTO dbo.OAS_Party (PartyName, Description, PartyType, OldRefID)
			SELECT @ConstantName, @ConstantName, 4, NULL

			IF @@ERROR <> 0
			BEGIN
				--Rollback --delete
				RETURN --error system
			END

			SELECT @BillerIdOut = SCOPE_IDENTITY()

			INSERT INTO dbo.LA_BillerInfo(PartyId, BillerName, BillerFullName, StatusId, CompanyName, Address1, Address2, [Description])
			SELECT
					@BillerIdOut
					, @BillerName
					, @BillerFullName
					, @StatusId
					, @CompanyName
					, @Address1
					, @Address2
					, @Description
			IF @@ERROR <> 0 
			BEGIN 
				--rollback
				DELETE dbo.OAS_Party WITH(ROWLOCK)
				WHERE PartyID = @BillerIdOut
				SELECT @ErrCode = 100
					, @ErrMsg = 'Cannot save the Biller, please try again!'
				RETURN
			END

			INSERT INTO dbo.LA_BankInfo(BankId, PartyId, AccountNumber, BankName, BankAddress, IBAN, BeneficiaryName, SwiftCode, CorrespondentBank, CorrespondentAccountNumber, CorrespondentAddress, CorrespondentSwiftCode)
			SELECT BankId, @BillerIdOut, AccountNumber, BankName, BankAddress, IBAN, BeneficiaryName, SwiftCode, CorrespondentBank, CorrespondentAccountNumber, CorrespondentAddress, CorrespondentSwiftCode
			FROM @BankInfo

			IF @@ERROR <> 0 
			BEGIN 
				--rollback
				DELETE dbo.OAS_Party WITH(ROWLOCK)
				WHERE PartyID = @BillerIdOut
				DELETE dbo.LA_BillerInfo WITH (ROWLOCK)
				WHERE PartyId = @BillerIdOut

				SELECT @ErrCode = 100
					, @ErrMsg = 'Cannot save the Biller, please try again!'
				RETURN
			END

			-- Write log
			SET @xml = (
				SELECT	PartyId							AS '@b'
						, BillerName					AS '@bn'
						, BillerFullName				AS '@bfn'
						, StatusId						AS '@s'
						, CompanyName					AS '@c'
						, Address1						AS '@a1'
						, Address2						AS '@a2'
						, LogoPath						AS '@lg'
						, Description					AS '@d'
						, (SELECT BankId							AS '@bid'
									, AccountNumber					AS '@a'
									, BankName						AS '@bna'
									, BankAddress					AS '@ba'
									, IBAN							AS '@i'
									, BeneficiaryName				AS '@bd'
									, SwiftCode						AS '@sc'
									, CorrespondentBank				AS '@cb'
									, CorrespondentAccountNumber	AS '@ca'
									, CorrespondentAddress			AS '@cad'
									, CorrespondentSwiftCode		AS '@cs'
							FROM dbo.LA_BankInfo WITH(NOLOCK)
							WHERE PartyId = @BillerIdOut
					FOR XML PATH('x'), TYPE)
					FROM dbo.LA_BillerInfo WITH(NOLOCK)
					WHERE PartyId = @BillerIdOut
				FOR XML PATH('z'), ROOT('r')			
				)

			SET @logSpData = REPLACE(CONVERT(NVARCHAR(MAX), @xml), '" />', '"/"')	

			SET @endRun = GETDATE()
			SET @duration = DATEDIFF(MILLISECOND, @startRun, @endRun) 	
		END
		ELSE
		BEGIN
			SELECT @ErrCode = 101
			,@ErrMsg = 'Cannot save the Biller because it existed in the system, please try again!'
			RETURN
		END
	END
	ELSE
	--Edit Biller
	BEGIN		
		IF EXISTS (SELECT 1 FROM dbo.OAS_Party p WITH (NOLOCK) 
						INNER JOIN dbo.LA_BillerInfo b WITH (NOLOCK) ON p.PartyId = b.PartyID 
					 WHERE p.PartyID = @BillerID AND p.PartyType = 4)
		BEGIN
			SELECT @BillerIdOut = @BillerID
			-- Write log
			SET @xml = (
				SELECT	PartyId							AS '@b'
						, BillerName					AS '@bn'
						, BillerFullName				AS '@bfn'
						, StatusId						AS '@s'
						, CompanyName					AS '@c'
						, Address1						AS '@a1'
						, Address2						AS '@a2'
						, LogoPath						AS '@lg'
						, [Description]					AS '@d'
						, (SELECT BankId							AS '@bid'
									, AccountNumber					AS '@a'
									, BankName						AS '@bna'
									, BankAddress					AS '@ba'
									, IBAN							AS '@i'
									, BeneficiaryName				AS '@bd'
									, SwiftCode						AS '@sc'
									, CorrespondentBank				AS '@cb'
									, CorrespondentAccountNumber	AS '@ca'
									, CorrespondentAddress			AS '@cad'
									, CorrespondentSwiftCode		AS '@cs'																	
							FROM dbo.LA_BankInfo WITH(NOLOCK)
							WHERE PartyId = @BillerID
					FOR XML PATH('x'), TYPE)
				FROM dbo.LA_BillerInfo WITH (NOLOCK)
				WHERE PartyId = @BillerID
				FOR XML PATH('z'), ROOT('r')
				)

			SET @logSPDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @xml), '" />', '"/"')	

			UPDATE dbo.LA_BillerInfo WITH (ROWLOCK, UPDLOCK)
			SET BillerName					 = @BillerName
				, BillerFullName			 = @BillerFullName
				, StatusId					 = @StatusId
				, CompanyName				 = @CompanyName
				, Address1					 = @Address1
				, Address2					 = @Address2
				, Description				 = @Description
			WHERE PartyId = @BillerID	

			IF @@ERROR <> 0 
			BEGIN
				SELECT @ErrCode = 101
				,@ErrMsg = 'Cannot save the Biller because it existed in the system, please try again!'
				RETURN
			END

			--update discount group assingment
			;MERGE dbo.LA_BankInfo WITH(ROWLOCK, UPDLOCK) AS t
			USING @BankInfo AS s
			ON (t.PartyId = s.PartyId AND t.BankId = s.BankId)
			WHEN NOT MATCHED BY TARGET
				THEN INSERT(BankId, PartyId, AccountNumber, BankName, BankAddress, IBAN, BeneficiaryName, SwiftCode, CorrespondentBank, CorrespondentAccountNumber, CorrespondentAddress, CorrespondentSwiftCode)
				VALUES (	
						s.BankId, s.PartyId, s.AccountNumber, s.BankName, s.BankAddress, s.IBAN, s.BeneficiaryName, s.SwiftCode, s.CorrespondentBank, s.CorrespondentAccountNumber, s.CorrespondentAddress, s.CorrespondentSwiftCode
					 )
			WHEN MATCHED 
			THEN UPDATE SET	AccountNumber				=  s.AccountNumber
							, BankName					=  s.BankName
							, BankAddress				=  s.BankAddress
							, IBAN						=  s.IBAN
							, BeneficiaryName			=  s.BeneficiaryName
							, SwiftCode					=  s.SwiftCode
							, CorrespondentBank			=  s.CorrespondentBank
							, CorrespondentAccountNumber=  s.CorrespondentAccountNumber
							, CorrespondentAddress		=  s.CorrespondentAddress
							, CorrespondentSwiftCode	=  s.CorrespondentSwiftCode
			WHEN NOT MATCHED BY SOURCE AND t.PartyId = @BillerID 
			THEN DELETE;


			SET @xml = (
				SELECT	PartyId							AS '@b'
						, BillerName					AS '@bn'
						, BillerFullName				AS '@bfn'
						, StatusId						AS '@s'
						, CompanyName					AS '@c'
						, Address1						AS '@a1'
						, Address2						AS '@a2'
						, LogoPath						AS '@lg'
						, [Description]					AS '@d'
						, (SELECT BankId							AS '@bid'
									, AccountNumber					AS '@a'
									, BankName						AS '@bna'
									, BankAddress					AS '@ba'
									, IBAN							AS '@i'
									, BeneficiaryName				AS '@bd'
									, SwiftCode						AS '@sc'
									, CorrespondentBank				AS '@cb'
									, CorrespondentAccountNumber	AS '@ca'
									, CorrespondentAddress			AS '@cad'
									, CorrespondentSwiftCode		AS '@cs'																	
							FROM dbo.LA_BankInfo WITH(NOLOCK)
							WHERE PartyId = @BillerID
					FOR XML PATH('x'), TYPE)
				FROM dbo.LA_BillerInfo WITH (NOLOCK)
				WHERE PartyId = @BillerID
				FOR XML PATH('z'), ROOT('r')
				)

			SET @logSpData = REPLACE(CONVERT(NVARCHAR(MAX), @xml), '" />', '"/"')	

			SET @endRun = GETDATE()
			SET @duration = DATEDIFF(MILLISECOND, @startRun, @endRun) 	

		END		
		ELSE
		BEGIN
			SELECT @ErrCode = 101
			,@ErrMsg = 'Cannot save the Biller because it existed in the system, please try again!'
			RETURN
		END
	END
	
	--Write Log	
	DECLARE @ActionID INT = 0
	SELECT @ActionID = ActionId
	FROM bodb_CustomerLog.dbo.LogAction_Lic WITH (NOLOCK)

	WHERE SPName = 'LA_BillerModify'
	BEGIN TRY
		EXEC bodb_CustomerLog.dbo.NAP_SpecialCustSetting_WriteLog 
			@UserId = @UserID
			, @IP = @LoginIP
			, @LicenseeID = 0
			, @CurrencyID = 0
			, @SPName = 'LA_BillerModify'
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
 GRANT EXECUTE ON [dbo].[LA_BillerModify] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_BillerModify] TO [vnteam]
GO 
