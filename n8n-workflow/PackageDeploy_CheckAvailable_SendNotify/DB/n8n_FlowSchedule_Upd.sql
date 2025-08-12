CREATE PROCEDURE n8n_FlowSchedule_Upd
@Flow VARCHAR(50),
@Runtime DATETIME
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE n8n_FlowSchedule SET LastRuntime = @Runtime WHERE Flow = @Flow
END
