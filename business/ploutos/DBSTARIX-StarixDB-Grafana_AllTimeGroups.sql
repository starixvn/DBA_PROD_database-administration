SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	plo.Grafana_AllTimeGroups
AS
/*
	Creator:	20191220@Billy
	Task:		Get all available time groups - [Redmine: #125807]
	Database:	DBSTARIX.StarixDB

	Revisions:
		- 20191220@Billy:	Initial - [Redmine: #125807]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	SELECT	GroupName
	FROM	plo.TimeGroups WITH (NOLOCK)
	ORDER BY SecondGroup ASC
END;
GO
/*<info serverAlias="DBSTARIX-StarixDB" executers="vnGrafana" viewers="" isFunction="0" isNested="0"></info>*/