
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.DataSync_getFieldInfo    Script Date: 1/21/2019 4:30:01 AM ******/
CREATE PROCEDURE dbo.[DataSync_getFieldInfo]
	@tbNames varchar(max)
AS
	SELECT o.name as tbName, c.[name] as fieldName, t.[name] as dataType, c.max_length, c.is_identity
		FROM sys.objects o with (nolock)
		INNER JOIN sys.columns c with (nolock) ON o.object_id = c.object_id
		INNER JOIN sys.types t with (nolock) ON c.system_type_id = t.system_type_id AND c.user_type_id = t.user_type_id
	WHERE
		o.type = 'U'
		AND o.name IN (SELECT Item FROM DataSync.SplitStrings_Moden(',',@tbNames))


GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
