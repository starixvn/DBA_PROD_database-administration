/*
	Creator:	20200227@Billy
	Task:		Disable SQL Logins - [Redmine: #128261]
	Server:		SITDB053
*/


SET NOCOUNT ON;

USE	master;
GO


--	BEGIN STEP 1:
--		Disable SQL Logins
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

ALTER LOGIN bodbAdminNet DISABLE;
ALTER LOGIN bodbDownlineNet DISABLE;
ALTER LOGIN bodbDownlineNetView DISABLE;
ALTER LOGIN bodbExtAccNet DISABLE;
ALTER LOGIN bodbLicenseeNet DISABLE;
GO
/*<info serverAlias="SITDB053-master" executers="" viewers="" isFunction="0" isNested="0"></info>*/