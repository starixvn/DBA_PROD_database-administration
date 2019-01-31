/*
	Task: Map user & permission for related accounts
	Run on DB054.[bodb_Licensee]
*/

USE [bodb_Licensee]
GO
CREATE USER [SqlLink] FOR LOGIN [SqlLink]
GO
USE [bodb_Licensee]
GO
EXEC sp_addrolemember N'db_denydatawriter', N'SqlLink'
GO
USE [bodb_Licensee]
GO
EXEC sp_addrolemember N'db_owner', N'SqlLink'
GO
------


CREATE USER [bodbAdminNet] FOR LOGIN [bodbAdminNet] WITH DEFAULT_SCHEMA=[dbo]
GO

CREATE USER [bodbDownlineNet] FOR LOGIN [bodbDownlineNet] WITH DEFAULT_SCHEMA=[dbo]
GO

CREATE USER [bodbExtAccNet] FOR LOGIN [bodbExtAccNet] WITH DEFAULT_SCHEMA=[dbo]
GO

CREATE USER [bodbLicenseeNet] FOR LOGIN [bodbLicenseeNet] WITH DEFAULT_SCHEMA=[dbo]
GO


EXEC sp_addrolemember N'db_datareader', N'bodbLicenseeNet'
GO



