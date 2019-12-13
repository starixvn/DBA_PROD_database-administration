/*
	Creator:	20190617@Billy
	Task:		#230-006 - Backup & Update OIC mailing list - [Redmine: #114307]
	Server:		DB052@MNL

	Revision:
		- 20190617@Billy:	Initialization - [Redmine: #114307]
*/

IF	@@SERVERNAME <> N'DB052' OR DB_ID(N'_This_MNL_DR_site') IS NULL
BEGIN;
	RAISERROR('This script cannot be run on this server!', 16, 1) WITH NOWAIT;
	RETURN;
END;

USE	bodb_OIC;

--	BEGIN STEP 1:
--		Backup table mailing list
----------------------------------------------------------------------------------------------------

SELECT	*
INTO	dbo.Contact_DRBackup
FROM	dbo.Contact WITH (NOLOCK);

SELECT	*
INTO	dbo.EmailConfiguration_DRBackup
FROM	dbo.EmailConfiguration WITH (NOLOCK);

SELECT	*
INTO	dbo.UserLicenseeType_DRBackup
FROM	dbo.UserLicenseeType WITH (NOLOCK);



--	BEGIN STEP 2:
--		Update mailing list
----------------------------------------------------------------------------------------------------

UPDATE	dbo.Contact WITH (TABLOCK)
SET		ContactEmail = ''
	;

UPDATE	dbo.EmailConfiguration WITH (TABLOCK)
SET		CcList = ''
	,	BccList = ''
	;

UPDATE	dbo.UserLicenseeType WITH (TABLOCK)
SET		Email = ''
	;