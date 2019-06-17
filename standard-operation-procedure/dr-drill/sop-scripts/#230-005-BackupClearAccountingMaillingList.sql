/*
	Creator:	20190617@Billy
	Task:		#230-005 - Backup & Update accounting mailing list - [Redmine: #114307]
	Server:		DB06@MNL

	Revision:
		- 20190617@Billy:	Initialization - [Redmine: #114307]
*/

IF	@@SERVERNAME <> N'DB06' OR DB_ID(N'_This_MNL_DR_site') IS NULL
BEGIN;
	RAISERROR('This script cannot be run on this server!', 16, 1) WITH NOWAIT;
	RETURN;
END;

USE	bodb_ACC;

--	BEGIN STEP 1:
--		Backup table mailing list
----------------------------------------------------------------------------------------------------

SELECT	*
INTO	dbo.Acc_MailingList_DRBackup
FROM	dbo.Acc_MailingList WITH (NOLOCK);


--	BEGIN STEP 2:
--		Update mailing list
----------------------------------------------------------------------------------------------------

UPDATE	dbo.Acc_MailingList WITH (TABLOCK)
SET		ToList = 'qa@starixsoft.com'
	,	CcList = ''
	,	BccList = ''
	;