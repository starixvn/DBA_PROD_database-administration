/*
	Create By: 20181227@Helen
	Task: ServiceBroker Consersation troubleshoot - soccer
	DB: ServiceBrokerDB
	
	Para's explaination
	
		
*/
DECLARE @fromService SYSNAME
		,@toService SYSNAME
		,@onContract SYSNAME
		,@messageType SYSNAME       
		
		
SELECT @fromService = N'//Service/Calculation_send',
			@toService = N'//Service/Calculation_receive',
			@onContract = N'//Contract/Calculation'
			
DECLARE  @handle UNIQUEIDENTIFIER
			
-- clean existing conversation if needed 
/*
IF EXISTS (SELECT TOP 1 * FROM sys.conversation_endpoints e WITH(NOLOCK) WHERE far_service = 'Service_Settlement_OtherSports')
BEGIN
	WHILE (1=1)
	BEGIN
		SELECT @handle = (SELECT TOP 1 conversation_handle FROM sys.conversation_endpoints e WITH(NOLOCK) WHERE far_service = 'Service_Settlement_OtherSports')
		IF @handle IS NOT NULL
		BEGIN
			END CONVERSATION @handle WITH CLEANUP
		END
		ELSE 
			BREAK	
	END
END

DELETE [sb].[DialogPool] WHERE FromService ='//Service/Calculation_send'

*/		
--- CREATE new conversation for other sports
BEGIN DIALOG CONVERSATION @handle
FROM SERVICE  @fromService 
TO SERVICE  @toService 
ON CONTRACT @onContract 
WITH ENCRYPTION = OFF								

IF @handle IS NOT NULL
BEGIN
	INSERT INTO [sb].[DialogPool] (FromService, ToService, OnContract, Handle,OwnerSPID, CreationTime, SendCount)
	VALUES (@fromService, @toService, @onContract, @handle, -1, CURRENT_TIMESTAMP, 0)
END	
