/*
	Creator:	20200120@Billy
	Task:		Create database that save toolkit for DBA - [Redmine: #126744]
	Server:		DBTOOL
*/

SET NOCOUNT ON;

USE	master;
GO
CREATE DATABASE ToolkitDB
	ON	PRIMARY (
			NAME		= N'ToolkitDB'
		,	FILENAME	= N'G:\USER_DB\ToolkitDB\ToolkitDB.mdf'
		,	SIZE		= 4096KB
		,	FILEGROWTH	= 4096KB
		)
	,	FILEGROUP DATA DEFAULT (
			NAME		= N'ToolkitDB_DATA'
		,	FILENAME	= N'G:\USER_DB\ToolkitDB\ToolkitDB_DATA.ndf'
		,	SIZE		= 131072KB
		,	FILEGROWTH	= 131072KB
		)
	,	FILEGROUP IDX (
			NAME		= N'ToolkitDB_IDX'
		,	FILENAME	= N'G:\USER_DB\ToolkitDB\ToolkitDB_IDX.ndf'
		,	SIZE		= 131072KB
		,	FILEGROWTH	= 131072KB
		)
	LOG ON (
		NAME		= N'ToolkitDB_log'
	,	FILENAME	= N'G:\USER_DB\ToolkitDB\ToolkitDB_log.ldf'
	,	SIZE		= 1048576KB
	,	FILEGROWTH	= 524288KB
	);
GO
ALTER AUTHORIZATION ON DATABASE::ToolkitDB TO sa;
GO
ALTER DATABASE ToolkitDB SET RECOVERY SIMPLE WITH NO_WAIT;
GO