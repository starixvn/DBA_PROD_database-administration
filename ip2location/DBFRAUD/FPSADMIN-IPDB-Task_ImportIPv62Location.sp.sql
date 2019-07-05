SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.Task_ImportIPv62Location
						@FilePath			NVARCHAR(128)		= 'E:\IP2Location'
					,	@ProductDB			VARCHAR(10)			= 'DB4'
AS
/*
	Creator:	20190624@Billy
	Task:		Import IP2Location to IPDB - DBFRAUD only - DB4 product - IPv6 - [Redmine: #000000]
	Database:	FPSADMIN.IPDB

	Revisions:
		- 20190624@Billy:	Initial - [Redmine: #000000]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@query		NVARCHAR(MAX)
		;

	-- Verify table --
	IF	OBJECT_ID('dbo.bk_IPv62Location_Old') IS NOT NULL
	BEGIN;
		DROP TABLE	dbo.bk_IPv62Location_Old;
	END;

	IF	OBJECT_ID('tempdb..##IPv62Location_file') IS NOT NULL
	BEGIN;
		RAISERROR('There are other processes running now.', 0, 0) WITH NOWAIT;

		RETURN -1;
	END;

	-- Checking source file --
	CREATE TABLE	##IPv62Location_file (
						file_name		NVARCHAR(MAX)
					,	depth			INT
					,	is_file			INT
					);

	SELECT	@query = N'';
	SELECT	@query = @query + N'
INSERT INTO	##IPv62Location_file (file_name, depth, is_file)
EXECUTE	sys.xp_dirtree N''' + @FilePath + N''', 1, 1;	
';

	EXECUTE	sys.sp_executesql @query;

	IF	NOT EXISTS (SELECT 1 FROM ##IPv62Location_file WITH (NOLOCK) WHERE file_name = N'IPv6-COUNTRY-REGION-CITY-ISP.CSV')
	BEGIN;
		RAISERROR('Source file is not available. Please copy file "IPv6-COUNTRY-REGION-CITY-ISP.CSV" to "%s" before executing the job.', 0, 0, @FilePath) WITH NOWAIT;

		DROP TABLE	##IPv62Location_file;

		RETURN -1;
	END;

	IF	NOT EXISTS (SELECT 1 FROM ##IPv62Location_file WITH (NOLOCK) WHERE file_name = @ProductDB + N'v6.FMT')
	BEGIN;
		RAISERROR('Source file is not available. Please copy file "%s.FMT" to "%s" before executing the job.', 0, 0, @ProductDB, @FilePath) WITH NOWAIT;

		DROP TABLE	##IPv62Location_file;

		RETURN -1;
	END;

	-- Import data to new table --
	IF	OBJECT_ID('dbo.tmp_IPv62Location_New') IS NOT NULL
		DROP TABLE	dbo.tmp_IPv62Location_New;

	CREATE TABLE	dbo.tmp_IPv62Location_New (
						ip_from			CHAR(39)
					,	ip_to			CHAR(39)
					,	country_code	CHAR(2)
					,	country_name	VARCHAR(64)
					,	region			VARCHAR(128)
					,	city			VARCHAR(128)
					,	isp_name		VARCHAR(256)
					,	CONSTRAINT	PK_tmp_IPv62Location_New PRIMARY KEY CLUSTERED (
										ip_from		ASC
									,	ip_to		ASC
									) ON DATA
					) ON DATA;

	CREATE NONCLUSTERED INDEX	IX_IPv62Location_IPTo ON dbo.tmp_IPv62Location_New (
									ip_to		ASC
								) ON DATA;

	SELECT	@query = N'';
	SELECT	@query = @query + N'\
BULK INSERT	dbo.tmp_IPv62Location_New
FROM	''' + @FilePath + N'\IPv6-COUNTRY-REGION-CITY-ISP.CSV''
WITH	(
	FORMATFILE = ''' + @FilePath + N'\' + @ProductDB + N'v6.FMT''
);
';

	EXECUTE	sys.sp_executesql @query;

	-- Switch to new location table --
	BEGIN TRANSACTION;

	EXECUTE	sys.sp_rename 'IPv62Location', 'bk_IPv62Location_Old', 'OBJECT';
	EXECUTE	sys.sp_rename 'PK_IPv62Location', 'PK_bk_IPv62Location_Old', 'OBJECT';

	EXECUTE	sys.sp_rename 'tmp_IPv62Location_New', 'IPv62Location', 'OBJECT';
	EXECUTE	sys.sp_rename 'PK_tmp_IPv62Location_New', 'PK_IPv62Location', 'OBJECT';

	COMMIT;
END;
GO
/*<info serverAlias="FPSADMIN-IPDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/