/*
	Created: 20230921@Sol
	Task: drop old index
	DB: FPS_DB02-FPS_DeviceFingerprint
*/

USE [FPS_DeviceFingerprint]

GO

/****** Object:  Index [IX_Device_Id]    Script Date: 9/20/2023 11:04:48 PM ******/
DROP INDEX [IX_Device_Id] ON [dbo].[Device]
GO

/****** Object:  Index [IX_Device_Code]    Script Date: 9/20/2023 11:05:03 PM ******/
DROP INDEX [IX_Device_Code] ON [dbo].[Device]
GO
