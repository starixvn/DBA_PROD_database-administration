/*
	Task: Alter sps to sync data to DB042 from this server (HA DB053 down)
	Run at DB052

*/


USE [bodb02]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[Task_BATransaction_CheckAndCorrect]  
AS  
/*  
	Created by:[Henry]  
	Date: 2011-06-20  
	Task: Check missing BA tickets  
	DB: DBEXT-bodb02,DBACC-bodb02
	Revisions:   
		20110824@Henry: Insert the missing tickets if happen  
		20110905@Jamie: Modify remove comma ','  
		20111208@Jim: change bettype condition   
		20150204@Don: Expand bet type ranges for Sportbook when processing BA  
		20150904@Patrick: Exclude bettype 901 for bettrade
		20170410@Harper: Implement Cashout Product
		20180806@Patrick: Sync BA ticket to DB042 [Redmine #98631]
		20181114@Sophia: Revise Job Verify BA - Rename SP from Task_BATransaction_Check To Task_BATransaction_CheckAndCorrect [Redmine: #103653]
		20181120@Sophia: Change 'DB052' To 'DB053' for steap switch to DB053 [Redmine: #103653]
		20180412@Percy: Expand Sportsbook bettype range - ESports [RedmineID: #100721]
 */  
SET NOCOUNT ON   
   
 --Query data with DONE status  
DECLARE @BATransaction TABLE (custid INT, transid BIGINT, transdate DATETIME)  
  
DECLARE @BAHistory_Done TABLE (custid INT, ondate DATETIME, offdate DATETIME)  
INSERT INTO @BAHistory_Done  
SELECT custid, ondate, offdate  
FROM bodb_Licensee.dbo.LicenseeBAHistory WITH (nolock)  
WHERE LicenseeID IN (
	SELECT LicenseeID 
	FROM bodb_Licensee.dbo.LicenseeBAConfig (NOLOCK) 
	WHERE EnableBA = 1
)  
AND status = 'Done'  
  
DECLARE @custid INT, @ondate DATETIME, @offdate DATETIME, @cnt INT  
StartLoop:  
    SELECT TOP 1 @custid = custid, @ondate = ondate, @offdate = offdate FROM @BAHistory_Done  
         
    SELECT @cnt = @@ROWCOUNT  
    IF @cnt = 0 GOTO EndLoop  
  
        INSERT INTO @BATransaction  
        SELECT custid, transid, transdate  
        FROM bettrans WITH (NOLOCK)  
        WHERE custid = @custid  
            AND transdate BETWEEN @ondate AND @offdate  
            AND tpositiontaking = 0  
            AND (bettype < 31 OR (bettype BETWEEN 121 AND 999) OR (bettype BETWEEN 1301 AND 1399) OR (bettype BETWEEN 9001 AND 9399))  
			AND bettype NOT IN (901, 911)
                   
    DELETE FROM @BAHistory_Done WHERE custid = @custid AND ondate = @ondate AND offdate = @offdate  
  
    GOTO StartLoop  
EndLoop:  
  
--Query data with Running status  
DECLARE @BAHistory_Running TABLE (custid INT, ondate DATETIME)  
INSERT INTO @BAHistory_Running  
SELECT custid, ondate  
FROM bodb_Licensee.dbo.LicenseeBAHistory WITH (NOLOCK)  
WHERE LicenseeID IN (
	SELECT LicenseeID 
	FROM bodb_Licensee.dbo.LicenseeBAConfig (NOLOCK) 
	WHERE EnableBA = 1
)  
AND STATUS = 'running'  
  
DECLARE @custid_r INT, @ondate_r DATETIME, @cnt_r INT  
StartLoop_r:  
    SELECT TOP 1 @custid_r = custid, @ondate_r = ondate FROM @BAHistory_Running  
         
    SELECT @cnt_r = @@ROWCOUNT  
    IF @cnt_r = 0 GOTO EndLoop_r  
  
        INSERT INTO @BATransaction  
        SELECT custid, transid, transdate  
        FROM bettrans WITH (NOLOCK)  
        WHERE custid = @custid_r  
            AND transdate >= @ondate_r  
            AND tpositiontaking =0  
            AND (bettype < 31 OR (bettype BETWEEN 121 AND 999) OR (bettype BETWEEN 1301 AND 1399) OR (bettype BETWEEN 9001 AND 9399))  
			AND bettype NOT IN (901, 911)
         
    DELETE FROM @BAHistory_Running WHERE custid = @custid_r AND ondate = @ondate_r  
  
    GOTO StartLoop_r  
