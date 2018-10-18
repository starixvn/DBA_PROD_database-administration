SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE [dbo].[ExecRep_APL_04]
	@Type int ,
	@DelIDList varchar(4000)
AS
/*
	@TYPE = 1 : Dot_ParlayMatchSetting	replicatoin [DB02_Odds_Info]
			2 : match_streaming			replicatoin [DB02_Odds_Info]
			3 : OddsSetting				replicatoin [DB02_Odds_Odds]
			4 : odds_flex				replicatoin [DB02_Odds_Odds], [DB02_Odds_Small]
			5 : odds_NumberWheel		replicatoin [DB02_Odds_Odds], [DB02_Odds_Small], [DB02_Trans_Odds_Small]
			6 : oddsHistory				replicatoin [DB02_Odds_Info]
			7 : MatchReportDetail		no replication
			8 : odds_maxbet				replicatoin [DB02_Odds_Small], [DB02_Sync_DR]

	Revisions:
		--20171018@change Clean up job use Replicaiton , execute from SP:DBA_CleanDataRelatedMatchandOddsTable
*/
BEGIN

	SET NOCOUNT ON 
	DECLARE @removedata TABLE 	( [Dataid] bigint NOT NULL )

	DECLARE @Dataid bigint ,
			@DataCnt int

	INSERT INTO @removedata SELECT val FROM [dbo].[strSplit] ( @DelIDList , ',' )
	SET @DataCnt = @@Rowcount

	IF @Type = 1 and EXISTS (SELECT * FROM sys.objects with(nolock) WHERE object_id = OBJECT_ID(N'[dbo].[Dot_ParlayMatchSetting]') AND type = (N'U'))
	BEGIN	
		--Clean Table Dot_ParlayMatchSetting 
		WHILE  @DataCnt > 0
		BEGIN
	
			SELECT TOP 1 @Dataid = Dataid FROM @removedata

			WHILE 1 = 1
			BEGIN

				DELETE TOP ( 2000 ) FROM Dot_ParlayMatchSetting  WITH (ROWLOCK, UPDLOCK) WHERE Matchid = @Dataid
				IF @@Rowcount < 2000 BREAK  

			END	

			DELETE @removedata WHERE Dataid = @Dataid
			SET @DataCnt = @DataCnt - 1

		END
	END

	IF @Type = 2 and EXISTS (SELECT * FROM sys.objects with(nolock) WHERE object_id = OBJECT_ID(N'[dbo].[match_streaming]') AND type = (N'U'))
	BEGIN
		--Clean Table match_streaming 
		WHILE  @DataCnt > 0
		BEGIN
	
			SELECT TOP 1 @Dataid = Dataid FROM @removedata

			WHILE 1 = 1
			BEGIN

				DELETE TOP ( 2000 ) FROM match_streaming  WITH (ROWLOCK, UPDLOCK) WHERE Matchid = @Dataid
				IF @@Rowcount < 2000 BREAK  

			END

			DELETE @removedata WHERE Dataid = @Dataid
			SET @DataCnt = @DataCnt - 1

		END
	END

	IF @Type = 3 and EXISTS (SELECT * FROM sys.objects with(nolock) WHERE object_id = OBJECT_ID(N'[dbo].[OddsSetting]') AND type = (N'U'))
	BEGIN
		--Clena Table OddsSetting 
		WHILE  @DataCnt > 0
		BEGIN
	
			SELECT TOP 1 @Dataid = Dataid FROM @removedata

			WHILE 1 = 1
			BEGIN

				DELETE TOP ( 2000 ) FROM OddsSetting  WITH (ROWLOCK, UPDLOCK) WHERE oddsid = @Dataid
				IF @@Rowcount < 2000 BREAK  

			END

			DELETE @removedata WHERE Dataid = @Dataid
			SET @DataCnt = @DataCnt - 1

		END
	END

	IF @Type = 4 and EXISTS (SELECT * FROM sys.objects with(nolock) WHERE object_id = OBJECT_ID(N'[dbo].[odds_flex]') AND type = (N'U'))
	BEGIN
		--Clena Table odds_flex 
		WHILE  @DataCnt > 0
		BEGIN
	
			SELECT TOP 1 @Dataid = Dataid FROM @removedata

			WHILE 1 = 1
			BEGIN

				DELETE TOP ( 2000 ) FROM odds_flex  WITH (ROWLOCK, UPDLOCK) WHERE oddsid = @Dataid
				IF @@Rowcount < 2000 BREAK  

			END

			DELETE @removedata WHERE Dataid = @Dataid
			SET @DataCnt = @DataCnt - 1

		END
	END

	IF @Type = 5  and EXISTS (SELECT * FROM sys.objects with(nolock) WHERE object_id = OBJECT_ID(N'[dbo].[odds_NumberWheel]') AND type = (N'U'))
	BEGIN
		--Clena Table odds_NumberWheel 
		WHILE  @DataCnt > 0
		BEGIN
	
			SELECT TOP 1 @Dataid = Dataid FROM @removedata

			WHILE 1 = 1
			BEGIN

				DELETE TOP ( 2000 )FROM odds_NumberWheel  WITH (ROWLOCK, UPDLOCK) WHERE oddsid = @Dataid
				IF @@Rowcount < 2000 BREAK  

			END

			DELETE @removedata WHERE Dataid = @Dataid
			SET @DataCnt = @DataCnt - 1

		END
	END

	IF @Type = 6 and EXISTS (SELECT * FROM sys.objects with(nolock) WHERE object_id = OBJECT_ID(N'[dbo].[oddsHistory]') AND type = (N'U'))
	BEGIN
		--Clena Table oddsHistory
		WHILE  @DataCnt > 0
		BEGIN
	
			SELECT TOP 1 @Dataid = Dataid FROM @removedata

			WHILE 1 = 1
			BEGIN

				DELETE TOP ( 2000 ) FROM oddsHistory  WITH (ROWLOCK, UPDLOCK) WHERE oddsid = @Dataid
				IF @@Rowcount < 2000 BREAK  

			END

			DELETE @removedata WHERE Dataid = @Dataid
			SET @DataCnt = @DataCnt - 1

		END
	END

	IF @Type = 7 and EXISTS (SELECT * FROM sys.objects with(nolock) WHERE object_id = OBJECT_ID(N'[dbo].[MatchReportDetail]') AND type = (N'U'))
	BEGIN
		--Clean Table MatchReportDetail	no replication
		WHILE  @DataCnt > 0
		BEGIN
	
			SELECT TOP 1 @Dataid = Dataid FROM @removedata

			WHILE 1 = 1
			BEGIN

				DELETE TOP ( 2000 ) FROM MatchReportDetail  WITH (ROWLOCK, UPDLOCK) WHERE Matchid = @Dataid
				IF @@Rowcount < 2000 BREAK  

			END

			DELETE @removedata WHERE Dataid = @Dataid
			SET @DataCnt = @DataCnt - 1		

		END
	END

	IF @Type = 8 and EXISTS (SELECT * FROM sys.objects with(nolock) WHERE object_id = OBJECT_ID(N'[dbo].[odds_maxbet]') AND type = (N'U'))
	BEGIN
		--Clean Table odds_maxbet
		WHILE  @DataCnt > 0
		BEGIN
	
			SELECT TOP 1 @Dataid = Dataid FROM @removedata

			WHILE 1 = 1
			BEGIN

				DELETE TOP ( 2000 )FROM odds_maxbet  WITH (ROWLOCK, UPDLOCK) WHERE oddsid = @Dataid
				IF @@Rowcount < 2000 BREAK  

			END

			DELETE @removedata WHERE Dataid = @Dataid
			SET @DataCnt = @DataCnt - 1	

		END
	END
END
GO
/*<info serverAlias="DBPRO-bodb02" executers="" viewers="" isFunction="0" isNested="0"></info>*/