USE	IPDB;
GO
ALTER PROCEDURE	dbo.Task_ImportIP2Location
						@FilePath			NVARCHAR(128)		= 'G:\IP2Location'
					,	@ProductDB			VARCHAR(10)			= 'DB4'
AS
/*
	Creator:	20180212@Billy
	Task:		Import IP2Location to IPDB - DBFRAUD only - DB4 product - [Redmine: #90857]
	Database:	DBFRAUD.IPDB
	
	Revisions:
		- 20180212@Billy:	Initial - [Redmine: #90857]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@query		NVARCHAR(MAX)
		;

	-- Verify table --
	IF	OBJECT_ID('dbo.bk_IP2Location_Old') IS NOT NULL
	BEGIN;
		RAISERROR('Last time run is not verified. Backup table exists.', 0, 0) WITH NOWAIT;

		RETURN;
	END;

	IF	OBJECT_ID('tempdb..##IP2Location_file') IS NOT NULL
	BEGIN;
		RAISERROR('There are other processes running now.', 0, 0) WITH NOWAIT;

		RETURN;
	END;
	
	-- Checking source file --
	CREATE TABLE	##IP2Location_file (
						file_name		NVARCHAR(MAX)
					,	depth			INT
					,	is_file			INT
					);

	SELECT	@query = N'';
	SELECT	@query = @query + N'
INSERT INTO	##IP2Location_file (file_name, depth, is_file)
EXECUTE	sys.xp_dirtree N''' + @FilePath + N''', 1, 1;	
';

	EXECUTE	sys.sp_executesql @query;

	IF	NOT EXISTS (SELECT 1 FROM ##IP2Location_file WITH (NOLOCK) WHERE file_name = N'IP-COUNTRY-REGION-CITY-ISP.CSV')
	BEGIN;
		RAISERROR('Source file is not available. Please copy file "IP-COUNTRY-REGION-CITY-ISP.CSV" to "%s" before executing the job.', 0, 0, @FilePath) WITH NOWAIT;
		
		DROP TABLE	##IP2Location_file;

		RETURN;
	END;
	
	IF	NOT EXISTS (SELECT 1 FROM ##IP2Location_file WITH (NOLOCK) WHERE file_name = @ProductDB + N'.FMT')
	BEGIN;
		RAISERROR('Source file is not available. Please copy file "%s.FMT" to "%s" before executing the job.', 0, 0, @ProductDB, @FilePath) WITH NOWAIT;
		
		DROP TABLE	##IP2Location_file;

		RETURN;
	END;

	-- Import data to new table --
	IF	OBJECT_ID('dbo.tmp_IP2Location_New') IS NOT NULL
		DROP TABLE	dbo.tmp_IP2Location_New;

	CREATE TABLE	dbo.tmp_IP2Location_New (
						ip_from			BIGINT
					,	ip_to			BIGINT
					,	country_code	CHAR(10)
					,	country_name	VARCHAR(64)
					,	region			VARCHAR(128)
					,	city			VARCHAR(128)
					,	isp_name		VARCHAR(256)
					,	CONSTRAINT	PK_tmp_IP2Location_New PRIMARY KEY CLUSTERED (
										ip_from		ASC
									,	ip_to		ASC
									) ON DATA
					) ON DATA;

	CREATE NONCLUSTERED INDEX	IX_IP2Location_IPTo ON dbo.tmp_IP2Location_New (
									ip_to		ASC
								) ON DATA;

	SELECT	@query = N'';
	SELECT	@query = @query + N'
BULK INSERT	dbo.tmp_IP2Location_New
FROM	''' + @FilePath + N'\IP-COUNTRY-REGION-CITY-ISP.CSV''
WITH	(
	FORMATFILE = ''' + @FilePath + N'\' + @ProductDB + N'.FMT''
);
';

	EXECUTE	sys.sp_executesql @query;

	-- Switch to new location table --
	BEGIN TRANSACTION;

	EXECUTE	sys.sp_rename 'IP2Location', 'bk_IP2Location_Old', 'OBJECT';
	EXECUTE	sys.sp_rename 'PK_IP2Location', 'PK_bk_IP2Location_Old', 'OBJECT';

	EXECUTE	sys.sp_rename 'tmp_IP2Location_New', 'IP2Location', 'OBJECT';
	EXECUTE	sys.sp_rename 'PK_tmp_IP2Location_New', 'PK_IP2Location', 'OBJECT';

	COMMIT;
END;
GO
