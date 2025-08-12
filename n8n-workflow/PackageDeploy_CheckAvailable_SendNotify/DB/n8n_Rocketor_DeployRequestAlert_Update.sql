CREATE PROCEDURE n8n_Rocketor_DeployRequestAlert_Update @DeployID INT
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Rocketor_DeployRequestAlert WITH(ROWLOCK) 
	SET ReminderSent = 1, ReminderSentAt=getdate() 
	WHERE DeployID = @DeployID
END  
GO