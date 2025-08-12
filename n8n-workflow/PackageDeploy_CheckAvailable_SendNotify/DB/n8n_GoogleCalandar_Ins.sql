CREATE PROCEDURE n8n_GoogleCalandar_Ins
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @monday DATETIME = DATEADD(week, DATEDIFF(week, 0, GETDATE() - 1), 0) 
	DECLARE @runCount INT , @runTime DATETIME
	SELECT @runCount = MAX(nc.RunCount),@runTime = MAX(nc.RunTime) FROM n8n_GoogleCalandar_Realtime nc WITH(NOLOCK) WHERE StartTime > @monday

	INSERT INTO n8n_GoogleCalandar (ID, StartTime, EndTime, Attendees, Room, Summary, IsDelete)
	SELECT ngcr.ID
		 , ngcr.StartTime
		 , ngcr.EndTime
		 , ngcr.Attendees
		 , ngcr.Room
		 , ngcr.Summary
		 , 0 AS IsDelete
	FROM n8n_GoogleCalandar_Realtime ngcr WITH (NOLOCK)
		LEFT JOIN n8n_GoogleCalandar ngc WITH (NOLOCK) ON ngcr.ID = ngc.ID
	WHERE ngc.ID IS NULL AND ngcr.StartTime > @monday

	UPDATE a 
	SET a.StartTime = b.StartTime, a.EndTime = b.EndTime, a.Attendees = b.Attendees, a.Summary = b.Summary,
		IsDelete = CASE WHEN b.RunTime < @runTime THEN 1 ELSE a.IsDelete END
	FROM n8n_GoogleCalandar a WITH (ROWLOCK)
		LEFT JOIN n8n_GoogleCalandar_Realtime b WITH(NOLOCK) ON a.ID = b.ID
	WHERE a.StartTime > @monday

END