/*<info serverAlias="dbsitec1/2/3-bodb_CustomerLog"></info>*/
/*
	Task - move siteDB AG to FC
		+ create service
	Run on dbsitec1/2/3
*/

USE [master]
GO
SELECT   [name]
 ,[is_broker_enabled] 
 ,[service_broker_guid]
FROM [sys].[databases] 
GO

--check clr enable or not
SELECT * FROM sys.configurations
WHERE name in ('clr enabled', 'clr strict security')

--if did not enable then run this script
/*
	--Disable clr strict security
	EXEC sp_configure 'show advanced options', 1;
	GO
	RECONFIGURE;
	GO
	EXEC sp_configure 'clr strict security', 0;  
	RECONFIGURE;

	go

	--Enable clr enabled
	EXEC sp_configure 'show advanced options', 1;
	GO
	RECONFIGURE;
	GO
	EXEC sp_configure 'clr enabled', 1;  
	RECONFIGURE;
*/