/*<info serverAlias="DBSTARIX-starixDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[vnDBA_sp_Monitor_GetReplAlert]
(
	@ServerName NVARCHAR (128) = 'DB052'
	,@PublicationName NVARCHAR (128) = 'DBTrans_Bet'
	, @isLatency BIT = 0 OUTPUT
)
AS
/*
	created: 20190315@Helen
	Task: Support show replication latency in replicated server
	DB: DBSTARIX/starixDB
	
	Revisions:
		- 20190320@Helen: Initialize - [Redmine:107963]
	
	Param's explaination:
		- @ServerName: Name of server like db052, db053, db06, db042 ......
		
*/
BEGIN
	SET @isLatency = 0
	
	IF EXISTS (SELECT TOP 1 1 
			   FROM dbo.vnDBA_Alert_Repl_Result WITH (NOLOCK)
			   WHERE Subcriber = @ServerName AND Publication = @PublicationName)
	BEGIN		   
		SET @isLatency = 1
	END	
END
GO