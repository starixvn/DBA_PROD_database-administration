/*
	Created: 20230801@Sol
	Task: change sa password
	DB: 10.40.40.33,16401
*/

USE [master]
GO
ALTER LOGIN [sa] WITH PASSWORD=N'xxx' OLD_PASSWORD=N'xxx'
GO
