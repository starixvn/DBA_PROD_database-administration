/*
	Creator:	20200227@Billy
	Task:		Check SQL Server Instance Name - [Redmine: #128261]
	Server:		SITDB055
*/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

USE	master;
GO

--	BEGIN STEP 1:
--		Check local server name
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

EXECUTE	sys.sp_helpserver;

SELECT	*
FROM	sys.servers WITH (NOLOCK);

SELECT	@@SERVERNAME, @@SERVICENAME;
GO
/*<info serverAlias="SITDB055-master" executers="" viewers="" isFunction="0" isNested="0"></info>*/