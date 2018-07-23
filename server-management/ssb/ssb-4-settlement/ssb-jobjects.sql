USE [bodb02]
GO

CREATE MESSAGE TYPE [//Message/Calculation] VALIDATION = NONE
GO

CREATE MESSAGE TYPE [//Message/EndOfStream] VALIDATION = NONE
GO

CREATE CONTRACT [//Contract/Calculation] ([//Message/Calculation] SENT BY ANY,
[//Message/EndOfStream] SENT BY ANY)
GO

CREATE QUEUE [dbo].[//Queue/Calculation_receive] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [sb].[SBQueue_receive] , MAX_QUEUE_READERS = 1 , EXECUTE AS N'dbo'  ), POISON_MESSAGE_HANDLING (STATUS = ON)  ON [ServiceBrokerData] 
GO

CREATE QUEUE [dbo].[//Queue/Calculation_send] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [sb].[SBQueue_send] , MAX_QUEUE_READERS = 1 , EXECUTE AS N'dbo'  ), POISON_MESSAGE_HANDLING (STATUS = ON)  ON [ServiceBrokerData] 
GO

CREATE SERVICE [//Service/Calculation_receive]  ON QUEUE [dbo].[//Queue/Calculation_receive] ([//Contract/Calculation])
GO

CREATE SERVICE [//Service/Calculation_send]  ON QUEUE [dbo].[//Queue/Calculation_send] ([//Contract/Calculation])
GO
