CREATE PROCEDURE n8n_HRM_LeaveLog_Realtime_Ins
	  @Leavedate DATE
	, @Nickname VARCHAR(100)
	, @Fullname NVARCHAR(100)
	, @Team VARCHAR(50)
	, @FromTime VARCHAR(20)
	, @ToTime VARCHAR(20)
	, @Runtime DATETIME
AS
BEGIN
	SET NOCOUNT ON;
	
	IF EXISTS (
			SELECT TOP 1 1
			FROM HRM_LeaveLog_Realtime m WITH (NOLOCK)
			WHERE m.Leavedate = @Leavedate 
					  AND m.Nickname = @Nickname
					  AND m.Team = @Team
					  AND m.FromTime = @FromTime
					  AND m.ToTime = @ToTime
		)
	BEGIN
    	UPDATE a 
		SET a.RunTime = @Runtime
		FROM HRM_LeaveLog_Realtime a WITH(ROWLOCK)
		WHERE a.Leavedate = @Leavedate 
			AND a.Nickname = @Nickname
			AND a.Team = @Team
			AND a.FromTime = @FromTime
			AND a.ToTime = @ToTime
    END
	ELSE
	BEGIN
    	INSERT INTO HRM_LeaveLog_Realtime (Nickname, Fullname, Team, Leavedate, FromTime, ToTime, CreatedDate, RunTime)
		VALUES (@Nickname, @Fullname, @Team, @Leavedate, @FromTime, @ToTime, GETDATE(), @Runtime);	
    END
	
END
GO