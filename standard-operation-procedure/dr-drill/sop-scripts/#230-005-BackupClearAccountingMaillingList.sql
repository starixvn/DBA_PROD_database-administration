/*
	Creator:	20190617@Billy
	Task:		Backup & Update accounting mailing list - [Redmine: #114307]
	Server:		DBACC

	Revision:
		- 20190617@Billy:	Initialization - [Redmine: #114307]
*/

USE	bodb_ACC;
GO

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