EndLoop_r:  
  
IF (SELECT count(a.transid)   
	FROM @BATransaction a  
		LEFT JOIN bodb_licensee.dbo.licenseebatransaction b (nolock) ON a.transid = b.transid  
	WHERE b.transid IS NULL) > 0  
BEGIN  
	DECLARE @BATicket TABLE (TransID BIGINT, Transdate DATETIME)  
   
	INSERT INTO @BATicket(TransID, Transdate)  
	SELECT a.transid,a.transdate 
	FROM @BATransaction a  
		LEFT JOIN bodb_licensee.dbo.licenseebatransaction b (nolock) ON a.transid = b.transid  
	WHERE b.transid IS NULL  
   
	DECLARE @tickets VARCHAR(7500)  
	DECLARE @alert VARCHAR(8000), @currentMaxTransID VARCHAR(50)  
   
	SELECT @tickets=''  
	SELECT @tickets =@tickets  + CAST(TransID AS varchar(20)) + ','  
	FROM @BATicket    
  
	IF LEN(RTRIM(LTRIM(@tickets))) > 1  
	BEGIN  
		INSERT INTO bodb_licensee.dbo.licenseebatransaction (TransID,Transdate)  
		SELECT transid,transdate FROM @BATicket  
    
		INSERT INTO bodb_licensee.dbo.licenseebatransaction_active (TransID,Transdate, custid, recommend, srecommend)  
		SELECT transid, transdate, custid, recommend, srecommend  
		FROM dbo.bettrans with(nolock)  
		where transid in (select transid from @BATicket)

		--Add more code to sync data to DB042 --> temporary solution
		DECLARE @XmlData NVARCHAR(MAX)
		SET @XmlData = (
			SELECT TransId AS t, Transdate AS td, custid AS c, recommend AS r, srecommend AS s
			FROM bodb_licensee.dbo.LicenseeBATransaction_active t
			WHERE EXISTS (SELECT TOP 1 1 FROM @BATicket tt WHERE t.TransID = tt.TransID)
			FOR XML RAW('r'), root
		)
		
		IF @XmlData IS NOT NULL AND @@SERVERNAME = 'DB052' 
			EXEC DB042.bodb_Licensee.dbo.Task_BATransaction_Copy_Ticket @XmlData = @XmlData
  
		SELECT @currentMaxTransID = VValue  
		FROM DBTXN.BODB02.DBO.SystemSettings WITH (NOLOCK)  
		WHERE VName='MaxTransID'  
  
		SELECT @tickets = substring(@tickets,0,len(@tickets)) --remove last comma  
		SELECT @alert = 'Missing one or more BA tickets: ' + @tickets + ' .The job has just inserted the missing tickets.' + ' Current Max TransID:' + @currentMaxTransID  
		RAISERROR (@alert, 16, 1)    
  
	END
END

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[Task_BATransaction_Ins]
AS  
/*  
	Created by:[Henry]  
	Date: 2011-06-20  
	Task: Insert BA Bets to LicenseeBATransaction  
	DB: DB052.BODB02  
	Revisions:   
		20110824@Henry: Change the range of the bettype (not between 31 and 120)  
		20110909@Viet: revise SP  
		20111208@Jim: Change bettype condition  
		20100315@kIWI: Remove @TempBACustID table   
		20121030@Viet: change the way to get data, reduce load for server.  
		20150127@Don: Expand bet type ranges for Sportbook when processing BA
		20150903@Patrick: #42910: Exclude ticket 901 for BetTrade
		20160301@Don: Add hard-code of [transid < 100000000000]
		20160416@Francis: Revert hard-code of [transid < 100000000000]
		20170410@Paul: Implement Cash Out [RedmineID :#71727]
		20180806@Patrick: Sync BA ticket to DB042 [Redmine #98631]
		20181002@Sophia: Sync BA ticket to DB053 (UAT) [Redmine #99855]
		20181025@Sophia: Revert SPs not to sync BA ticket to DB053, due to DB053 has the job Gen BA ticket by itself (PRO) [Redmine #99855]	
		20181107@Patrick: DB052 Indexes Revolution [Redmine: #103572]
		20181120@Sophia: Change 'DB052' To 'DB053' for steap switch to DB053 [Redmine: #103653]
		20180412@Percy: Expand Sportsbook bettype range - ESports [RedmineID: #100721]
 */  
