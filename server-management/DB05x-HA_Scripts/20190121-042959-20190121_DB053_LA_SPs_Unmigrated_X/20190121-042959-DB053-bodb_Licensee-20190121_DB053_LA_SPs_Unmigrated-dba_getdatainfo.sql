
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.dba_getdatainfo    Script Date: 1/21/2019 4:30:01 AM ******/
create procedure dba_getdatainfo
with execute as owner
as
begin
  --exec sys.xp_readerrorlog
  SELECT 
		 [Current LSN],
		 [Operation],
		 [Context],
		 [Transaction ID],
		 [Log Record Length],
		 [Description]
	FROM fn_dblog (null, null);

end

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
