SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
ALTER PROCEDURE	dbo.DBA_Skype_Notify_Ack
						@notiList			SQL_VARIANT
AS
/*
	Creator:	20180906@Billy
	Task:		Skype Notification - Update messages' status - [Redmine: #101021]
	Database:	DBMON.MonDBDW
	
	Revisions:
		- 20170207@Billy:	Initialization - [Redmine: #101021]

	Parameters:
		@minute			: We will get the message from this amount of minutes in the past to the current time
		@type			: The message type that we will get (NULL values means get all of the types)
*/
BEGIN
	SET NOCOUNT ON;
	
	-- Declare variables & temporary schemas --
	DECLARE	@notis			VARCHAR(MAX)
		;

	DECLARE	@Notifications	AS TABLE (
								NotificationId		INT
							);

	SELECT	@notis		= CONVERT(VARCHAR(MAX), @notiList);

	-- Get the time of @minute ago --
	WITH cte AS (
		SELECT	[start]		= CAST(1 AS INT)
			,	[finish]	= CASE WHEN CHARINDEX(',', @notis, 1) = 0 THEN LEN(@notis) + 1 ELSE CHARINDEX(',', @notis, 1) END
		UNION ALL
		SELECT	[start]		= CAST(cte.finish + 1 AS INT)
			,	[finish]	= CASE WHEN CHARINDEX(',', @notis, cte.finish + 1) = 0 THEN LEN(@notis) + 1 ELSE CHARINDEX(',', @notis, cte.finish + 1) END
		FROM	cte
		WHERE	cte.finish < LEN(@notis)
	)
	INSERT INTO	@Notifications (NotificationId)
	SELECT	n.NotificationId
	FROM		cte
	CROSS APPLY	(
		SELECT	[NotificationId]	= LTRIM(RTRIM(SUBSTRING(@notis, cte.start, cte.finish - cte.start)))
	) AS n
	OPTION (MAXRECURSION 0);

	-- Update notifications' status --
	UPDATE	sn WITH (ROWLOCK)
	SET		sn.isNoticed = 1
	FROM		dbo.DBA_SkypeNotifications AS sn
	INNER JOIN	@Notifications AS n
			ON	sn.NotificationId = n.NotificationId
	WHERE	sn.isNoticed = 0									-- Update only unnotified messages;
END;
GO
/*<info serverAlias="DBMON-MonDBDW" executers="DBA_Letstalk,MonDB_User" viewers="" isFunction="0" isNested="0"></info>*/