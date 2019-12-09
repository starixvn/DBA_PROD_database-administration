/*
	Creator:	20191205@Billy
	Task:		Description - [Redmine: #124921]
	Server:		DBMON.MonDBDW
*/

INSERT INTO	dbo.vnDBA_SPPF_ServerList_Filtered (ServerId, ServerName)
SELECT	ServerID, ServerName
FROM	dbo.Mon_SPPF_ServerList WITH (NOLOCK)
WHERE	isEnabled = 1
	AND	ServerName IN (
			N'DBTRANS'
		,	N'DBCUST'
		,	N'DB02'
		,	N'DB042'
		,	N'DB052'
		,	N'DB053'
		,	N'DB054'
		,	N'DB06'
		,	N'DB061'
		,	N'DB05'
		,	N'DB05BK1'
		,	N'DBTP'
		,	N'DBDW'
		,	N'DBDW2'
		,	N'DBSPARE'
		,	N'DBDWCSS'
		,	N'DBDIST'
		,	N'DBDIST02'
		,	N'DBDIST03'
		,	N'DBDISTRM'
		);