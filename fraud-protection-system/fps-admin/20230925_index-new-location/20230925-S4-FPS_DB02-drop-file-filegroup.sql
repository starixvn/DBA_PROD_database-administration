/*
	Created: 20230921@Sol
	Task: drop old file/filegroup
	DB: FPS_DB02-FPS_DeviceFingerprint
*/

USE [FPS_DeviceFingerprint]
GO
ALTER DATABASE [FPS_DeviceFingerprint]  REMOVE FILE DEVICE_INDEX_03_BigINT
GO
ALTER DATABASE [FPS_DeviceFingerprint] REMOVE FILEGROUP DEVICE_INDEX_03_BigINT
GO
