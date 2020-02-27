/*
	Creator:	20200228@Billy
	Task:		Enable new SQL Logins - [Redmine: #128261]
	Server:		SITDB055
*/

SET NOCOUNT ON;

--	BEGIN STEP 1:
--		Enable SQL Logins
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	master;

ALTER LOGIN bodbAdminNet ENABLE;

ALTER LOGIN bodbDownlineNet ENABLE;

ALTER LOGIN bodbDownlineNetView ENABLE;

ALTER LOGIN bodbExtAccNet ENABLE;

ALTER LOGIN bodbLicenseeNet ENABLE;
GO
/*<info serverAlias="SITDB055-master" executers="" viewers="" isFunction="0" isNested="0"></info>*/