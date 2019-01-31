
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.DataSync_CreateObject    Script Date: 1/21/2019 4:30:01 AM ******/
CREATE PROCEDURE dbo.[DataSync_CreateObject]
	@script nvarchar(max)
AS
	SET @script = REPLACE(@script, 'vbCrLf', CHAR(13)+CHAR(10))
	
	EXECUTE sp_executesql @script


GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
