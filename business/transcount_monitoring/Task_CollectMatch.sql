ALTER PROCEDURE	dbo.Task_CollectMatch
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

	DECLARE	@match AS TABLE (
				matchid			INT
			,	matchname		NVARCHAR(200)
			);
			
	INSERT INTO	@match (matchid, matchname)
	EXECUTE	DBTPKBT.bodb02.dbo.Task_CaptureMatch;

	MERGE	dbo.match AS m
	USING	@match AS tm
		ON	m.matchid = tm.matchid
	WHEN MATCHED THEN
		UPDATE SET	m.matchname = tm.matchname
	WHEN NOT MATCHED THEN
		INSERT (   matchid,    matchname)
		VALUES (tm.matchid, tm.matchname)
	;
END;