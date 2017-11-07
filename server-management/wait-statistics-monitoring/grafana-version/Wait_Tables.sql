USE StarixDB;
GO

CREATE TABLE	dbo.vnDBA_Wait_Captured (
					ServerName				NVARCHAR(128)	NOT NULL
				,	CalculateDate			DATETIME		NOT NULL
				,	Calc_msTicks			BIGINT			NOT NULL
				,	WaitType				NVARCHAR(60)	NOT NULL
				,	CalcWaitingTasksCount	BIGINT			NOT NULL
				,	CalcWaitTime_ms			BIGINT			NOT NULL
				,	CalcSignalWaitTime_ms	BIGINT			NOT NULL
				,	CONSTRAINT	PK_vnDBA_Wait_Captured PRIMARY KEY CLUSTERED (
									ServerName		ASC
								,	WaitType		ASC
								,	CalculateDate	ASC
								) WITH (DATA_COMPRESSION = PAGE) ON WaitStat
				) ON WaitStat;
GO

CREATE TABLE	dbo.vnDBA_Wait_Staging (
					ServerName				NVARCHAR(128)	NOT NULL
				,	CaptureDate				DATETIME		NOT NULL
				,	msTicks					BIGINT			NOT NULL
				,	WaitType				NVARCHAR(60)	NOT NULL
				,	WaitingTasksCount		BIGINT			NOT NULL
				,	WaitTime_ms				BIGINT			NOT NULL
				,	SignalWaitTime_ms		BIGINT			NOT NULL
				,	CONSTRAINT	PK_vnDBA_Wait_Staging PRIMARY KEY CLUSTERED (
									ServerName		ASC
								,	WaitType		ASC
								) ON WaitStat
				) ON WaitStat;
GO

CREATE TABLE	dbo.vnDBA_Wait_Metadata (
					WaitType				NVARCHAR(60)	NOT NULL
				,	Category				NVARCHAR(60)	NOT NULL
				,	Ignorable				BIT				NOT NULL
				,	Report					NVARCHAR(60)	NULL
				,	CONSTRAINT	PK_vnDBA_Wait_Metadata PRIMARY KEY CLUSTERED (
									Ignorable		ASC
								,	WaitType		ASC
								) ON WaitStat
				) ON WaitStat;
GO

CREATE TABLE	dbo.vnDBA_Wait_Servers (
					ServerName				NVARCHAR(128)	NOT NULL
				,	isMonitored				BIT				NOT NULL
				,	CONSTRAINT	PK_vnDBA_Wait_Servers PRIMARY KEY CLUSTERED (
									ServerName		ASC
								) ON WaitStat
				) ON WaitStat;
GO