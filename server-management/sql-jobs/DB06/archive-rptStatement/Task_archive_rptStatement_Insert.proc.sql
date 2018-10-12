SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE	dbo.Task_archive_rptStatement_Insert
						@winlostdate	DATE
AS
/*
	Created: Cody
	Date: 20141224
	Task : Archive data from rptStament into rptStatementOld at Balance Up Day
	DB: DBACC.bodb_Report

	Revisions:
		- 20150831@Sophia:	Apply Colossus Bets - get Grand Prize - [Redmine - #42428] 
		- 20181012@Billy:	Performance workaround - [Redmine: #103163]
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE	@DateName	VARCHAR(10)
		,	@Query		NVARCHAR(MAX)
		;
	
	IF	OBJECT_ID('tempdb..#MissCustID') IS NOT NULL
		DROP TABLE	#MissCustID;

	CREATE TABLE	#MissCustID (
						CustID	INT		PRIMARY KEY
					);

	IF	OBJECT_ID('tempdb..#ActiveCustID') IS NOT NULL
		DROP TABLE	#ActiveCustID;

	CREATE TABLE	#ActiveCustID (
						CustID	INT		PRIMARY KEY
					);

	IF	NOT EXISTS (
			SELECT	TOP(1) 1
			FROM	dbo.rptStatement_Old WITH (NOLOCK)
			WHERE	WinlostDate = @winlostdate
		)
	BEGIN
		INSERT	INTO dbo.rptStatement_Old
			(	WinlostDate, Custid, OpeningBalance, VoidAmt, Turnover, NetTurnover, TransferAmt, Winlost, Comm, ClosingBalance, GrandPrize)
		SELECT	winlostdate, custid, openingbalance, voidamt, turnover, netturnover, transferamt, winlost, comm, closingbalance, GrandPrize
		FROM	dbo.rptStatement WITH (NOLOCK)
		WHERE	winlostdate = @winlostdate;
	END;

	SELECT	@DateName = DATENAME(WEEKDAY, CONVERT(DATE, @winlostdate));

	IF @DateName = 'Saturday'
	BEGIN
		INSERT INTO	#ActiveCustId (CustID)
		SELECT	DISTINCT
				custid
		FROM	dbo.rptStatement WITH (NOLOCK);
		
		SELECT	@Query = N'';
		SELECT	@Query = @Query + N'
SELECT	DISTINCT CustID
FROM	dbo.rptStatement_Old WITH (NOLOCK)
WHERE	WinlostDate >= ''' + CONVERT(NVARCHAR(MAX), DATEADD(DAY, -7, @winlostdate), 120) + N''';
';

		INSERT INTO	#MissCustID (CustID)
		EXECUTE	sys.sp_executesql @Query;
		
		DELETE	mss WITH (TABLOCK)
		FROM		#MissCustID AS mss
		INNER JOIN	#ActiveCustId AS act WITH (NOLOCK)
				ON	mss.CustID = act.CustID;

		IF	EXISTS (SELECT 1 FROM #MissCustID WITH (NOLOCK))
		BEGIN
			INSERT INTO	dbo.rptStatement_Old
				(	 WinlostDate,     Custid, OpeningBalance, VoidAmt, Turnover, NetTurnover, TransferAmt, Winlost, Comm, ClosingBalance, GrandPrize)
			SELECT	@winlostdate, cus.CustID, 0             , NULL   , NULL    , NULL       , NULL       , NULL   , NULL, 0             , NULL
			FROM	#MissCustID AS cus WITH (NOLOCK);
		END;
	END;
	
	DROP TABLE	#MissCustID;
	DROP TABLE	#ActiveCustID;
END;
GO
/*<info serverAlias="DBRPT-bodb_Report" executers="" viewers="" isFunction="0" isNested="1"></info>*/