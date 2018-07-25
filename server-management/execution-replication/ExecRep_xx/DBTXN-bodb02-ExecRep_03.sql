USE	bodb02;
GO

ALTER PROCEDURE [dbo].[ExecRep_03]
	@matchid int = 0,
	@neweventdate smalldatetime
AS
/*
20150121@Martin(DBTrans):Update Bettransm winlost date if exist when match eventdate changed.
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
	END
END

GO
/*<info serverAlias="DBTXN-bodb02" executers="" viewers="" isFunction="0" isNested="0"></info>*/