
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_DiscountGroupValidListSel    Script Date: 1/21/2019 4:30:03 AM ******/
/****** Object:  Stored Procedure dbo.LA_DiscountGroupValidListSel    Script Date: 15/06/2015 13:57:52 PM ******/
/****** Object:  Stored Procedure dbo.LA_DiscountGroupValidListSel    Script Date: 18/05/2015 09:15:08 AM ******/
CREATE PROCEDURE [dbo].[LA_DiscountGroupValidListSel] 
	@DiscountGroupType TINYINT
AS
/*  
	 Created: 20150422@Florent
	 Task : get all valid group
	 DB: DB052.bodb_Licensee
	 Revisions:     
		
	 Params:
*/
BEGIN
	SET NOCOUNT ON
	SELECT DiscountGroupId, DiscountGroupName
	FROM dbo.LA_DiscountGroupHeader WITH(NOLOCK)
	WHERE DiscountGroupType = @DiscountGroupType
		AND CONVERT(DATE,GETDATE()) BETWEEN FromDate AND ToDate
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_DiscountGroupValidListSel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_DiscountGroupValidListSel] TO [vnteam]
GO 
