/*
	Creator:	20190611@Billy
	Task:		#110-004 - [Redmine: #114307]
	Server:		DB052 - DB053 - DB06

	Revision:
		- 20190611@Billy: Initialization - [Redmine: #114307]
		- 20191213@Billy: UI improvement - [Redmine: #125425]
*/

--	BEGIN STEP 1:
--		Check Database Property
----------------------------------------------------------------------------------------------------

USE	master;

SELECT	[Database]		= db.name
	,	[BrokerStatus]	= CASE db.is_broker_enabled WHEN 1 THEN 'ENABLED' WHEN 0 THEN '' ELSE NULL END
	,	[Status]		= CASE db.is_broker_enabled WHEN 1 THEN N'OK __' ELSE N'__ NG' END
FROM	sys.databases AS db WITH (NOLOCK)
WHERE	db.name IN (N'bodb02');
GO


--	BEGIN STEP 2:
--		Update database property if needed
----------------------------------------------------------------------------------------------------

RETURN;

USE	master;

ALTER DATABASE bodb02 SET ENABLE_BROKER WITH ROLLBACK IMMEDIATE;
GO


--	BEGIN STEP 3:
--		Check Service Broker Status
----------------------------------------------------------------------------------------------------

USE	bodb02;

SELECT	[SysObj]			= obj.name
	,	[SysObjType]		= obj.type
	,	[Obj]				= CASE WHEN obj.name = N'sysxmitqueue' THEN N'transmission_queue' ELSE par.name END
	,	[ObjType]			= CASE WHEN obj.name = N'sysxmitqueue' THEN N'V' ELSE par.type END
	,	[QueueStatus]		= CASE sq.is_enqueue_enabled WHEN 1 THEN 'ENABLED' WHEN 0 THEN '' ELSE NULL END
	,	[ActivationSP]		= sq.activation_procedure
	,	[ActivationStatus]	= CASE sq.is_activation_enabled WHEN 1 THEN 'ENABLED' WHEN 0 THEN '' ELSE NULL END
	,	[Rows]				= ptt.rows
	,	[Status]			= CASE	WHEN par.name = N'//Queue/Calculation_send' THEN CASE WHEN sq.is_activation_enabled = 1 THEN N'OK __' ELSE N'__ NG' END
									WHEN par.name = N'//Queue/Calculation_receive' THEN CASE WHEN sq.is_activation_enabled = 0 THEN N'OK __' ELSE N'__ NG' END
									WHEN par.name = N'Queue_Settlement_OtherSports' THEN CASE WHEN sq.is_activation_enabled = 0 THEN N'OK __' ELSE N'__ NG' END
									ELSE N''
							  END
FROM		sys.all_objects AS obj WITH (NOLOCK)
LEFT JOIN	sys.all_objects AS par WITH (NOLOCK)
		ON	obj.parent_object_id = par.object_id
LEFT JOIN	sys.partitions AS ptt WITH (NOLOCK)
		ON	(ptt.object_id = obj.object_id OR ptt.object_id = obj.parent_object_id)
		AND	ptt.index_id IN (0, 1)
LEFT JOIN	sys.service_queues AS sq WITH (NOLOCK)
		ON	sq.object_id = par.object_id
WHERE	par.type = 'SQ'
	OR	obj.name = 'sysxmitqueue'
ORDER BY par.name;
GO


--	BEGIN STEP 4:
--		Update queue status is needed
----------------------------------------------------------------------------------------------------

RETURN;

USE	bodb02;

ALTER QUEUE	dbo.[//Queue/Calculation_send]
	WITH	STATUS				= ON
		,	RETENTION			= OFF
		,	ACTIVATION (
				STATUS				= ON
			)
		,	POISON_MESSAGE_HANDLING (
				STATUS				= ON
			)
		;

ALTER QUEUE	dbo.[//Queue/Calculation_receive]
	WITH	STATUS				= ON
		,	RETENTION			= OFF
		,	ACTIVATION (
				STATUS				= OFF
			)
		,	POISON_MESSAGE_HANDLING (
				STATUS				= ON
			)
		;

ALTER QUEUE	dbo.Queue_Settlement_OtherSports
	WITH	STATUS				= ON
		,	RETENTION			= OFF
		,	ACTIVATION (
				STATUS				= OFF
			)
		,	POISON_MESSAGE_HANDLING (
				STATUS				= ON
			)
		;
GO

