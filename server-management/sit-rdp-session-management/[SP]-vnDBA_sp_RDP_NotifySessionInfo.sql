USE	MonDB;
GO
ALTER PROCEDURE	dbo.vnDBA_sp_RDP_NotifySessionInfo
AS
/*
	Creator:	20180208@Billy
	Task:		SIT RDP Session Management - Notify Session Info - [Redmine: #90722]
	Database:	DBSPARE.MonDB
	
	Revisions:
		- 20180208@Billy:	Initial - [Redmine: #90722]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@Message		NVARCHAR(MAX)
		,	@MaxTime		DATETIME
		;

	DECLARE	@WorkHourBegin	TINYINT
		,	@WorkHourEnd	TINYINT
		;

	SELECT	@WorkHourBegin	= 8
		,	@WorkHourEnd	= 6
		;

	IF	NOT(DATEPART(HOUR, GETDATE()) BETWEEN 8 AND 18) AND DATEPART(MINUTE, GETDATE()) <> 0 AND DATEPART(HOUR, GETDATE()) % 2 <> 0
	BEGIN;
		RAISERROR('Out of work time, limited notification!', 0, 0) WITH NOWAIT;

		RETURN;
	END;

	SELECT	@MaxTime = CurrentTime
	FROM	OPENQUERY(SITDB06, '
SELECT	TOP(1)
		CurrentTime
FROM	MonDB.dbo.vnDBA_RDP_Sessions WITH (NOLOCK)
WHERE	SessionStatusId BETWEEN 1001 AND 1999
ORDER BY CurrentTime DESC
');
			
	IF	@MaxTime IS NULL
		RETURN;

	SELECT	@Message = N'(shock) [SIT RDP] (shock)
The following users disconnect without log off:
' + ms.str + '
------------------------------------------------------------------------------------------'
	FROM	(
		SELECT	'[' + ServerName + ': ' + CAST(SessionId AS VARCHAR(MAX)) + '] - ' + UserName + ' - ' + ClientName + ' - Disconnected: ' + CAST(DATEDIFF(MINUTE, DisconnectTime, CurrentTime) AS VARCHAR(MAX)) + ' mins
'
		FROM	SITDB06.MonDB.dbo.vnDBA_RDP_Sessions WITH (NOLOCK)
		WHERE	SessionStatusId BETWEEN 1001 AND 1499
			AND	CurrentTime <= @MaxTime
		FOR XML PATH ('')
		,	TYPE
	) AS xm(xml)
	CROSS APPLY (
		SELECT	LEFT(xq.str, LEN(xq.str) - 2)
		FROM	(
			SELECT	xm.xml.value('.[1]', 'NVARCHAR(MAX)')
		) xq(str)
	) AS ms(str);

	IF	ISNULL(@Message, '') <> ''
		EXECUTE DBMONDW.MonDBDW.dbo.DBA_Letstalk_NewJobMessage @ServerName = N'SIT-Env', @JobId = NULL, @JobName = N'vnDBA : SIT RDP Management', @Message = @Message, @CaseId = 1;
	
	SELECT	@Message = N'(shock) [SIT RDP] (shock)
The following users disconnect without log off:
' + ms.str + '
------------------------------------------------------------------------------------------'
	FROM	(
		SELECT	'[' + ServerName + ': ' + CAST(SessionId AS VARCHAR(MAX)) + '] - ' + UserName + ' - ' + ClientName + ' - Disconnected: ' + CAST(DATEDIFF(MINUTE, DisconnectTime, CurrentTime) AS VARCHAR(MAX)) + ' mins
'
		FROM	SITDB06.MonDB.dbo.vnDBA_RDP_Sessions WITH (NOLOCK)
		WHERE	SessionStatusId BETWEEN 1501 AND 1999
			AND	CurrentTime <= @MaxTime
		FOR XML PATH ('')
		,	TYPE
	) AS xm(xml)
	CROSS APPLY (
		SELECT	LEFT(xq.str, LEN(xq.str) - 2)
		FROM	(
			SELECT	xm.xml.value('.[1]', 'NVARCHAR(MAX)')
		) xq(str)
	) AS ms(str);
	
	IF	ISNULL(@Message, '') <> ''
		EXECUTE DBMONDW.MonDBDW.dbo.DBA_Letstalk_NewJobMessage @ServerName = N'BOT', @JobId = NULL, @JobName = N'Bot Message', @Message = @Message, @CaseId = 1;

	EXECUTE	SITDB06.MonDB.dbo.vnDBA_sp_RDP_ResolveInfo @MaxTime;
END;
GO
