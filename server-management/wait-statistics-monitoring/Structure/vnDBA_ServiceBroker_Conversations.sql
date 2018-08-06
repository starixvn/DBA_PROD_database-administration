--	BEGIN STEP :
--		Description
----------------------------------------------------------------------------------------------------

USE	StarixDB;
GO

CREATE TABLE	dbo.vnDBA_ServiceBroker_Conversations (
					FeatureName				NVARCHAR(128)
				,	TargetName				NVARCHAR(128)
				,	ConversationNo			INT
				,	ConversationHandle		UNIQUEIDENTIFIER
				)
