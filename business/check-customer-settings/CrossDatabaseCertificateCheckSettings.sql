/*
	Creator:	20180718@Billy
	Task:		Certificate for cross database authentication - [Redmine: #00000]
	Server:		DBCHECK.CheckResultDB
*/


USE	CheckResultDB;
GO

CREATE CERTIFICATE	CheckSettingAuthenticationCertificate
ENCRYPTION BY PASSWORD = '[{Cr0ssD@t@b@s31e6e1}]'
WITH SUBJECT = 'Certificate for StarixDB to access server level permission';
GO

BACKUP CERTIFICATE	CheckSettingAuthenticationCertificate
TO FILE = 'C:\CheckSettingAuthenticationCertificate.cer'
WITH PRIVATE KEY (
	FILE = 'C:\CheckSettingAuthenticationCertificate_Private.cer'
,	ENCRYPTION BY PASSWORD = '[{E268y87O264e648e5u1708}]'
,	DECRYPTION BY PASSWORD = '[{Cr0ssD@t@b@s31e6e1}]'
);
GO

USE	CheckCustDB;
GO

CREATE CERTIFICATE	CheckSettingAuthenticationCertificate
FROM FILE = 'C:\CheckSettingAuthenticationCertificate.cer'
WITH PRIVATE KEY (
	FILE = 'C:\CheckSettingAuthenticationCertificate_Private.cer'
,	DECRYPTION BY PASSWORD = '[{E268y87O264e648e5u1708}]'
,	ENCRYPTION BY PASSWORD = '[{Cr0ssD@t@b@s31e6e1}]'
);
GO

CREATE USER	CheckSettingUser
FROM CERTIFICATE	CheckSettingAuthenticationCertificate;
GO

GRANT AUTHENTICATE TO CheckSettingUser;
GO

EXECUTE	sys.sp_addrolemember @rolename = 'db_datareader', @membername = 'CheckSettingUser';
GO