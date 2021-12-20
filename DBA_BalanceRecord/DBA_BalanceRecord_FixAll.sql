USE [bodb02]
GO
ALTER PROCEDURE [dbo].[DBA_BalanceRecord_FixAll]
	@display bit = 0
AS
/*
	Created: 20210818@Bobby
	Task: Megre PROD code
	DB: DBBAH/bodb02
		
	Revisions:
		- 20210818@Bobby: Implement new MB day
*/
BEGIN
	IF @display = 0 SET NOCOUNT ON

	DECLARE @moveBetsDay SMALLDATETIME
	EXEC dbo.NAP_Admin_GetMovebetDate @MovebetDate = @moveBetsDay OUTPUT
	IF @moveBetsDay IS NULL
		RETURN

	Declare @LastBTBalance TABLE (custid int PRIMARY KEY, RowID bigint, BTBalance money)
	INSERT INTO @LastBTBalance
	SELECT custid, RowID, BTBalance
	FROM dbo.BalanceRecord with (nolock)
	WHERE RowID IN (
		SELECT MAX(RowID) FROM dbo.BalanceRecord with (nolock)
		WHERE BTBalance Is Not NULL 
		GROUP BY custid
	)
	AND BTBalance <> NewBalance
	AND custid NOT IN (SELECT custid FROM DBTrans.bodb02.dbo.Task_Cust_CheckBalance_Exception)

	Declare @LastNewBalance TABLE (custid int PRIMARY KEY, RowID bigint, NewBalance money)
	INSERT INTO @LastNewBalance
	SELECT custid, RowID, NewBalance 
	FROM dbo.BalanceRecord with (nolock)
	WHERE RowID IN (
		SELECT MAX(RowID) FROM dbo.BalanceRecord with (nolock)
		WHERE custid IN (SELECT custid FROM @LastBTBalance)
		GROUP BY custid
	)

	DELETE B
	FROM @LastBTBalance B
		INNER JOIN @LastNewBalance N ON B.custid = N.custid
	WHERE BTBalance = NewBalance

	--Declare @L TABLE (rid int identity (1,1) PRIMARY KEY, custid int)
	CREATE TABLE #L (rid int identity (1,1) PRIMARY KEY, custid int)Declare @re int
	SET @re = 0

	Declare @r int, @c int, @rx int
	Declare @s1 money, @s2 money, @r1 money, @r2 money,
		@s3 int,@r3 int

		INSERT INTO #L (custid)
		SELECT custid FROM @LastBTBalance

		SET @rx = @@ROWCOUNT

	PRINT CAST(@rx as varchar(10)) + ' accounts'
	SET @r = 1
	WHILE @r <= @rx
	BEGIN
		SELECT @c = custid FROM #L WHERE rid = @r
		SET @r = @r + 1
	
		IF EXISTS (SELECT 1 FROM dbo.BalanceTrigger with (nolock) WHERE custid = @c)
		BEGIN
			DELETE FROM @LastBTBalance WHERE custid = @c
			CONTINUE
		END
	
		BEGIN
			SELECT @s1=SUM(CAST(1 as bigint) * statusid), @s2=SUM(winlost-actual_stake+playercomm), @s3 = COUNT(*) FROM dbo.bettrans with (nolock) WHERE custid = @c
			SELECT @r1=SUM(CAST(1 as bigint) * statusid), @r2=SUM(winlost-actual_stake+playercomm), @r3 = COUNT(*) FROM DBTrans.bodb02.dbo.bettrans with (nolock) WHERE custid = @c
			IF @s2 = @r2
			BEGIN
				IF @s2 = (SELECT NewBalance FROM dbo.BalanceRecord with (nolock) WHERE RowID = (SELECT MAX(RowID) FROM dbo.BalanceRecord with (nolock) WHERE custid = @c))
				BEGIN
					DELETE FROM @LastBTBalance WHERE custid = @c
					CONTINUE
				END
			
				EXEC DBA_BalanceRecord_ReInit @custid = @c
			END
			ELSE
				--SELECT @c custid, @s1 X1, @r1 X2,@s2 SUM1, @r2 SUM2, @s3 CNT1, @r3 CNT2
				IF @s3 <  @r3 -- record missing : sync it
				BEGIN
					SET IDENTITY_INSERT bettrans ON
				
					INSERT INTO dbo.bettrans (
	[transid],[custid],[transdate],[oddsid],[hdp1],[hdp2],[odds],
	[stake],[status],[winlost],[awinlost],[mwinlost],
	[playercomm],[comm],[acomm],[apositiontaking],[mpositiontaking],[tpositiontaking],
	[playerdiscount],[discount],[adiscount],[livehomescore],[liveawayscore],[liveindicator],
	[betteam],[creator],[refno],[comstatus],[winlostdate],[betfrom],
	[betcheck],[checktime],[oddsspread],[actualrate],[matchid],
	[recommend],[mrecommend],[ruben],[betid],[statuswinlost],
	[modds],[bettype],[betdaqid],[actual_stake],[currency],[ip],
	[transdesc],[sdiscount],[scomm],[spositiontaking],[swinlost],[srecommend],
	[Username],[CurrencyName],[virtualrate],[oddstype],[statusID],
	[currency2],[balance],[SecAcceptFlag],[transid2]
					)
					SELECT
	[transid],[custid],[transdate],[oddsid],[hdp1],[hdp2],[odds],
	[stake],[status],[winlost],[awinlost],[mwinlost],
	[playercomm],[comm],[acomm],[apositiontaking],[mpositiontaking],[tpositiontaking],
	[playerdiscount],[discount],[adiscount],[livehomescore],[liveawayscore],[liveindicator],
	[betteam],[creator],[refno],[comstatus],[winlostdate],[betfrom],
	[betcheck],[checktime],[oddsspread],[actualrate],[matchid],
	[recommend],[mrecommend],[ruben],[betid],[statuswinlost],
	[modds],[bettype],[betdaqid],[actual_stake],[currency],[ip],
	[transdesc],[sdiscount],[scomm],[spositiontaking],[swinlost],[srecommend],
	[Username],[CurrencyName],[virtualrate],[oddstype],[statusID],
	[currency2],[balance],[SecAcceptFlag],[transid2]
					FROM DBTrans.bodb02.dbo.bettrans with (nolock)
					WHERE custid = @c
					AND transid NOT IN (SELECT transid FROM dbo.bettrans with (nolock) WHERE custid = @c)
				
					SET @s3 = @s3 + @@ROWCOUNT
					SET IDENTITY_INSERT bettrans OFF				
				END

				IF @s3 >= @r3
				BEGIN
					DELETE FROM dbo.bettrans
					WHERE custid = @c
					AND transid NOT IN (
						SELECT transid FROM DBTrans.bodb02.dbo.bettrans b with (nolock) WHERE custid = @c
						)
					
					UPDATE B5
					SET winlost = b.winlost,
						actual_stake = b.actual_stake,
						playercomm = b.playercomm,
						statusid = b.statusid, [status] = b.[status],
						ruben = b.ruben,
						winlostdate = b.winlostdate
					FROM
						dbo.bettrans B5 with (nolock)
						INNER JOIN DBTrans.bodb02.dbo.bettrans b with (nolock) ON B5.transid = b.transid AND 
						b.custid = @c AND
						(B5.winlost <> b.winlost OR
						B5.actual_stake <> b.actual_stake OR
						B5.playercomm <> b.playercomm OR
						B5.statusid <> b.statusid OR B5.[status] <> b.[status]OR
						B5.ruben <> b.ruben OR
						B5.winlostdate <> b.winlostdate)
					WHERE
						B5.custid = @c
					
					--PRINT 'Update ' + CAST(@@ROWCOUNT as varchar(10)) + ' out of ' + CAST(@s3 as varchar(10))		

					--DELETE FROM dbo.BalanceTrigger with (rowlock) WHERE custid = @c
					--EXEC DBA_BalanceRecord_ReInit @custid = @c
				END
		END
	END

	DROP TABLE #L

	IF @display = 1 
	SELECT B.custid, B.BTBalance, N.NewBalance, CASE WHEN B.RowID = N.RowID THEN 'Yes' ELSE '' END SameRow
	FROM @LastBTBalance B INNER JOIN @LastNewBalance N ON B.custid = N.custid
	ORDER BY B.custid
	--select 'exec task_checkbalance @custid = ',custid,',@action = ''LogAndFix'''
END