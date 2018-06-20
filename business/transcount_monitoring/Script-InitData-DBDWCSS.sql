MERGE	dbo.match AS m
USING	DBTPKBT.bodb02.dbo.match_Billy_test AS tm
	ON	m.matchid = tm.matchid
WHEN MATCHED THEN
	UPDATE SET	m.matchname = tm.matchname
WHEN NOT MATCHED THEN
	INSERT (   matchid,    matchname)
	VALUES (tm.matchid, tm.matchname);

IF OBJECT_ID('tempdb..#temp') IS NOT NULL
	DROP TABLE	#temp;

SELECT	transdate, matchid, transcnt
INTO #temp
FROM	DBTPKBT.bodb02.dbo.transdate_summary_Billy_test



MERGE	dbo.transcount AS t
USING	#temp AS tp
	ON	t.transdate = tp.transdate
	AND	t.matchid = tp.matchid
WHEN MATCHED THEN
	UPDATE SET	t.transcnt = t.transcnt + tp.transcnt
WHEN NOT MATCHED THEN
	INSERT (   transdate,    matchid,    transcnt)
	VALUES (tp.transdate, tp.matchid, tp.transcnt)
;