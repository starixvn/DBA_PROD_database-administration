SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.vnDBA_sp_Partition_UpdateStatus
AS
/*
	Creator:	20181019@Billy
	Task:		Update partitions status of all servers - [Redmine: #103503]
	Database:	DBSTARIX.StarixDB
	
	Revisions:
		- 20181019@Billy:	Initial - [Redmine: #103503]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@InnerQuery		NVARCHAR(MAX)
		,	@InnerExecute	NVARCHAR(MAX)
		,	@OuterQuery		NVARCHAR(MAX)
		,	@OuterExecute	NVARCHAR(MAX)
		,	@Server			NVARCHAR(128)
		;

	DECLARE	@Servers	AS TABLE (
							ServerName		NVARCHAR(128)
						,	Done			BIT
						,	PRIMARY KEY CLUSTERED (Done, ServerName)
						);
						
	CREATE TABLE	#result (
						ServerName			NVARCHAR(128)
					,	DatabaseName		NVARCHAR(128)
					,	TableName			NVARCHAR(128)
					,	PartitionScheme		NVARCHAR(128)
					,	PartitionFunction	NVARCHAR(128)
					,	Interval			NVARCHAR(50)
					,	Target				SQL_VARIANT
					,	MaxValue			SQL_VARIANT
					);

	INSERT INTO	@Servers (ServerName, Done)
	SELECT	srv.ServerName, 0
	FROM	dbo.vnDBA_Wait_Servers AS srv WITH (NOLOCK)
	WHERE	srv.isMonitored = 1
		AND	ISNULL(srv.Category, N'') <> 'Distributor';

	SELECT	@InnerExecute = N'';
	SELECT	@InnerExecute = @InnerExecute + N'
USE [?];

INSERT INTO	#result (ServerName, DatabaseName, TableName, PartitionScheme, PartitionFunction, Interval, Target, MaxValue)
SELECT	DISTINCT
	@@SERVERNAME
,	DB_NAME()
,	t.name
,	ps.name
,	pf.name
,
CASE
	WHEN s.step BETWEEN 0.9 AND 1.1		THEN ''Daily''
	WHEN s.step BETWEEN 6.9 AND 7.1		THEN ''Weekly''
	WHEN s.step BETWEEN 28.0 AND 31.0	THEN ''Monthly''
	WHEN s.step BETWEEN 90.0 AND 92.0	THEN ''Quarterly''
	WHEN s.step BETWEEN 181.0 AND 184.0	THEN ''Half-yearly''
	WHEN s.step BETWEEN 365.0 AND 366.0	THEN ''Yearly''
	ELSE CAST(s.step AS VARCHAR)
END
,	s.target
,	s.maxvalue
FROM		sys.partition_schemes AS ps WITH (NOLOCK)
INNER JOIN	sys.partition_functions AS pf WITH (NOLOCK)
		ON	ps.function_id = pf.function_id
INNER JOIN	sys.indexes AS i WITH (NOLOCK)
		ON	i.data_space_id = ps.data_space_id
INNER JOIN	sys.tables AS t WITH (NOLOCK)
		ON	t.object_id = i.object_id
CROSS APPLY	(
	SELECT	AVG(CONVERT(DECIMAL(38,24), upp.value) - CONVERT(DECIMAL(38,24), low.value))
		,	MAX(upp.target)
		,	MAX(upp.value)
	FROM		(
		SELECT	TOP 99999999
				value = CASE WHEN d.t LIKE ''%DATE%'' THEN CONVERT(DATETIME, prv.value) ELSE prv.value END
			,	target = CASE WHEN d.t LIKE ''%DATE%'' THEN YEAR(CONVERT(DATETIME, prv.value)) ELSE prv.value END
			,	boundary_id = ROW_NUMBER() OVER(ORDER BY prv.value ASC)
		FROM	sys.partition_range_values AS prv WITH (NOLOCK)
		CROSS APPLY (SELECT CAST(SQL_VARIANT_PROPERTY(prv.value, ''BaseType'') AS VARCHAR)) d(t)
		WHERE	prv.function_id = ps.function_id
	) upp
	INNER JOIN	(
		SELECT	TOP 99999999
				value = CASE WHEN CAST(SQL_VARIANT_PROPERTY(prv.value, ''BaseType'') AS VARCHAR) LIKE ''%DATE%'' THEN CONVERT(DATETIME, prv.value) ELSE prv.value END
			,	boundary_id = ROW_NUMBER() OVER(ORDER BY prv.value ASC)
		FROM	sys.partition_range_values AS prv WITH (NOLOCK)
		WHERE	prv.function_id = ps.function_id
	) low
			ON	low.boundary_id = upp.boundary_id - 1
) s(step, target, maxvalue);
';
	
	SELECT	@InnerQuery = N'';
	SELECT	@InnerQuery = @InnerQuery + N'
CREATE TABLE	#result (
					ServerName			NVARCHAR(128)
				,	DatabaseName		NVARCHAR(128)
				,	TableName			NVARCHAR(128)
				,	PartitionScheme		NVARCHAR(128)
				,	PartitionFunction	NVARCHAR(128)
				,	Interval			NVARCHAR(50)
				,	Target				SQL_VARIANT
				,	MaxValue			SQL_VARIANT
				);

EXECUTE	sys.sp_MSforeachdb @Query;

SELECT	ServerName, DatabaseName, TableName, PartitionScheme, PartitionFunction, Interval, Target, MaxValue
FROM	#result WITH (NOLOCK);
;';

	SELECT	@OuterQuery = N'';
	SELECT	@OuterQuery = @OuterQuery + N'
EXECUTE	~Server~KBT.master.sys.sp_executesql @Query, N''@Query NVARCHAR(MAX)'', @Execute;
';

	WHILE	0 = 0
	BEGIN;
		UPDATE	TOP(1)
				@Servers
		SET		@Server = ServerName
			,	Done = 1
		WHERE	Done = 0;

		IF	@@ROWCOUNT = 0
			BREAK;

		SELECT	@OuterExecute = REPLACE(@OuterQuery, N'~Server~', REPLACE(@Server, N'\', N'_'));

		INSERT INTO	#result (ServerName, DatabaseName, TableName, PartitionScheme, PartitionFunction, Interval, Target, MaxValue)
		EXECUTE	sys.sp_executesql @OuterExecute, N'@Query NVARCHAR(MAX), @Execute NVARCHAR(MAX)', @InnerQuery, @InnerExecute;

		RAISERROR('Done %s.', 0, 0, @Server) WITH NOWAIT;
	END;

	BEGIN TRANSACTION;
	TRUNCATE TABLE	dbo.vnDBA_Partition_Status;
	INSERT INTO	dbo.vnDBA_Partition_Status
		(	ServerName, DatabaseName, TableName, PartitionScheme, PartitionFunction, Interval, Target, MaxValue)
	SELECT	ServerName, DatabaseName, TableName, PartitionScheme, PartitionFunction, Interval, Target, MaxValue
	FROM	#result WITH (NOLOCK);
	COMMIT;
END;
GO
/*<info serverAlias="DBSTARIX-StarixDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/