/*
	Creator:	20200310@Billy
	Task:		Create linked server for FPSMON - [Redmine: #112758]
	Server:		FPSMON
*/

SET NOCOUNT ON;

USE	master;

DECLARE	@LinkedServer	NVARCHAR(128)
	,	@Server			NVARCHAR(128)
	;

--	BEGIN STEP :
--		DBFRAUD
----------------------------------------------------------------------------------------------------
BEGIN;
	SELECT	@LinkedServer	= N'KBTDBFRAUD'
		,	@Server			= N'DBFRAUD'
		;

	IF	NOT EXISTS (SELECT 1 FROM sys.servers WITH (NOLOCK) WHERE name = @LinkedServer)
	BEGIN;
		EXECUTE	master.dbo.sp_addlinkedserver @server = @LinkedServer, @srvproduct = N'SQL_Server', @provider = N'SQLOLEDB', @datasrc = @Server;
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'collation compatible', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'data access', @optvalue = N'true';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'dist', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'pub', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'rpc', @optvalue = N'true';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'rpc out', @optvalue = N'true';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'sub', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'connect timeout', @optvalue = N'0';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'collation name', @optvalue = NULL;
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'lazy schema validation', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'query timeout', @optvalue = N'0';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'use remote collation', @optvalue = N'true';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'remote proc transaction promotion', @optvalue = N'false';
		EXECUTE	master.dbo.sp_addlinkedsrvlogin @rmtsrvname = @LinkedServer, @locallogin = NULL , @useself = N'True';

		RAISERROR(N'Linked server %s created', 0, 0, @LinkedServer) WITH NOWAIT;
	END;
END;


--	BEGIN STEP :
--		FPS_DB01
----------------------------------------------------------------------------------------------------
BEGIN;
	SELECT	@LinkedServer	= N'KBTFPS_DB01'
		,	@Server			= N'FPS_DB01'
		;

	IF	NOT EXISTS (SELECT 1 FROM sys.servers WITH (NOLOCK) WHERE name = @LinkedServer)
	BEGIN;
		EXECUTE	master.dbo.sp_addlinkedserver @server = @LinkedServer, @srvproduct = N'SQL_Server', @provider = N'SQLOLEDB', @datasrc = @Server;
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'collation compatible', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'data access', @optvalue = N'true';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'dist', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'pub', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'rpc', @optvalue = N'true';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'rpc out', @optvalue = N'true';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'sub', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'connect timeout', @optvalue = N'0';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'collation name', @optvalue = NULL;
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'lazy schema validation', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'query timeout', @optvalue = N'0';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'use remote collation', @optvalue = N'true';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'remote proc transaction promotion', @optvalue = N'false';
		EXECUTE	master.dbo.sp_addlinkedsrvlogin @rmtsrvname = @LinkedServer, @locallogin = NULL , @useself = N'True';

		RAISERROR(N'Linked server %s created', 0, 0, @LinkedServer) WITH NOWAIT;
	END;
END;


--	BEGIN STEP :
--		FPS_DB01\MSSQLSERVERWEB
----------------------------------------------------------------------------------------------------
BEGIN;
	SELECT	@LinkedServer	= N'KBTFPS_DB01_MSSQLSERVERWEB'
		,	@Server			= N'FPS_DB01\MSSQLSERVERWEB'
		;

	IF	NOT EXISTS (SELECT 1 FROM sys.servers WITH (NOLOCK) WHERE name = @LinkedServer)
	BEGIN;
		EXECUTE	master.dbo.sp_addlinkedserver @server = @LinkedServer, @srvproduct = N'SQL_Server', @provider = N'SQLOLEDB', @datasrc = @Server;
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'collation compatible', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'data access', @optvalue = N'true';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'dist', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'pub', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'rpc', @optvalue = N'true';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'rpc out', @optvalue = N'true';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'sub', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'connect timeout', @optvalue = N'0';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'collation name', @optvalue = NULL;
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'lazy schema validation', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'query timeout', @optvalue = N'0';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'use remote collation', @optvalue = N'true';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'remote proc transaction promotion', @optvalue = N'false';
		EXECUTE	master.dbo.sp_addlinkedsrvlogin @rmtsrvname = @LinkedServer, @locallogin = NULL , @useself = N'True';

		RAISERROR(N'Linked server %s created', 0, 0, @LinkedServer) WITH NOWAIT;
	END;
END;


--	BEGIN STEP :
--		FPS_DB02
----------------------------------------------------------------------------------------------------
BEGIN;
	SELECT	@LinkedServer	= N'KBTFPS_DB02'
		,	@Server			= N'FPS_DB02'
		;

	IF	NOT EXISTS (SELECT 1 FROM sys.servers WITH (NOLOCK) WHERE name = @LinkedServer)
	BEGIN;
		EXECUTE	master.dbo.sp_addlinkedserver @server = @LinkedServer, @srvproduct = N'SQL_Server', @provider = N'SQLOLEDB', @datasrc = @Server;
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'collation compatible', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'data access', @optvalue = N'true';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'dist', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'pub', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'rpc', @optvalue = N'true';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'rpc out', @optvalue = N'true';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'sub', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'connect timeout', @optvalue = N'0';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'collation name', @optvalue = NULL;
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'lazy schema validation', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'query timeout', @optvalue = N'0';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'use remote collation', @optvalue = N'true';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'remote proc transaction promotion', @optvalue = N'false';
		EXECUTE	master.dbo.sp_addlinkedsrvlogin @rmtsrvname = @LinkedServer, @locallogin = NULL , @useself = N'True';

		RAISERROR(N'Linked server %s created', 0, 0, @LinkedServer) WITH NOWAIT;
	END;
END;


--	BEGIN STEP :
--		FPS_DB02\FPS_01
----------------------------------------------------------------------------------------------------
BEGIN;
	SELECT	@LinkedServer	= N'KBTFPS_DB02_FPS_01'
		,	@Server			= N'FPS_DB02\FPS_01'
		;

	IF	NOT EXISTS (SELECT 1 FROM sys.servers WITH (NOLOCK) WHERE name = @LinkedServer)
	BEGIN;
		EXECUTE	master.dbo.sp_addlinkedserver @server = @LinkedServer, @srvproduct = N'SQL_Server', @provider = N'SQLOLEDB', @datasrc = @Server;
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'collation compatible', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'data access', @optvalue = N'true';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'dist', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'pub', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'rpc', @optvalue = N'true';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'rpc out', @optvalue = N'true';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'sub', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'connect timeout', @optvalue = N'0';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'collation name', @optvalue = NULL;
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'lazy schema validation', @optvalue = N'false';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'query timeout', @optvalue = N'0';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'use remote collation', @optvalue = N'true';
		EXECUTE	master.dbo.sp_serveroption @server = @LinkedServer, @optname = N'remote proc transaction promotion', @optvalue = N'false';
		EXECUTE	master.dbo.sp_addlinkedsrvlogin @rmtsrvname = @LinkedServer, @locallogin = NULL , @useself = N'True';

		RAISERROR(N'Linked server %s created', 0, 0, @LinkedServer) WITH NOWAIT;
	END;
END;
GO