
SET NOCOUNT ON;

-- Copy Transactions to archive database --
RAISERROR('Copy Transactions', 0, 0) WITH NOWAIT;

EXECUTE	sys.sp_MSforeachdb N'
USE [?]
IF	DB_NAME() LIKE ''FPS[_]SUB[_]MAX%''
	INSERT INTO	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.trash.Transactions (TransID, AccountID, DeviceID, SubscriberID, TransDate, ActionName, IP, Country, CountryCode, Region, City, ServiceProvider, ISP, Browser, PluginID, Flagged, RuleSetID, ResultType, RuleVersionID, URL, ActionResult, UserAgent)
	SELECT	trn.TransID, trn.AccountID, trn.DeviceID, trn.SubscriberID, trn.TransDate, trn.ActionName, trn.IP, trn.Country, trn.CountryCode, trn.Region, trn.City, trn.ServiceProvider, trn.ISP, trn.Browser, trn.PluginID, trn.Flagged, trn.RuleSetID, trn.ResultType, trn.RuleVersionID, trn.URL, trn.ActionResult, trn.UserAgent
	FROM		[?].dbo.Transactions AS trn WITH (NOLOCK)
	LEFT JOIN	[?].dbo.Accounts AS acc WITH (NOLOCK)
			ON	trn.AccountID = acc.AccountID
	WHERE	acc.AccountID IS NULL
		AND	trn.TransDate > 0;

RAISERROR(''Done ?'', 0, 0) WITH NOWAIT;
';

