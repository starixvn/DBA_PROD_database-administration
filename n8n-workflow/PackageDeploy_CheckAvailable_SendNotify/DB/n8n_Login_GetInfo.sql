ALTER PROCEDURE n8n_Login_GetInfo
	  @LoginName VARCHAR(50)
	, @SiteName VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT Id
		 , SiteName
 		 , CASE WHEN DATEDIFF(HOUR,UpdatedAt,GETDATE()) > 4 THEN '' ELSE Cookie END AS Cookie
		 , LoginName
		 , 'xxxxxxxx' AS PassLogin
		 , CreatedAt
		 , UpdatedAt
	FROM n8n_CookiesLogin
	WHERE LoginName = @LoginName
		AND SiteName = @SiteName
END
GO