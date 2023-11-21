/*
	Created: 20231026@Sol
	Task: sync all linked server from fps_db02 to 10.40.40.34,16402
	DB: 10.40.40.34,16402-msdb
*/

GO

USE [master]

GO

/****** Object:  LinkedServer [_DBFRAUD_]    Script Date: 10/31/2023 11:20:57 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'_DBFRAUD_', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.33,16401'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'_DBFRAUD_',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'_DBFRAUD_', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_DBFRAUD_', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'_DBFRAUD_', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_DBFRAUD_', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_DBFRAUD_', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'_DBFRAUD_', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'_DBFRAUD_', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_DBFRAUD_', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'_DBFRAUD_', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'_DBFRAUD_', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_DBFRAUD_', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'_DBFRAUD_', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'_DBFRAUD_', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO


/****** Object:  LinkedServer [_FPS_DB02_FPS_01_]    Script Date: 10/31/2023 11:20:57 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'_FPS_DB02_FPS_01_', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.33,16401'
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

/****** Object:  LinkedServer [DBNOTI]    Script Date: 10/31/2023 11:20:57 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBNOTI', @srvproduct=N'SQL_Server', @provider=N'SQLNCLI', @datasrc=N'DBSPARE'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBNOTI',@useself=N'False',@locallogin=NULL,@rmtuser=N'sqlLink',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNOTI', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNOTI', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNOTI', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNOTI', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNOTI', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNOTI', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNOTI', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNOTI', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNOTI', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBNOTI', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNOTI', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNOTI', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNOTI', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

/****** Object:  LinkedServer [FPS_LINUX33]    Script Date: 10/31/2023 11:20:57 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FPS_LINUX33', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.33,16401'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'FPS_LINUX33',@useself=N'False',@locallogin=NULL,@rmtuser=N'sqllink',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'FPS_LINUX33', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPS_LINUX33', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPS_LINUX33', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPS_LINUX33', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPS_LINUX33', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPS_LINUX33', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPS_LINUX33', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPS_LINUX33', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPS_LINUX33', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'FPS_LINUX33', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPS_LINUX33', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPS_LINUX33', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPS_LINUX33', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [FPSADMIN]    Script Date: 10/31/2023 11:20:57 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FPSADMIN', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.33,16401'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'FPSADMIN',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSADMIN', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSADMIN', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSADMIN', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSADMIN', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSADMIN', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSADMIN', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSADMIN', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSADMIN', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSADMIN', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'FPSADMIN', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSADMIN', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSADMIN', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSADMIN', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

/****** Object:  LinkedServer [FPSARC]    Script Date: 10/31/2023 11:20:57 PM ******/
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


/****** Object:  LinkedServer [FPSCR]    Script Date: 10/31/2023 11:20:57 PM ******/
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

/****** Object:  LinkedServer [FPSDEV]    Script Date: 10/31/2023 11:20:57 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FPSDEV', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.33,16401'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'FPSDEV',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDEV', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDEV', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDEV', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDEV', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDEV', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDEV', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDEV', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDEV', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDEV', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDEV', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDEV', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDEV', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDEV', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO


/****** Object:  LinkedServer [FPSRPT]    Script Date: 10/31/2023 11:20:57 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FPSRPT', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.33,16401'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'FPSRPT',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSRPT', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSRPT', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSRPT', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSRPT', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSRPT', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSRPT', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSRPT', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSRPT', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSRPT', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'FPSRPT', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSRPT', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSRPT', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSRPT', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

