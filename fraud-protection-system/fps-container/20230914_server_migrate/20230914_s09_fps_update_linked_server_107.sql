
/*
	Created: 20230912@Sol
	Task: update linked server
	DB: 10.40.40.107 - FPS_DB01
*/


USE [master]
GO

EXEC master.dbo.sp_dropserver @server=N'FPSCR', @droplogins='droplogins'
GO

/****** Object:  LinkedServer [FPSCR]    Script Date: 9/13/2023 2:34:38 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FPSCR', @srvproduct=N'SQL_Server', @provider=N'SQLNCLI', @datasrc=N'10.40.40.33,16401'
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

----
EXEC master.dbo.sp_dropserver @server=N'KBTFPS_DB02_FPS_01', @droplogins='droplogins'

GO

/****** Object:  LinkedServer [KBTFPS_DB02_FPS_01]    Script Date: 9/13/2023 2:34:38 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'KBTFPS_DB02_FPS_01', @srvproduct=N'SQL_Server', @provider=N'SQLNCLI', @datasrc=N'10.40.40.33,16401'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'KBTFPS_DB02_FPS_01',@useself=N'False',@locallogin=NULL,@rmtuser=N'sqllink',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'KBTFPS_DB02_FPS_01', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'KBTFPS_DB02_FPS_01', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'KBTFPS_DB02_FPS_01', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'KBTFPS_DB02_FPS_01', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'KBTFPS_DB02_FPS_01', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'KBTFPS_DB02_FPS_01', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'KBTFPS_DB02_FPS_01', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'KBTFPS_DB02_FPS_01', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'KBTFPS_DB02_FPS_01', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'KBTFPS_DB02_FPS_01', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'KBTFPS_DB02_FPS_01', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'KBTFPS_DB02_FPS_01', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'KBTFPS_DB02_FPS_01', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

