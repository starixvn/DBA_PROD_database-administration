/*
	Created: 20230912@Sol
	Task: update linked server
	DB: 10.40.40.33,16401
*/


USE [master]
GO

EXEC master.dbo.sp_dropserver @server=N'_FPS_DB01_MSSQLSERVERWEB_', @droplogins='droplogins'
GO

/****** Object:  LinkedServer [_FPS_DB01_MSSQLSERVERWEB_]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'_FPS_DB01_MSSQLSERVERWEB_', @srvproduct=N'SQL_Server', @provider=N'SQLNCLI', @datasrc=N'10.40.40.107\MSSQLSERVERWEB,49218'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'_FPS_DB01_MSSQLSERVERWEB_',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'_FPS_DB01_MSSQLSERVERWEB_',@useself=N'True',@locallogin=N'fpsdev',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'_FPS_DB01_MSSQLSERVERWEB_',@useself=N'True',@locallogin=N'vnfps',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'_FPS_DB01_MSSQLSERVERWEB_',@useself=N'True',@locallogin=N'vnLukas',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'_FPS_DB01_MSSQLSERVERWEB_',@useself=N'True',@locallogin=N'vnSPU',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'_FPS_DB01_MSSQLSERVERWEB_',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL

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

-------------------

EXEC master.dbo.sp_dropserver @server=N'_FPS_DB02_', @droplogins='droplogins'
GO

/****** Object:  LinkedServer [_FPS_DB02_]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'_FPS_DB02_', @srvproduct=N'SQL_Server', @provider=N'SQLNCLI', @datasrc=N'10.40.40.119'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'_FPS_DB02_',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'_FPS_DB02_',@useself=N'True',@locallogin=N'fpsdev',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'_FPS_DB02_',@useself=N'True',@locallogin=N'vnfps',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'_FPS_DB02_',@useself=N'True',@locallogin=N'vnLukas',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'_FPS_DB02_',@useself=N'True',@locallogin=N'vnSPU',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'_FPS_DB02_',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL

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


-------------------

EXEC master.dbo.sp_dropserver @server=N'_FPSARC_', @droplogins='droplogins'
GO

/****** Object:  LinkedServer [_FPSARC_]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'_FPSARC_', @srvproduct=N'SQL_Server', @provider=N'SQLNCLI', @datasrc=N'10.40.40.107'
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

-------------------

EXEC master.dbo.sp_dropserver @server=N'FPSARCHIVE', @droplogins='droplogins'
GO

/****** Object:  LinkedServer [FPSARCHIVE]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FPSARCHIVE', @srvproduct=N'SQL_Server', @provider=N'SQLNCLI', @datasrc=N'10.40.40.107'
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

-------------------

EXEC master.dbo.sp_dropserver @server=N'FPSDI', @droplogins='droplogins'
GO

/****** Object:  LinkedServer [FPSDI]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FPSDI', @srvproduct=N'SQL_Server', @provider=N'SQLNCLI', @datasrc=N'10.40.40.119'
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

-------------------

EXEC master.dbo.sp_dropserver @server=N'FPSLIC107WEB', @droplogins='droplogins'
GO

/****** Object:  LinkedServer [FPSLIC107WEB]    Script Date: 8/25/2023 2:44:28 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FPSLIC107WEB', @srvproduct=N'SQL_Server', @provider=N'SQLNCLI', @datasrc=N'10.40.40.107\MSSQLSERVERWEB,49218'
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