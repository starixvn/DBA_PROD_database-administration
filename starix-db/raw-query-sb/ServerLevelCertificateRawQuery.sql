/*
	Creator:	20180625@Billy
	Task:		Ceriticate for server level authentication - [Redmine: #00000]
	Server:		DBSTARIX.StarixDB
*/


USE	master;
GO

CREATE CERTIFICATE	StarixServerAuthenticationCertificate
ENCRYPTION BY PASSWORD = '~`St@r1xS3rv3r1e6e1`~'
WITH SUBJECT = 'Certificate for StarixDB to access server level permission';
GO

CREATE LOGIN vnStarix
FROM CERTIFICATE StarixServerAuthenticationCertificate;
GRANT AUTHENTICATE SERVER TO vnStarix;
GO

BACKUP CERTIFICATE	StarixServerAuthenticationCertificate
TO FILE = 'C:\StarixServerAuthenticationCertificate.cer'
WITH PRIVATE KEY (
	FILE = 'C:\StarixServerAuthenticationCertificate_Private.cer'
,	ENCRYPTION BY PASSWORD = '~`E268y87O23a57e8`~'
,	DECRYPTION BY PASSWORD = '~`St@r1xS3rv3r1e6e1`~'
);
GO

USE	StarixDB;
GO

CREATE CERTIFICATE	StarixServerAuthenticationCertificate
FROM FILE = 'C:\StarixServerAuthenticationCertificate.cer'
WITH PRIVATE KEY (
	FILE = 'C:\StarixServerAuthenticationCertificate_Private.cer'
,	DECRYPTION BY PASSWORD = '~`E268y87O23a57e8`~'
,	ENCRYPTION BY PASSWORD = '~`St@r1xS3rv3r1e6e1`~'
);
GO

CREATE USER	vnStarix FROM CERTIFICATE StarixServerAuthenticationCertificate;
GO

ALTER AUTHORIZATION ON DATABASE::StariXDB TO sa;
GO
