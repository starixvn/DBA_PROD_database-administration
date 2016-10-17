/*
	Creator:	20160803@Billy
	Task:		Create tables for monitoring feature - [Redmine: #58941]
	Server:		*ALL_SERVER*
*/


--	BEGIN STEP 1:	*ALL_SERVER*.MonDB
--		Create table for saving objects information
----------------------------------------------------------------------------------------------------

USE	MonDB;
GO

IF	EXISTS (SELECT 1 FROM sys.objects AS o WHERE o.name = N'vnDBA_Monitor_Staging' AND o.type = 'U')
	DROP TABLE	dbo.vnDBA_Monitor_Staging;
GO

CREATE TABLE	dbo.vnDBA_Monitor_Staging (
					info_date					DATETIME			NOT NULL
				,	server_name					SYSNAME				NOT NULL	-- Name of the server.
				,	xml_data					NVARCHAR(MAX)		NULL		-- Detail information of the object
				) ON [PRIMARY];

