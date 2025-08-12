GO
CREATE TRIGGER trg_PreventDuplicateAttendanceLog
ON [HRM_AttendanceLog]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

	IF EXISTS (
			SELECT TOP 1 1
			FROM HRM_AttendanceLog m WITH (NOLOCK)
				INNER JOIN INSERTED i ON m.WorkDate = i.WorkDate
					AND m.Nickname = i.Nickname
		)
	BEGIN
    	UPDATE m 
		SET m.RunTime = i.RunTime, m.CheckInTime = i.CheckInTime,  m.CheckOutTime = i.CheckOutTime 
		FROM HRM_AttendanceLog m WITH(ROWLOCK) INNER JOIN INSERTED i ON m.WorkDate = i.WorkDate
					AND m.Nickname = i.Nickname
		
    END
	ELSE
	BEGIN
    	INSERT INTO HRM_AttendanceLog (Nickname, WorkDate, CheckInTime, CheckOutTime, RunTime)
		SELECT i.Nickname, i.WorkDate, i.CheckInTime, i.CheckOutTime, i.RunTime
		FROM inserted i
    END
END;