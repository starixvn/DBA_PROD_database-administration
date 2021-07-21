/*<info serverAlias="DBTXN-bodb02" executers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[DBA_ReIndex_GetList]
	@FragmentThreshold smallmoney = 30,
	@TargetThreshold smallmoney = 15,
	@Debug bit = 0
AS
/*
	Created:	20180629@Joe
	Task:		20180629 - Generate list of SP to ReIndex
	DB:			DBTXN.bodb02
	
	Revisions:
	- 20180629@Joe : create new Index Reorganized concept
					Generate list of SP to ReIndex
					ReIndex will perform by DBA_ReIndex_ProcessOne
					and terminate by  DBA_ReIndex_Terminate
	- 20210710@Joe : dm_db_index_physical_stats into temp table, seem faster this way
				   condition to included index fragment between @TargetThreshold and @FragmentThreshold, if task less than 100
	- 20210719@Bobby : re-format coding and logging enhancement
*/
BEGIN

	DECLARE @time_trace datetime

	IF NOT EXISTS (SELECT * FROM bodb02.dbo.SystemSettings WHERE VName = N'ReIndex_spid')     INSERT INTO bodb02.dbo.SystemSettings (VName, VValue) VALUES ('ReIndex_spid',0)
	IF NOT EXISTS (SELECT * FROM bodb02.dbo.SystemSettings WHERE VName = N'ReIndex_rn')       INSERT INTO bodb02.dbo.SystemSettings (VName, VValue) VALUES ('ReIndex_rn'  ,0)
	--IF NOT EXISTS (SELECT * FROM bodb02.dbo.SystemSettings WHERE VName = N'ReIndex_Status')   INSERT INTO bodb02.dbo.SystemSettings (VName, VValue) VALUES ('ReIndex_Status','')
	IF NOT EXISTS (SELECT * FROM bodb02.dbo.SystemSettings WHERE VName = N'ReIndex_Fragment') INSERT INTO bodb02.dbo.SystemSettings (VName, VValue) VALUES ('ReIndex_Fragment','')
	IF NOT EXISTS (SELECT * FROM bodb02.dbo.SystemSettings WHERE VName = N'ReIndex_RunSince') INSERT INTO bodb02.dbo.SystemSettings (VName, VValue) VALUES ('ReIndex_RunSince',CONVERT(nvarchar(16),CURRENT_TIMESTAMP, 120))
	IF NOT EXISTS (SELECT * FROM bodb02.dbo.SystemSettings WHERE VName = N'ReIndex_Debug') INSERT INTO bodb02.dbo.SystemSettings (VName, VValue) VALUES ('ReIndex_Debug','')

	SELECT @Debug = ISNULL(@Debug,0)
		,@time_trace = CURRENT_TIMESTAMP;


	UPDATE bodb02.dbo.SystemSettings SET VValue = 0 WHERE VName = N'ReIndex_spid'
	UPDATE bodb02.dbo.SystemSettings SET VValue = CONVERT(nvarchar(16),CURRENT_TIMESTAMP, 120) WHERE VName = N'ReIndex_RunSince'
	UPDATE bodb02.dbo.SystemSettings SET VValue = @Debug WHERE VName = N'ReIndex_Debug'

	DELETE r
	FROM MonDB.dbo.DBA_ReIndex_Record AS r
	WHERE id_db = DB_ID()


	SELECT * 
		INTO #fi 
		FROM  sys.dm_db_index_physical_stats(DB_ID(), null, NULL, NULL, 'LIMITED')

	DECLARE @tmp TABLE (
		[time_trace] [datetime] NULL,
		[id_db] [bigint] NULL,
		[id_table] [bigint] NULL,
		[id_index] [bigint] NULL,
		[name_table] [varchar](500) NULL,
		[name_index] [varchar](500) NULL,
		[index_type] [char](1) NULL,
		[RunCounter] [int] NULL,
		[TimeStart] [datetime2](6) NULL,
		[command] [nvarchar](1000) NULL,
		[FragmentTarget] [smallmoney] NULL,
		[page_count] [bigint] NULL,
		[Fragment] [smallmoney],
		[Debug] [bit] NULL
		)

	INSERT INTO @tmp (time_trace, Debug, id_db, id_table, id_index, name_table, name_index, index_type, command, FragmentTarget, page_count, Fragment)
	SELECT @time_trace,@Debug,
	--fi.avg_fragmentation_in_percent AS [AverageFragmentation],'ALTER INDEX [' + i.name + '] ON [' + sch.name + '].[' + tbl.name + '] REORGANIZE', 
	--CASE WHEN fi.avg_fragmentation_in_percent > 20 THEN 'NEED' ELSE '' END Cond,
	--tbl.object_id,
	--tbl.name,
	--i.*
		DB_ID() id_db, tbl.object_id id_table, i.index_id id_index, 
		tbl.name name_table, i.name name_index, CASE i.type_desc WHEN 'CLUSTERED' THEN 'C' ELSE '' END index_type, 
		'ALTER INDEX [' + i.name + '] ON [' + sch.name + '].[' + tbl.name + '] REORGANIZE ' command, --WITH ( LOB_COMPACTION = ON )'
		@TargetThreshold AS FragmentTarget,
		page_count,
		fi.avg_fragmentation_in_percent AS Fragment
	FROM
	sys.tables AS tbl
	INNER JOIN sys.schemas sch ON tbl.schema_id = sch.schema_id
	INNER JOIN sys.indexes AS i ON (i.index_id > 0 and i.is_hypothetical = 0) AND (i.object_id=tbl.object_id)
	--INNER JOIN sys.dm_db_index_physical_stats(DB_ID(), null, NULL, NULL, 'LIMITED') AS fi 
	INNER JOIN #fi fi ON fi.object_id=i.object_id AND fi.index_id=i.index_id
	WHERE
		tbl.name NOT LIKE 'BalanceRecord%'
		-- if it's Friday VN/TW Time, we will skip "14" tables and related table, due to today got "Friday routine"
		AND CASE 
		WHEN DATEPART(WEEKDAY, DATEADD(hour, 11, CURRENT_TIMESTAMP)) = 6 AND 
			(tbl.name LIKE '%14' 
			OR tbl.name IN ('bettranssum','sum_winloss','Intg_GameRoundBetStake','MarkedTransaction','zzzbettrans','zzzbettransm') 
			OR tbl.name LIKE 'TicketVoiding%'
			) THEN 0 
		ELSE 1 END = 1
		--AND fi.avg_fragmentation_in_percent > @FragmentThreshold
	/*
	ORDER BY 
		CASE WHEN tbl.name = 'bettrans' AND i.type_desc = 'CLUSTERED' THEN 1 ELSE 0 END,
		CASE i.type_desc WHEN 'CLUSTERED' THEN 'C' ELSE '' END DESC, 
		page_count DESC
	*/
	DECLARE @cnt INT

	SELECT @CNT = COUNT(*)
	FROM @tmp
		WHERE
			Fragment > @FragmentThreshold AND page_count > 3

	IF @CNT >= 100
		INSERT INTO MonDB.dbo.DBA_ReIndex_Record (time_trace, Debug, id_db, id_table, id_index, name_table, name_index, index_type, command, FragmentTarget, page_count, Fragment)
		SELECT time_trace, Debug, id_db, id_table, id_index, name_table, name_index, index_type, command, FragmentTarget, page_count, Fragment
		FROM @tmp
		WHERE
			Fragment > @FragmentThreshold AND page_count > 3
		ORDER BY
			CASE WHEN name_table = 'bettrans' AND index_type = 'C' THEN 1 ELSE 0 END, -- CIX bettrans, be last in high fragment
			index_type DESC, -- clustered index first, for high fragement
			CAST(Fragment * 100 AS bigint) * page_count DESC -- high value of Fragment x page next.
	ELSE
	BEGIN
		-- this will let ReIndex got more work in this round
		-- which help it got less work to do in next round
		-- because some 'incoming work' was bring to handle already.
		INSERT INTO MonDB.dbo.DBA_ReIndex_Record (time_trace, Debug, id_db, id_table, id_index, name_table, name_index, index_type, command, FragmentTarget, page_count, Fragment)
		SELECT TOP(100) time_trace, Debug, id_db, id_table, id_index, name_table, name_index, index_type, command, FragmentTarget, page_count, Fragment
		FROM @tmp
		WHERE
			(Fragment - @TargetThreshold) > 3 AND page_count > 3
		ORDER BY 
			CASE WHEN Fragment > @FragmentThreshold THEN 0 ELSE 1 END, -- high fragment first
			CASE WHEN name_table = 'bettrans' AND index_type = 'C' THEN 1 ELSE 0 END, -- CIX bettrans, be last in high fragment
			index_type DESC, -- clustered index first, for high fragement
			CAST(Fragment * 100 AS bigint) * page_count DESC -- high value of Fragment x page next.

	END

	IF @@SERVERNAME NOT IN ('DBTRANS', 'DB206')
		DELETE r
		FROM MonDB.dbo.DBA_ReIndex_Record AS r
		WHERE name_table = 'bettrans' AND index_type = 'C'

END
GO


