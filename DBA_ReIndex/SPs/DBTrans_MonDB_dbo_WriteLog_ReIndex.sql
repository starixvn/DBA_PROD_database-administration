ALTER PROCEDURE [dbo].[WriteLog_ReIndex]
	@time_trace		DATETIME,
	@record_rn		INT,
	@RunCounter		INT,
	@doing			VARCHAR(1000) = ''
AS
/*
	Created:	20210716@Bobby
	Task:		00000 - ReIndex operations
	DB:			DBTXN.MonDB

	Revisions:
		- 20210716@Bobby :: Implement writing log for ReIndex operations
*/

BEGIN
	SET NOCOUNT ON;

	IF @@SERVERNAME NOT IN (N'DBTRANS', N'DB206') RETURN

	INSERT INTO [dbo].[DBA_ReIndex_Log](
		[time_trace],
		[record_rn],
		[run_counter],
		[doing],
		[logdate]
	)
	VALUES (
		@time_trace,
		@record_rn,
		@RunCounter,
		@doing,
		CURRENT_TIMESTAMP
	)
END
GO