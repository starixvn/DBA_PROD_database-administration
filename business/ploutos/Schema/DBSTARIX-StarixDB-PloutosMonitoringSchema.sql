/*
	Creator:	20191219@Billy
	Task:		Ploutos Monitoring - [Redmine: #125807]
	Server:		DBSTARIX.StarixDB
*/


--	BEGIN STEP 1:
--		Add new database file for Ploutos Data
----------------------------------------------------------------------------------------------------

USE master;
GO
ALTER DATABASE StarixDB ADD FILEGROUP Ploutos;
GO
ALTER DATABASE StarixDB ADD FILE (
	NAME		= N'Ploutos_DATA'
,	FILENAME	= N'M:\DBA_DB\StarixDB\Ploutos_DATA.ndf'
,	SIZE		= 32768KB
,	FILEGROWTH	= 32768KB
) TO FILEGROUP Ploutos;
GO


--	BEGIN STEP 2:
--		Create schema for Ploutos Monitoring
----------------------------------------------------------------------------------------------------

USE	StarixDB;
GO
CREATE SCHEMA plo AUTHORIZATION dbo;
GO


--	BEGIN STEP 3:
--		Create table for storing Ploutos Performance
----------------------------------------------------------------------------------------------------

USE	StarixDB;
GO

CREATE TABLE	plo.IncomingTicketRate (
					BrandCode		VARCHAR(20)
				,	SecondStamp		INT
				,	TicketCount		INT
				,	CONSTRAINT	PK_IncomingTicketRate PRIMARY KEY CLUSTERED (
									BrandCode	ASC
								,	SecondStamp	ASC
								) WITH (DATA_COMPRESSION = PAGE) ON Ploutos
				);


CREATE TABLE	plo.APIPushingTicketRate (
					BrandCode		VARCHAR(20)
				,	SecondStamp		INT
				,	TicketCount		INT
				,	CONSTRAINT	PK_APIPushingTicketRate PRIMARY KEY CLUSTERED (
									BrandCode	ASC
								,	SecondStamp	ASC
								) WITH (DATA_COMPRESSION = PAGE) ON Ploutos
				);


CREATE TABLE	plo.IncomingTicketRate_History (
					UpdateTime		DATETIME
						CONSTRAINT	DF_IncomingTicketRate_History_UpdateTime DEFAULT (GETDATE())
				,	BrandCode		VARCHAR(20)
				,	SecondStamp		INT
				,	TicketCount		INT
				);

CREATE CLUSTERED INDEX	CIX_IncomingTicketRate_History ON plo.IncomingTicketRate_History (
								UpdateTime	ASC
						) WITH (DATA_COMPRESSION = PAGE) ON Ploutos;


CREATE TABLE	plo.APIPushingTicketRate_History (
					UpdateTime		DATETIME
						CONSTRAINT	DF_APIPushingTicketRate_History_UpdateTime DEFAULT (GETDATE())
				,	BrandCode		VARCHAR(20)
				,	SecondStamp		INT
				,	TicketCount		INT
				);

CREATE CLUSTERED INDEX	CIX_APIPushingTicketRate_History ON plo.APIPushingTicketRate_History (
								UpdateTime	ASC
						) WITH (DATA_COMPRESSION = PAGE) ON Ploutos;


CREATE TABLE	plo.IncomingPlayerRate (
					BrandCode		VARCHAR(20)
				,	SecondStamp		INT
				,	PlayerCount		INT
				,	CONSTRAINT	PK_IncomingPlayerRate PRIMARY KEY CLUSTERED (
									BrandCode	ASC
								,	SecondStamp	ASC
								) WITH (DATA_COMPRESSION = PAGE) ON Ploutos
				);


CREATE TABLE	plo.APIPushingPlayerRate (
					BrandCode		VARCHAR(20)
				,	SecondStamp		INT
				,	PlayerCount		INT
				,	CONSTRAINT	PK_APIPushingPlayerRate PRIMARY KEY CLUSTERED (
									BrandCode	ASC
								,	SecondStamp	ASC
								) WITH (DATA_COMPRESSION = PAGE) ON Ploutos
				);


CREATE TABLE	plo.IncomingPlayerRate_History (
					UpdateTime		DATETIME
						CONSTRAINT	DF_IncomingPlayerRate_History_UpdateTime DEFAULT (GETDATE())
				,	BrandCode		VARCHAR(20)
				,	SecondStamp		INT
				,	PlayerCount		INT
				);

CREATE CLUSTERED INDEX	CIX_IncomingPlayerRate_History ON plo.IncomingPlayerRate_History (
								UpdateTime	ASC
						) WITH (DATA_COMPRESSION = PAGE) ON Ploutos;


CREATE TABLE	plo.APIPushingPlayerRate_History (
					UpdateTime		DATETIME
						CONSTRAINT	DF_APIPushingPlayerRate_History_UpdateTime DEFAULT (GETDATE())
				,	BrandCode		VARCHAR(20)
				,	SecondStamp		INT
				,	PlayerCount		INT
				);

CREATE CLUSTERED INDEX	CIX_APIPushingPlayerRate_History ON plo.APIPushingPlayerRate_History (
								UpdateTime	ASC
						) WITH (DATA_COMPRESSION = PAGE) ON Ploutos;
GO