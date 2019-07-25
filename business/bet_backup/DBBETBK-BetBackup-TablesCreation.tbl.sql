/*
	Creator:	20190723@Billy
	Task:		Tables for BetBackup - [Redmine: #116270]
	Server:		DBBETBK.BetBackup
*/

USE	BetBackup;
GO

--	BEGIN STEP 1:
--		bettrans & bettransReject
----------------------------------------------------------------------------------------------------

-- bettrans --
BEGIN;
	CREATE TABLE	dbo.bettrans (
						transid				BIGINT			NOT NULL
					,	custid				INT				NOT NULL
					,	transdate			DATETIME		NOT NULL
					,	oddsid				INT				NOT NULL
					,	hdp1				SMALLMONEY		NULL
					,	hdp2				SMALLMONEY		NULL
					,	odds				SMALLMONEY		NULL
					,	stake				MONEY			NOT NULL
					,	status				NVARCHAR(10)	NULL
					,	winlost				MONEY			NULL
					,	awinlost			MONEY			NULL
					,	mwinlost			MONEY			NULL
					,	playercomm			MONEY			NULL
					,	comm				MONEY			NULL
					,	acomm				MONEY			NULL
					,	apositiontaking		SMALLMONEY		NULL
					,	mpositiontaking		SMALLMONEY		NULL
					,	tpositiontaking		SMALLMONEY		NULL
					,	playerdiscount		DECIMAL(9,8)	NULL
					,	discount			DECIMAL(9,8)	NULL
					,	adiscount			DECIMAL(9,8)	NULL
					,	livehomescore		SMALLINT		NULL
					,	liveawayscore		SMALLINT		NULL
					,	liveindicator		BIT				NULL
					,	betteam				NVARCHAR(10)	NULL
					,	creator				INT				NOT NULL
					,	refno				BIGINT			NOT NULL
					,	comstatus			NVARCHAR(20)	NULL
					,	winlostdate			SMALLDATETIME	NULL
					,	betfrom				NVARCHAR(1)		NULL
					,	betcheck			NVARCHAR(50)	NULL
					,	checktime			DATETIME		NULL
					,	oddsspread			MONEY			NULL
					,	actualrate			FLOAT			NULL
					,	matchid				INT				NULL
					,	recommend			INT				NOT NULL
					,	mrecommend			INT				NOT NULL
					,	ruben				TINYINT			NULL
					,	betid				BIGINT			NULL
					,	statuswinlost		TINYINT			NULL
					,	modds				SMALLMONEY		NULL
					,	bettype				SMALLINT		NULL
					,	betdaqid			BIGINT			NULL
					,	currency			TINYINT			NULL
					,	transdesc			NVARCHAR(2000)	NULL
					,	sdiscount			DECIMAL			NULL
					,	scomm				MONEY			NULL
					,	spositiontaking		SMALLMONEY		NULL
					,	srecommend			INT				NOT NULL
					,	ExtraInfo			VARCHAR(1000)	NULL
					,	WalletType			TINYINT			NULL
					,	BonusID				INT				NULL
					,	RefCode				BIGINT			NULL
					,	BackupDate			DATETIME		NOT NULL
							CONSTRAINT DF_bettrans_BackupDate DEFAULT GETDATE()
					) ON bettrans_DATA;

	CREATE CLUSTERED INDEX	CIX_bettrans ON dbo.bettrans (
								transid		ASC
							) WITH (DATA_COMPRESSION = PAGE) ON bettrans_DATA;

	CREATE NONCLUSTERED INDEX	IX_bettrans_matchid ON dbo.bettrans (
									matchid		ASC
								)
								INCLUDE (winlostdate, oddsid, bettype) WITH (DATA_COMPRESSION = PAGE) ON bettrans_IDX;

	CREATE NONCLUSTERED INDEX	IX_bettrans_transdate ON dbo.bettrans (
									transdate	ASC
								) WITH (DATA_COMPRESSION = PAGE) ON bettrans_IDX;

	CREATE NONCLUSTERED INDEX	IX_bettrans_winlostdate ON dbo.bettrans (
									winlostdate	ASC
								) WITH (DATA_COMPRESSION = PAGE) ON bettrans_IDX;

	CREATE NONCLUSTERED INDEX	IX_bettrans_bettype ON dbo.bettrans (
									bettype		ASC
								)
								INCLUDE (matchid, oddsid) WITH (DATA_COMPRESSION = PAGE) ON bettrans_IDX;
