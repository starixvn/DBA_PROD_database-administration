SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE TRIGGER	plo.Trg_AfterUpdate_APIPushingPlayerRate ON plo.APIPushingPlayerRate
AFTER UPDATE
AS
/*
	Creator:	20191219@Billy
	Task:		Insert history for updated API pusing player report - [Redmine: #125807]
	Database:	DBSTARIX.StarixDB

	Revisions:
		- 20191219@Billy:	Initial - [Redmine: #125807]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET NOCOUNT ON;

	INSERT INTO	plo.APIPushingPlayerRate_History
		(	BrandCode, SecondStamp, PlayerCount)
	SELECT	BrandCode, SecondStamp, PlayerCount
	FROM	deleted;
END;
GO