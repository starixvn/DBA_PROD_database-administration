USE	bodb02;
GO
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
ALTER PROCEDURE	dbo.Task_Sync_GetData_mnl
						@SessionId		UNIQUEIDENTIFIER
					,	@DstServer		NVARCHAR(128)
					,	@Table			NVARCHAR(128)
					,	@WinLostDate	SMALLDATETIME
					,	@Key01			SQL_VARIANT
					,	@Key02			SQL_VARIANT
					,	@Key03			SQL_VARIANT
					,	@SyncStatus		TINYINT			= 2
AS
/*
	Creator:	20190510@Billy
	Task:		Description - [Redmine: #000000]
	Database:	bodb02

	Revisions:
		- 20190510@Billy:	Initial - [Redmine: #000000]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@Query			NVARCHAR(MAX)
		,	@Param			NVARCHAR(MAX)
		,	@Execute		NVARCHAR(MAX)
		,	@DataQuery		NVARCHAR(MAX)
		,	@DataParam		NVARCHAR(MAX)
		;

	SELECT	@DataQuery = N''
		,	@DataParam = N''
		,	@Query = N''
		,	@Param = N''
		;
	IF	@Table = N'bettrans14'
	BEGIN;
		SELECT	@DataQuery = @DataQuery + N'
SELECT	[TransId]	= CONVERT(BIGINT, Key01)
FROM	dbo.Task_Sync_ChecksumResult_mnl WITH (NOLOCK)
WHERE	SessionId = @SessionId
	AND	TableName = @Table
	AND	WinLostDate = ISNULL(@WinLostDate, WinLostDate)
	AND	(Key01 IS NULL OR Key01 = ISNULL(@Key01, Key01))
	AND	(Key02 IS NULL OR Key02 = ISNULL(@Key02, Key02))
	AND	(Key03 IS NULL OR Key03 = ISNULL(@Key03, Key03))
	AND	SyncStatus = ISNULL(@SyncStatus, 2);
'
			,	@DataParam = @DataParam + N'@SessionId UNIQUEIDENTIFIER, @Table NVARCHAR(128), @WinLostDate SMALLDATETIME, @Key01 SQL_VARIANT, @Key02 SQL_VARIANT, @Key03 SQL_VARIANT, @SyncStatus TINYINT'
			;
		SELECT	@Query = @Query + N'
DECLARE	@TransList AS TABLE (
			TransId		BIGINT
		,	PRIMARY KEY CLUSTERED (TransId)
		);

INSERT INTO @TransList (TransId)
EXECUTE	[~~Server~~].bodb02.sys.sp_executesql @Query, @Param, @SessionId, @Table, @WinLostDate, @Key01, @Key02, @Key03, @SyncStatus;

SELECT	~~b.Columns~~
FROM		dbo.bettrans14 AS b WITH (NOLOCK)
INNER JOIN	@TransList AS tl
		ON	b.transid = tl.TransId;
'
			,	@Param = @Param + N'@Query NVARCHAR(MAX), @Param NVARCHAR(MAX), ' + @DataParam
			;

		SELECT	@Execute = REPLACE(REPLACE(@Query, N'~~Server~~', @DstServer), N'~~b.Columns~~', dbo.f_GetColumnList_mnl(@Table, 'SELECT', 'b'));
		EXECUTE sys.sp_executesql @Execute, @Param, @DataQuery, @DataParam, @SessionId, @Table, @WinLostDate, @Key01, @Key02, @Key03, @SyncStatus;
	END;
END;
GO