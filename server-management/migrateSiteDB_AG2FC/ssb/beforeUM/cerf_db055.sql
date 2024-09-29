/*<info serverAlias="DB055-master"></info>*/
/*
	Task - Scale out dbtrans
		+ Setup SSB ( certificate, endpoint)
	Run on db055
*/

USE [master]
GO

--//drop old certificate
--DROP CERTIFICATE SSBS_DBGRP02N1_Cert
--DROP CERTIFICATE SSBS_DBGRP02N2_Cert

--//restore ssb certificate ==> from DBTrans
-->> Need to copy file first
CREATE CERTIFICATE SSBS_DBSITEC1_Cert
   AUTHORIZATION dba_cert_User
   FROM FILE = N'G:\SSBSQLCertificates\SSBS_DBSITEC1_Cert.cer'
GO

CREATE CERTIFICATE SSBS_DBSITEC2_Cert
   AUTHORIZATION dba_cert_User
   FROM FILE = N'G:\SSBSQLCertificates\SSBS_DBSITEC2_Cert.cer'
GO

CREATE CERTIFICATE SSBS_DBSITEC3_Cert
   AUTHORIZATION dba_cert_User
   FROM FILE = N'G:\SSBSQLCertificates\SSBS_DBSITEC3_Cert.cer'
GO


use bodb_CustomerLog
go
CREATE ROUTE [Route_TicketVoiding_DBSITEC1]   WITH  SERVICE_NAME  = N'Service_TicketVoiding_DBSITEC1' ,  ADDRESS  = N'TCP://172.16.40.66:4741' 
go
CREATE ROUTE [Route_TicketVoiding_DBSITEC2]   WITH  SERVICE_NAME  = N'Service_TicketVoiding_DBSITEC2' ,  ADDRESS  = N'TCP://172.16.40.67:4741' 
go
CREATE ROUTE [Route_TicketVoiding_DBSITEC3]   WITH  SERVICE_NAME  = N'Service_TicketVoiding_DBSITEC3' ,  ADDRESS  = N'TCP://172.16.40.68:4741' 
go
CREATE ROUTE [Route_UserLog_DBSITEC1]   WITH  SERVICE_NAME  = N'Service_UserLog_DBSITEC1' ,  ADDRESS  = N'TCP://172.16.40.66:4741' 
go
CREATE ROUTE [Route_UserLog_DBSITEC2]   WITH  SERVICE_NAME  = N'Service_UserLog_DBSITEC2' ,  ADDRESS  = N'TCP://172.16.40.67:4741' 
go
CREATE ROUTE [Route_UserLog_DBSITEC3]   WITH  SERVICE_NAME  = N'Service_UserLog_DBSITEC3' ,  ADDRESS  = N'TCP://172.16.40.68:4741' 