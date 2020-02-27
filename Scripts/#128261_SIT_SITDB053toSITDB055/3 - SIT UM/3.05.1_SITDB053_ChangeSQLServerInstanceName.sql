/*
	Creator:	20200227@Billy
	Task:		Change SQL Server Instance Name - [Redmine: #128261]
	Server:		SITDB053
*/

SET NOCOUNT ON;

USE	master;
GO

--	BEGIN STEP 1:
--		Recreate local server name
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

EXECUTE	sys.sp_dropserver @server = N'SITDB053';
EXECUTE	sys.sp_addserver @server = N'SITDB055', @local = 'local';
GO
/*<info serverAlias="SITDB053-master" executers="" viewers="" isFunction="0" isNested="0"></info>*/