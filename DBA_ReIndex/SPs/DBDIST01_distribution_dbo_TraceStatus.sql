CREATE PROCEDURE [dbo].[TraceStatus]
	@tracer_id int
	,@isDelay bit OUTPUT
	,@committime datetime = NULL OUTPUT
	,@ServerName varchar(100) = ''
AS
/*
	Created:	20100711@Joe
	Task:		20100711 - rewrite code to support both check for Publisher and Subscriber
	DB:			DBTXN.MonDB

	Revisions:
	-- 20100711@Joe :: rewrite code to support both check for Publisher and Subscriber
	-- @isDelay = 1, TracerToken not reach distributor yet
	-- @isDelay = 0
*/
BEGIN

	IF @ServerName = '' -- called as publisher, trace for Publisher -> Distributor (LogReader)
	BEGIN
		SELECT 
			@isDelay = CASE
				WHEN publisher_commit   IS NULL THEN 1
				WHEN distributor_commit IS NULL THEN 1
				ELSE 0 END
			,@committime = distributor_commit
		FROM
			distribution.dbo.MStracer_tokens WITH (NOLOCK)
		WHERE
			tracer_id = @tracer_id

		IF @@ROWCOUNT = 0 SET @isDelay = 1
	END
	ELSE IF @ServerName = 'GETTIME'
	BEGIN
		SET @committime = SYSDATETIME()
	END
	ELSE -- called as subscriber, trace for Publisher -> Distributor -> Subscriber 
	BEGIN
		SELECT
			@isDelay = CASE WHEN subscriber_commit IS NULL THEN 1 ELSE 0 END
			,@committime = subscriber_commit
		FROM distribution.dbo.MStracer_history t WITH (NOLOCK)
			inner join distribution.dbo.MSdistribution_agents a WITH (NOLOCK) on t.agent_id = a.id
			inner join master.dbo.sysservers s WITH (NOLOCK) on s.srvid = a.subscriber_id 
		WHERE parent_tracer_id = @tracer_id
			AND a.name LIKE ('%-' + @ServerName + '-%')

		IF @@ROWCOUNT = 0 SELECT @isDelay = 1
	END
END
GO
GRANT EXECUTE ON TraceStatus TO SQLLink
GO