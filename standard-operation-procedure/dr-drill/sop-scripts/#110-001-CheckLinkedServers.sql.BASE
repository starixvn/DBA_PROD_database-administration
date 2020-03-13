/*
	Creator:	20190611@Billy
	Task:		#110-001 - Check Linked Servers - [Redmine: #114307]
	Server:		DBSPARE

	Revision:
		- 20190611@Billy:	Initialization - [Redmine: #114307]
*/


SET NOCOUNT ON;

DECLARE	@Query				NVARCHAR(MAX)
	,	@Param				NVARCHAR(MAX)
	,	@Execute			NVARCHAR(MAX)
	,	@LinkedServerQuery	NVARCHAR(MAX)
	,	@LinkedServerParam	NVARCHAR(MAX)
	;

DECLARE	@KBT				NVARCHAR(MAX)
	,	@MNL				NVARCHAR(MAX)
	,	@ID					INT
	;

IF	OBJECT_ID('tempdb..#ServerMapping') IS NOT NULL
	DROP TABLE	#ServerMapping;
CREATE TABLE	#ServerMapping (
					ID		INT				IDENTITY(1,1)
				,	KBT		NVARCHAR(128)
				,	MNL		NVARCHAR(128)
				,	Done	BIT
						DEFAULT 0
				,	PRIMARY KEY CLUSTERED (KBT, MNL)
				);

IF	OBJECT_ID('tempdb..#ResultKBT') IS NOT NULL
	DROP TABLE	#ResultKBT;
CREATE TABLE	#ResultKBT (
					ID					INT
				,	ServerName			NVARCHAR(128)	NOT NULL
				,	LinkedServer		NVARCHAR(128)	NOT NULL
				,	Provider			NVARCHAR(128)	NOT NULL
				,	DataSource			NVARCHAR(4000)
				,	Linked				BIT
				,	DataAccess			BIT
				,	RPC					BIT
				,	RPCOut				BIT
				,	RemoteTransPromote	BIT
				,	ConnectTimeout		INT
				,	QueryTimeout		INT
				,	DefaultLogin		NVARCHAR(128)
				,	PRIMARY KEY CLUSTERED (ID, LinkedServer)
				);

IF	OBJECT_ID('tempdb..#ResultMNL') IS NOT NULL
	DROP TABLE	#ResultMNL;
CREATE TABLE	#ResultMNL (
					ID					INT
				,	ServerName			NVARCHAR(128)	NOT NULL
				,	LinkedServer		NVARCHAR(128)	NOT NULL
				,	Provider			NVARCHAR(128)	NOT NULL
				,	DataSource			NVARCHAR(4000)
				,	Linked				BIT
				,	DataAccess			BIT
				,	RPC					BIT
				,	RPCOut				BIT
				,	RemoteTransPromote	BIT
				,	ConnectTimeout		INT
				,	QueryTimeout		INT
				,	DefaultLogin		NVARCHAR(128)
				,	PRIMARY KEY CLUSTERED (ID, LinkedServer)
				);

SELECT	@LinkedServerQuery = N'';
SELECT	@LinkedServerQuery = @LinkedServerQuery + N'
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT	[Id]					= @ID
	,	[ServerName]			= @@SERVERNAME
	,	[LinkedServer]			= svr.name
	,	[Provider]				= svr.provider
	,	[DataSource]			= svr.data_source
	,	[Linked]				= svr.is_linked
	,	[DataAccess]			= svr.is_data_access_enabled
	,	[RPC]					= svr.is_remote_login_enabled
	,	[RPCOut]				= svr.is_rpc_out_enabled
	,	[RemoteTransPromote]	= svr.is_remote_proc_transaction_promotion_enabled
	,	[ConnectTimeout]		= svr.connect_timeout
	,	[QueryTimeout]			= svr.query_timeout
	,	[DefaultLogin]			= CASE	WHEN ll.uses_self_credential IS NULL THEN N''[N/A]''
										WHEN ll.uses_self_credential = 0 THEN ISNULL(ll.remote_name, N''[Anonymous]'')
										WHEN ll.uses_self_credential = 1 THEN N''[Impersonate]''
										ELSE NULL
								  END
FROM		sys.servers AS svr WITH (NOLOCK)
LEFT JOIN	sys.linked_logins AS ll WITH (NOLOCK)
		ON	svr.server_id = ll.server_id
		AND	ll.local_principal_id = 0
WHERE	svr.server_id > 0
ORDER BY svr.name;
';

SELECT	@LinkedServerParam = N'';
SELECT	@LinkedServerParam = @LinkedServerParam + N'@ID INT';

