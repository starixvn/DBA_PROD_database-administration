
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Dot_Admin_CheckSPExist    Script Date: 1/21/2019 4:30:01 AM ******/
-- =============================================
-- Check storedprocedure is existed in database or not
-- =============================================
create PROCEDURE [dbo].[Dot_Admin_CheckSPExist]
	@spName nvarchar(100)
AS

BEGIN
	DECLARE @ObjectId int
	SELECT @ObjectId = object_id(@spName,'p')
	IF (@ObjectId IS NULL)
		SELECT 'False' AS IsExisted
	ELSE
		SELECT 'True' AS IsExisted

END

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
