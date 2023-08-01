/*
	Created: 20230801@Sol
	Task: create linked server
	DB: 10.40.40.33,16401
*/

USE [master]
GO

/****** Object:  LinkedServer [FPSADMIN]    Script Date: 8/1/2023 3:27:02 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FPSADMIN', @srvproduct=N'SQL_Server', @provider=N'MSOLEDBSQL', @datasrc=N'10.40.40.33,16401'

 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'FPSADMIN',@useself=N'False',@locallogin=NULL,@rmtuser=N'SqlLink',@rmtpassword='xxx'
GO