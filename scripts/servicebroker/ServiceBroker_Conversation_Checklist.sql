/*

	Created: 20190103@Helen
	Task: ServiceBroker Conversation troubleshoot checklist
	DB: ServiceBroker DB
	
----- CHECKING DATA ------------------
SELECT * FROM [sb].[ConfigurationReference] WITH (NOLOCK)	  

SELECT * FROM [sb].[ConfigurationReferenceDetail] WITH (NOLOCK)	 

SELECT * FROM [sb].[ConversationCount] WITH (NOLOCK)	 

SELECT * FROM [Sb].[ConversationManagement] WITH (NOLOCK)	 

SELECT s.name, e.far_service, e.is_initiator
			 , e.conversation_handle, e.conversation_id
			 , e.conversation_group_id, e.state, e.state_desc
			 , e.send_sequence
			 , e.system_sequence
FROM sys.conversation_endpoints e WITH(NOLOCK)
	INNER JOIN sys.services s WITH(NOLOCK) on e.service_id = s.service_id	 

*/
------------ #1: Open more conversation, for example: current = 3, and want more 4 Conversations  -------------------------------------------------

UPDATE [sb].[ConfigurationReferenceDetail] SET minConversation = 0 
-- #1.1 - TO Control - DB054/bodb02
EXEC [Sb].[DBA_ConversationManagement] 
		@functionName = 'TOControl'
	  , @contractName = 'Contract_TOControl_Single'		  
	  , @fromService = 'Service_TOControl_Initiator_DBAGE'
	  , @toService = 'Service_TOControl_Target_DBAGE'
	  , @Coversation_number = 4
	  , @Mode ='AddNew'
	  
-- #1.2 - BETRUNNING - DB053/bodb02
EXEC [Sb].[DBA_ConversationManagement] 
		@functionName = 'BETRUNNING'
	  , @contractName = 'Contract_Settled_Ticket'		  
	  , @fromService = 'Service_Settled_Ticket_DBAGE'
	  , @toService = 'Service_Settled_Ticket_BETRUNNING'
	  , @Coversation_number = 4
	  , @Mode  ='AddNew'
	  
-- #1.3 - WRITELOG - DBCUST/bodb_CustomerLog
EXEC [Sb].[DBA_ConversationManagement] 
		@functionName = 'Login'
	  , @contractName = 'Contract_CustomerLog_UserLog_Login'		  
	  , @fromService = 'Service_CustomerLog_DBCUST'
	  , @toService = 'Service_CustomerLog_DBLOG'
	  , @Coversation_number = 4
	  , @Mode  ='AddNew'
EXEC [Sb].[DBA_ConversationManagement] 
		@functionName = 'Login'
	  , @contractName = 'Contract_CustomerLog_eaUserLog_Login'		  
	  , @fromService = 'Service_CustomerLog_DBCUST'
	  , @toService = 'Service_CustomerLog_DBLOG'
	  , @Coversation_number = 4
	  , @Mode  ='AddNew'	  	  	  
------------ #2: clear all and then renew conversation: 10
UPDATE [sb].[ConfigurationReferenceDetail] SET minConversation = 0 

--#2.1 - Check Message has been completed or not ?
--#2.3 - set minConversation = 0, [sb].[ConfigurationReferenceDetail]	 
-- #1.1 - TO Control - DB054/bodb02
EXEC [Sb].[DBA_ConversationManagement] 
		@functionName = 'TOControl'
	  , @contractName = 'Contract_TOControl_Single'		  
	  , @fromService = 'Service_TOControl_Initiator_DBAGE'
	  , @toService = 'Service_TOControl_Target_DBAGE'
	  , @Coversation_number = 10
	  , @Mode = 'Reset'	
	  
-- #1.2 - BETRUNNING - DB053/bodb02
EXEC [Sb].[DBA_ConversationManagement] 
		@functionName = 'BETRUNNING'
	  , @contractName = 'Contract_Settled_Ticket'		  
	  , @fromService = 'Service_Settled_Ticket_DBAGE'
	  , @toService = 'Service_Settled_Ticket_BETRUNNING'
	  , @Coversation_number = 10
	  , @Mode = 'Reset'	
	  
-- #1.3 - WRITELOG - DBCUST/bodb_CustomerLog
EXEC [Sb].[DBA_ConversationManagement] 
		@functionName = 'Login'
	  , @contractName = 'Contract_CustomerLog_UserLog_Login'		  
	  , @fromService = 'Service_CustomerLog_DBCUST'
	  , @toService = 'Service_CustomerLog_DBLOG'
	  , @Coversation_number = 10
	  , @Mode = 'Reset'	
	  
EXEC [Sb].[DBA_ConversationManagement] 
		@functionName = 'Login'
	  , @contractName = 'Contract_CustomerLog_eaUserLog_Login'		  
	  , @fromService = 'Service_CustomerLog_DBCUST'
	  , @toService = 'Service_CustomerLog_DBLOG'
	  , @Coversation_number = 10
	  , @Mode = 'Reset'	
	  

	  
