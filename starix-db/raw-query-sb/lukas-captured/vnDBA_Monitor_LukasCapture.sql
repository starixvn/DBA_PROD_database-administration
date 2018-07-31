USE	StarixDB;
GO

IF	OBJECT_ID('dbo.vnDBA_Monitor_LukasCapture') IS NOT NULL
	--RETURN;
	DROP TABLE	dbo.vnDBA_Monitor_LukasCapture;

CREATE TABLE	dbo.vnDBA_Monitor_LukasCapture (
					servername				NVARCHAR(128)
				,	capturedate				DATETIME
				,	spid					SMALLINT
				,	ecid					SMALLINT
				,	blockedBy				SMALLINT
				,	database_login			VARCHAR(256)
				,	CMD_status				VARCHAR(MAX)
				,	wait					VARCHAR(60)
				,	wait_type				VARCHAR(60)
				,	waitresource			VARCHAR(256)
				,	current_stmt			VARCHAR(MAX)
				,	lastwaittype			VARCHAR(60)
				,	resource_description	VARCHAR(256)
				,	wait_duration_ms		INT
				,	current_batch			VARCHAR(MAX)
				,	reads					BIGINT
				,	logical_reads			BIGINT
				,	cpu						BIGINT
				,	time_elapsed_ms			INT
				,	program					VARCHAR(128)
				,	batch_plan				VARCHAR(MAX)
				);

CREATE CLUSTERED INDEX	CIX_Monitor_LukasCapture ON dbo.vnDBA_Monitor_LukasCapture (
							servername	ASC
						,	capturedate	ASC
						,	spid		ASC
						) WITH (DATA_COMPRESSION = PAGE) ON Monitor;

CREATE NONCLUSTERED INDEX	IX_Monitor_LukasCapture ON dbo.vnDBA_Monitor_LukasCapture (
								capturedate	ASC
							,	servername	ASC
							) WITH (DATA_COMPRESSION = PAGE) ON Monitor;

