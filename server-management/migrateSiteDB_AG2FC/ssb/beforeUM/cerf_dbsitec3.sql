/*<info serverAlias="DBSID-master"></info>*/
/*
	Task - migrate siteDB AG to FC
		+ Setup SSB ( certificate, endpoint)
	Run on DBSITEC3
*/
USE master
GO

CREATE USER [dba_cert_User] FOR LOGIN [dba_cert_User]
GO

--//create master ket for ssb certtificate
CREATE MASTER KEY ENCRYPTION BY PASSWORD = N'!i@b#ssb#mlogin$9)';
GO

--Creating certificate that will be used for encrypting messages. 
CREATE CERTIFICATE [SSBS_DBSITEC3_Cert]
       WITH SUBJECT = N'Certificate For DBSITEC3',
       EXPIRY_DATE = N'12/31/2080';
GO

--//backup ssb certificate
BACKUP CERTIFICATE [SSBS_DBSITEC3_Cert]
       TO FILE = N'G:\SSBSQLCertificates\SSBS_DBSITEC3_Cert.cer';
GO

--restore certificate from db055
CREATE CERTIFICATE SSBS_DB055_Cert
   AUTHORIZATION dba_cert_User
   FROM FILE = N'G:\SSBSQLCertificates\SSBS_DB055_Cert.cer'
GO

CREATE CERTIFICATE SSBS_DB054_Cert
   AUTHORIZATION dba_cert_User
   FROM FILE = N'G:\SSBSQLCertificates\SSBS_DB054_Cert.cer'
GO

--//create endpoint
CREATE ENDPOINT [Endpoint_SSB_DBSITEC3] 
	STATE = STARTED
	AS TCP (LISTENER_PORT = 4741, LISTENER_IP = ALL)
	FOR SERVICE_BROKER (MESSAGE_FORWARDING = DISABLED
						, MESSAGE_FORWARD_SIZE = 10
						, AUTHENTICATION = CERTIFICATE [SSBS_DBSITEC3_Cert]
						, ENCRYPTION = REQUIRED ALGORITHM RC4)
GO

GRANT CONNECT ON ENDPOINT::[Endpoint_SSB_DBSITEC3] TO dba_cert_User
GO
