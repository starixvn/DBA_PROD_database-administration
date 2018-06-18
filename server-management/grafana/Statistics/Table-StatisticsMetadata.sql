/*
	Creator:	20180618@Billy
	Task:		Statistical Metadata Tables - [Redmine: #96988]
	Server:		StarixDB
*/


--	BEGIN STEP 1:
--		Performance Counter Statistical Metadata
----------------------------------------------------------------------------------------------------

CREATE TABLE	dbo.vnDBA_Statistics_Perf_Metadata_ByHour (
					CounterId		INT
				,	DayHour			TINYINT
				,	n				INT
				,	mean			DECIMAL(38,10)
				,	variance		DECIMAL(38,10)
				) ON DATA;

CREATE CLUSTERED INDEX	CIX_vnDBA_Statistics_Perf_Metadata_ByHour ON dbo.vnDBA_Statistics_Perf_Metadata_ByHour (
							CounterId ASC
						,	DayHour ASC
						) ON DATA;