BEGIN
	SET NOCOUNT ON   
  
	DECLARE @temptrans AS TABLE (transid BIGINT, transdate DATETIME, custid INT, recommend INT, srecommend INT)  
    
	DECLARE @smallID BIGINT, @maxtransID BIGINT, @currentDate DATETIME    
	-- scan each transid twice to prevent missing by locking  
	SELECT @smallID = cast(isnull(vvalue,0) AS BIGINT)  
	FROM bodb_licensee.dbo.LICSettings WITH(ROWLOCK)   
	WHERE vname = 'BA_transid'   
  
	SELECT @maxtransID = max(transid) FROM dbo.bettrans WITH(NOLOCK) --WHERE transid < 100000000000
       
	UPDATE bodb_licensee.dbo.LICSettings WITH(ROWLOCK, UPDLOCK)  
	SET vvalue = vvalue2  
	,vvalue2 = cast(@maxtransID AS VARCHAR(200))  
	WHERE vname = 'BA_transid'  
  
	INSERT INTO @temptrans (transid, transdate, custid, recommend, srecommend)  
	SELECT transid, transdate, custid, recommend, srecommend
	FROM dbo.bettrans WITH(NOLOCK, index=PK_bettrans) --IXU_transid/PK_bettrans
	WHERE TransID BETWEEN @smallID AND @maxtransID  
		AND (Bettype < 31 OR (Bettype BETWEEN 121 AND 999) OR (Bettype BETWEEN 1301 AND 1399) OR (Bettype BETWEEN 9001 AND 9399))  
		AND StatusID <> 121 --DONE  
		AND tpositiontaking = 0
		AND (bettype < 901 OR bettype > 904)
		AND (bettype < 911 OR bettype > 914)
  
	IF @@ROWCOUNT = 0 RETURN  
   
	DELETE @temptrans  
	WHERE custid NOT IN (  
			SELECT CustID   
			FROM bodb_Licensee.dbo.LicenseeBAHistory WITH (NOLOCK)   
			WHERE Status = 'Running'  
				OR (Status = 'Done'  
					AND DATEDIFF(MINUTE,OffDate,CURRENT_TIMESTAMP)<=2)  

			UNION ALL --Cash Out

			SELECT custid
			FROM dbo.TradeCust WITH(NOLOCK)
			WHERE VendorID = 14
		) 

   
	DELETE t   
	FROM @temptrans t  
		INNER JOIN bodb_Licensee.dbo.LicenseeBATransaction ba WITH(NOLOCK) ON t.TransID = ba.TransID  
   
	INSERT INTO Bodb_Licensee.dbo.LicenseeBATransaction (TransID, Transdate)  
	SELECT TransID, Transdate   
	FROM @temptrans  
  
	INSERT INTO Bodb_Licensee.dbo.LicenseeBATransaction_active (TransID, Transdate, custid, recommend, srecommend)  
	SELECT TransID, Transdate, custid, recommend, srecommend  
	FROM @temptrans

	--Add more code to sync data to DB042 --> temporary solution
	DECLARE @XmlData NVARCHAR(MAX) 
	SET @XmlData = (
		SELECT TransId AS t, Transdate AS td, custid AS c, recommend AS r, srecommend AS s
		FROM @temptrans
		FOR XML RAW('r'), root
	)	
	
	IF @XmlData IS NOT NULL AND @@SERVERNAME = 'DB052' 
		EXEC DB042.bodb_Licensee.dbo.Task_BATransaction_Copy_Ticket @XmlData = @XmlData
		
END

GO

GRANT VIEW DEFINITION ON [dbo].[Task_BATransaction_Ins] TO [vnteam] AS [dbo]
GO


