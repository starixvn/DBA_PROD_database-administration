/*
	Creator:	20200227@Billy
	Task:		Disable unused SQL Logins - [Redmine: #128261]
	Server:		SITDB053
*/


SET NOCOUNT ON;

USE	master;
GO


--	BEGIN STEP 1:
--		Disable Unused SQL Logins
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

ALTER LOGIN bodbinternalNet DISABLE;
ALTER LOGIN bodbRMSNet DISABLE;
ALTER LOGIN DataSync DISABLE;
ALTER LOGIN Dot_3rdparty DISABLE;
ALTER LOGIN Dot_Admin DISABLE;
ALTER LOGIN Dot_Casino DISABLE;
ALTER LOGIN Dot_Member DISABLE;
ALTER LOGIN dwrs2 DISABLE;
ALTER LOGIN ibcrep DISABLE;
GO
/*<info serverAlias="SITDB053-master" executers="" viewers="" isFunction="0" isNested="0"></info>*/