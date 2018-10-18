SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE [dbo].[Bet_ExecRep_08]
	@matchid int = 0,
	@neweventdate smalldatetime
AS
/*
	Revisions:
		20150121@Martin(DBTrans):Update Bettransm winlost date if exist when match eventdate changed.
		20150904@Martin(DBTrans):From Victor's Project need, add translog and bettransg table need update winlostdate
*/
BEGIN
	IF @matchid <> 0
	BEGIN
		--update bettrans winlose date
		UPDATE bettrans WITH (ROWLOCK,UPDLOCK)
			SET winlostdate = @neweventdate
		WHERE bettrans.matchid = @matchid

		--update parlay bettransm winlose date if exist
		UPDATE bettransm WITH (ROWLOCK,UPDLOCK)
			SET winlostdate = @neweventdate
		WHERE matchid = @matchid
			AND winlostdate IS NOT NULL

		--update live casino bettransg winlost date if exist
		UPDATE bettransg WITH (ROWLOCK,UPDLOCK)
			SET winlostdate = @neweventdate
		WHERE matchid = @matchid

		--update 3rd translog winlost date if exist
		UPDATE translog WITH (ROWLOCK,UPDLOCK)
			SET winlostdate = @neweventdate
		WHERE eventID = @matchid and Gameid between 801 and 806
	END
END
GO
/*<info serverAlias="DBTXN-bodb02" executers="" viewers="" isFunction="0" isNested="0"></info>*/