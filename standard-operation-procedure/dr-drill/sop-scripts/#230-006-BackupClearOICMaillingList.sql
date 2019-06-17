/*
	Creator:	20190617@Billy
	Task:		Backup & Update OIC mailing list - [Redmine: #114307]
	Server:		DBOIC

	Revision:
		- 20190617@Billy:	Initialization - [Redmine: #114307]
*/

USE	bodb_OIC;
GO

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