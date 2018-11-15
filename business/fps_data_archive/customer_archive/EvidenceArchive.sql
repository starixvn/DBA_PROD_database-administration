INSERT INTO	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.trash.EvidenceMaster (EviID, EviGroupID, EviCode, CreateBy, CreateDate, Comment, ItemID, ItemType, CentralPoint, SubscriberID, StatusID)
SELECT	tbl.EviID, tbl.EviGroupID, tbl.EviCode, tbl.CreateBy, tbl.CreateDate, tbl.Comment, tbl.ItemID, tbl.ItemType, tbl.CentralPoint, tbl.SubscriberID, tbl.StatusID
FROM		dbo.EvidenceMaster AS tbl WITH (NOLOCK)
INNER JOIN	FPS_MiddleService.dbo.Accounts_tmp#3 AS tmp WITH (NOLOCK)
		ON	tbl.ItemID = tmp.AccountID
		AND	tbl.SubscriberID = tmp.SubscriberID
		AND	tbl.ItemType = 0

INSERT INTO	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.trash.EvidenceSub (EviSubID, EviID, ItemID, ItemType, ItemValue, SubscriberID, LevelID, AffectedDate, EviSource)
SELECT	tbl.EviSubID, tbl.EviID, tbl.ItemID, tbl.ItemType, tbl.ItemValue, tbl.SubscriberID, tbl.LevelID, tbl.AffectedDate, tbl.EviSource
FROM		dbo.EvidenceSub AS tbl WITH (NOLOCK)
INNER JOIN	FPS_MiddleService.dbo.Accounts_tmp#3 AS tmp WITH (NOLOCK)
		ON	tbl.ItemID = tmp.AccountID
		AND	tbl.SubscriberID = tmp.SubscriberID
		AND	tbl.ItemType = 0

INSERT INTO	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.trash.EvidenceHistories (EviHisID, EviID, EviGroupID, EviCode, CreateBy, CreateDate, Comment, ItemID, ItemType, CentralPoint, SubscriberID, StatusID)
SELECT	tbl.EviHisID, tbl.EviID, tbl.EviGroupID, tbl.EviCode, tbl.CreateBy, tbl.CreateDate, tbl.Comment, tbl.ItemID, tbl.ItemType, tbl.CentralPoint, tbl.SubscriberID, tbl.StatusID
FROM		dbo.EvidenceHistories AS tbl WITH (NOLOCK)
INNER JOIN	FPS_MiddleService.dbo.Accounts_tmp#3 AS tmp WITH (NOLOCK)
		ON	tbl.ItemID = tmp.AccountID
		AND	tbl.SubscriberID = tmp.SubscriberID
		AND	tbl.ItemType = 0

INSERT INTO	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.trash.ExceptionHistories (ExceptionHisID, ExceptionID, CreateBy, CreateDate, Comment, ActionName, DeviceID, AccountID, SubscriberID_From, SubscriberID_To)
SELECT	tbl.ExceptionHisID, tbl.ExceptionID, tbl.CreateBy, tbl.CreateDate, tbl.Comment, tbl.ActionName, tbl.DeviceID, tbl.AccountID, tbl.SubscriberID_From, tbl.SubscriberID_To
FROM		dbo.ExceptionHistories AS tbl WITH (NOLOCK)
INNER JOIN	FPS_MiddleService.dbo.Accounts_tmp#3 AS tmp WITH (NOLOCK)
		ON	tbl.AccountID = tmp.AccountID
		AND	tbl.SubscriberID_From <= tmp.SubscriberID
		AND	tbl.SubscriberID_To >= tmp.SubscriberID

INSERT INTO	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.trash.Exceptions (ExceptionID, CreateBy, CreateDate, Comment, ActionName, DeviceID, AccountID, SubscriberID_From, SubscriberID_To, StatusID)
SELECT	tbl.ExceptionID, tbl.CreateBy, tbl.CreateDate, tbl.Comment, tbl.ActionName, tbl.DeviceID, tbl.AccountID, tbl.SubscriberID_From, tbl.SubscriberID_To, tbl.StatusID
FROM		dbo.Exceptions AS tbl WITH (NOLOCK)
INNER JOIN	FPS_MiddleService.dbo.Accounts_tmp#3 AS tmp WITH (NOLOCK)
		ON	tbl.AccountID = tmp.AccountID
		AND	tbl.SubscriberID_From <= tmp.SubscriberID
		AND	tbl.SubscriberID_To >= tmp.SubscriberID




DELETE	tbl
FROM		dbo.EvidenceMaster AS tbl
INNER JOIN	FPS_MiddleService.dbo.Accounts_tmp#3 AS tmp WITH (NOLOCK)
		ON	tbl.ItemID = tmp.AccountID
		AND	tbl.SubscriberID = tmp.SubscriberID
		AND	tbl.ItemType = 0

DELETE	tbl
FROM		dbo.EvidenceSub AS tbl
INNER JOIN	FPS_MiddleService.dbo.Accounts_tmp#3 AS tmp WITH (NOLOCK)
		ON	tbl.ItemID = tmp.AccountID
		AND	tbl.SubscriberID = tmp.SubscriberID
		AND	tbl.ItemType = 0

DELETE	tbl
FROM		dbo.EvidenceHistories AS tbl
INNER JOIN	FPS_MiddleService.dbo.Accounts_tmp#3 AS tmp WITH (NOLOCK)
		ON	tbl.ItemID = tmp.AccountID
		AND	tbl.SubscriberID = tmp.SubscriberID
		AND	tbl.ItemType = 0

DELETE	tbl
FROM		dbo.ExceptionHistories AS tbl
INNER JOIN	FPS_MiddleService.dbo.Accounts_tmp#3 AS tmp WITH (NOLOCK)
		ON	tbl.AccountID = tmp.AccountID
		AND	tbl.SubscriberID_From <= tmp.SubscriberID
		AND	tbl.SubscriberID_To >= tmp.SubscriberID

DELETE	tbl
FROM		dbo.Exceptions AS tbl
INNER JOIN	FPS_MiddleService.dbo.Accounts_tmp#3 AS tmp WITH (NOLOCK)
		ON	tbl.AccountID = tmp.AccountID
		AND	tbl.SubscriberID_From <= tmp.SubscriberID
		AND	tbl.SubscriberID_To >= tmp.SubscriberID