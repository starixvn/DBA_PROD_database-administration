SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE [dbo].[Bet_ExecRep_06]
	@matchid int = 0,
	@neweventdate smalldatetime
AS
/*
20150121@Martin(DBTrans):Update Bettransm winlost date if exist when match eventdate changed.
20150904@Martin(DBTrans):From Victor's Project need, add translog and bettransg table need update winlostdate
20180419@Martin(DBTrans):update bettrans winlostdate in batch job
20180607@Martin(DBTrans):hotfix when 1 ticket will not update winlostdate issue.
*/
BEGIN
	IF @matchid <> 0
	BEGIN
		DECLARE @TotalCount int, @rn int
		SET @rn=1
		
		--update bettrans winlose date
		DECLARE @UpdateList1 TABLE (rn int PRIMARY KEY IDENTITY(1,1), transid bigint)
		INSERT INTO @UpdateList1 (transid)
		SELECT transid
		FROM bettrans WITH (NOLOCK)
		WHERE matchid=@matchid AND winlostdate <> @neweventdate
		SET @TotalCount = @@ROWCOUNT
		
		WHILE @rn<=@TotalCount
		BEGIN
			UPDATE bettrans WITH (ROWLOCK,UPDLOCK)
				SET winlostdate = @neweventdate
			WHERE transid in 
				(SELECT transid FROM @UpdateList1 WHERE rn between @rn and @rn+999)
			SET @rn = @rn + 1000
		END
		
		--UPDATE bettrans WITH (ROWLOCK,UPDLOCK)
		--	SET winlostdate = @neweventdate
		--WHERE bettrans.matchid = @matchid

		--update parlay bettransm winlose date if exist
		SET @rn=1
		DECLARE @UpdateList2 TABLE (rn int PRIMARY KEY IDENTITY(1,1), transid bigint)
		INSERT INTO @UpdateList2 (transid)
		SELECT transid
		FROM bettransm WITH (NOLOCK)
		WHERE matchid=@matchid AND winlostdate IS NOT NULL AND winlostdate <> @neweventdate
		SET @TotalCount = @@ROWCOUNT
		
		WHILE @rn<=@TotalCount
		BEGIN
			UPDATE bettransm WITH (ROWLOCK,UPDLOCK)
				SET winlostdate = @neweventdate
			WHERE transid in 
				(SELECT transid FROM @UpdateList2 WHERE rn between @rn and @rn+999)
			SET @rn = @rn + 1000
		END
		--UPDATE bettransm WITH (ROWLOCK,UPDLOCK)
		--	SET winlostdate = @neweventdate
		--WHERE matchid = @matchid
		--	AND winlostdate IS NOT NULL

		--update live casino bettransg winlost date if exist
		SET @rn=1
		DECLARE @UpdateList3 TABLE (rn int PRIMARY KEY IDENTITY(1,1), transid bigint)
		INSERT INTO @UpdateList3 (transid)
		SELECT transid
		FROM bettransg WITH (NOLOCK)
		WHERE matchid=@matchid AND winlostdate IS NOT NULL AND winlostdate <> @neweventdate
		SET @TotalCount = @@ROWCOUNT
		
		WHILE @rn<=@TotalCount
		BEGIN
			UPDATE bettransg WITH (ROWLOCK,UPDLOCK)
				SET winlostdate = @neweventdate
			WHERE transid in 
				(SELECT transid FROM @UpdateList3 WHERE rn between @rn and @rn+999)
			SET @rn = @rn + 1000
		END
		--UPDATE bettransg WITH (ROWLOCK,UPDLOCK)
		--	SET winlostdate = @neweventdate
		--WHERE matchid = @matchid

		--update 3rd translog winlost date if exist
		SET @rn=1
		DECLARE @UpdateList4 TABLE (rn int PRIMARY KEY IDENTITY(1,1), transid bigint)
		INSERT INTO @UpdateList4 (transid)
		SELECT translogid
		FROM translog WITH (NOLOCK)
		WHERE eventID = @matchid AND Gameid between 801 AND 806 AND winlostdate <> @neweventdate
		SET @TotalCount = @@ROWCOUNT
		
		WHILE @rn<=@TotalCount
		BEGIN
			UPDATE translog WITH (ROWLOCK,UPDLOCK)
				SET winlostdate = @neweventdate
			WHERE translogid in 
				(SELECT transid FROM @UpdateList4 WHERE rn between @rn and @rn+999)
			SET @rn = @rn + 1000
		END
		--UPDATE translog WITH (ROWLOCK,UPDLOCK)
		--	SET winlostdate = @neweventdate
		--WHERE eventID = @matchid and Gameid between 801 and 806
	END
END
GO
/*<info serverAlias="DBTXN-bodb02" executers="" viewers="" isFunction="0" isNested="0"></info>*/