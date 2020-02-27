/*
	Creator:	20200228@Billy
	Task:		Switch to new SQL Logins - [Redmine: #128261]
	Server:		SITDB055
*/

SET NOCOUNT ON;

--	BEGIN STEP 1:
--		Rename SQL Logins
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

USE	master;

ALTER LOGIN bodbAdminNet WITH NAME = bodbAdminNet_Old;
ALTER LOGIN bodbAdminNet_New WITH NAME = bodbAdminNet;

ALTER LOGIN bodbDownlineNet WITH NAME = bodbDownlineNet_Old;
ALTER LOGIN bodbDownlineNet_New WITH NAME = bodbDownlineNet;

ALTER LOGIN bodbDownlineNetView WITH NAME = bodbDownlineNetView_Old;
ALTER LOGIN bodbDownlineNetView_New WITH NAME = bodbDownlineNetView;

ALTER LOGIN bodbExtAccNet WITH NAME = bodbExtAccNet_Old;
ALTER LOGIN bodbExtAccNet_New WITH NAME = bodbExtAccNet;

ALTER LOGIN bodbLicenseeNet WITH NAME = bodbLicenseeNet_Old;
ALTER LOGIN bodbLicenseeNet_New WITH NAME = bodbLicenseeNet;
GO
/*<info serverAlias="SITDB055-master" executers="" viewers="" isFunction="0" isNested="0"></info>*/