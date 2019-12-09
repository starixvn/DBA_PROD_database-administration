/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE Acc_ExecRep_Cust_01
	@CustIDs VARCHAR(MAX) 	= ''
AS
/*
	Created:	Daniel
	Date:		20191205
	Task:		Archive Credit Account - Delete data
	DB:			DBCUST/CustDB
	Original:	

	Revisions:
		- 20191205@Daniel: Initialize
	
	Param's Explanation:
		@CustIDs: input list of CustIDs to clean data
*/

	DECLARE @tmpCust TABLE(CustID INT)
			    
	INSERT INTO @tmpCust(custid)	
	SELECT val
	FROM dbo.strSplit(@CustIDs,',')
	
	IF dbo.f_CheckRepTable('CustBetSetting3rd_Agent') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.CustBetSetting3rd_Agent WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END

	IF dbo.f_CheckRepTable('custsetting') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.custsetting WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END

	-----------------------------------

	IF dbo.f_CheckRepTable('customer') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.customer WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END

	IF dbo.f_CheckRepTable('custinfo') = 1 		
	WHILE(1=1)
	BEGIN
		DELETE TOP(10000) dbo.custinfo WITH (ROWLOCK)
		WHERE	custid IN (SELECT custid FROM @tmpCust) 
	
		IF @@ROWCOUNT < 10000 
			BREAK
	END


