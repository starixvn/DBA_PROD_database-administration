/*
	Creator:	20190416@Billy
	Task:		Archive tables HA - [Redmine: #111418]
	Server:		DBARC
*/

USE bodb_archive;
GO

--	BEGIN STEP 1:
--		Archive tables metadata
----------------------------------------------------------------------------------------------------

CREATE TABLE	dbo.Task_ArchiveHA_StandbyServers (
					ServerName		NVARCHAR(128)	NOT NULL
				,	LinkedServer	NVARCHAR(128)	NOT NULL
				,	DataMonthLimit	SMALLINT		NULL
				,	isActive		BIT				NOT NULL
						CONSTRAINT	DF_ArchiveHA_StandbyServers_isActive DEFAULT (1)
				,	CONSTRAINT	PK_ArchiveHA_StandbyServers PRIMARY KEY NONCLUSTERED (
									ServerName	ASC
								) ON DATA
				) ON DATA;

CREATE CLUSTERED INDEX	CIX_ArchiveHA_StandbyServers ON dbo.Task_ArchiveHA_StandbyServers (
							isActive	ASC
						,	ServerName	ASC
						) ON DATA;

CREATE TABLE	dbo.Task_ArchiveHA_ArchiveTables (
					DatabaseName	NVARCHAR(128)	NOT NULL
				,	TableName		NVARCHAR(128)	NOT NULL
				,	TableType		INT				NULL
				,	KeyList			NVARCHAR(MAX)	NOT NULL
				,	isActive		BIT				NOT NULL
						CONSTRAINT	DF_ArchiveHA_ArchiveTables_isActive DEFAULT (1)
				,	CONSTRAINT	PK_ArchiveHA_ArchiveTables PRIMARY KEY CLUSTERED (
									DatabaseName	ASC
								,	TableName		ASC
								) ON DATA
				) ON DATA;
GO


--	BEGIN STEP 2:
--		Archive tables check rowcount result
----------------------------------------------------------------------------------------------------

CREATE TABLE	dbo.Task_ArchiveHA_RowcountResult (
					StandbyServer		NVARCHAR(128)	NOT NULL
				,	DatabaseName		NVARCHAR(128)	NOT NULL
				,	TableName			NVARCHAR(128)	NULL
				,	WinLostDate			DATETIME		NULL
				,	ActiveRowcount		BIGINT			NULL
				,	StandbyRowcount		BIGINT			NULL
				,	TimeType			VARCHAR(10)		NULL
) ON DATA;

CREATE CLUSTERED INDEX	CIX_ArchiveHA_RowcountResult ON dbo.Task_ArchiveHA_RowcountResult (
							StandbyServer	ASC
						,	DatabaseName	ASC
						,	TableName		ASC
						,	WinLostDate		ASC
						) ON DATA;

CREATE NONCLUSTERED INDEX	IX_ArchiveHA_RowcountResult_TimeType ON dbo.Task_ArchiveHA_RowcountResult (
								TimeType	ASC
							) ON DATA;
GO