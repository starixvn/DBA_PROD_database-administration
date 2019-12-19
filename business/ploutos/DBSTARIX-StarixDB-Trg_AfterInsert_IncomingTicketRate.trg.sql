SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE TRIGGER	plo.Trg_AfterUpdate_IncomingTicketRate ON plo.IncomingTicketRate
AFTER UPDATE
AS
/*
	Creator:	20191219@Billy
	Task:		Insert history for updated incoming ticket report - [Redmine: #125807]
	Database:	DBSTARIX.StarixDB

	Revisions:
		- 20191219@Billy:	Initial - [Redmine: #125807]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET NOCOUNT ON;

	INSERT INTO	plo.IncomingTicketRate_History
		(	BrandCode, SecondStamp, TicketCount)
	SELECT	BrandCode, SecondStamp, TicketCount
	FROM	deleted;
END;
GO