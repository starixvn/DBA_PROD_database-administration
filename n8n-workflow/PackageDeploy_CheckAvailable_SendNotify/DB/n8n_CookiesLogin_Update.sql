CREATE PROCEDURE n8n_CookiesLogin_Update
	  @LoginName VARCHAR(50)
	, @SiteName VARCHAR(50)
	, @Cookie NVARCHAR(MAX) 
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE n8n_CookiesLogin WITH(ROWLOCK) SET COOKIE = @Cookie, UpdatedAt = GETDATE() WHERE LoginName = @LoginName AND SiteName = @SiteName
	SELECT @Cookie AS Cookie
END
GO
