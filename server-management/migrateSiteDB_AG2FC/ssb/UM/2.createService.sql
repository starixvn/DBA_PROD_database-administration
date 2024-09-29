/*<info serverAlias="dbsitec1/2/3-bodb_CustomerLog"></info>*/
/*
	Task - move siteDB AG to FC
		+ create service
	Run on dbsitec1/2/3
*/


USE [bodb_CustomerLog]
GO

/****** Object:  BrokerService [Service_TicketVoiding_DBSITEC1]    Script Date: 9/27/2024 5:35:32 AM ******/
CREATE SERVICE [Service_TicketVoiding_DBSITEC1]  ON QUEUE [dbo].[Queue_TicketVoiding] ([Contract_TicketVoiding_Log])
GO
CREATE SERVICE [Service_UserLog_DBSITEC1]  ON QUEUE [dbo].[Queue_UserLog] 
GO


----------------------------------------------------------------------------------------
USE [bodb_CustomerLog]
GO

/****** Object:  BrokerService [Service_TicketVoiding_DBSITEC1]    Script Date: 9/27/2024 5:35:32 AM ******/
CREATE SERVICE [Service_TicketVoiding_DBSITEC2]  ON QUEUE [dbo].[Queue_TicketVoiding] ([Contract_TicketVoiding_Log])
GO
CREATE SERVICE [Service_UserLog_DBSITEC2]  ON QUEUE [dbo].[Queue_UserLog] 
GO



----------------------------------------------------------------------------------------
USE [bodb_CustomerLog]
GO

/****** Object:  BrokerService [Service_TicketVoiding_DBSITEC1]    Script Date: 9/27/2024 5:35:32 AM ******/
CREATE SERVICE [Service_TicketVoiding_DBSITEC3]  ON QUEUE [dbo].[Queue_TicketVoiding] ([Contract_TicketVoiding_Log])
GO
CREATE SERVICE [Service_UserLog_DBSITEC3]  ON QUEUE [dbo].[Queue_UserLog] 
GO

