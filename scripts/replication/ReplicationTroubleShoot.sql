/*
	Created: 20181231@Helen
	Task: Pontus Scritps - Replication
	DB: Distribution DB
*/
---- #1: list agent not writting log in specfic duration
SELECT *
INTO #TEMP 
FROM(
	SELECT agent_id,xact_seqno,[time], row_number() over(partition by agent_id order by timestamp desc) as row 
	FROM MSdistribution_history t (nolock)
) AS T
WHERE t.row in (1,2)

SELECT t.agent_id
	-- 2 latest times for writting history
	, time1, time2
	, GETDATE() AS currentdate
	, DATEDIFF (MINUTE,time1,GETDATE()) AS NotWriteLog
FROM #TEMP T
	CROSS APPLY (SELECT time time1 FROM #TEMP T1 WHERE T1.agent_id = T.agent_id AND T1.ROW = 1) AS tmp1 
	CROSS APPLY (SELECT time time2 FROM #TEMP T2 WHERE T2.agent_id = T.agent_id AND T2.ROW = 2) AS tmp2 
WHERE DATEDIFF (MINUTE,time1,GETDATE()) > 5 

---- #2: error commands
--EXEC sys.sp_browsereplcmds 'xxx','xxx' 