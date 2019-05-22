USE	bodb02;
GO
ALTER PROCEDURE	dbo.Acc_ExecRep_04
						@SessionId		UNIQUEIDENTIFIER
					,	@Server			NVARCHAR(128)		= NULL
					,	@Table			NVARCHAR(128)		= NULL
AS
/*
	Creator:	20190521@Billy
	Task:		Description - [Redmine: #000000]
	Database:	bodb02

	Revisions:
		- 20190521@Billy:	Initial - [Redmine: #000000]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET NOCOUNT ON;

	--	BEGIN STEP:
	--		Verification
	----------------------------------------------------------------------------------------------------
	IF	OBJECT_ID('dbo.Task_Sync_ChecksumResult_mnl') IS NULL
	OR	OBJECT_ID('dbo.f_GetColumnList_mnl') IS NULL
	BEGIN;
		RAISERROR('The objects required to run are missing. Abort.', 0, 0) WITH NOWAIT;
		RETURN -1;
	END;

	IF	ISNULL(@Server, @@SERVERNAME) <> @@SERVERNAME
	BEGIN;
		RAISERROR('This command cannot run on this server. Abort.', 0, 0) WITH NOWAIT;
		RETURN -2;
	END;

	DECLARE	@Query		NVARCHAR(MAX)
		,	@Param		NVARCHAR(MAX)
		,	@Execute	NVARCHAR(MAX)
		;

	DECLARE	@SrcServer	NVARCHAR(128)
		,	@_Table		NVARCHAR(128)
		;

	SELECT	@SrcServer = CASE	WHEN @@SERVERNAME = N'DBMNL' THEN N'DB061'
								WHEN @@SERVERNAME = N'DBTRANS' THEN N'DBMNL'
								ELSE N'DBTRANS'
						  END;


	--	BEGIN STEP:
	--		bettrans14
	----------------------------------------------------------------------------------------------------
	SELECT	@_Table = N'bettrans14'
	IF	ISNULL(@Table, @_Table) = @_Table
	AND	EXISTS (SELECT 1 FROM dbo.Task_Sync_ChecksumResult_mnl WITH (NOLOCK) WHERE SessionId = @SessionId AND TableName = @_Table)
	BEGIN;
		SELECT	@Query = N'';
		SELECT	@Query = @Query + N'
DECLARE	@Rowcount	INT
	;

DECLARE	@Trans AS TABLE (
			transid		BIGINT
		,	PRIMARY KEY CLUSTERED (transid ASC)
		);

WHILE	0 = 0
BEGIN;
	DELETE	@Trans;
	
	UPDATE	TOP(1000)
			l WITH (ROWLOCK)
	SET		SyncStatus = 2
	OUTPUT	CONVERT(BIGINT, inserted.Key01)
	INTO	@Trans
	FROM	dbo.Task_Sync_ChecksumResult_mnl AS l
	WHERE	l.SessionId = @SessionId
		AND	l.TableName = @Table
		AND	l.SyncStatus = 0;

	DELETE	b WITH (ROWLOCK)
	FROM		dbo.bettrans14 AS b
	INNER JOIN	@Trans AS tmp
			ON	tmp.transid = b.transid;

	INSERT INTO	dbo.bettrans14 (~~Columns~~)
	EXECUTE	[~~Server~~].bodb02.dbo.Task_Sync_GetData_mnl @SessionId, @DstServer, @Table, NULL, NULL, NULL, NULL, 2;

	UPDATE	l WITH (ROWLOCK)
	SET		SyncStatus = 1
	FROM		dbo.Task_Sync_ChecksumResult_mnl AS l
	INNER JOIN	@Trans AS tmp
			ON	tmp.transid = CONVERT(BIGINT, l.Key01)
	WHERE	l.SessionId = @SessionId
		AND	l.TableName = @Table
		AND	l.SyncStatus = 2;

	SELECT	@Rowcount	= COUNT(1)
	FROM	dbo.Task_Sync_ChecksumResult_mnl AS l WITH (NOLOCK)
	WHERE	l.SessionId = @SessionId
		AND	l.TableName = @Table
		AND	l.SyncStatus = 0;

	RAISERROR(''	$ %7d rows left of [%14s]'', 0, 0, @Rowcount, @Table) WITH NOWAIT;

	IF	@Rowcount = 0
		BREAK;
END;

';

		SELECT	@Param = N'';
		SELECT	@Param = @Param + N'@SessionId UNIQUEIDENTIFIER, @DstServer NVARCHAR(128), @Table NVARCHAR(128)';

		SELECT	@Execute = REPLACE(REPLACE(@Query, N'~~Columns~~', dbo.f_GetColumnList_mnl(@_Table, 'SELECT', NULL)), N'~~Server~~', @SrcServer);

		EXECUTE	sys.sp_executesql @Execute, @Param, @SessionId, @@SERVERNAME, @_Table;
	END;
END;