SELECT	@Query = N'';
SELECT	@Query = @Query + N'
EXECUTE	[~~Server~~].master.sys.sp_executesql @Query, @Param, @ID;
';

SELECT	@Param = N'';
SELECT	@Param = @Param + N'@Query NVARCHAR(MAX), @Param NVARCHAR(MAX), ' + @LinkedServerParam;


INSERT INTO	#ServerMapping (KBT, MNL)
VALUES	('KBTDBTRANS'	, 'MNL_DBTRANS')
	,	('KBTDBCUST'	, 'MNL_DBCUST')
	,	('KBTDB02'		, 'MNL_DB02')
	,	('KBTDB05'		, 'MNL_DB05')
	,	('KBTDB05BK1'	, 'MNL_DB05')
	,	('KBTDB052'		, 'MNL_DB052')
	,	('KBTDB053'		, 'MNL_DB053')
	,	('KBTDB054'		, 'MNL_DB053')
	,	('KBTDB042'		, 'MNL_DB053')
	,	('KBTDB06'		, 'MNL_DB06')
	,	('KBTDB061'		, 'MNL_DB06')
	,	('KBTDBDW'		, 'MNL_DBDW')
	,	('KBTDBDW2'		, 'MNL_DBDW')
	,	('KBTDBLICAPI'	, 'MNL_DBLICAPI')
	,	('KBTDBLICAPI02', 'MNL_DBLICAPI')
	;


WHILE	0 = 0
BEGIN;
	UPDATE	TOP(1)
			tbl WITH (ROWLOCK)
	SET		@KBT = KBT
		,	@MNL = MNL
		,	@ID  = ID
		,	Done = 1
	FROM	#ServerMapping AS tbl
	WHERE	Done = 0;

	IF	@@ROWCOUNT = 0
		BREAK;

	SELECT	@Execute = REPLACE(@Query, N'~~Server~~', @KBT);

	INSERT INTO	#ResultKBT (ID, ServerName, LinkedServer, Provider, DataSource, Linked, DataAccess, RPC, RPCOut, RemoteTransPromote, ConnectTimeout, QueryTimeout, DefaultLogin)
	EXECUTE	sys.sp_executesql @Execute, @Param, @LinkedServerQuery, @LinkedServerParam, @ID;

	RAISERROR('Done %-15s - %4d rows', 0, 0, @KBT, @@ROWCOUNT) WITH NOWAIT;


	SELECT	@Execute = REPLACE(@Query, N'~~Server~~', @MNL);

	INSERT INTO	#ResultMNL (ID, ServerName, LinkedServer, Provider, DataSource, Linked, DataAccess, RPC, RPCOut, RemoteTransPromote, ConnectTimeout, QueryTimeout, DefaultLogin)
	EXECUTE	sys.sp_executesql @Execute, @Param, @LinkedServerQuery, @LinkedServerParam, @ID;

	RAISERROR('Done %-15s - %4d rows', 0, 0, @MNL, @@ROWCOUNT) WITH NOWAIT;

END;

SELECT	kbt.ID
	,	kbt.ServerName, kbt.LinkedServer, kbt.Provider, kbt.DataSource, kbt.DefaultLogin, kbt.ConnectTimeout, kbt.QueryTimeout
	,	[||] = '||'
	,	mnl.ServerName, mnl.LinkedServer, mnl.Provider, mnl.DataSource, mnl.DefaultLogin, mnl.ConnectTimeout, mnl.QueryTimeout
	,	[Linked] = CAST(kbt.Linked AS CHAR(1)) + CAST(mnl.Linked AS CHAR(1))
	,	[DataAccess] = CAST(kbt.DataAccess AS CHAR(1)) + CAST(mnl.DataAccess AS CHAR(1))
	,	[RPC] = CAST(kbt.RPC AS CHAR(1)) + CAST(mnl.RPC AS CHAR(1))
	,	[RPCOut] = CAST(kbt.RPCOut AS CHAR(1)) + CAST(mnl.RPCOut AS CHAR(1))
	,	[RemoteTransPromote] = CAST(kbt.RemoteTransPromote AS CHAR(1)) + CAST(mnl.RemoteTransPromote AS CHAR(1))
FROM			#ResultKBT AS kbt WITH (NOLOCK)
FULL OUTER JOIN	#ResultMNL AS mnl WITH (NOLOCK)
			ON	kbt.ID = mnl.ID
			AND	kbt.LinkedServer = mnl.LinkedServer
ORDER BY ISNULL(kbt.ID, mnl.ID), ISNULL(kbt.LinkedServer, mnl.LinkedServer)