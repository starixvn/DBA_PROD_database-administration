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
		- 20180914@Billy:	Exclude inactive licensees - [Redmine: #101011]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	-- Select ignored list --
	CREATE TABLE	#IgnoreList (
						custid			INT
					,	PRIMARY KEY CLUSTERED (custid ASC)
					);

	DECLARE	@InactiveLicensees	AS TABLE (
									LicenseeName	VARCHAR(50)
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

	INSERT INTO	@InactiveLicensees (LicenseeName)
	VALUES	('DELA'), ('Bezbet'), ('SG8'), ('Tycoon'), ('Ibobet'), ('VCasia'), ('Bwinning'), ('Livebet365'), ('yq355'), ('bcr999'), ('lebao8888'), ('i668bet'), ('i228bet')
		,	('hl5888'), ('ks5555'), ('fx9888'), ('hn555'), ('wx7777'), ('pg5688'), ('wsd666'), ('lj9888'), ('gj7777'), ('lwl8888'), ('eb6688'), ('wy6666'), ('fl5688')
		,	('gi6688'), ('wl5688'), ('wg5688'), ('cl668'), ('cx5888'), ('fg6666'), ('gp1688'), ('kh5688'), ('bvl8888'), ('bw6688'), ('gb688'), ('db5688'), ('Giant Winner')
		,	('mymbet'), ('Athenaqa'), ('alogeu'), ('67BET'), ('SLC88'), ('Bet2day'), ('Winner99'), ('XTD1'), ('XTD2'), ('LivebetIDR'), ('K8'), ('Sga88'), ('Hbobet'), ('Wawabet')
		,	('Mgm88'), ('Saloncs'), ('Royalebet'), ('UUSS'), ('Allbetclub'), ('BlueOcean'), ('THBET'), ('Lambo777'), ('28BET'), ('LivebetKR'), ('Tonybet'), ('MarvelDH')
		,	('DAYWIN'), ('KaiHao'), ('RYB95'), ('SHABAING'), ('Greenplay'), ('Deebet'), ('666VIP'), ('Inbet'), ('TS'), ('Mirabet'), ('Doctorgame'), ('YHY1980'), ('Empire555')
		,	('Citibet'), ('21Cash'), ('DUOLE'), ('Asianbet'), ('Baobet'), ('TooBet'), ('BE7TH'), ('Lexibet'), ('King10'), ('CQ11'), ('Uwin18'), ('12betco'), ('Platinum')
		,	('Emmyo'), ('GDC'), ('Aragon88'), ('Leon'), ('Kasking88'), ('LZYQ'), ('May-88'), ('Star99'), ('LongBao'), ('KGvip'), ('Wuming'), ('AK318'), ('Holey'), ('10BET'), ('WM8888')
		;

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

	INSERT INTO	dbo.Deposit_Supers (CustId, BetLimit)
	SELECT	DISTINCT
			ci.custid, ISNULL(ia.IsDisabled, 0)
	FROM		CheckCustDB.dbo.custInfo AS ci WITH (NOLOCK)
	INNER JOIN	CheckCustDB.dbo.Dep_CustSuper AS dcs WITH (NOLOCK)
			ON	ci.CustId = dcs.CustId
	OUTER APPLY	(
		SELECT	[IsDisabled]	= 1
		FROM	@InactiveLicensees AS il
		WHERE	il.LicenseeName = dcs.Site
	) AS ia
	WHERE	ci.RoleID = 4 
		AND	ci.Enabled = 1;

	-- Cleanup temporary table --
	DROP TABLE	#IgnoreList;
END;
GO
/*<info serverAlias="DBCHECK-CheckResultDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/