IF	OBJECT_ID('tempdb..#subs') IS NOT NULL
	DROP TABLE	#subs;

CREATE TABLE	#subs (
					SubscriberId		INT
				,	SubscriberName		VARCHAR(50)
				,	IsActive			BIT
				,	IsTest				BIT
				);

INSERT INTO	#subs (SubscriberId, SubscriberName, IsActive, IsTest)
SELECT	ms.SubscriberId, ISNULL(sub.SubscriberName, st.SubscriberName), ISNULL(sub.IsActive, 0), ISNULL(sub.IsTest, st.IsTest)
FROM	(
	SELECT	DISTINCT
			SubscriberId
	FROM	dbo.Customers WITH (NOLOCK)
) AS ms
LEFT JOIN	FPS_ADMIN.dbo.Subscribers AS sub WITH (NOLOCK)
		ON	sub.SubscriberID = ms.SubscriberId
LEFT JOIN	FPS_ADMIN.dbo.Subscribers_Terminated AS st WITH (NOLOCK)
		ON	st.SubscriberID = ms.SubscriberId

SELECT	*
FROM	#subs
ORDER BY IsActive ASC, IsTest DESC, SubscriberId

INSERT INTO	dbo.Customers_bk
SELECT	cst.*
FROM		dbo.Customers AS cst WITH (NOLOCK)
INNER JOIN	#subs AS sub
		ON	cst.SubscriberId = sub.SubscriberId
WHERE	sub.IsActive = 0
	OR	sub.IsTest = 1

INSERT INTO	dbo.Associations_bk
SELECT	ass.*
FROM		dbo.Associations AS ass WITH (NOLOCK)
INNER JOIN	dbo.Customers AS cst WITH (NOLOCK)
		ON	ass.CustId = cst.CustId
INNER JOIN	#subs AS sub
		ON	cst.SubscriberId = sub.SubscriberId
WHERE	sub.IsActive = 0
	OR	sub.IsTest = 1

INSERT INTO	dbo.CustomerEvidences_bk
SELECT	ce.*
FROM		dbo.CustomerEvidences AS ce WITH (NOLOCK)
INNER JOIN	dbo.Customers AS cst WITH (NOLOCK)
		ON	ce.CustId = cst.CustId
INNER JOIN	#subs AS sub
		ON	cst.SubscriberId = sub.SubscriberId
WHERE	sub.IsActive = 0
	OR	sub.IsTest = 1

DELETE	ce
FROM		dbo.CustomerEvidences AS ce
INNER JOIN	dbo.Customers AS cst WITH (NOLOCK)
		ON	ce.CustId = cst.CustId
INNER JOIN	#subs AS sub
		ON	cst.SubscriberId = sub.SubscriberId
WHERE	sub.IsActive = 0
	OR	sub.IsTest = 1

DELETE	ass
FROM		dbo.Associations AS ass
INNER JOIN	dbo.Customers AS cst WITH (NOLOCK)
		ON	ass.CustId = cst.CustId
INNER JOIN	#subs AS sub
		ON	cst.SubscriberId = sub.SubscriberId
WHERE	sub.IsActive = 0
	OR	sub.IsTest = 1

DELETE	cst
FROM		dbo.Customers AS cst
INNER JOIN	#subs AS sub
		ON	cst.SubscriberId = sub.SubscriberId
WHERE	sub.IsActive = 0
	OR	sub.IsTest = 1