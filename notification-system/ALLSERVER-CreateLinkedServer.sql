USE	master;
GO
IF	@@SERVERNAME = N'DBSPARE'
	EXECUTE	master.dbo.sp_addlinkedserver @server = N'DBNOTI', @srvproduct = N'SQL_Server', @provider = N'SQLOLEDB', @datasrc = N'10.1.1.222';
ELSE
	EXECUTE	master.dbo.sp_addlinkedserver @server = N'DBNOTI', @srvproduct = N'SQL_Server', @provider = N'SQLOLEDB', @datasrc = N'DBSPARE';
GO
EXECUTE	master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'collation compatible'             , @optvalue = N'false';
EXECUTE	master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'data access'                      , @optvalue = N'true';
EXECUTE	master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'dist'                             , @optvalue = N'false';
EXECUTE	master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'pub'                              , @optvalue = N'false';
EXECUTE	master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'rpc'                              , @optvalue = N'true';
EXECUTE	master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'rpc out'                          , @optvalue = N'true';
EXECUTE	master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'sub'                              , @optvalue = N'false';
EXECUTE	master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'connect timeout'                  , @optvalue = N'0';
EXECUTE	master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'collation name'                   , @optvalue = null;
EXECUTE	master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'lazy schema validation'           , @optvalue = N'false';
EXECUTE	master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'query timeout'                    , @optvalue = N'0';
EXECUTE	master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'use remote collation'             , @optvalue = N'true';
EXECUTE	master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'remote proc transaction promotion', @optvalue = N'false';
GO
EXECUTE	master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = NULL , @useself = N'False', @rmtuser = N'sqlLink', @rmtpassword = N'**********'
GO
