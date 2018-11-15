IF	OBJECT_ID('tempdb..#tmp') IS NOT NULL
	DROP TABLE	#tmp

SELECT	*
INTO	#tmp
FROM	OPENQUERY(FPSADMIN, N'
SELECT	*
FROM	FPS_ADMIN.dbo.OWCustomer_20181102 WITH (NOLOCK)
WHERE	ssite IS NULL
	AND	roleid < 5;
');


INSERT INTO	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.maxbet789y.Transactions (TransID, AccountID, DeviceID, SubscriberID, TransDate, ActionName, IP, Country, CountryCode, Region, City, ServiceProvider, ISP, Browser, PluginID, Flagged, RuleSetID, ResultType, RuleVersionID, URL, ActionResult, UserAgent)
SELECT	trn.TransID, trn.AccountID, trn.DeviceID, trn.SubscriberID, trn.TransDate, trn.ActionName, trn.IP, trn.Country, trn.CountryCode, trn.Region, trn.City, trn.ServiceProvider, trn.ISP, trn.Browser, trn.PluginID, trn.Flagged, trn.RuleSetID, trn.ResultType, trn.RuleVersionID, trn.URL, trn.ActionResult, trn.UserAgent
FROM		dbo.Transactions AS trn WITH (NOLOCK)
INNER JOIN	dbo.Accounts AS acc WITH (NOLOCK)
		ON	trn.AccountID = acc.AccountID
INNER JOIN	#tmp AS tmp WITH (NOLOCK)
		ON	tmp.username = acc.UserName

INSERT INTO	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.maxbet789y.Associations (Ass_ID, DeviceID, AccountID, CreatedDate, LastAccessedDate, ExceptionID)
SELECT	ass.Ass_ID, ass.DeviceID, ass.AccountID, ass.CreatedDate, ass.LastAccessedDate, ass.ExceptionID
FROM		dbo.Associations AS ass WITH (NOLOCK)
INNER JOIN	dbo.Accounts AS acc WITH (NOLOCK)
		ON	ass.AccountID = acc.AccountID
INNER JOIN	#tmp AS tmp WITH (NOLOCK)
		ON	tmp.username = acc.UserName

INSERT INTO	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.maxbet789y.Accounts (AccountID, UserName, UserName2, SubscriberID, CreatedDate)
SELECT	acc.AccountID, acc.UserName, acc.UserName2, acc.SubscriberID, acc.CreatedDate
FROM		dbo.Accounts AS acc WITH (NOLOCK)
INNER JOIN	#tmp AS tmp WITH (NOLOCK)
		ON	acc.UserName = tmp.username



DELETE	trn
FROM		dbo.Transactions AS trn
INNER JOIN	dbo.Accounts AS acc WITH (NOLOCK)
		ON	trn.AccountID = acc.AccountID
INNER JOIN	#tmp AS tmp WITH (NOLOCK)
		ON	tmp.username = acc.UserName

DELETE	ass
FROM		dbo.Associations AS ass
INNER JOIN	dbo.Accounts AS acc WITH (NOLOCK)
		ON	ass.AccountID = acc.AccountID
INNER JOIN	#tmp AS tmp WITH (NOLOCK)
		ON	tmp.username = acc.UserName

DELETE	acc
FROM		dbo.Accounts AS acc
INNER JOIN	#tmp AS tmp WITH (NOLOCK)
		ON	acc.UserName = tmp.username