/*
	Creator:	20191213@Billy
	Task:		#120-001 - Cleanup settlement service broker queues - [Redmine: #125425]
	Server:		DB052 - DB053 - DB06

	Revision:
		- 20191213@Billy: Initialization - [Redmine: #125425]
*/

--	BEGIN STEP 1:
--		Cleanup settlement service broker queues
----------------------------------------------------------------------------------------------------

USE	bodb02;
GO

DECLARE	@conversation_handle	UNIQUEIDENTIFIER

WHILE	0 = 0
BEGIN
	WAITFOR (
		RECEIVE	TOP(100)
				@conversation_handle = conversation_handle
		FROM	dbo.[//Queue/Calculation_receive] 
	), TIMEOUT 100;
	
	IF	@@ROWCOUNT = 0
		BREAK;
END;


WHILE	0 = 0
BEGIN
	WAITFOR (
		RECEIVE	TOP(100)
				@conversation_handle = conversation_handle
		FROM	dbo.[Queue_Settlement_OtherSports] 
	), TIMEOUT 100;
	
	IF	@@ROWCOUNT = 0
		BREAK;
END;