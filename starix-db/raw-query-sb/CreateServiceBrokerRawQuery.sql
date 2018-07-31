/*
	Creator:	20180625@Billy
	Task:		Raw Query SB Execution - [Redmine: #00000]
	Server:		DBSTARIX.StarixDB
*/


--	BEGIN STEP 1:
--		Message Type definition
----------------------------------------------------------------------------------------------------

USE	StarixDB;
GO

CREATE MESSAGE TYPE	RawQueryMessage
	AUTHORIZATION dbo
	VALIDATION = NONE;
GO


--	BEGIN STEP 2:
--		Initiator Service
----------------------------------------------------------------------------------------------------

USE	StarixDB;
GO

CREATE CONTRACT	RawQueryContract
	AUTHORIZATION dbo (
		RawQueryMessage		SENT BY INITIATOR
	);

--GRANT REFERENCES ON CONTRACT::RawQueryContract TO xxx;
GO

CREATE QUEUE	dbo.RawQueryInitiatorQueue
	ON DATA;

--GRANT RECEIVE ON dbo.RawQueryInitiatorQueue TO xxx;
GO

CREATE SERVICE	RawQueryInitiator
	ON QUEUE	dbo.RawQueryInitiatorQueue (
					RawQueryContract
				);

--GRANT SEND ON SERVICE::RawQueryInitiator TO PUBLIC;
GO


--	BEGIN STEP 3:
--		Target Service
----------------------------------------------------------------------------------------------------

USE	StarixDB;
GO

CREATE PROCEDURE	dbo.SB_RawQueryTargetQueueActivator
AS
BEGIN;
	SET NOCOUNT ON;
END;
GO

CREATE QUEUE	dbo.RawQueryTargetQueue
	WITH	ACTIVATION (
				STATUS				= ON
			,	PROCEDURE_NAME		= dbo.SB_RawQueryTargetQueueActivator
			,	MAX_QUEUE_READERS	= 30
			,	EXECUTE AS OWNER
			) ON DATA;

--GRANT RECEIVE ON dbo.SB_RawQueryTargetQueueActivator TO xxx;
GO

CREATE SERVICE	RawQueryTarget
	ON QUEUE	dbo.RawQueryTargetQueue (
					RawQueryContract
				);

--GRANT SEND ON SERVICE::RawQueryTarget TO PUBLIC;
GO


--	BEGIN STEP x:
--		Cleanup
----------------------------------------------------------------------------------------------------

/*

DROP SERVICE	RawQueryTarget;
DROP QUEUE		dbo.RawQueryTargetQueue;
DROP PROCEDURE	dbo.SB_RawQueryTargetQueueActivator;

DROP SERVICE	RawQueryInitiator;
DROP QUEUE		dbo.RawQueryInitiatorQueue;

DROP CONTRACT	RawQueryContract;

DROP MESSAGE TYPE	RawQueryMessage;

*/
