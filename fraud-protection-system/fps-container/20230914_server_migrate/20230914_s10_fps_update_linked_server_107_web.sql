/*
	Created: 20230912@Sol
	Task: update linked server
	DB: 10.40.40.107 - FPS_DB01\MSSQLSERVERWEB
*/

USE [master]

GO
---------
EXEC master.dbo.sp_dropserver @server=N'FPSARC', @droplogins='droplogins'

GO

/****** Object:  LinkedServer [FPSARC]    Script Date: 9/13/2023 3:20:59 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FPSARC', @srvproduct=N'SQLSERVER', @provider=N'SQLNCLI', @datasrc=N'10.40.40.33,16401'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'FPSARC',@useself=N'False',@locallogin=NULL,@rmtuser=N'sqllink',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARC', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARC', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARC', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARC', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARC', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARC', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARC', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARC', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARC', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARC', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARC', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARC', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARC', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

---------
EXEC master.dbo.sp_dropserver @server=N'FPSTICKET', @droplogins='droplogins'
GO

/****** Object:  LinkedServer [FPSTICKET]    Script Date: 9/13/2023 3:20:59 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FPSTICKET', @srvproduct=N'SQLSERVER', @provider=N'SQLNCLI', @datasrc=N'10.40.40.33,16401'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'FPSTICKET',@useself=N'False',@locallogin=NULL,@rmtuser=N'sqllink',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSTICKET', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSTICKET', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSTICKET', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSTICKET', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSTICKET', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSTICKET', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSTICKET', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSTICKET', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSTICKET', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'FPSTICKET', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSTICKET', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSTICKET', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSTICKET', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

