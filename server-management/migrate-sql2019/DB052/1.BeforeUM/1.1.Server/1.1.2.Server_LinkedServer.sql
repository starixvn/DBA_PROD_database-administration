/***
	- Created@20211229: Bobby
	- Host: Run on DB052N2
***/
USE [master]
GO

/****** Object:  LinkedServer [DB02]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DB02', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB02',@useself=N'True',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB02',@useself=N'True',@locallogin=N'bodbDownlineNet',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB02',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB02',@useself=N'True',@locallogin=N'sa',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DB02', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB02', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB02', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB02', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB02', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB02', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB02', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB02', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DB02', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DB02', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB02', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DB02', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB02', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DB03]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DB03', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB03',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB03',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DB03', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB03', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB03', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB03', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB03', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB03', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB03', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB03', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DB03', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DB03', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB03', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DB03', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB03', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DB042]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DB042', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB042',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB042',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DB042', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB042', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB042', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB042', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB042', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB042', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB042', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB042', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DB042', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DB042', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB042', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DB042', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB042', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DB05]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DB05', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB05',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB05',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB05',@useself=N'True',@locallogin=N'sa',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB05',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DB05', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB05', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB05', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB05', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB05', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB05', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB05', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB05', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DB05', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DB05', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB05', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DB05', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB05', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DB053]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DB053', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB053',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB053',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DB053', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB053', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB053', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB053', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB053', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB053', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB053', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB053', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DB053', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DB053', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB053', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DB053', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB053', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

/****** Object:  LinkedServer [DB054]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DB054', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB054',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB054',@useself=N'True',@locallogin=N'bodbAdminNet',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB054',@useself=N'True',@locallogin=N'bodbRMSNet',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB054',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB054',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DB054', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB054', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB054', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB054', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB054', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB054', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB054', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB054', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DB054', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DB054', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB054', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DB054', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB054', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DB06]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DB06', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB06',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB06',@useself=N'True',@locallogin=N'bodbAdminNet',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB06',@useself=N'True',@locallogin=N'bodbDownlineNet',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB06',@useself=N'True',@locallogin=N'bodbDownlineNetView',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB06',@useself=N'True',@locallogin=N'bodbLicenseeNet',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB06',@useself=N'True',@locallogin=N'Dot_Admin',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB06',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB06',@useself=N'True',@locallogin=N'vnJoe',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DB06',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DB06', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB06', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB06', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB06', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB06', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB06', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB06', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB06', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DB06', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DB06', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DB06', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DB06', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DB06', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBABS_STDBY]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBABS_STDBY', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBABS_STDBY',@useself=N'True',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBABS_STDBY', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBABS_STDBY', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBABS_STDBY', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBABS_STDBY', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBABS_STDBY', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBABS_STDBY', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBABS_STDBY', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBABS_STDBY', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBABS_STDBY', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBABS_STDBY', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBABS_STDBY', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBABS_STDBY', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBABS_STDBY', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBACC]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBACC', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBACC',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBACC',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBACC',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBACC', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBACC', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBACC', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBACC', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBACC', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBACC', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBACC', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBACC', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBACC', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBACC', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBACC', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBACC', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBACC', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBAFF]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBAFF', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBAFF',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBAFF',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBAFF12BET]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBAFF12BET', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBAFF12BET',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBAFF12BET',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBAFF12BET',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF12BET', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF12BET', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF12BET', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF12BET', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF12BET', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF12BET', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF12BET', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF12BET', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF12BET', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF12BET', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF12BET', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF12BET', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAFF12BET', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBAGE]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBAGE', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBAGE',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBAGE',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBAGE',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBAGE', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAGE', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAGE', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAGE', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAGE', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAGE', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAGE', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAGE', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAGE', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBAGE', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAGE', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAGE', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBAGE', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBARC]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBARC', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBARC',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBARC',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBARC',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBARC', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBARC', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBARC', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBARC', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBARC', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBARC', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBARC', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBARC', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBARC', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBARC', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBARC', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBARC', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBARC', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

/****** Object:  LinkedServer [DBBAS]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBBAS', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBBAS',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBBAS',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBBAS', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBBAS', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBBAS', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBBAS', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBBAS', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBBAS', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBBAS', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBBAS', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBBAS', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBBAS', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBBAS', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBBAS', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBBAS', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBCASINO]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBCASINO', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBCASINO',@useself=N'False',@locallogin=NULL,@rmtuser=N'vnteam',@rmtpassword='#########'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCASINO', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCASINO', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCASINO', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCASINO', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCASINO', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCASINO', @optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCASINO', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCASINO', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCASINO', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBCASINO', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCASINO', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCASINO', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCASINO', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBCRM]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBCRM', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBCRM',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBCRM',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBCRM',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBCRM_STDBY]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBCRM_STDBY', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBCRM_STDBY',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBCRM_STDBY',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBCRM_STDBY',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM_STDBY', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM_STDBY', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM_STDBY', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM_STDBY', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM_STDBY', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM_STDBY', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM_STDBY', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM_STDBY', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM_STDBY', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM_STDBY', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM_STDBY', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM_STDBY', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCRM_STDBY', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBCUST]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBCUST', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBCUST',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBCUST',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBCUST',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBCUST', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCUST', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCUST', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCUST', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCUST', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCUST', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCUST', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCUST', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCUST', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBCUST', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCUST', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCUST', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBCUST', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBDEPOSIT]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBDEPOSIT', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBDEPOSIT',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBDEPOSIT',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBDEPOSIT',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBDEPOSIT', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDEPOSIT', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDEPOSIT', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDEPOSIT', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDEPOSIT', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDEPOSIT', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDEPOSIT', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDEPOSIT', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDEPOSIT', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBDEPOSIT', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDEPOSIT', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDEPOSIT', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDEPOSIT', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBDW]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBDW', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBDW',@useself=N'False',@locallogin=NULL,@rmtuser=N'SQLlink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBDW',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBDW',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBDW2]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBDW2', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBDW2',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBDW2',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW2', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW2', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW2', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW2', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW2', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW2', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW2', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW2', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW2', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW2', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW2', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW2', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDW2', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBDWCSS]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBDWCSS', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBDWCSS',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBDWCSS',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBDWCSS',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBDWCSS', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDWCSS', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDWCSS', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDWCSS', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDWCSS', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDWCSS', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDWCSS', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDWCSS', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDWCSS', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBDWCSS', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDWCSS', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDWCSS', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBDWCSS', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

/****** Object:  LinkedServer [DBEAS]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBEAS', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBEAS',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBEAS',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBEAS',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBEAS', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEAS', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEAS', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEAS', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEAS', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEAS', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEAS', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEAS', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEAS', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBEAS', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEAS', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEAS', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEAS', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBEXT]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBEXT', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBEXT',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBEXT',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBEXT',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBEXT', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEXT', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEXT', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEXT', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEXT', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEXT', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEXT', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEXT', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEXT', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBEXT', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEXT', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEXT', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBEXT', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBLASARC]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBLASARC', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBLASARC',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBLASARC',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBLASARC',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBLASARC', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLASARC', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLASARC', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLASARC', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLASARC', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLASARC', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLASARC', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLASARC', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLASARC', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBLASARC', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLASARC', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLASARC', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLASARC', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBLCC]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBLCC', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBLCC',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBLCC',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBLCC',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBLCC', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLCC', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLCC', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLCC', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLCC', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLCC', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLCC', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLCC', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLCC', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBLCC', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLCC', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLCC', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLCC', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBLIC]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBLIC', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBLIC',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBLIC',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBLIC',@useself=N'True',@locallogin=N'sa',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBLIC',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBLIC', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLIC', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLIC', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLIC', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLIC', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLIC', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLIC', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLIC', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLIC', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBLIC', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLIC', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLIC', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLIC', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBLOG]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBLOG', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBLOG',@useself=N'True',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBLOG',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBLOG_STDBY]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBLOG_STDBY', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBLOG_STDBY',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBLOG_STDBY',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBLOG_STDBY',@useself=N'True',@locallogin=N'sa',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBLOG_STDBY',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG_STDBY', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG_STDBY', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG_STDBY', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG_STDBY', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG_STDBY', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG_STDBY', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG_STDBY', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG_STDBY', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG_STDBY', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG_STDBY', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG_STDBY', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG_STDBY', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBLOG_STDBY', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBMA]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBMA', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBMA',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBMA',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBMA',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBMA', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBMA', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBMA', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBMA', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBMA', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBMA', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBMA', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBMA', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBMA', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBMA', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBMA', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBMA', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBMA', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBN88POL]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBN88POL', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBN88POL',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBN88POL',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBN88POL', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBN88POL', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBN88POL', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBN88POL', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBN88POL', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBN88POL', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBN88POL', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBN88POL', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBN88POL', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBN88POL', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBN88POL', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBN88POL', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBN88POL', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBNAP]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBNAP', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBNAP',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBNAP',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBNAP',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAP', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAP', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAP', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAP', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAP', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAP', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAP', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAP', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAP', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAP', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAP', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAP', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAP', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBNAPLOG]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBNAPLOG', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBNAPLOG',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBNAPLOG',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBNAPLOG',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAPLOG', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAPLOG', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAPLOG', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAPLOG', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAPLOG', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAPLOG', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAPLOG', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAPLOG', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAPLOG', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAPLOG', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAPLOG', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAPLOG', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBNAPLOG', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBNOTI]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBNOTI', @srvproduct=N'SQL_Server', @provider=N'SQLNCLI', @datasrc=N'DBSPARE'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBNOTI',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
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

/****** Object:  LinkedServer [DBODDSFEED]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBODDSFEED', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBODDSFEED',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBODDSFEED',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBODDSFEED',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBODDSFEED', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBODDSFEED', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBODDSFEED', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBODDSFEED', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBODDSFEED', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBODDSFEED', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBODDSFEED', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBODDSFEED', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBODDSFEED', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBODDSFEED', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBODDSFEED', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBODDSFEED', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBODDSFEED', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBOIC]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBOIC', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBOIC',@useself=N'False',@locallogin=NULL,@rmtuser=N'sqllink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBOIC',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBOIC', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOIC', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOIC', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOIC', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOIC', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOIC', @optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOIC', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOIC', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOIC', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBOIC', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOIC', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOIC', @optname=N'use remote collation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOIC', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

/****** Object:  LinkedServer [DBONUSER]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBONUSER', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBONUSER',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBONUSER',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBONUSER', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBONUSER', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBONUSER', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBONUSER', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBONUSER', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBONUSER', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBONUSER', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBONUSER', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBONUSER', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBONUSER', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBONUSER', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBONUSER', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBONUSER', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

/****** Object:  LinkedServer [DBOWP]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBOWP', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBOWP',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBOWP',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBOWP', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOWP', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOWP', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOWP', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOWP', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOWP', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOWP', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOWP', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOWP', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBOWP', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOWP', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOWP', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBOWP', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBPOL]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBPOL', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBPOL',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBPOL',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOL', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOL', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOL', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOL', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOL', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOL', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOL', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOL', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOL', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOL', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOL', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOL', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOL', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBPOLICY]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBPOLICY', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBPOLICY',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBPOLICY',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBPOLICY',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOLICY', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOLICY', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOLICY', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOLICY', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOLICY', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOLICY', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOLICY', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOLICY', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOLICY', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOLICY', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOLICY', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOLICY', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPOLICY', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBPRO]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBPRO', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBPRO',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBPRO',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBPRO', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPRO', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPRO', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPRO', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPRO', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPRO', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPRO', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPRO', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPRO', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBPRO', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPRO', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPRO', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPRO', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

/****** Object:  LinkedServer [DBPROMO]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBPROMO', @srvproduct=N'MySQL', @provider=N'MSDASQL', @datasrc=N'DBPROMO'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBPROMO',@useself=N'False',@locallogin=NULL,@rmtuser=N'sqllink',@rmtpassword='#########'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPROMO', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPROMO', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPROMO', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPROMO', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPROMO', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPROMO', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPROMO', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPROMO', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPROMO', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBPROMO', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPROMO', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPROMO', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPROMO', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

/****** Object:  LinkedServer [DBPTCS]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBPTCS', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBPTCS',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBPTCS',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBPTCS',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBPTCS_STDBY]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBPTCS_STDBY', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBPTCS_STDBY',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBPTCS_STDBY',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBPTCS_STDBY',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS_STDBY', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS_STDBY', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS_STDBY', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS_STDBY', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS_STDBY', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS_STDBY', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS_STDBY', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS_STDBY', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS_STDBY', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS_STDBY', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS_STDBY', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS_STDBY', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCS_STDBY', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBPTCSARC]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBPTCSARC', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBPTCSARC',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBPTCSARC',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBPTCSARC',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCSARC', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCSARC', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCSARC', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCSARC', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCSARC', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCSARC', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCSARC', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCSARC', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCSARC', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCSARC', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCSARC', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCSARC', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBPTCSARC', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBRMS]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBRMS', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBRMS',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBRMS',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBRMS',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBRMS_STDBY]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBRMS_STDBY', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBRMS_STDBY',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBRMS_STDBY',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBRMS_STDBY',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS_STDBY', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS_STDBY', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS_STDBY', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS_STDBY', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS_STDBY', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS_STDBY', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS_STDBY', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS_STDBY', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS_STDBY', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS_STDBY', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS_STDBY', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS_STDBY', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRMS_STDBY', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBRPT]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBRPT', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBRPT',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBRPT',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBRPT',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBRPT', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRPT', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRPT', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRPT', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRPT', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRPT', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRPT', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRPT', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRPT', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBRPT', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRPT', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRPT', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBRPT', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBSPARE]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBSPARE', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBSPARE',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBSPARE',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBSPARE', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSPARE', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSPARE', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSPARE', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSPARE', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSPARE', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSPARE', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSPARE', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSPARE', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBSPARE', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSPARE', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSPARE', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSPARE', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBSUM]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBSUM', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBSUM',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBSUM',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBSUM',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBSUM', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSUM', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSUM', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSUM', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSUM', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSUM', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSUM', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSUM', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSUM', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBSUM', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSUM', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSUM', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBSUM', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBTRANS]    Script Date: 12/24/2021 5:05:35 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBTRANS', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBTRANS',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBTRANS',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBTRANS',@useself=N'True',@locallogin=N'sa',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBTRANS',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBTRANS', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTRANS', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTRANS', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTRANS', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTRANS', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTRANS', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTRANS', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTRANS', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTRANS', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBTRANS', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTRANS', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTRANS', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTRANS', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO

/****** Object:  LinkedServer [DBTXN]    Script Date: 12/24/2021 5:05:36 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBTXN', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBTXN',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBTXN',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBTXN',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBTXN', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTXN', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTXN', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTXN', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTXN', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTXN', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTXN', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTXN', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTXN', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBTXN', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTXN', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTXN', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBTXN', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO

/****** Object:  LinkedServer [DBWH]    Script Date: 12/24/2021 5:05:36 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'DBWH', @srvproduct=N'SQL Server'
 /* For security reasons the linked server remote logins password is changed with ######### */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBWH',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='#########'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBWH',@useself=N'True',@locallogin=N'NT AUTHORITY\SYSTEM',@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'DBWH',@useself=N'True',@locallogin=N'vnteam',@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'DBWH', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBWH', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBWH', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBWH', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBWH', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBWH', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBWH', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBWH', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBWH', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'DBWH', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'DBWH', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'DBWH', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'DBWH', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO


