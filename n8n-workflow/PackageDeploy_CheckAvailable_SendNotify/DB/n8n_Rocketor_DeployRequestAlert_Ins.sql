CREATE PROCEDURE n8n_Rocketor_DeployRequestAlert_Ins
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE @Runtime DATETIME;
	SELECT @Runtime = MAX(drt.RunTimeAt) FROM Rocketor_DeployRequest drt WITH(NOLOCK)

	INSERT INTO Rocketor_DeployRequestAlert (DeployID, MeetingID, LeaveID,AttendID, Reason,ReminderSent)
	SELECT drt.ID AS DeployID
		 , ml.MeetingID
		 , ll.LeaveID
		 , al.AttendID
		 , CASE
			   WHEN ll.LeaveID IS NOT NULL THEN 'Off'
			   WHEN ml.MeetingID IS NOT NULL THEN 'In a meeting'
			   WHEN al.AttendID IS NOT NULL THEN 'Checkin/checkout'
		   END AS Reason
		, 0
	FROM Rocketor_DeployRequest drt WITH (NOLOCK)
		LEFT JOIN Rocketor_DeployRequestAlert drr WITH (NOLOCK) ON drr.DeployID = drt.ID
		LEFT JOIN TeamMember tm WITH (NOLOCK) ON tm.Username = drt.Assignee
		OUTER APPLY (
			SELECT TOP 1 ml.MeetingID
			FROM n8n_GoogleCalandar ml WITH (NOLOCK)
			WHERE CAST(drt.DeployIn AS DATETIME) BETWEEN ml.StartTime AND ml.EndTime
				AND ml.Attendees LIKE '%' + drt.Assignee + '%'
				AND IsDelete = 0
		) ml
		LEFT JOIN HRM_LeaveLog ll WITH (NOLOCK) ON ll.Nickname = tm.Nickname
			AND CAST(drt.DeployIn AS DATETIME) BETWEEN CAST(CAST(ll.Leavedate AS VARCHAR(20)) + ' ' + ll.FromTime AS DATETIME) AND CAST(CAST(ll.Leavedate AS VARCHAR(20)) + ' ' + ll.ToTime AS DATETIME)
			AND ll.IsDelete = 0

		-- Checkin/checkout
		LEFT JOIN HRM_AttendanceLog al WITH(NOLOCK) ON tm.Nickname = al.Nickname
			AND CAST(drt.DeployIn AS DATE) = al.WorkDate
			AND ((CheckInTime <> 'null' AND al.CheckOutTime <> 'null') OR (al.CheckInTime = 'null'))

		WHERE drr.DeployID IS NULL AND drt.RunTimeAt >= @Runtime AND ISNULL(drt.IsDelete,0) = 0
		AND (ll.LeaveID IS NOT NULL 
			OR ml.MeetingID IS NOT NULL 
			OR al.AttendID IS NOT NULL)
END  

GO