INSERT INTO	dbo.Customers_trash (CustId, Username, Username2, RoleId, CurrencyId, CurrencyName, SubscriberId, FpsAccountId, IsDeposit, CreatedDate)
SELECT	cst.CustId, cst.Username, cst.Username2, cst.RoleId, cst.CurrencyId, cst.CurrencyName, cst.SubscriberId, cst.FpsAccountId, cst.IsDeposit, cst.CreatedDate
FROM		dbo.Customers AS cst WITH (NOLOCK)
INNER JOIN	dbo.Accounts_tmp AS tmp WITH (NOLOCK)
		ON	cst.SubscriberId = tmp.SubscriberID
		AND	cst.FpsAccountId = tmp.AccountID
WHERE	cst.CustId > -99999999999999


INSERT INTO dbo.Associations_trash (CustId, DeviceId, CreatedDate)
SELECT	ass.CustId, ass.DeviceId, ass.CreatedDate
FROM				dbo.Customers_trash AS trs WITH (NOLOCK)
INNER MERGE JOIN	dbo.Associations AS ass WITH (NOLOCK)
				ON	trs.CustId = ass.CustId

INSERT INTO	dbo.CustomerEvidences_trash (CustId, EviCode, CreatedDate)
SELECT	ce.CustId, ce.EviCode, ce.CreatedDate
FROM				dbo.Customers_trash AS trs WITH (NOLOCK)
INNER MERGE JOIN	dbo.CustomerEvidences AS ce WITH (NOLOCK)
				ON	trs.CustId = ce.CustId


DELETE	tbl WITH (TABLOCK)
FROM		dbo.CustomerEvidences AS tbl
INNER JOIN	dbo.CustomerEvidences_trash AS trs WITH (NOLOCK)
		ON	tbl.CustId = trs.CustId
		AND	tbl.EviCode = trs.EviCode

DELETE	tbl WITH (TABLOCK)
FROM		dbo.Associations AS tbl
INNER MERGE JOIN	dbo.Associations_trash AS trs WITH (NOLOCK)
		ON	tbl.CustId = trs.CustId
		AND	tbl.DeviceId = trs.DeviceId

DELETE	tbl WITH (TABLOCK)
FROM		dbo.Customers AS tbl
INNER JOIN	dbo.Customers_trash AS trs WITH (NOLOCK)
		ON	tbl.CustId = trs.CustId
