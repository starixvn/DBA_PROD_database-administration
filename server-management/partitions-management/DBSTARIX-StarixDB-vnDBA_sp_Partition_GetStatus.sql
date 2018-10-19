SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.vnDBA_sp_Partition_GetStatus
						@ServerName			NVARCHAR(128)	= NULL
					,	@DatabaseName		NVARCHAR(128)	= NULL
					,	@TableName			NVARCHAR(128)	= NULL
					,	@PartitionScheme	NVARCHAR(128)	= NULL
					,	@PartitionFunction	NVARCHAR(128)	= NULL
					,	@Like				BIT				= 1
AS
/*
	Creator:	20181019@Billy
	Task:		Get partitions status of all servers - [Redmine: #103503]
	Database:	DBSTARIX.StarixDB
	
	Revisions:
		- 20181019@Billy:	Initial - [Redmine: #103503]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@LikeCharacter	NCHAR(1);

	SELECT	@LikeCharacter		= CASE @Like WHEN 1 THEN N'%' ELSE N'' END
		,	@ServerName			= NULLIF(@ServerName, N'')
		,	@DatabaseName		= NULLIF(@DatabaseName, N'')
		,	@TableName			= NULLIF(@TableName, N'')
		,	@PartitionScheme	= ISNULL(@PartitionScheme, N'')
		,	@PartitionFunction	= ISNULL(@PartitionFunction, N'')
		;

	SELECT	ServerName, DatabaseName, TableName, PartitionScheme, PartitionFunction, Interval, Target, MaxValue
	FROM	dbo.vnDBA_Partition_Status WITH (NOLOCK)
	WHERE	ServerName = ISNULL(@ServerName, ServerName)
		AND	DatabaseName = ISNULL(@DatabaseName, DatabaseName)
		AND	TableName = ISNULL(@TableName, TableName)
		AND	PartitionScheme LIKE @LikeCharacter + @PartitionScheme + @LikeCharacter
		AND	PartitionFunction LIKE @LikeCharacter + @PartitionFunction + @LikeCharacter
	ORDER BY ServerName, DatabaseName, TableName;
END;
GO
GRANT EXECUTE ON dbo.vnDBA_sp_Partition_GetStatus TO vnGrafana AS dbo;
GO
/*<info serverAlias="DBSTARIX-StarixDB" executers="vnGrafana" viewers="" isFunction="0" isNested="0"></info>*/