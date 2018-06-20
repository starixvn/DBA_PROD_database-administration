ALTER PROCEDURE	dbo.Task_CollectTranscount
AS
/*
	Creator:	20180619@Billy
	Task:		Description - [Redmine: #00000]
	Database:	DBDWCSS.StarixDB
	
	Revisions:
		- 20180619@Billy:	Initial - [Redmine: #00000]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@fromdate	DATETIME
		;

	DECLARE	@transcount AS TABLE (
				matchid		INT
			,	transdate	DATETIME
			,	transcnt	INT
			);

	SELECT	TOP(1)
			@fromdate	= DATEADD(SECOND, 1, transdate)
	FROM	dbo.transcount WITH (NOLOCK)
	ORDER BY transdate DESC;

	INSERT INTO	@transcount (transdate, matchid, transcnt)
	EXECUTE	DBTPKBT.bodb02.dbo.Task_CaptureTranscount @fromdate;

	MERGE	dbo.transcount AS t
	USING	@transcount AS tp
		ON	t.transdate = tp.transdate
		AND	t.matchid = tp.matchid
	WHEN MATCHED THEN
		UPDATE SET	t.transcnt = t.transcnt + tp.transcnt
	WHEN NOT MATCHED THEN
		INSERT (   transdate,    matchid,    transcnt)
		VALUES (tp.transdate, tp.matchid, tp.transcnt)
	;
END;