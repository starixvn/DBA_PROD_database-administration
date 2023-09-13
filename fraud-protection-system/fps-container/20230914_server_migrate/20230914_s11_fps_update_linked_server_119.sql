
/*
	Created: 20230912@Sol
	Task: update linked server
	DB: 10.40.40.119 - FPS_DB02
*/

USE [master]

GO

---------
EXEC master.dbo.sp_dropserver @server=N'_FPS_DB02_FPS_01_', @droplogins='droplogins'

GO

/****** Object:  LinkedServer [_FPS_DB02_FPS_01_]    Script Date: 9/13/2023 3:34:57 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'_FPS_DB02_FPS_01_', @srvproduct=N'', @provider=N'SQLNCLI', @datasrc=N'10.40.40.33,16401'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'_FPS_DB02_FPS_01_',@useself=N'False',@locallogin=NULL,@rmtuser=N'sqlLink',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_FPS_01_', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_FPS_01_', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_FPS_01_', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_FPS_01_', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_FPS_01_', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_FPS_01_', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_FPS_01_', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_FPS_01_', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_FPS_01_', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_FPS_01_', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_FPS_01_', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_FPS_01_', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_FPS_01_', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

---------
EXEC master.dbo.sp_dropserver @server=N'FPSARC', @droplogins='droplogins'

GO

/****** Object:  LinkedServer [FPSARC]    Script Date: 9/13/2023 3:34:57 AM ******/
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


/****** Object:  LinkedServer [FPSCR]    Script Date: 9/13/2023 3:34:57 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FPSCR', @srvproduct=N'SQLSERVER', @provider=N'SQLNCLI', @datasrc=N'10.40.40.33,16401'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'FPSCR',@useself=N'False',@locallogin=NULL,@rmtuser=N'sqllink',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSCR', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSCR', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSCR', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSCR', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSCR', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSCR', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSCR', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSCR', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSCR', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'FPSCR', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSCR', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSCR', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSCR', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO
