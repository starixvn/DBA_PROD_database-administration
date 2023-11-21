/*
	Created: 20230925@Sol
	Task: create new filegroup/file in T driver
	DB: FPS_DB02-FPS_DeviceFingerprint
*/


---Create file and filegroup to new location
USE [master]
GO
ALTER DATABASE FPS_DeviceFingerprint ADD FILEGROUP [DEVICE_INDEX_03_BigINT_T]
GO
ALTER DATABASE FPS_DeviceFingerprint ADD FILE ( NAME = N'DEVICE_INDEX_03_BigINT_T', FILENAME = N'T:\DATA\FPS_DeviceFingerprint\DEVICE_INDEX_03_BigINT_T.ndf' , SIZE = 8192KB , FILEGROWTH = 65536KB ) TO FILEGROUP [DEVICE_INDEX_03_BigINT_T]
GO
