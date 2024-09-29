/*<info serverAlias="DB054-master"></info>*/
/*
	Task - Scale out dbtrans
		+ Setup SSB ( certificate, endpoint)
	Run on db054
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


