CREATE PROCEDURE n8n_HRM_LeaveLog_Ins
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @monday DATETIME = DATEADD(WEEK, DATEDIFF(WEEK, 0, GETDATE() - 1), 0)
	
	DECLARE @runCount INT
		  , @runTime DATETIME

	SELECT @runTime = MAX(nc.RunTime) FROM HRM_LeaveLog_Realtime nc WITH(NOLOCK) WHERE Leavedate > @monday

	SET IDENTITY_INSERT [dbo].[HRM_LeaveLog] ON 

	INSERT INTO HRM_LeaveLog (LeaveID,Nickname, Fullname, Team, Leavedate, FromTime, ToTime, IsDelete)
	SELECT ngcr.LeaveID
		 , ngcr.Nickname
		 , ngcr.Fullname
		 , ngcr.Team
		 , ngcr.Leavedate 
		 , ngcr.FromTime
		 , ngcr.ToTime
		 , 0 AS IsDelete
	FROM HRM_LeaveLog_Realtime ngcr WITH (NOLOCK)
		LEFT JOIN HRM_LeaveLog ngc WITH (NOLOCK) ON ngcr.LeaveID = ngc.LeaveID
	WHERE ngc.LeaveID IS NULL 

	SET IDENTITY_INSERT [dbo].[HRM_LeaveLog] OFF

	UPDATE a 
	SET IsDelete = CASE WHEN b.RunTime < @runTime THEN 1 ELSE a.IsDelete END
	FROM HRM_LeaveLog a WITH (ROWLOCK)
		LEFT JOIN HRM_LeaveLog_Realtime b WITH(NOLOCK) ON a.LeaveID = b.LeaveID
	WHERE a.Leavedate > @monday

END

GO