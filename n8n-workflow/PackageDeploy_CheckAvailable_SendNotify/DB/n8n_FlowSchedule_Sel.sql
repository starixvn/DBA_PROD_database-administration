CREATE PROCEDURE n8n_FlowSchedule_Sel 
@Flow VARCHAR(50)
AS
BEGIN
	
	DECLARE @today DATETIME= GETDATE()
	SET @today = DATEADD(HOUR,11,@today)
	 
	SELECT Flow
		 , Interval
		 , CASE WHEN DATEDIFF(MINUTE,LastRuntime,@today) > Interval THEN 1 ELSE 0 END TriggerRun
		 , LastRuntime
	FROM n8n_FlowSchedule (NOLOCK) WHERE Flow = @Flow OR @Flow= ''
END