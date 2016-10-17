/*
	Creator:	20160630@Billy
	Task:		System Monitoring Feature - Create Remote Servers List Table - [Redmine: #58941]
	Server:		DBTP
*/


--	BEGIN STEP 1:	*SERVER*.MonDB
--		Create Remote Servers List Table
----------------------------------------------------------------------------------------------------

USE	MonDB;
GO

IF	EXISTS(SELECT 1 FROM sys.objects AS o WHERE o.name = 'vnDBA_Servers_RemoteList' AND o.type = 'U')
BEGIN
	RAISERROR('Table exists!', 16, 1) WITH NOWAIT;

--	DROP TABLE	dbo.vnDBA_Servers_RemoteList;
END;

CREATE TABLE	dbo.vnDBA_Servers_RemoteList (
					remote_name				SYSNAME
				,	job_monitored			TINYINT
						CONSTRAINT DF_vnDBA_Servers_RemoteList_jobMon DEFAULT 0
				,	object_monitored		TINYINT
						CONSTRAINT DF_vnDBA_Servers_RemoteList_objMon DEFAULT 0
				);

ALTER TABLE	dbo.vnDBA_Servers_RemoteList
	ADD CONSTRAINT	PK_vnDBA_Servers_RemoteList PRIMARY KEY CLUSTERED (
						remote_name			ASC
					) ON [PRIMARY];
GO


--	BEGIN STEP :	*SERVER*.MonDB
--		Initial data for vnDBA_Servers_RemoteList table
----------------------------------------------------------------------------------------------------

IF	@@SERVERNAME = N'DBTP'			-- KBT
BEGIN
    INSERT INTO	dbo.vnDBA_Servers_RemoteList
			(	remote_name)
    VALUES	(	'DBCUST')
		,	(	'DBTRANS')
		,	(	'DB02')
		,	(	'DB05')
		,	(	'DB052')
		,	(	'DB053')
		,	(	'DB054')
		,	(	'DB06')
		,	(	'DB07')
		,	(	'DBDW')
		,	(	'DBDW2')
		;
END;

IF	@@SERVERNAME = N'SITDB06'		-- SIT
BEGIN
    INSERT INTO	dbo.vnDBA_Servers_RemoteList
			(	remote_name)
    VALUES	(	'DBCUST')
		,	(	'DBTRANS')
		,	(	'DB02')
		,	(	'DB05')
		,	(	'DB052')
		,	(	'DB053')
		,	(	'DB07')
		,	(	'DBDW')
		;
END;
GO

IF	@@SERVERNAME = N'DB233'			-- Local Test
BEGIN
	INSERT INTO	dbo.vnDBA_Servers_RemoteList
			(	remote_name)
    VALUES	(	'DB206')
		,	(	'DB215')
		,	(	'DB234')
		;
END;