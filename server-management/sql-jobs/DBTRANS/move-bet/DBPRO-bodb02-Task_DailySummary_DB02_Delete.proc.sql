SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE [dbo].[Task_DailySummary_DB02_Delete]
	@winlostdate datetime
AS

	-- Run on DB02 (ProductDB)
	-- call by TransDB : Task_DailySummary
	-- 20110802@Sylvia: Delete Dot_Admin_Assignment_Operator
	-- 20121031@Sylvia: Delete SS_GameState
	-- 20130520@Victor: Add Delete VSOutright by eventdate
	-- 20130531@Sophia: Put Delete code into ExecRep_APL_01
	
BEGIN

	EXEC ExecRep_APL_01 @WinlostDate = @Winlostdate

END
GO
GRANT VIEW DEFINITION ON dbo.Task_DailySummary_DB02_Delete TO vnteam AS dbo;
GO
/*<info serverAlias="DBPRO-bodb02" executers="" viewers="vnteam" isFunction="0" isNested="1"></info>*/