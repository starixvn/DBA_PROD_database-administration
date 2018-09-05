SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE [dbo].[Task_archive_rptStatement_Delete]
	@winlostdate DATE
AS
/*
Created: Cody
Date: 20150107
Task : delete data on rptStatement after archive into rptStatement_Old
DB: DBACC.bodb02

Revisions:

*/	

BEGIN
		SET NOCOUNT ON;
		
		IF EXISTS(SELECT TOP 1 1 FROM bodb_Report.dbo.rptStatement_Old WITH (NOLOCK) WHERE winlostdate = @winlostdate)
		BEGIN
			DELETE dbo.rptStatement 
			WHERE winlostdate = @winlostdate
		END
END
GO
/*<info serverAlias="DBRPT-bodb_Report" executers="" viewers="" isFunction="0" isNested="1"></info>*/