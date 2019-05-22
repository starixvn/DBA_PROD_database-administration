
CREATE TABLE	dbo.Task_Sync_ChecksumResult_mnl (
					SessionId			UNIQUEIDENTIFIER
				,	TableName			NVARCHAR(128)
				,	Category			NVARCHAR(128)
				,	WinLostDate			DATETIME
				,	Key01				SQL_VARIANT
				,	Key02				SQL_VARIANT
				,	Key03				SQL_VARIANT
				,	SrcCount			INT
				,	SrcChecksum			INT
				,	SrcBinaryChecksum	INT
				,	DstCount			INT
				,	DstChecksum			INT
				,	DstBinaryChecksum	INT
				,	SyncStatus			TINYINT
						CONSTRAINT DF_Sync_ChecksumResult_SyncStatus_mnl DEFAULT (0)
				);

CREATE CLUSTERED INDEX	CIX_Sync_ChecksumResult ON dbo.Task_Sync_ChecksumResult_mnl (
							SessionId
						,	TableName
						,	WinLostDate
						) WITH (DATA_COMPRESSION = PAGE) ON DATA;

CREATE NONCLUSTERED INDEX	IX_Sync_ChecksumResult_Status ON dbo.Task_Sync_ChecksumResult_mnl (
								SyncStatus
							,	SessionId
							,	TableName
							)
							INCLUDE (Category, Key01, Key02, Key03)
							WITH (DATA_COMPRESSION = PAGE) ON DATA;


--CREATE TABLE	dbo.Task_Sync_SynchronizeList_mnl (
--					SessionId			UNIQUEIDENTIFIER
--				,	TableName			NVARCHAR(128)
--				,	WinLostDate			DATETIME
--				,	Key01				SQL_VARIANT
--				,	Key02				SQL_VARIANT
--				,	Key03				SQL_VARIANT
--				,	SrcChecksum			INT
--				,	SrcBinaryChecksum	INT
--				,	DstChecksum			INT
--				,	DstBinaryChecksum	INT
--				);

--CREATE CLUSTERED INDEX	CIX_Sync_SynchronizeList ON dbo.Task_Sync_SynchronizeList_mnl (
--							SessionId
--						,	TableName
--						,	WinLostDate
--						) WITH (DATA_COMPRESSION = PAGE) ON DATA;