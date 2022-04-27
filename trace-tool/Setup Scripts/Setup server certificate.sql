/*
	Task: SP Trace - Setup server certificate
	Created: Daniel@20220427
	IMPORTANT!! Follow step order & instruction in comment lines
*/

--1. Create server certificate in master database
USE MASTER
GO
CREATE certificate serverlevel_cert
ENCRYPTION BY PASSWORD = '!@h19hPrIv()'
WITH SUBJECT = 'Certificate for signing SPs need high privileges'
SELECT * FROM sys.certificates

GO

--2. Create server login from the CERT & grant necessary permissions
USE MASTER
GO
CREATE LOGIN dbacert_user FROM certificate serverlevel_cert
GO
GRANT ALTER TRACE TO dbacert_user
GO
GRANT VIEW SERVER STATE TO dbacert_user
GO

--3. Backup the server cert to file
USE MASTER
GO
BACKUP certificate serverlevel_cert TO FILE = 'G:\serverlevel_cert.CER'
WITH PRIVATE KEY
( FILE = 'G:\serverlevel_cert.PVK',
DECRYPTION BY PASSWORD = '!@h19hPrIv()', -- pwd to open the key
ENCRYPTION BY PASSWORD = '!@h19hPrIv()' -- must protect the file
)
GO

--4. Create the same cert in MonDB using the cert file backed-up, it will be use to sign relevant SPs in MonDB next step
USE MonDB
GO
CREATE certificate serverlevel_cert FROM FILE = 'G:\serverlevel_cert.CER'
WITH PRIVATE KEY
( FILE = 'G:\serverlevel_cert.PVK',
DECRYPTION BY PASSWORD = '!@h19hPrIv()', -- to read the file
ENCRYPTION BY PASSWORD = '!@h19hPrIv()' -- pwd to protect the key
)
SELECT * FROM sys.certificates
GO