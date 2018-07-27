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
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	-- Select for Non-DCS --
	TRUNCATE TABLE	dbo.Credit_Supers;

	INSERT INTO	dbo.Credit_Supers (CustId)
	SELECT	DISTINCT
			ci.custid
	FROM	CheckCustDB.dbo.custInfo AS ci WITH (NOLOCK)
	WHERE	ci.RoleID = 4 
		AND	NOT EXISTS (SELECT custid from CheckCustDB.dbo.Dep_CustSuper AS dcs WITH (NOLOCK) WHERE ci.CustId = dcs.CustId)
		AND	ci.Enabled = 1;

	-- Select for DCS --
	TRUNCATE TABLE	dbo.Credit_DCS;

	INSERT INTO	dbo.Credit_DCS (CustId, RoleId, isFinished)
	SELECT	DISTINCT
			ci.CustId, ci.RoleId, 0
	FROM		CheckCustDB.dbo.CustInfo AS ci WITH (NOLOCK)
	INNER JOIN	CheckCustDB.dbo.CustSuper AS s WITH (NOLOCK)
			ON	s.CustId = ci.CustId
	INNER JOIN	CheckCustDB.dbo.CustDirectAccount AS da WITH (NOLOCK)
			ON	da.CustId = ci.CustId
	WHERE	ci.RoleId = 4
		AND	NOT EXISTS (SELECT CustId FROM CheckCustDB.dbo.Dep_CustSuper AS dcs WITH (NOLOCK) WHERE ci.CustId = dcs.CustId)
		AND	ci.Enabled = 1
		AND	s.isInternal = 0
		AND	ci.Currency NOT IN (20, 27, 28);

	INSERT INTO	dbo.Credit_DCS (CustId, RoleId, isFinished)
	SELECT	DISTINCT
			ci.CustId, ci.RoleId, 0
	FROM		CheckCustDB.dbo.CustInfo AS ci WITH (NOLOCK)
	INNER JOIN	CheckCustDB.dbo.CustDirectAccount AS da WITH (NOLOCK)
			ON	ci.CustId = da.CustId
	WHERE	ci.RoleId BETWEEN 1 AND 3
		AND	NOT EXISTS (SELECT CustId FROM CheckCustDB.dbo.Dep_CustSuper AS dcs WITH (NOLOCK) WHERE ci.srecommend = dcs.CustId)
		AND	ci.Enabled = 1
		AND	EXISTS (SELECT 1 FROM CheckCustDB.dbo.CustSuper AS cs WITH (NOLOCK) WHERE ci.srecommend = cs.CustId AND cs.isInternal = 0)
		AND	ci.currency NOT IN (20, 27, 28);

	-- Select for Deposit --
	TRUNCATE TABLE	dbo.Deposit_Supers;

	INSERT INTO	dbo.Deposit_Supers (CustId)
	SELECT	DISTINCT
			ci.custid
	FROM	CheckCustDB.dbo.custInfo AS ci WITH (NOLOCK)
	WHERE	ci.RoleID = 4 
		AND	EXISTS (SELECT custid from CheckCustDB.dbo.Dep_CustSuper AS dcs WITH (NOLOCK) WHERE ci.CustId = dcs.CustId)
		AND	ci.Enabled = 1;

END;
GO
/*<info serverAlias="DBCHECK-CheckResultDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/