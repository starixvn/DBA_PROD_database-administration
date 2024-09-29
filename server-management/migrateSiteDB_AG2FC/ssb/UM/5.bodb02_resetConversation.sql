/*<info serverAlias="DBSITEC1/2/3-bodb02"></info>*/
/*
	Task - Scale out dbtrans
		+ renew conversation
	Run on DBSITEC1/2/3
*/

use bodb02
go

select 'end conversation ''' + cast(conversation_handle as varchar(200)) +''' with cleanup ', * 
from sys.conversation_endpoints where far_service like 'bet_set%'

select 'end conversation ''' + cast(conversation_handle as varchar(200)) +''' with cleanup ', * 
from sys.conversation_endpoints where far_service like 'parlaybet%'


--01
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'settlement'
	, @contractName = 'bet_settle_contract_01'		  
	, @fromService = 'bet_settle_send_service_01'
	, @toService = 'bet_settle_receive_service_01'
	, @coversation_number = 4
	, @mode = 'Reset'

--02
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'settlement'
	, @contractName = 'bet_settle_contract_02'		  
	, @fromService = 'bet_settle_send_service_02'
	, @toService = 'bet_settle_receive_service_02'
	, @coversation_number = 4
	, @mode = 'Reset'

--03
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'settlement'
	, @contractName = 'bet_settle_contract_03'		  
	, @fromService = 'bet_settle_send_service_03'
	, @toService = 'bet_settle_receive_service_03'
	, @coversation_number = 4
	, @mode = 'Reset'

--04
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'settlement'
	, @contractName = 'bet_settle_contract_04'		  
	, @fromService = 'bet_settle_send_service_04'
	, @toService = 'bet_settle_receive_service_04'
	, @coversation_number = 4
	, @mode = 'Reset'

--05
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'settlement'
	, @contractName = 'bet_settle_contract_05'		  
	, @fromService = 'bet_settle_send_service_05'
	, @toService = 'bet_settle_receive_service_05'
	, @coversation_number = 4
	, @mode = 'Reset'

--06
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'settlement'
	, @contractName = 'bet_settle_contract_06'		  
	, @fromService = 'bet_settle_send_service_06'
	, @toService = 'bet_settle_receive_service_06'
	, @coversation_number = 4
	, @mode = 'Reset'

--07
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'settlement'
	, @contractName = 'bet_settle_contract_07'		  
	, @fromService = 'bet_settle_send_service_07'
	, @toService = 'bet_settle_receive_service_07'
	, @coversation_number = 4
	, @mode = 'Reset'

--08
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'settlement'
	, @contractName = 'bet_settle_contract_08'		  
	, @fromService = 'bet_settle_send_service_08'
	, @toService = 'bet_settle_receive_service_08'
	, @coversation_number = 4
	, @mode = 'Reset'

go

--++prepare
--01
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'settlement'
	, @contractName = 'bet_settle_contract_prepare_01'		  
	, @fromService = 'bet_settle_send_service_prepare_01'
	, @toService = 'bet_settle_receive_service_prepare_01'
	, @coversation_number = 4
	, @mode = 'Reset'

--02
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'settlement'
	, @contractName = 'bet_settle_contract_prepare_02'		  
	, @fromService = 'bet_settle_send_service_prepare_02'
	, @toService = 'bet_settle_receive_service_prepare_02'
	, @coversation_number = 4
	, @mode = 'Reset'

--03
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'settlement'
	, @contractName = 'bet_settle_contract_prepare_03'		  
	, @fromService = 'bet_settle_send_service_prepare_03'
	, @toService = 'bet_settle_receive_service_prepare_03'
	, @coversation_number = 4
	, @mode = 'Reset'

--04
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'settlement'
	, @contractName = 'bet_settle_contract_prepare_04'		  
	, @fromService = 'bet_settle_send_service_prepare_04'
	, @toService = 'bet_settle_receive_service_prepare_04'
	, @coversation_number = 4
	, @mode = 'Reset'

--05
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'settlement'
	, @contractName = 'bet_settle_contract_prepare_05'		  
	, @fromService = 'bet_settle_send_service_prepare_05'
	, @toService = 'bet_settle_receive_service_prepare_05'
	, @coversation_number = 4
	, @mode = 'Reset'

--06
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'settlement'
	, @contractName = 'bet_settle_contract_prepare_06'		  
	, @fromService = 'bet_settle_send_service_prepare_06'
	, @toService = 'bet_settle_receive_service_prepare_06'
	, @coversation_number = 4
	, @mode = 'Reset'

--07
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'settlement'
	, @contractName = 'bet_settle_contract_prepare_07'		  
	, @fromService = 'bet_settle_send_service_prepare_07'
	, @toService = 'bet_settle_receive_service_prepare_07'
	, @coversation_number = 4
	, @mode = 'Reset'

--08
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'settlement'
	, @contractName = 'bet_settle_contract_prepare_08'		  
	, @fromService = 'bet_settle_send_service_prepare_08'
	, @toService = 'bet_settle_receive_service_prepare_08'
	, @coversation_number = 4
	, @mode = 'Reset'

go

--++parlay
--01
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'parlaysettlement'
	, @contractName = 'parlaybet_settle_contract_01'		  
	, @fromService = 'parlaybet_settle_send_service_01'
	, @toService = 'parlaybet_settle_receive_service_01'
	, @coversation_number = 4
	, @mode = 'Reset'

--02
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'parlaysettlement'
	, @contractName = 'parlaybet_settle_contract_02'		  
	, @fromService = 'parlaybet_settle_send_service_02'
	, @toService = 'parlaybet_settle_receive_service_02'
	, @coversation_number = 4
	, @mode = 'Reset'

--03
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'parlaysettlement'
	, @contractName = 'parlaybet_settle_contract_03'		  
	, @fromService = 'parlaybet_settle_send_service_03'
	, @toService = 'parlaybet_settle_receive_service_03'
	, @coversation_number = 4
	, @mode = 'Reset'

--04
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'parlaysettlement'
	, @contractName = 'parlaybet_settle_contract_04'		  
	, @fromService = 'parlaybet_settle_send_service_04'
	, @toService = 'parlaybet_settle_receive_service_04'
	, @coversation_number = 4
	, @mode = 'Reset'

--05
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'parlaysettlement'
	, @contractName = 'parlaybet_settle_contract_05'		  
	, @fromService = 'parlaybet_settle_send_service_05'
	, @toService = 'parlaybet_settle_receive_service_05'
	, @coversation_number = 4
	, @mode = 'Reset'

--06
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'parlaysettlement'
	, @contractName = 'parlaybet_settle_contract_06'		  
	, @fromService = 'parlaybet_settle_send_service_06'
	, @toService = 'parlaybet_settle_receive_service_06'
	, @coversation_number = 4
	, @mode = 'Reset'

--07
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'parlaysettlement'
	, @contractName = 'parlaybet_settle_contract_07'		  
	, @fromService = 'parlaybet_settle_send_service_07'
	, @toService = 'parlaybet_settle_receive_service_07'
	, @coversation_number = 4
	, @mode = 'Reset'

--08
exec [sb].[DBA_ConversationManagement] 
	  @functionName = 'parlaysettlement'
	, @contractName = 'parlaybet_settle_contract_08'		  
	, @fromService = 'parlaybet_settle_send_service_08'
	, @toService = 'parlaybet_settle_receive_service_08'
	, @coversation_number = 4
	, @mode = 'Reset'

go
