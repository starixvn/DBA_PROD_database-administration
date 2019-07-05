/*
	Creator:	20190705@Billy
	Task:		Schema for IPDB of FPS - [Redmine: #116251]
	Server:		DBFRAUD.IPDB
*/


USE IPDB;
GO

--	BEGIN STEP :
--		IP2Location
----------------------------------------------------------------------------------------------------

CREATE TABLE	dbo.IP2Location (
					ip_from			BIGINT			NOT NULL
				,	ip_to			BIGINT			NOT NULL
				,	country_code	CHAR(10)		NULL
				,	country_name	VARCHAR(64)		NULL
				,	region			VARCHAR(128)	NULL
				,	city			VARCHAR(128)	NULL
				,	isp_name		VARCHAR(256)	NULL
				,	CONSTRAINT	PK_IP2Location PRIMARY KEY CLUSTERED (
									ip_from	ASC
								,	ip_to	ASC
								) ON DATA
					) ON DATA;

CREATE NONCLUSTERED INDEX	IX_IP2Location_IPTo ON dbo.IP2Location (
								ip_to	ASC
							) ON DATA;
GO


--	BEGIN STEP :
--		IPv62Location
----------------------------------------------------------------------------------------------------

CREATE TABLE	dbo.IPv62Location (
					ip_from				CHAR(39) NOT NULL
				,	ip_to				CHAR(39) NOT NULL
				,	country_code		CHAR(2) NULL
				,	country_name		VARCHAR(64) NULL
				,	region				VARCHAR(128) NULL
				,	city				VARCHAR(128) NULL
				,	isp_name			VARCHAR(256) NULL
				,	CONSTRAINT	PK_IPv62Location PRIMARY KEY CLUSTERED (
									ip_from	ASC
								,	ip_to	ASC
								) ON DATA
				) ON DATA;

CREATE NONCLUSTERED INDEX	IX_IPv62Location_IPTo ON dbo.IPv62Location (
								ip_to	ASC
							) ON DATA;
GO


--	BEGIN STEP :
--		dbo.IPDBVersion
----------------------------------------------------------------------------------------------------

CREATE TABLE	dbo.IPDBVersion (
					version_date		DATE
				,	CONSTRAINT	PK_IPDBVersion PRIMARY KEY CLUSTERED (version_date) ON DATA
				) ON DATA;
GO