/*
	Creator:	20200227@Billy
	Task:		Disable SQL Logins for UM - [Redmine: #128261]
	Server:		SITDBTRANS, SITDB02, SITDBCUST, SITDB05
*/

SET NOCOUNT ON;

USE	master;
GO

--	BEGIN STEP 1:
--		Disable SQL Login
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

EXECUTE	master.dbo.DBA_UM_LoginDisable;
GO
/*<info serverAlias="SITDBTRANS-master;SITDBCUST-master;SITDB02-master;SITDB05-master" executers="" viewers="" isFunction="0" isNested="0"></info>*/