END;

-- bettransReject --
BEGIN;
	CREATE TABLE	dbo.bettransReject (
						transid				BIGINT			NOT NULL
					,	custid				INT				NOT NULL
					,	transdate			DATETIME		NOT NULL
					,	oddsid				INT				NOT NULL
					,	hdp1				SMALLMONEY		NULL
					,	hdp2				SMALLMONEY		NULL
					,	odds				SMALLMONEY		NULL
					,	stake				MONEY			NOT NULL
					,	status				NVARCHAR(10)	NULL
					,	tpositiontaking		SMALLMONEY		NULL
					,	livehomescore		SMALLINT		NULL
					,	liveawayscore		SMALLINT		NULL
					,	liveindicator		BIT				NULL
					,	betteam				NVARCHAR(10)	NULL
					,	winlostdate			SMALLDATETIME	NULL
					,	matchid				INT				NULL
					,	ruben				TINYINT			NULL
					,	bettype				SMALLINT		NULL
					,	currency			TINYINT			NULL
					,	transdesc			NVARCHAR(2000)	NULL
					,	BackupDate			DATETIME		NOT NULL
					) ON bettransReject_DATA;

	CREATE CLUSTERED INDEX	CIX_bettransReject ON dbo.bettransReject (
								transid		ASC
							) WITH (DATA_COMPRESSION = PAGE) ON bettransReject_DATA;

	CREATE NONCLUSTERED INDEX	IX_bettransReject_matchid ON dbo.bettransReject (
									matchid		ASC
								)
								INCLUDE (winlostdate, oddsid, bettype) WITH (DATA_COMPRESSION = PAGE) ON bettransReject_IDX;
END;


--	BEGIN STEP 2:
--		bettransm
----------------------------------------------------------------------------------------------------

-- bettransm --
BEGIN;
	CREATE TABLE	dbo.bettransm (
						transid				BIGINT			NOT NULL
					,	custid				INT				NOT NULL
					,	transdate			DATETIME		NOT NULL
					,	oddsid				INT				NOT NULL
					,	hdp1				SMALLMONEY		NULL
					,	hdp2				SMALLMONEY		NULL
					,	odds				SMALLMONEY		NULL
					,	stake				MONEY			NOT NULL
					,	status				NVARCHAR(10)	NULL
					,	winlost				MONEY			NULL
					,	livehomescore		SMALLINT		NULL
					,	liveawayscore		SMALLINT		NULL
					,	liveindicator		BIT				NULL
					,	betteam				NVARCHAR(10)	NULL
					,	refno				BIGINT			NOT NULL
					,	comstatus			NVARCHAR(20)	NULL
					,	winlostdate			SMALLDATETIME	NULL
					,	betfrom				NVARCHAR(1)		NULL
					,	matchid				INT				NULL
					,	matchdate			SMALLDATETIME	NULL
					,	finalodds			SMALLMONEY		NULL
					,	bettype				SMALLINT		NULL
					,	BackupDate			DATETIME		NOT NULL
					) ON bettransm_DATA;

	CREATE CLUSTERED INDEX	CIX_bettransm ON dbo.bettransm (
								transid		ASC
							) WITH (DATA_COMPRESSION = PAGE) ON bettransm_DATA;

	CREATE NONCLUSTERED INDEX	IX_bettransm_matchdate ON dbo.bettransm (
									matchdate	ASC
								) WITH (DATA_COMPRESSION = PAGE) ON bettransm_IDX;

	CREATE NONCLUSTERED INDEX	IX_bettransm_matchid ON dbo.bettransm (
									matchid		ASC
								) WITH (DATA_COMPRESSION = PAGE) ON bettransm_IDX;

	CREATE NONCLUSTERED INDEX	IX_bettransm_transdate ON dbo.bettransm (
									transdate	ASC
								) WITH (DATA_COMPRESSION = PAGE) ON bettransm_IDX;
