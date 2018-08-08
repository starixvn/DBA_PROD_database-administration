USE	CheckResultDB;
GO

ALTER PROCEDURE	dbo.vnDBA_sp_CheckSetting_SelectSupers
AS
/*
	Creator:	20180718@Billy
	Task:		Description - [Redmine: #00000]
	Database:	DBDWCSS.CheckResultDB
	
	Revisions:
		- 20180718@Billy:	Initial - [Redmine: #00000]
		- 20180801@Billy:	Update cust super non-DCS list - [Redmine: #99249]
		- 20180807@Elodie:	Exclude super belong site not offer - [Redmine: #73556]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	-- Select ignored list --
	CREATE TABLE	#IgnoreList (
						custid		INT
					,	PRIMARY KEY CLUSTERED (custid ASC)
					);

	INSERT INTO	#IgnoreList (custid)
	SELECT	ci.custid
	FROM	CheckCustDB.dbo.custInfo AS ci WITH (NOLOCK)
	WHERE	ci.roleid = 4
		AND	(	ci.username LIKE '%Acc%'
			OR	ci.username LIKE '%3rdSuper%'
			OR	ci.username LIKE 'STEST%'
			OR	(	ci.username LIKE 'SM%'
				AND	ci.custid < 100
				)
			);

	-- Select for Non-DCS --
	TRUNCATE TABLE	dbo.Credit_Supers;

	INSERT INTO	dbo.Credit_Supers (CustId)
	SELECT	ci.custid
	FROM		CheckCustDB.dbo.custInfo AS ci WITH (NOLOCK)
	INNER JOIN	CheckCustDB.dbo.Customer AS c WITH (NOLOCK)
			ON	ci.custid = c.custid
	INNER JOIN	CheckCustDB.dbo.custSuper AS s WITH (NOLOCK)
			ON	ci.custid = s.custid
	WHERE	ci.RoleID = 4  
		AND	NOT EXISTS (SELECT custid FROM CheckCustDB.dbo.Dep_CustSuper AS dcs WITH (NOLOCK) WHERE ci.custid = dcs.CustId)
		AND	ci.Enabled = 1
		AND	s.IsInternal = 0
		AND	NOT EXISTS (SELECT 1 FROM dbo.f_GetSiteNotOffer() AS nos WHERE nos.site = c.site)
		AND	NOT EXISTS (SELECT 1 FROM dbo.f_GetCurrencyTest() AS ct WHERE ct.currency = ci.currency)
		AND	NOT EXISTS (SELECT 1 FROM #IgnoreList AS il WITH (NOLOCK) WHERE il.custid = ci.custid);

	-- Select for DCS --
	TRUNCATE TABLE	dbo.Credit_DCS;

	INSERT INTO	dbo.Credit_DCS (CustId, RoleId, isFinished)
	SELECT	DISTINCT
			ci.CustId, ci.RoleId, 0
	FROM		CheckCustDB.dbo.CustInfo AS ci WITH (NOLOCK)
	INNER JOIN	CheckCustDB.dbo.Customer AS c WITH (NOLOCK)
			ON	ci.custid = c.custid
	INNER JOIN	CheckCustDB.dbo.CustSuper AS s WITH (NOLOCK)
			ON	s.CustId = ci.CustId
	INNER JOIN	CheckCustDB.dbo.CustDirectAccount AS da WITH (NOLOCK)
			ON	da.CustId = ci.CustId
	WHERE	ci.RoleId = 4
		AND	NOT EXISTS (SELECT CustId FROM CheckCustDB.dbo.Dep_CustSuper AS dcs WITH (NOLOCK) WHERE ci.CustId = dcs.CustId)
		AND	ci.Enabled = 1
		AND	s.isInternal = 0
		AND	NOT EXISTS (SELECT 1 FROM dbo.f_GetSiteNotOffer() AS nos WHERE nos.site = c.site)
		AND	NOT EXISTS (SELECT 1 FROM dbo.f_GetCurrencyTest() AS ct WHERE ct.currency = ci.currency)
		AND	NOT EXISTS (SELECT 1 FROM #IgnoreList AS il WITH (NOLOCK) WHERE il.custid = ci.custid);
		
	INSERT INTO	dbo.Credit_DCS (CustId, RoleId, isFinished)
	SELECT	DISTINCT
			ci.CustId, ci.RoleId, 0
	FROM		CheckCustDB.dbo.CustInfo AS ci WITH (NOLOCK)
	INNER JOIN	CheckCustDB.dbo.Customer AS c WITH (NOLOCK)
			ON	ci.CustId = c.CustId
	INNER JOIN	CheckCustDB.dbo.CustDirectAccount AS da WITH (NOLOCK)
			ON	ci.CustId = da.CustId
	WHERE	ci.RoleId IN (2, 3)
		AND	NOT EXISTS (SELECT CustId FROM CheckCustDB.dbo.Dep_CustSuper AS dcs WITH (NOLOCK) WHERE ci.srecommend = dcs.CustId)
		AND	ci.Enabled = 1
		AND	EXISTS (SELECT 1 FROM CheckCustDB.dbo.CustSuper AS cs WITH (NOLOCK) WHERE ci.srecommend = cs.CustId AND cs.isInternal = 0)
		AND	NOT EXISTS (SELECT 1 FROM dbo.f_GetSiteNotOffer() AS nos WHERE nos.site = c.site)
		AND	NOT EXISTS (SELECT 1 FROM dbo.f_GetCurrencyTest() AS ct WHERE ct.currency = ci.currency)
		AND	NOT EXISTS (SELECT 1 FROM #IgnoreList AS il WITH (NOLOCK) WHERE il.custid = ci.custid);

	INSERT INTO	dbo.Credit_DCS (CustId, RoleId, isFinished)
	SELECT	DISTINCT
			ci.CustId, ci.RoleId, 0
	FROM		CheckCustDB.dbo.CustInfo AS ci WITH (NOLOCK)
	INNER JOIN	CheckCustDB.dbo.Customer AS c WITH (NOLOCK)
			ON	ci.recommend = c.CustId
	INNER JOIN	CheckCustDB.dbo.CustDirectAccount AS da WITH (NOLOCK)
			ON	ci.CustId = da.CustId
	WHERE	ci.RoleId = 1
		AND	NOT EXISTS (SELECT CustId FROM CheckCustDB.dbo.Dep_CustSuper AS dcs WITH (NOLOCK) WHERE ci.srecommend = dcs.CustId)
		AND	ci.Enabled = 1
		AND	EXISTS (SELECT 1 FROM CheckCustDB.dbo.CustSuper AS cs WITH (NOLOCK) WHERE ci.srecommend = cs.CustId AND cs.isInternal = 0)
		AND	NOT EXISTS (SELECT 1 FROM dbo.f_GetSiteNotOffer() AS nos WHERE nos.site = c.site)
		AND	NOT EXISTS (SELECT 1 FROM dbo.f_GetCurrencyTest() AS ct WHERE ct.currency = ci.currency)
		AND	NOT EXISTS (SELECT 1 FROM #IgnoreList AS il WITH (NOLOCK) WHERE il.custid = ci.custid);

	-- Select for Deposit --
	TRUNCATE TABLE	dbo.Deposit_Supers;

	INSERT INTO	dbo.Deposit_Supers (CustId)
	SELECT	DISTINCT
			ci.custid
	FROM	CheckCustDB.dbo.custInfo AS ci WITH (NOLOCK)
	WHERE	ci.RoleID = 4 
		AND	EXISTS (SELECT custid from CheckCustDB.dbo.Dep_CustSuper AS dcs WITH (NOLOCK) WHERE ci.CustId = dcs.CustId)
		AND	ci.Enabled = 1;

	-- Cleanup temporary table --
	DROP TABLE	#IgnoreList;
END;
GO
/*<info serverAlias="DBCHECK-CheckResultDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/