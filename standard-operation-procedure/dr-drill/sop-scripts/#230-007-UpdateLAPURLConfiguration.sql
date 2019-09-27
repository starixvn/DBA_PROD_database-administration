/*
	Creator:	20190917@Billy
	Task:		#230-007 - Backup & Update OIC mailing list - [Redmine: #120468]
	Server:		DB052@MNL

	Revision:
		- 20190917@Billy:	Initialization - [Redmine: #120468]
*/

IF	@@SERVERNAME <> N'DBCUST' OR DB_ID(N'_This_MNL_DR_site') IS NULL
BEGIN;
	RAISERROR('This script cannot be run on this server!', 16, 1) WITH NOWAIT;
	RETURN;
END;

USE	SiteConfig;

--	BEGIN STEP 1:
--		Backup table config
----------------------------------------------------------------------------------------------------

SELECT	*
INTO	dbo.LicVendorProfile_DRBackup
FROM	dbo.LicVendorProfile WITH (NOLOCK);



--	BEGIN STEP 2:
--		Update config
----------------------------------------------------------------------------------------------------

UPDATE	dbo.LicVendorProfile WITH (TABLOCK)
SET		LRF_Url ='http://lrf.ibcbk.com';