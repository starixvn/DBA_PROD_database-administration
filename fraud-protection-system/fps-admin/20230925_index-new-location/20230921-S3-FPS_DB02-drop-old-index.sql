/*
	Created: 20230921@Sol
	Task: drop old index
	DB: FPS_DB02-FPS_DeviceFingerprint
*/

USE [FPS_DeviceFingerprint]

GO

/****** Object:  Index [IX_Device_CreatedDate]    Script Date: 9/24/2023 11:33:35 PM ******/
DROP INDEX [IX_Device_CreatedDate] ON [dbo].[Device]
GO