/*<info serverAlias="dbsitec1/2/3-bodb_CustomerLog"></info>*/
/*
	Task - move siteDB AG to FC
		+ create service
	Run on dbsitec1/2/3
*/


USE [bodb_CustomerLog]
GO

select 'end conversation ''' + cast(conversation_handle as varchar(200)) +''' with cleanup ', * 
from sys.conversation_endpoints where far_service like '%Service_TicketVoiding_DBLOG%'

select 'end conversation ''' + cast(conversation_handle as varchar(200)) +''' with cleanup ', * 
from sys.conversation_endpoints where far_service like '%Service_UserLog_DBLOG%'

EXEC [sb].[DBA_ConversationManagement] 
	  @functionName = 'TicketVoiding'
	, @contractName = 'Contract_TicketVoiding_Log'		  
	, @fromService = 'Service_TicketVoiding_DBSITEC1'
	, @toService = 'Service_TicketVoiding_DBLOG'
	, @Coversation_number = 5
	, @Mode = 'Reset'
GO
EXEC [sb].[DBA_ConversationManagement] 
	  @functionName = 'UserLog'
	, @contractName = 'Contract_UserLog'		  
	, @fromService = 'Service_UserLog_DBSITEC1'
	, @toService = 'Service_UserLog_DBLOG'
	, @Coversation_number = 5
	, @Mode = 'Reset'

GO
----------------------------------------------------------------------------------------------------------------------------------------------
select 'end conversation ''' + cast(conversation_handle as varchar(200)) +''' with cleanup ', * 
from sys.conversation_endpoints where far_service like '%Service_TicketVoiding_DBLOG%'

select 'end conversation ''' + cast(conversation_handle as varchar(200)) +''' with cleanup ', * 
from sys.conversation_endpoints where far_service like '%Service_UserLog_DBLOG%'

EXEC [sb].[DBA_ConversationManagement] 
	  @functionName = 'TicketVoiding'
	, @contractName = 'Contract_TicketVoiding_Log'		  
	, @fromService = 'Service_TicketVoiding_DBSITEC2'
	, @toService = 'Service_TicketVoiding_DBLOG'
	, @Coversation_number = 5
	, @Mode = 'Reset'
GO
EXEC [sb].[DBA_ConversationManagement] 
	  @functionName = 'UserLog'
	, @contractName = 'Contract_UserLog'		  
	, @fromService = 'Service_UserLog_DBSITEC2'
	, @toService = 'Service_UserLog_DBLOG'
	, @Coversation_number = 5
	, @Mode = 'Reset'

GO
----------------------------------------------------------------------------------------------------------------------------------------------
select 'end conversation ''' + cast(conversation_handle as varchar(200)) +''' with cleanup ', * 
from sys.conversation_endpoints where far_service like '%Service_TicketVoiding_DBLOG%'

select 'end conversation ''' + cast(conversation_handle as varchar(200)) +''' with cleanup ', * 
from sys.conversation_endpoints where far_service like '%Service_UserLog_DBLOG%'

EXEC [sb].[DBA_ConversationManagement] 
	  @functionName = 'TicketVoiding'
	, @contractName = 'Contract_TicketVoiding_Log'		  
	, @fromService = 'Service_TicketVoiding_DBSITEC3'
	, @toService = 'Service_TicketVoiding_DBLOG'
	, @Coversation_number = 5
	, @Mode = 'Reset'
GO
EXEC [sb].[DBA_ConversationManagement] 
	  @functionName = 'UserLog'
	, @contractName = 'Contract_UserLog'		  
	, @fromService = 'Service_UserLog_DBSITEC3'
	, @toService = 'Service_UserLog_DBLOG'
	, @Coversation_number = 5
	, @Mode = 'Reset'

GO