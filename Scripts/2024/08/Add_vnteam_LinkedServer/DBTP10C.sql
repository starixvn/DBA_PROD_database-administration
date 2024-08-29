/*<info serverAlias="DBTP10C-master></info>*/
/*  
	Created by: 20240829@Sol
	Task: add vnteam to linked server
	DB: DBTP10C-master
*/

EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'chatbot_190', @locallogin = N'vnsas', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'chatbot_190', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'chatbot_33', @locallogin = N'vnsas', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'chatbot_33', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'CTS_160', @locallogin = N'vnsas', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'CTS_160', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'CTS_190', @locallogin = N'vnsas', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'CTS_190', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'CTS_34', @locallogin = N'vnsas', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'CTS_34', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'CTS_KL', @locallogin = N'vnsas', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'CTS_KL', @locallogin = N'vnteam', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = N'vnsas', @useself = N'True'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = N'vnteam', @useself = N'True'

GO

--- REVERT ---
/*

EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'chatbot_190', @locallogin = N'vnsas'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'chatbot_190', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'chatbot_33', @locallogin = N'vnsas'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'chatbot_33', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'CTS_160', @locallogin = N'vnsas'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'CTS_160', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'CTS_190', @locallogin = N'vnsas'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'CTS_190', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'CTS_34', @locallogin = N'vnsas'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'CTS_34', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'CTS_KL', @locallogin = N'vnsas'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'CTS_KL', @locallogin = N'vnteam'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = N'vnsas'
EXEC master.dbo.sp_droplinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = N'vnteam'

*/