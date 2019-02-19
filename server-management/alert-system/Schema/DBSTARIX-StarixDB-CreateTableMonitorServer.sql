/*
	Created: 20190219@Helen
	Task: Capture statement running when relplication latency
	DB: DBDWCSS/StarixDB
*/
CREATE TABLE [dbo].[vnDBA_Monitor_Servers]
(
	[ServerName] [nvarchar](128) NOT NULL,
	[MonitorDatabase] [nvarchar](128) NOT NULL,
	 CONSTRAINT [PK_vnDBA_Monitor_Servers] PRIMARY KEY CLUSTERED 
	(
		[ServerName] ASC
	)
)
GO
INSERT INTO [dbo].[vnDBA_Monitor_Servers] (ServerName,MonitorDatabase)
VALUES ('DB042','MonDB')
,('DB043', 'MonDB')
,('DB044', 'MonDB')
,('DB05', 'MonDB')
,('DB052', 'MonDB')
,('DB053', 'MonDB')
,('DB054', 'MonDB')
,('DB06', 'MonDB')
,('DBTP', 'MonDB')
,('DBLICAPI', 'MonDB')
,('DBLICAPI02', 'MonDB')
,('DB04Admin2', 'MonDB')
,('DBTRANS', 'MonDB')
