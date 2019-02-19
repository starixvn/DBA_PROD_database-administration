/*
	Created: 20190219@Helen
	Task: Capture statement running when relplication latency
	DB: DBDWCSS/StarixDB
*/
CREATE TABLE [dbo].[vnDBA_Monitor_Servers]
(
	[ServerName] [nvarchar](128) NOT NULL,
	[MonitorDatabase] [nvarchar](128) NOT NULL,
	[IsActive] BIT,
	[IsAlertReplication] BIT,
	 CONSTRAINT [PK_vnDBA_Monitor_Servers] PRIMARY KEY CLUSTERED 
	(
		[ServerName] ASC
	)
)  
GO
INSERT INTO [dbo].[vnDBA_Monitor_Servers] (ServerName,MonitorDatabase, IsActive,IsAlertReplication )
VALUES ('DB042','MonDB',1, 1),
('DB043', 'MonDB',1, 1),
('DB044', 'MonDB',1, 1),
('DB05', 'MonDB',1, 1),
('DB052', 'MonDB',1, 1),
('DB053', 'MonDB',1, 1),
('DB054', 'MonDB',1, 1),
('DB06', 'MonDB',1, 1),
('DBTP', 'MonDB',1, 1),
('DBLICAPI', 'MonDB',1, 1),
('DBLICAPI02', 'MonDB',1, 1),
('DB04Admin2', 'MonDB',1, 1),
('DBTRANS', 'MonDB',1, 1),
-- add more servers but set IsalertReplication = 0
('DB02','MonDB',1,0),
('DB04Admin1','MonDB',1,0),
('DB04Admin2','MonDB',1,0),
('DBAFF','MonDB',1,0),
('DBCUST','MonDB',1,0),
('DBDIST','MONDB',1,0),
('DBDIST02','MONDB',1,0),
('DBDIST03','MONDB',1,0),
('DBDW','MonDB',1,0),
('DBDW2','MonDB',1,0),
('DBDWCSS','MonDB',1,0),
('DBFRAUD','PerfMonDB',1,0),
('DBLICAPI','MonDB',1,0),
('DBLICAPI02','MonDB',1,0),
('FPS_DB01\MSSQLSERVERWEB','PerfMonDB',1,0),
('FPS_DB02','PerfMonDB',1,0),
('FPS_DB02\FPS_01','PerfMonDB',1,0)

