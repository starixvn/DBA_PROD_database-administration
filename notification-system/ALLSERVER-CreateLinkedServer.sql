USE	master;
GO
EXEC master.dbo.sp_addlinkedserver @server = N'DBNOTI', @srvproduct = N'SQL_Server', @provider = N'SQLOLEDB', @datasrc = N'DBSPARE';
GO
EXEC master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'collation compatible'             , @optvalue = N'false';
EXEC master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'data access'                      , @optvalue = N'true';
EXEC master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'dist'                             , @optvalue = N'false';
EXEC master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'pub'                              , @optvalue = N'false';
EXEC master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'rpc'                              , @optvalue = N'true';
EXEC master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'rpc out'                          , @optvalue = N'true';
EXEC master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'sub'                              , @optvalue = N'false';
EXEC master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'connect timeout'                  , @optvalue = N'0';
EXEC master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'collation name'                   , @optvalue = null;
EXEC master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'lazy schema validation'           , @optvalue = N'false';
EXEC master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'query timeout'                    , @optvalue = N'0';
EXEC master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'use remote collation'             , @optvalue = N'true';
EXEC master.dbo.sp_serveroption @server = N'DBNOTI', @optname = N'remote proc transaction promotion', @optvalue = N'false';
GO
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'DBNOTI', @locallogin = NULL , @useself = N'False', @rmtuser = N'sqlLink', @rmtpassword = N'**********'
GO
