CREATE PROCEDURE n8n_Rocketor_DeployRequestAlert_Sel
AS
BEGIN
	SET NOCOUNT ON;

  	SELECT drr.DeployID
		 , drr.Reason
		 , drt.Message
		 , drt.Requester
		 , drt.RequestTime
		 , drt.DeployIn
		 , drt.Assignee
		 , drt.Environment
		 , ml.Room
		 , ml.StartTime
		 , ml.EndTime
		 , ll.Leavedate
		 , ll.FromTime
		 , ll.ToTime
		 , al.CheckInTime
		 , al.CheckOutTime
		 , drr.ReminderSent
		 , drr.ReminderSentAt
		 , drr.CreatedAt
	FROM Rocketor_DeployRequestAlert drr WITH (NOLOCK)
		INNER JOIN Rocketor_DeployRequest drt WITH (NOLOCK) ON drt.Id = drr.DeployID
		LEFT JOIN n8n_GoogleCalandar ml WITH (NOLOCK) ON drr.MeetingID = ml.MeetingID
		LEFT JOIN HRM_LeaveLog ll WITH (NOLOCK) ON drr.LeaveID = ll.LeaveID
		LEFT JOIN HRM_AttendanceLog al WITH(NOLOCK) ON al.AttendID = drr.AttendID
	WHERE	ReminderSent = 0 
END  
GO