IF	OBJECT_ID('tempdb..#invalid') IS NOT NULL
	DROP TABLE	#invalid;

CREATE TABLE	#invalid (
					AccountID	INT
				,	RoleId		SMALLINT
				);

CREATE CLUSTERED INDEX #CIX_invalid ON #invalid (AccountID)

INSERT INTO	#invalid (AccountID, RoleId)
SELECT	acc.AccountID, ow.roleid
FROM			dbo.Accounts AS acc WITH (NOLOCK)
LEFT MERGE JOIN	(
	SELECT	usr.username, usr.roleid
	FROM	FPS_SUB_Template.dbo.OWUsers AS usr WITH (NOLOCK)
) AS ow
			ON	acc.UserName = ow.Username
WHERE	ISNULL(ow.roleid, 0) NOT IN (1);

SELECT	RoleId, COUNT(1)
FROM	#invalid
GROUP BY RoleId;

RAISERROR('', 0, 0) WITH NOWAIT;

DELETE	tmp WITH (TABLOCK)
FROM				#invalid AS tmp
INNER MERGE JOIN	dbo.Accounts AS acc WITH (NOLOCK)
				ON	tmp.AccountID = acc.AccountID
INNER MERGE JOIN	(
	SELECT	usr.username, usr.roleid
	FROM	FPS_SUB_Template.dbo.OWUsers AS usr WITH (NOLOCK)
) AS ow
				ON	acc.UserName = ow.Username
WHERE	ow.roleid IN (1);

SELECT	RoleId, COUNT(1)
FROM	#invalid
GROUP BY RoleId;

RAISERROR('', 0, 0) WITH NOWAIT;

DELETE	tmp WITH (TABLOCK)
FROM				#invalid AS tmp
INNER MERGE JOIN	dbo.Accounts AS acc WITH (NOLOCK)
				ON	tmp.AccountID = acc.AccountID
INNER MERGE JOIN	(
	SELECT	usr.username, usr.roleid
	FROM	FPS_SUB_Template.dbo.OWUsers AS usr WITH (NOLOCK)
) AS ow
				ON	acc.UserName2 = ow.Username
WHERE	ow.roleid IN (1);

SELECT	RoleId, COUNT(1)
FROM	#invalid
GROUP BY RoleId;

RAISERROR('', 0, 0) WITH NOWAIT;

DELETE	tmp WITH (TABLOCK)
FROM		#invalid AS tmp
INNER JOIN	dbo.Accounts AS acc WITH (NOLOCK)
		ON	tmp.AccountID = acc.AccountID
WHERE	acc.CreatedDate >= '2018-10-05';

SELECT	RoleId, COUNT(1)
FROM	#invalid
GROUP BY RoleId;

RAISERROR('', 0, 0) WITH NOWAIT;

DELETE	tbl WITH (TABLOCK)
FROM	(
	SELECT	*, [rn] = ROW_NUMBER() OVER (PARTITION BY AccountId ORDER BY AccountId)
	FROM	#invalid
) AS tbl
WHERE	tbl.rn > 1;

SELECT	RoleId, COUNT(1)
FROM	#invalid
GROUP BY RoleId;

RAISERROR('', 0, 0) WITH NOWAIT;


--	BEGIN STEP :
--		Description
----------------------------------------------------------------------------------------------------

INSERT INTO	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.trash.Accounts_#2 (AccountID, UserName, UserName2, SubscriberID, CreatedDate)
SELECT	acc.AccountID, acc.UserName, acc.UserName2, acc.SubscriberID, acc.CreatedDate
FROM		#invalid AS tmp
INNER JOIN	dbo.Accounts AS acc WITH (NOLOCK)
		ON	tmp.AccountID = acc.AccountID
WHERE	acc.AccountID > 0;


INSERT INTO	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.trash.Associations_#2 (Ass_ID, DeviceID, AccountID, CreatedDate, LastAccessedDate, ExceptionID, SubscriberID)
SELECT	ass.Ass_ID, ass.DeviceID, ass.AccountID, ass.CreatedDate, ass.LastAccessedDate, ass.ExceptionID, acc.SubscriberID
FROM		#invalid AS tmp
INNER JOIN	dbo.Accounts AS acc WITH (NOLOCK)
		ON	tmp.AccountID = acc.AccountID
INNER JOIN	dbo.Associations AS ass WITH (NOLOCK)
		ON	acc.AccountID = ass.AccountID
WHERE	acc.AccountID > 0
	AND	ass.AccountID > 0;



DELETE	ass WITH (ROWLOCK)
FROM		#invalid AS tmp WITH (NOLOCK)
INNER JOIN	dbo.Associations AS ass
		ON	tmp.AccountID = ass.AccountID
WHERE	ass.AccountID > 0

DELETE	acc WITH (ROWLOCK)
FROM		#invalid AS tmp WITH (NOLOCK)
INNER JOIN	dbo.Accounts AS acc
		ON	tmp.AccountID = acc.AccountID
WHERE	acc.AccountID > 0