END;


--	BEGIN STEP 3:
--		translog & translogReject
----------------------------------------------------------------------------------------------------

-- translog --
BEGIN;
	CREATE TABLE	dbo.translog (
						translogid			BIGINT			NOT NULL
					,	custid				INT				NOT NULL
					,	transdate			DATETIME		NOT NULL
					,	odds				SMALLMONEY		NULL
					,	stake				MONEY			NOT NULL
					,	status				NVARCHAR(20)	NULL
					,	tpositiontaking		SMALLMONEY		NULL
					,	winlostdate			SMALLDATETIME	NOT NULL
					,	currency			TINYINT			NULL
					,	transdesc			NVARCHAR(2000)	NULL
					,	productID			INT				NOT NULL
					,	gameID				INT				NOT NULL
					,	eventID				INT				NOT NULL
					,	vendorID			INT				NOT NULL
					,	GameId3rd			NVARCHAR(100)	NULL
					,	TranId3rd			NVARCHAR(128)	NULL
					,	custom1				VARCHAR(50)		NULL
					,	custom2				VARCHAR(50)		NULL
					,	custom3				VARCHAR(50)		NULL
					,	LiveIndicator		BIT				NOT NULL
					,	BackupDate			DATETIME		NOT NULL
					) ON translog_DATA;

	CREATE CLUSTERED INDEX	CIX_translog ON dbo.translog (
								eventID			ASC
							) WITH (DATA_COMPRESSION = PAGE) ON translog_DATA;

	CREATE NONCLUSTERED INDEX	IX_translog_translogid ON dbo.translog (
									translogid		ASC
								)
								INCLUDE (currency, stake, odds, custom3, tpositiontaking) WITH (DATA_COMPRESSION = PAGE) ON translog_IDX;

	CREATE NONCLUSTERED INDEX	IX_translog_winlostdate ON dbo.translog (
									winlostdate		ASC
								) WITH (DATA_COMPRESSION = PAGE) ON translog_IDX;

	CREATE NONCLUSTERED INDEX	IX_translog_gameID ON dbo.translog (
									gameID			ASC
								)
								INCLUDE (translogid, currency, stake, odds, custom3, tpositiontaking) WITH (DATA_COMPRESSION = PAGE) ON translog_IDX;
END;

-- translogReject --
BEGIN;
	CREATE TABLE	dbo.translogReject (
						translogid			BIGINT			NOT NULL
					,	custid				INT				NOT NULL
					,	transdate			DATETIME		NOT NULL
					,	odds				SMALLMONEY		NULL
					,	stake				MONEY			NOT NULL
					,	status				NVARCHAR(20)	NULL
					,	tpositiontaking		SMALLMONEY		NULL
					,	winlostdate			SMALLDATETIME	NOT NULL
					,	currency			TINYINT			NULL
					,	transdesc			NVARCHAR(2000)	NULL
					,	productID			INT				NOT NULL
					,	gameID				INT				NOT NULL
					,	eventID				INT				NOT NULL
					,	vendorID			INT				NOT NULL
					,	GameId3rd			NVARCHAR(100)	NULL
					,	TranId3rd			NVARCHAR(128)	NULL
					,	custom1				VARCHAR(50)		NULL
					,	custom2				VARCHAR(50)		NULL
					,	custom3				VARCHAR(50)		NULL
					,	LiveIndicator		BIT				NOT NULL
					,	BackupDate			DATETIME		NOT NULL
					) ON translogReject_DATA;

	CREATE CLUSTERED INDEX	CIX_translogReject ON dbo.translogReject (
								eventID			ASC
							) WITH (DATA_COMPRESSION = PAGE) ON translogReject_DATA;

	CREATE NONCLUSTERED INDEX	IX_translogReject_translogid ON dbo.translogReject (
									translogid		ASC
								) WITH (DATA_COMPRESSION = PAGE) ON translogReject_IDX;

	CREATE NONCLUSTERED INDEX	IX_translogReject_gameID ON dbo.translogReject (
									gameID			ASC
								)
								INCLUDE (translogid, currency, status) WITH (DATA_COMPRESSION = PAGE) ON translogReject_IDX;
END;
GO