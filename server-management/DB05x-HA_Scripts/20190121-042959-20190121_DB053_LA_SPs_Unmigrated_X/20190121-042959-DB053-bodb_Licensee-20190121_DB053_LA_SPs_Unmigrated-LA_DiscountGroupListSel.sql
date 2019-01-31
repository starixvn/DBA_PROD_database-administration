
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_DiscountGroupListSel    Script Date: 1/21/2019 4:30:03 AM ******/
/****** Object:  Stored Procedure dbo.LA_DiscountGroupListSel    Script Date: 15/06/2015 13:57:52 PM ******/
CREATE PROCEDURE dbo.LA_DiscountGroupListSel @DiscountGroupType TINYINT
AS
/*  
	 Created: 20150422@Patrick
	 Task : Discount group select
	 DB: DB052.bodb_Licensee
	 Revisions:     
		
	 Params:
*/
BEGIN
	SET NOCOUNT ON
	SELECT DiscountGroupId, DiscountGroupName
	FROM dbo.LA_DiscountGroupHeader WITH(NOLOCK)
	WHERE DiscountGroupType = @DiscountGroupType
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_DiscountGroupListSel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_DiscountGroupListSel] TO [vnteam]
GO 
