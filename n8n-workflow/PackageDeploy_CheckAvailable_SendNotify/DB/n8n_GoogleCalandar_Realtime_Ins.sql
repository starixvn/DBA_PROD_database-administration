CREATE PROCEDURE n8n_GoogleCalandar_Realtime_Ins
	  @ID VARCHAR(100)
	, @StartTime DATETIME
	, @EndTime DATETIME
	, @Attendees VARCHAR(500)
	, @Room VARCHAR(255)
	, @Summary VARCHAR(255)
	, @Runtime DATETIME
AS 
BEGIN
	SET NOCOUNT ON;
	
	IF EXISTS (SELECT TOP 1 1 FROM n8n_GoogleCalandar_Realtime WITH(NOLOCK) WHERE ID = @ID AND Room = @Room)
	BEGIN
    	UPDATE a 
		SET a.StartTime = @StartTime,
			a.EndTime = @EndTime,
			a.Summary = @Summary,
			a.RunCount = a.RunCount + 1,
			a.RunTime = @Runtime
		FROM n8n_GoogleCalandar_Realtime a WITH(ROWLOCK)
		WHERE ID = @ID AND Room = @Room
    END
	ELSE
	BEGIN
    	INSERT INTO n8n_GoogleCalandar_Realtime (ID, StartTime, EndTime, Attendees, Room, Summary, RunCount,RunTime)
		VALUES (@ID, @StartTime, @EndTime, @Attendees, @Room, @Summary, 1, @Runtime);	
    END
	
END
GO