/*
	Created: 20230801@Sol
	Task: create linked server
	DB: 10.40.40.33,16401
*/


USE [master]
GO

/****** Object:  LinkedServer [_DBFRAUD_]    Script Date: 8/25/2023 2:44:28 AM ******/
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


/****** Object:  LinkedServer [_FPS_DB01_MSSQLSERVERWEB_]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'_FPS_DB01_MSSQLSERVERWEB_', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.33,16403'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'_FPS_DB01_MSSQLSERVERWEB_',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='########'

GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB01_MSSQLSERVERWEB_', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB01_MSSQLSERVERWEB_', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB01_MSSQLSERVERWEB_', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB01_MSSQLSERVERWEB_', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB01_MSSQLSERVERWEB_', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB01_MSSQLSERVERWEB_', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB01_MSSQLSERVERWEB_', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB01_MSSQLSERVERWEB_', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB01_MSSQLSERVERWEB_', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB01_MSSQLSERVERWEB_', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB01_MSSQLSERVERWEB_', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB01_MSSQLSERVERWEB_', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB01_MSSQLSERVERWEB_', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

/****** Object:  LinkedServer [_FPS_DB02_]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'_FPS_DB02_', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.33,16402'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'_FPS_DB02_',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='########'

GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

/****** Object:  LinkedServer [_FPS_DB02_FPS_01_]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'_FPS_DB02_FPS_01_', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.33,16401'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'_FPS_DB02_FPS_01_',@useself=N'False',@locallogin=NULL,@rmtuser=N'sqllink',@rmtpassword='########'

GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_FPS_01_', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_FPS_01_', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_FPS_01_', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_FPS_01_', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_FPS_01_', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPS_DB02_FPS_01_', @optname=N'rpc out', @optvalue=N'false'
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

/****** Object:  LinkedServer [_FPSARC_]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'_FPSARC_', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.33,16404'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'_FPSARC_',@useself=N'True',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'_FPSARC_', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPSARC_', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPSARC_', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPSARC_', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPSARC_', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPSARC_', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPSARC_', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPSARC_', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPSARC_', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'_FPSARC_', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPSARC_', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPSARC_', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'_FPSARC_', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBFRAUD]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBFRAUD', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.33,16401'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBFRAUD',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'DBFRAUD', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBFRAUD', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBFRAUD', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBFRAUD', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBFRAUD', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBFRAUD', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBFRAUD', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBFRAUD', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBFRAUD', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBFRAUD', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBFRAUD', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBFRAUD', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBFRAUD', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

/****** Object:  LinkedServer [DBNOTI]    Script Date: 8/25/2023 2:44:28 AM ******/
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

/****** Object:  LinkedServer [FPSADMIN]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FPSADMIN', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'FPSADMIN',@useself=N'False',@locallogin=NULL,@rmtuser=N'linkdbserver',@rmtpassword='########'
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

/****** Object:  LinkedServer [FPSARC]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FPSARC', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.33,16401'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'FPSARC',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='########'

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

/****** Object:  LinkedServer [FPSARCHIVE]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FPSARCHIVE', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.33,16402'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'FPSARCHIVE',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='########'

GO

EXEC master.dbo.sp_serveroption @server=N'FPSARCHIVE', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARCHIVE', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARCHIVE', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARCHIVE', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARCHIVE', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARCHIVE', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARCHIVE', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARCHIVE', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARCHIVE', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARCHIVE', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARCHIVE', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARCHIVE', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSARCHIVE', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

/****** Object:  LinkedServer [FPSBR]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FPSBR', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.33,16401'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'FPSBR',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSBR', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSBR', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSBR', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSBR', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSBR', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSBR', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSBR', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSBR', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSBR', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'FPSBR', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSBR', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSBR', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSBR', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

/****** Object:  LinkedServer [FPSCR]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FPSCR', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.33,16401'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'FPSCR',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='########'
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

/****** Object:  LinkedServer [FPSDEV]    Script Date: 8/25/2023 2:44:28 AM ******/
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

/****** Object:  LinkedServer [FPSDI]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FPSDI', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.33,16402'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'FPSDI',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDI', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDI', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDI', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDI', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDI', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDI', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDI', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDI', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDI', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDI', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDI', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDI', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSDI', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

/****** Object:  LinkedServer [FPSLIC107WEB]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FPSLIC107WEB', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.33,16403'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'FPSLIC107WEB',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLIC107WEB', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLIC107WEB', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLIC107WEB', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLIC107WEB', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLIC107WEB', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLIC107WEB', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLIC107WEB', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLIC107WEB', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLIC107WEB', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLIC107WEB', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLIC107WEB', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLIC107WEB', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLIC107WEB', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO


/****** Object:  LinkedServer [FPSLOG]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FPSLOG', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.33,16401'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'FPSLOG',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLOG', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLOG', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLOG', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLOG', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLOG', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLOG', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLOG', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLOG', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLOG', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLOG', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLOG', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLOG', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'FPSLOG', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

/****** Object:  LinkedServer [FPSRPT]    Script Date: 8/25/2023 2:44:28 AM ******/
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

/****** Object:  LinkedServer [FPSTICKET]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FPSTICKET', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.33,16401'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'FPSTICKET',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='########'
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

/****** Object:  LinkedServer [OWSRV]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'OWSRV', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.100'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'OWSRV',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='########'

GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

/****** Object:  LinkedServer [OWSRV_ARC]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'OWSRV_ARC', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.90'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'OWSRV_ARC',@useself=N'False',@locallogin=NULL,@rmtuser=N'sqlLink',@rmtpassword='########'

GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV_ARC', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV_ARC', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV_ARC', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV_ARC', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV_ARC', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV_ARC', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV_ARC', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV_ARC', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV_ARC', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV_ARC', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV_ARC', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV_ARC', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'OWSRV_ARC', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO