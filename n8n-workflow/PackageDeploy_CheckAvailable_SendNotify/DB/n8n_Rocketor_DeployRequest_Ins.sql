CREATE PROCEDURE n8n_Rocketor_DeployRequest_Ins
	  @Message NVARCHAR(MAX)
	, @Type NVARCHAR(50)
	, @RequestTime DATETIME
	, @Requester NVARCHAR(100)
	, @Repo NVARCHAR(255)
	, @PackageName NVARCHAR(500)
	, @Environment NVARCHAR(100)
	, @Assignee NVARCHAR(100)
	, @DeployInUM NVARCHAR(10)
	, @DeployIn VARCHAR(50)
	, @StartTime DATETIME
AS
BEGIN
	SET NOCOUNT ON;


	IF EXISTS (SELECT TOP 1 1 FROM Rocketor_DeployRequest d WITH(NOLOCK) WHERE d.Requester = @Requester AND d.RequestTime = @RequestTime)
		BEGIN
        	UPDATE Rocketor_DeployRequest SET RunTimeAt = @StartTime WHERE Requester = @Requester AND RequestTime = @RequestTime AND PackageName = @PackageName
        END
	ELSE
		INSERT INTO Rocketor_DeployRequest (Message, Type, RequestTime, Requester, Repo, PackageName, Environment, Assignee, DeployInUM, DeployIn,RunTimeAt,IsDelete)
		VALUES (@Message , @Type , @RequestTime , @Requester , @Repo , @PackageName , @Environment , @Assignee , @DeployInUM , @DeployIn, @StartTime,0)
END

GO