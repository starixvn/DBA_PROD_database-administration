SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.Grafana_GetMetadata
						@Filter			NVARCHAR(128)		= N'ALL'
AS
/*
	Creator:	20190710@Billy
	Task:		Get metadata for showing on Grafana - [Redmine: #110664]
	Database:	DBNOTI.NotificationDB

	Revisions:
		- 20190710@Billy:	Initial - [Redmine: #110664]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET NOCOUNT ON;

	IF	@Filter = N'ALL'
	BEGIN;
		SELECT	[@ServerName]	= j.ServerName
			,	[@JobId]		= j.JobId
			,	[@JobName]		= j.JobName
			,	[@CaseId]		= j.CaseId
			,	[Letstalk]		= ISNULL(l.RoomName, N'')
			,	[Skype]			= ISNULL(s.SkypeName, N'')
		FROM		dbo.DBA_LetstalkJobs AS j WITH (NOLOCK)
		LEFT JOIN	dbo.DBA_LetstalkRooms AS l WITH (NOLOCK)
				ON	j.RoomId = l.RoomId
				AND	l.isActive = 1
		LEFT JOIN	dbo.DBA_SkypeGroup AS s WITH (NOLOCK)
				ON	j.SkypeGroupId = s.GroupId;

		RETURN;
	END;
END;
GO
/*<info serverAlias="DBNOTI-NotificationDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/