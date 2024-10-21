/*<info serverAlias="db055-bodb_CustomerLog"></info>*/
/*
	Task - move siteDB AG to FC
		+ create service
	Run on db055
*/


USE [bodb_CustomerLog]
GO

CREATE ROUTE [Route_TicketVoiding_DBSITEC1]   WITH  SERVICE_NAME  = N'Service_TicketVoiding_DBSITEC1' ,  ADDRESS  = N'TCP://10.40.40.242:4741' 
go
CREATE ROUTE [Route_TicketVoiding_DBSITEC2]   WITH  SERVICE_NAME  = N'Service_TicketVoiding_DBSITEC2' ,  ADDRESS  = N'TCP://10.40.40.243:4741' 
go
CREATE ROUTE [Route_TicketVoiding_DBSITEC3]   WITH  SERVICE_NAME  = N'Service_TicketVoiding_DBSITEC3' ,  ADDRESS  = N'TCP://10.40.40.244:4741' 
go
CREATE ROUTE [Route_UserLog_DBSITEC1]   WITH  SERVICE_NAME  = N'Service_UserLog_DBSITEC1' ,  ADDRESS  = N'TCP://10.40.40.242:4741' 
go                                                                                           
CREATE ROUTE [Route_UserLog_DBSITEC2]   WITH  SERVICE_NAME  = N'Service_UserLog_DBSITEC2' ,  ADDRESS  = N'TCP://10.40.40.243:4741' 
go                                                                                           
CREATE ROUTE [Route_UserLog_DBSITEC3]   WITH  SERVICE_NAME  = N'Service_UserLog_DBSITEC3' ,  ADDRESS  = N'TCP://10.40.40.244:4741'
go
DROP ROUTE [Route_TicketVoiding_DBGRP01L]
GO
DROP ROUTE [Route_TicketVoiding_DBGRP02L]
GO
DROP ROUTE [Route_TicketVoiding_DBGRP03L]
GO
DROP ROUTE [Route_UserLog_DBGRP01L]
GO
DROP ROUTE [Route_UserLog_DBGRP02L]
GO
DROP ROUTE [Route_UserLog_DBGRP03L]
GO
