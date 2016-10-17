/*
	Creator:	20160802@Billy
	Task:		Create tables for monitoring feature - [Redmine: #58941]
	Server:		KBT	- DBTP
				SIT	- SITDB06
*/


--	BEGIN STEP 1:	*SERVERS*.MonDB
--		Create table for saving objects information
----------------------------------------------------------------------------------------------------

USE	MonDB;
GO

IF	EXISTS (SELECT 1 FROM sys.objects AS o WHERE o.name IN (N'vnDBA_Monitor_Information', N'vnDBA_Monitor_Report', N'vnDBA_Monitor_Report_bk') AND o.type = 'U')
	RAISERROR('Table exists!', 16, 1) WITH NOWAIT;

--	DROP TABLE	dbo.vnDBA_Monitor_Information;
--	DROP TABLE	dbo.vnDBA_Monitor_Report;
--	DROP TABLE	dbo.vnDBA_Monitor_Report_bk;
GO

CREATE TABLE	dbo.vnDBA_Monitor_Information (
					server_name					SYSNAME				NOT NULL	-- Name of the server.
				,	database_name				SYSNAME				NOT NULL	-- Name of the database, if object is server object, this field is empty.
				,	object_id					VARCHAR(40)			NOT NULL	-- ID of the monitored object.
				,	object_name					SYSNAME				NOT NULL	-- Name of the monitored object.
				,	object_type					VARCHAR(64)			NOT NULL	-- Type of montiored object.
				,	created_date				DATETIME			NOT NULL	-- Creation date of the object.
				,	update_date					DATETIME			NOT NULL	-- Last updated time.
				,	xml_data					XML					NULL		-- Detail information of the object
				) ON [PRIMARY];

ALTER TABLE	dbo.vnDBA_Monitor_Information
	ADD CONSTRAINT	PK_vnDBA_Monitor_Information PRIMARY KEY CLUSTERED (
						server_name				ASC
					,	object_type				ASC
					,	database_name			ASC
					,	object_name				ASC
					,	object_id				ASC
					) ON [PRIMARY];
GO					


CREATE TABLE	dbo.vnDBA_Monitor_Report (
					report_type					VARCHAR(64)			NOT NULL
				,	verify_date					DATETIME			NOT NULL
				,	resolve_date				DATETIME			NULL
				,	server_name					SYSNAME				NOT NULL
				,	database_name				SYSNAME				NOT NULL
				,	object_id					VARCHAR(40)			NOT NULL
				,	object_name					SYSNAME				NOT NULL
				,	object_type					VARCHAR(64)			NOT NULL
				,	old_xml_data				XML					NULL
				,	xml_data					XML					NULL
				,	is_notified					BIT					NOT NULL
				) ON [PRIMARY];
GO



CREATE TABLE	dbo.vnDBA_Monitor_Report_bk (
					report_type					VARCHAR(64)			NOT NULL
				,	verify_date					DATETIME			NOT NULL
				,	resolve_date				DATETIME			NOT NULL
				,	server_name					SYSNAME				NOT NULL
				,	database_name				SYSNAME				NOT NULL
				,	object_id					VARCHAR(40)			NOT NULL
				,	object_name					SYSNAME				NOT NULL
				,	object_type					VARCHAR(64)			NOT NULL
				,	old_xml_data				XML					NULL
				,	xml_data					XML					NULL
				) ON [PRIMARY];

ALTER TABLE	dbo.vnDBA_Monitor_Report_bk
	ADD CONSTRAINT	PK_vnDBA_Monitor_Report_bk PRIMARY KEY CLUSTERED (
						verify_date				DESC
					,	report_type				ASC
					,	server_name				ASC
					,	database_name			ASC
					,	object_id				ASC
					) ON [PRIMARY];
GO



CREATE TRIGGER	dbo.vnDBA_Monitor_Report_Archive ON dbo.vnDBA_Monitor_Report
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;

    INSERT INTO	dbo.vnDBA_Monitor_Report_bk
		(	  report_type,   verify_date,   resolve_date,   server_name,   database_name,   object_id,   object_name,   object_type,   old_xml_data,   xml_data)
    SELECT	i.report_type, i.verify_date, i.resolve_date, i.server_name, i.database_name, i.object_id, i.object_name, i.object_type, i.old_xml_data, i.xml_data
	FROM	Inserted i
	WHERE	i.resolve_date IS NOT NULL
		AND	i.is_notified = 1;

	DELETE	dbo.vnDBA_Monitor_Report
	WHERE	resolve_date IS NOT NULL
		AND	is_notified = 1;
END;
GO

--CREATE TRIGGER	dbo.vnDBA_Monitor_Report_Archive_Delete ON dbo.vnDBA_Monitor_Report
--AFTER DELETE
--AS
--BEGIN
--	SET NOCOUNT ON;

--    INSERT INTO	dbo.vnDBA_Monitor_Report_bk
--		(	  report_type,   verify_date, resolve_date,   server_name,   database_name,   object_id,   object_name,   object_type,   old_xml_data,   xml_data)
--    SELECT	d.report_type, d.verify_date, GETDATE()   , d.server_name, d.database_name, d.object_id, d.object_name, d.object_type, d.old_xml_data, d.xml_data
--	FROM	Deleted d;
--END;
--GO