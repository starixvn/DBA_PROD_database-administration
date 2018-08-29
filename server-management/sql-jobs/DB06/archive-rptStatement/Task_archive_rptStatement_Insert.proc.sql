SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE [dbo].[Task_archive_rptStatement_Insert]
	@winlostdate DATE
AS
/*
Created: Cody
Date: 20141224
Task : Archive data from rptStament into rptStatementOld at Balance Up Day
DB: DBACC.bodb_report

Revisions:
	- 20150831@Sophia: Apply Colossus Bets - get Grand Prize [#42428] 

*/	
BEGIN
		SET NOCOUNT ON;
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.rptStatement_Old WITH(NOLOCK) WHERE WinlostDate = @winlostdate)
		BEGIN
			INSERT INTO dbo.rptStatement_Old(
				winlostdate
				,custid
				,openingbalance
				,voidamt
				,turnover
				,netturnover
				,transferamt
				,winlost
				,comm
				,closingbalance
				,GrandPrize
			)
			SELECT 
				winlostdate
				,custid
				,openingbalance
				,voidamt
				,turnover
				,netturnover
				,transferamt
				,winlost
				,comm
				,closingbalance
				,GrandPrize
			FROM 
				dbo.rptStatement WITH(NOLOCK)
			WHERE
				winlostdate = @winlostdate
		END
		
		
		DECLARE @DateName varchar(10)
		SELECT @DateName = DATENAME(dw,CONVERT(DATE,@winlostdate))

		IF @DateName = 'Saturday'
		BEGIN
		
			IF OBJECT_ID('tempdb..#MissCustID') IS NOT NULL
			BEGIN
				DROP TABLE #MissCustID
			END
			
			CREATE TABLE #MissCustID(CustID INT)
			
			INSERT INTO #MissCustID
			SELECT 
				DISTINCT
				rptO.custid 
			FROM  dbo.rptStatement_Old rptO  WITH(NOLOCK)
				LEFT JOIN dbo.rptStatement rpt WITH(NOLOCK)
				ON rptO.custid = rpt.custid
			WHERE
				rptO.winlostdate >= DATEADD(DD, -7, @winlostdate)
				AND rpt.custid IS NULL
			
			IF EXISTS(SELECT TOP 1 1 FROM #MissCustID)
			BEGIN
				INSERT INTO dbo.rptStatement_Old(
					winlostdate
					,custid
					,openingbalance
					,voidamt
					,turnover
					,netturnover
					,transferamt
					,winlost
					,comm
					,closingbalance
					,GrandPrize
				)
				SELECT
					@winlostdate winlostdate
					,cus.custid
					,0 openingbalance
					,NULL voidamt
					,NULL turnover
					,NULL netturnover
					,NULL transferamt
					,NULL winlost
					,NULL comm
					,0 closingbalance
					,NULL GrandPrize
				FROM #MissCustID cus
			
			
			END
			DROP  TABLE #MissCustID
		END
END
GO
/*<info serverAlias="DBRPT-bodb_Report" executers="" viewers="" isFunction="0" isNested="0"></info>*/