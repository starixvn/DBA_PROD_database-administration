
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_Inv_AmfPartySel    Script Date: 1/21/2019 4:30:04 AM ******/
/****** Object:  Stored Procedure dbo.LA_Inv_AmfPartySel    Script Date: 7/19/2018 3:21:22 AM ******/
CREATE PROCEDURE [dbo].[LA_Inv_AmfPartySel]
	@HasAmf			BIT,
	@UserId			INT,
	@FunctionId		INT,
	@Environment	VARCHAR(50)
AS
/*	Header:
	Created: 20171226 - Bruce.Bui
	Task : Manage AMF
	DB: DB052.bodb_Licensee

	Revisions:
		- 20171226: create SP
		- 20180716@bruce: add new group TEST for credit [#98126]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Parties TABLE(PartyId INT, PartyName VARCHAR(50), BrandName VARCHAR(50), ParentId INT, HasAmf BIT)
	INSERT INTO @Parties (PartyId, PartyName, BrandName, ParentId)
		EXEC dbo.LA_PartyListSel @UserId = @UserId, @FunctionId=@FunctionId

	INSERT INTO @Parties (PartyId, PartyName, BrandName, ParentId)
	EXEC dbo.LA_PartyListNonOfficialSel

	UPDATE p SET HasAmf = 1
	FROM dbo.LA_InvoiceStatement s WITH(NOLOCK)
	INNER JOIN dbo.LA_InvoiceHeader h WITH(NOLOCK) ON h.InvoiceHeaderId=s.InvoiceHeaderId
	INNER JOIN @Parties p ON p.PartyId = s.RefPartyId
	WHERE s.InvItemTypeId = 3 AND p.ParentId > 0
		AND h.StatusId = 0 -- 0: normal invoice
		AND h.Environment=@Environment

	;WITH p AS (
		SELECT  PartyId, PartyName, BrandName, ParentId
		FROM @Parties
		WHERE ParentId>0 AND ISNULL(HasAmf,0) = @HasAmf
	)
	SELECT PartyId, PartyName, BrandName, ParentId
	FROM @Parties pp
	WHERE pp.ParentId=0 AND pp.PartyId IN (SELECT DISTINCT p.ParentId FROM p)
	UNION ALL
	SELECT PartyId, PartyName, BrandName, ParentId FROM p
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_Inv_AmfPartySel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_Inv_AmfPartySel] TO [vnteam]
GO 
