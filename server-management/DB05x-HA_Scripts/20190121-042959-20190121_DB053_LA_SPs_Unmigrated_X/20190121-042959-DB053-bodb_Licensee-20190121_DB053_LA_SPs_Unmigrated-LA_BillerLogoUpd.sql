
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_BillerLogoUpd    Script Date: 1/21/2019 4:30:02 AM ******/
/****** Object:  Stored Procedure dbo.LA_BillerLogoUpd    Script Date: 3/1/2017 3:46:48 PM ******/

CREATE PROCEDURE [dbo].[LA_BillerLogoUpd]
	@logoData	VARBINARY(MAX)
	, @height	INT
	, @width	INT
	, @billerId	INT
AS
/*
	 Created: 20170224@bruce
	 Task : save biller logo [RedmineID: #72187]
	 DB: DB052.bodb_Licensee

	 Revisions:
*/
BEGIN
SET NOCOUNT ON
	UPDATE dbo.LA_BillerInfo WITH(ROWLOCK, UPDLOCK)
	SET	Logo = @logoData,
		LogoHeight=@height,
		LogoWidth=@width
	WHERE PartyId=@billerId
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_BillerLogoUpd] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_BillerLogoUpd] TO [vnteam]
GO 
