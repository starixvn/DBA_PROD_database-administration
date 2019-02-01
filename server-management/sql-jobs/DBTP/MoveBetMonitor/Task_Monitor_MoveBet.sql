/*<info serverAlias="DBTP-bodb02" executers="" viewers="vnteam" isFunction="0" isNested="0"></info>*/
GO
CREATE PROCEDURE dbo.Task_Monitor_MoveBet
AS
/*
	Created by: Helen
	Date: 20190201
	Task: Job Move Bets Monitor
	DB: DBTP.bodb02

	Revision:
		- 20190201@Helen:  Job Move Bets Monitor for delete bettransm on DBTRANS, DB052, DB053, DB06 - [Redmine: 108581]
*/
BEGIN
	
	DECLARE @Days AS TABLE (ScheduleId TINYINT, RunningDay DATETIME, IsFinish BIT DEFAULT (0))
	DECLARE @CurrentDateTime DATETIME
	DECLARE @currentDate DATETIME, @startDate DATETIME, @RunningDay DATETIME
	DECLARE @Message NVARCHAR(500), @CheckDBTrans BIT, @CheckDBs VARCHAR(50) = '', @sql NVARCHAR(MAX)
	
	INSERT INTO @Days (ScheduleId, RunningDay)
	EXEC DBTRANS.bobd02.dbo.Task_MoveBetsDayByScheduleSel 

	IF @@ROWCOUNT = 0
		RETURN
	
	SET @currentDate = GETDATE()
	SET @startDate = CONVERT(VARCHAR(10),GETDATE(),126) + ' 17:30:00.000'
	
	-- only checking with 30 minutes since starting movebet job
	IF DATEDIFF(MINUTE,@startDate,@currentDate)> 30 
		RETURN
		
	WHILE 1 = 1 
	BEGIN 
		UPDATE TOP (1) @Days
		SET IsFinish = 1
			,@RunningDay = RunningDay
				WHERE IsFinish = 0
				
		IF @@ROWCOUNT = 0 BREAK
		
		IF DATEDIFF(MINUTE,@startDate,@currentDate)> 5
		BEGIN
			IF EXISTS (SELECT TOP 1 1 
					FROM dbo.bettransm WITH (NOLOCK) 
					WHERE winlostdate = @RunningDay
					)
				SET @CheckDBs = @CheckDBs + ','  + 'DBTRANS'
			
			-- CHECK db052
			SELECT  @sql = N'SELECT * FROM OPENQUERY(DB052, ' + ''''
					+ 'SELECT TOP 1 1 FROM bodb02.dbo.bettransm WITH (NOLOCK) WHERE winlostdate = ' + '''' + + '''' + CONVERT(VARCHAR(10),@RunningDay,101)
					+ '''' + + '''' + ''')'
			EXECUTE sp_executesql @sql ;  

			IF @@ROWCOUNT > 0
				 SET @CheckDBs =  @CheckDBs + ','  + ' DB052'
			
			-- CHECK db053
			SELECT  @sql = N'SELECT * FROM OPENQUERY(DB053, ' + ''''
					+ 'SELECT TOP 1 1 FROM bodb02.dbo.bettransm WITH (NOLOCK) WHERE winlostdate = ' + '''' + + '''' + CONVERT(VARCHAR(10),@RunningDay,101)
					+ '''' + + '''' + ''')'
			EXECUTE sp_executesql @sql ;  

			IF @@ROWCOUNT > 0
				 SET @CheckDBs =  @CheckDBs + ','  + ' DB053'
				 
			-- CHECK db06
			SELECT  @sql = N'SELECT * FROM OPENQUERY(DB06, ' + ''''
					+ 'SELECT TOP 1 1 FROM bodb02.dbo.bettransm WITH (NOLOCK) WHERE winlostdate = ' + '''' + + '''' + CONVERT(VARCHAR(10),@RunningDay,101)
					+ '''' + + '''' + ''')'
			EXECUTE sp_executesql @sql ;  

			IF @@ROWCOUNT > 0
				  SET @CheckDBs =  @CheckDBs + ','  + ' DB06'
			
			SET @CheckDBs = STUFF(@CheckDBs,1,1,'')  
				 	 	  
			SET @Message = 'Duration of deleting bettransm in Move Bet Job on ' + CONVERT(VARCHAR(10),@RunningDay, 101) + ' is being over 5 minutes.' + CHAR(10)
			+ 'Please help check in SERVER: ' + @CheckDBs
			
			--	Sending alert via letstalk 
			EXECUTE DBMONDW.MonDBDW.dbo.DBA_Letstalk_NewJobMessage 
				@ServerName = @@SERVERNAME
				, @JobId = NULL
				, @JobName = N'DBA : Monitor MoveBet Job'
				, @Message = @Message, @CaseId = 1
			--	Sending alert via skype 
			EXECUTE DBMONDW.MonDBDW.dbo.DBA_Skype_NewMessage
				  @ServerName = @@SERVERNAME
				 , @JobId  = NULL
				 , @JobName = N'DBA : Monitor MoveBet Job'
				 , @Message = @message
				 , @isSimple = 1
			
			IF @CheckDBs <> '' 
				BREAK
			
		END
	END
END
GO