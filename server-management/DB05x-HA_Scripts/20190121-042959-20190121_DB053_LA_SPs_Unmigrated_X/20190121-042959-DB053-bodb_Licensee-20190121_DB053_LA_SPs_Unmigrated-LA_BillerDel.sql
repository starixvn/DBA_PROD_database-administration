
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_BillerDel    Script Date: 1/21/2019 4:30:02 AM ******/

CREATE PROCEDURE [dbo].[LA_BillerDel] 
	@BillerID	INT	
	, @UserID	INT
	, @LoginIP	VARCHAR (50)	= ''
	, @ErrCode	INT				= 0		OUTPUT
	, @ErrMsg	NVARCHAR(1000)	= ''	OUTPUT
AS
/*  
	 Created: 20150408@Florent
	 Task : Delete Biller Information
	 DB: DB052.bodb_Licensee  
   
	 Revisions:     
		- 20150918@Victor: Support Chinese on Settings
		- 20161110@bruce.bui: fixbug- do not allow delete biller if invoice is issued
*/
BEGIN
	SET NOCOUNT ON

	--check exist
	IF ISNULL(@BillerID, '') = ''
		RETURN

	-- only can delete which Biller dont issue any invoice on system
	IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.LA_InvoiceHeader WITH(NOLOCK) WHERE BillerId = @BillerID)
		BEGIN
			DECLARE 
				@startRun		DATETIME,
				@endRun			DATETIME,
				@duration		INT,
				@logSPData		NVARCHAR(MAX),
				@logSPDataOld	NVARCHAR(MAX),
				@xml			XML

			-- Time start
			SET @startRun = GETDATE()
	
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
							WHERE PartyId = @BillerId
					FOR XML PATH('x'), TYPE)
					FROM dbo.LA_BillerInfo WITH(NOLOCK)
					WHERE PartyId = @BillerId
				FOR XML PATH('z'), ROOT('r')			
				)

			SET @logSPDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @xml), '" />', '"/"')	

			DELETE dbo.OAS_Party WITH (ROWLOCK, UPDLOCK)
			WHERE PartyType = 4 AND PartyID = @BillerId

			DELETE dbo.LA_BillerInfo WITH (ROWLOCK, UPDLOCK)
			WHERE PartyId = @BillerId

			DELETE dbo.LA_BankInfo WITH (ROWLOCK, UPDLOCK)
			WHERE PartyId = @BillerId

			--Delete setting
			
			DELETE dbo.LA_InvoiceSetting WITH (ROWLOCK, UPDLOCK)
			WHERE ToPartyId = @BillerId
					
			IF @@ERROR <> 0 
			BEGIN 
				SELECT @ErrCode = 110
					, @ErrMsg = 'Cannot delete the Biller, please try again!'
			RETURN
			END

			SET @endRun = GETDATE()
			SET @duration = DATEDIFF(MILLISECOND, @startRun, @endRun) 
			

			--Write log	
			DECLARE @ActionID INT = 0
			SELECT @ActionID = ActionId
			FROM bodb_CustomerLog.dbo.LogAction_Lic WITH (NOLOCK)
			WHERE SPName = 'LA_BillerDel'

			BEGIN TRY
				EXEC bodb_CustomerLog.dbo.NAP_SpecialCustSetting_WriteLog 
					@UserId = @UserID
					, @IP = @LoginIP
					, @LicenseeID = 0
					, @CurrencyID = 0
					, @SPName = 'LA_BillerDel'
					, @CustId = 0
					, @ActionId = @ActionID
					, @Duration = @duration
					, @Data = @logSPData
					, @OldData = @logSPDataOld
				BEGIN
					SELECT @ErrCode = 0
						,@ErrMsg = 'The Biller is deleted successfully'
					RETURN
				END
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
	ELSE	
		BEGIN
			SELECT @ErrCode = 112
			,@ErrMsg = 'The Biller cannot be deleted because it''s already responsible for billing!'
			RETURN
		END		
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_BillerDel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_BillerDel] TO [vnteam]
GO 
