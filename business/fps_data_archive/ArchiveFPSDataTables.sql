/*
	Creator:	20180925@Billy
	Task:		Archive FPS Data - [Redmine: #101008]
	Server:		FPSDI.FPS_DeviceFingerprint
*/

USE	FPS_DeviceFingerprint;
GO

--	BEGIN STEP :
--		Description
----------------------------------------------------------------------------------------------------

CREATE TABLE	dbo.DBA_Archive_DeviceSingleAssociation (
					SubscriberId		INT
				,	DeviceId			INT
				,	DeviceNo			NVARCHAR(50)
				,	CONSTRAINT	PK_Archive_DeviceSingleAssociation PRIMARY KEY CLUSTERED (SubscriberId, DeviceId)
				) ON DI_DRAFT_DATA;