USE [bodb02]
GO
ALTER PROCEDURE [dbo].[DBA_BalanceRecord_FixRecent]
AS
/*
	Created: 20210818@Bobby
	Task: Megre PROD code
	DB: DBBAH/bodb02
		
	Revisions:
		- 20210818@Bobby: Implement new MB day
*/
BEGIN
	--Declare @L TABLE (rid int identity (1,1) PRIMARY KEY, custid int)
	CREATE TABLE #L (rid int identity (1,1) PRIMARY KEY, custid int)
	Declare @re int
	SET @re = 0

	Declare @r int,@c int, @rx int
	Declare @s1 money, @s2 money, @r1 money, @r2 money,
		@s3 int,@r3 int

	IF @re = 0
	BEGIN
		TRUNCATE TABLE #L
		INSERT INTO #L (custid)
		--SELECT BTBalance, NewBalance, * FROM (
		SELECT DISTINCT custid FROM (
		SELECT TOP 10000 *
		FROM BalanceRecord (nolock)
		ORDER BY RowID DESC
		) X WHERE BTBalance <> NewBalance AND BTBalance IS NOT NULL
		AND custid NOT IN (SELECT custid FROM DBTrans.bodb02.dbo.Task_Cust_CheckBalance_Exception)

		SET @rx = @@ROWCOUNT
	END
	ELSE
		SELECT @rx = COUNT(*) FROM #L


	-- give delay to allow data clearance.
	WAITFOR DELAY '000:00:20.000'

	Declare @rcnt int, @TopBTBalance money, @TopNewBalance money, @MaxTransID bigint
	Declare @CheckTotal int, @Skip int, @NormalInit int, @TicketInsert int, @TicketUpdate int, @TicketDelete int, @List varchar(2000)
	SELECT @CheckTotal = @rx, @Skip = 0, @NormalInit = 0, @TicketInsert = 0, @TicketUpdate = 0 , @TicketDelete = 0, @List = ''

	SET @r = 1
	WHILE @r <= @rx
	BEGIN
		SELECT @c = custid FROM #L WHERE rid = @r
		SET @r = @r + 1


		IF EXISTS (SELECT 1 FROM dbo.BalanceTrigger with (nolock) WHERE custid = @c)
		BEGIN
			SET @Skip = @Skip + 1
			CONTINUE
		END

		SELECT TOP 1 @TopBTBalance  = BTBalance  FROM dbo.BalanceRecord WHERE custid = @c AND BTBalance IS NOT NULL ORDER BY RowID
		SELECT TOP 1 @TopNewBalance = NewBalance FROM dbo.BalanceRecord WHERE custid = @c ORDER BY RowID
		IF (@TopBTBalance = @TopNewBalance)
		BEGIN
			SET @Skip = @Skip + 1
			CONTINUE
		END
	
	
	
		IF NOT EXISTS (SELECT 1 FROM dbo.BalanceTrigger with (nolock) WHERE custid = @c)
		BEGIN
			SELECT @s1=SUM(CAST(1 as bigint) * statusid), @s2=SUM(winlost-actual_stake+playercomm), @s3 = COUNT(*) FROM dbo.bettrans with (nolock) WHERE custid = @c
			SELECT @r1=SUM(CAST(1 as bigint) * statusid), @r2=SUM(winlost-actual_stake+playercomm), @r3 = COUNT(*) FROM DBTrans.bodb02.dbo.bettrans with (nolock) WHERE custid = @c
			IF @s2 = @r2
			BEGIN
				IF @s2 = (SELECT NewBalance FROM dbo.BalanceRecord with (nolock) WHERE RowID = (SELECT MAX(RowID) FROM dbo.BalanceRecord with (nolock) WHERE custid = @c))
				BEGIN
					SET @Skip = @Skip + 1
					CONTINUE
				END
				
				EXEC DBA_BalanceRecord_ReInit @custid = @c
				SET @NormalInit = @NormalInit + 1
				SET @List = @List + ', ' + CAST(@c as varchar(20)) + ' '
			END
			ELSE
				--SELECT @c custid, @s1 X1, @r1 X2,@s2 SUM1, @r2 SUM2, @s3 CNT1, @r3 CNT2
				IF @s3 <  @r3 -- record missing : sync it
				BEGIN
					SELECT @MaxTransID = MAX(transid) FROM dbo.bettrans with (nolock)
			
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
	'FI:' + [transdesc],[sdiscount],[scomm],[spositiontaking],[swinlost],[srecommend],
	[Username],[CurrencyName],[virtualrate],[oddstype],[statusID],
	[currency2],[balance],[SecAcceptFlag],[transid2]
					FROM DBTrans.bodb02.dbo.bettrans with (nolock)
					WHERE custid = @c
					AND transid NOT IN (SELECT transid FROM dbo.bettrans with (nolock) WHERE custid = @c)
					AND transid <= @MaxTransID

					SET @rcnt = @@ROWCOUNT				
					SET @s3 = @s3 + @rcnt
					SET IDENTITY_INSERT bettrans OFF
				
					IF @rcnt <> 0 SET @TicketInsert = @TicketInsert + 1
				END

				IF @s3 >= @r3
				BEGIN
					DELETE FROM dbo.bettrans
					WHERE custid = @c
					AND transid NOT IN (
						SELECT transid FROM DBTrans.bodb02.dbo.bettrans b with (nolock) WHERE custid = @c
						)
					
					IF @@ROWCOUNT <> 0 SET @TicketDelete = @TicketDelete + 1

					UPDATE B5
					SET winlost = b.winlost,
						actual_stake = b.actual_stake,
						playercomm = b.playercomm,
						statusid = b.statusid, [status] = b.[status],
						ruben = b.ruben,
						winlostdate = b.winlostdate,
						transdesc = 'FU:' + B5.transdesc
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
					
					IF @@ROWCOUNT <> 0 SET @TicketUpdate = @TicketUpdate + 1
					
					--PRINT 'Update ' + CAST(@@ROWCOUNT as varchar(10)) + ' out of ' + CAST(@s3 as varchar(10))		
					--DELETE FROM dbo.BalanceTrigger with (rowlock) WHERE custid = @c
					--EXEC DBA_BalanceRecord_ReInit @custid = @c
				END
		END
	END

	DROP TABLE #L

	PRINT 'Check : ' + CAST(@rx as varchar(10)) + ' Accounts'
	+ ', Skip = ' + CAST(@Skip as varchar(10))
	+ ', Init = ' + CAST(@NormalInit as varchar(10))
	+ ', Ins = ' + CAST(@TicketInsert as varchar(10))
	+ ', Del = ' + CAST(@TicketDelete as varchar(10))
	+ ', Upd = ' + CAST(@TicketUpdate as varchar(10))
	+ @List
END
GO
