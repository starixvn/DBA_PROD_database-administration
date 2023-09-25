/*
	Created: 20230925@Sol
	Task: create new index
	DB: FPS_DB02-FPS_DeviceFingerprint
*/


---create index
USE [FPS_DeviceFingerprint]

GO

/****** Object:  Index [IX_Device_CreatedDate]    Script Date: 9/24/2023 11:32:06 PM ******/
CREATE NONCLUSTERED INDEX [IX_Device_CreatedDate_T] ON [dbo].[Device]
(
	[CreatedDate] DESC
)
INCLUDE([Id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [DEVICE_INDEX_03_BigINT_T]
GO