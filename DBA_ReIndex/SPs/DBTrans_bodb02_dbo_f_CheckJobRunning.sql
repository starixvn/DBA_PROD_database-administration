/*<info serverAlias="DBTXN-bodb02" executers="" isFunction="1" isNested="1"></info>*/
CREATE FUNCTION [dbo].[f_CheckJobRunning] (@JobName NVARCHAR(125))
RETURNS BIT
AS
/*
	Created:	20210708@Joe
	Task:		20210708 - check a job is working or NOT
	DB:			DBTXN.bodb02

	Revisions:
		- 20210708@Joe: check a job is working or NOT
*/

BEGIN
	IF EXISTS (SELECT 1
			FROM msdb.dbo.sysjobs j WITH(NOLOCK) 
				INNER JOIN msdb.dbo.sysjobactivity ja WITH(NOLOCK) ON ja.job_id = j.job_id
				  INNER JOIN msdb.dbo.syssessions s WITH(NOLOCK) ON s.session_id = ja.session_id
				INNER JOIN (
					SELECT MAX(agent_start_date) AS max_agent_start_date
					FROM msdb.dbo.syssessions WITH(NOLOCK)
				) ms ON s.agent_start_date = ms.max_agent_start_date
			WHERE j.name = @JobName
				  AND ja.run_requested_date IS NOT NULL 
				  AND ja.stop_execution_date IS NULL)
		RETURN 1
	RETURN 0
END

GO