/***
	- Created@20211124: Bobby
	- Host: Run on DB053
	- Task: DO login migration
***/
use master;
GO

SELECT 
'EXEC master..sp_addsrvrolemember @loginame = N''' + SL.name + ''', @rolename = N''' + SR.name + ''';
' AS [-- Roles To Be Assigned --]
FROM master.sys.server_role_members SRM
INNER JOIN master.sys.server_principals SR ON SR.principal_id = SRM.role_principal_id
    JOIN master.sys.server_principals SL ON SL.principal_id = SRM.member_principal_id
WHERE SL.type IN ('S','G','U')
        AND SL.name NOT LIKE '##%##'
        AND SL.name NOT LIKE 'NT AUTHORITY%'
        AND SL.name NOT LIKE 'NT SERVICE%'
        AND SL.name <> ('sa')
        AND SL.name <> 'distributor_admin';


go

/***
	- Created@20211124: Bobby
	- Host: Run on DB053N1
	- Task: DO login migration
***/
use master;
GO
EXEC master..sp_addsrvrolemember @loginame = N'thien', @rolename = N'sysadmin';  
EXEC master..sp_addsrvrolemember @loginame = N'RDCooper', @rolename = N'sysadmin';  
EXEC master..sp_addsrvrolemember @loginame = N'RDVictor', @rolename = N'sysadmin';  
EXEC master..sp_addsrvrolemember @loginame = N'vnLukas', @rolename = N'sysadmin';  
EXEC master..sp_addsrvrolemember @loginame = N'RDBenLee', @rolename = N'sysadmin';  
EXEC master..sp_addsrvrolemember @loginame = N'vnDaniel', @rolename = N'sysadmin';  
EXEC master..sp_addsrvrolemember @loginame = N'RDLeon', @rolename = N'sysadmin';  
EXEC master..sp_addsrvrolemember @loginame = N'Viet', @rolename = N'sysadmin';  
EXEC master..sp_addsrvrolemember @loginame = N'vnJoe', @rolename = N'sysadmin';  
EXEC master..sp_addsrvrolemember @loginame = N'vnPatrick', @rolename = N'sysadmin';  
EXEC master..sp_addsrvrolemember @loginame = N'RDVivi', @rolename = N'sysadmin';  
EXEC master..sp_addsrvrolemember @loginame = N'RDSylvia', @rolename = N'sysadmin';  
EXEC master..sp_addsrvrolemember @loginame = N'RDAlfie', @rolename = N'sysadmin';  
EXEC master..sp_addsrvrolemember @loginame = N'vnBobby', @rolename = N'sysadmin';  
EXEC master..sp_addsrvrolemember @loginame = N'RDCharlie', @rolename = N'sysadmin';  
EXEC master..sp_addsrvrolemember @loginame = N'RDMei', @rolename = N'sysadmin';  
EXEC master..sp_addsrvrolemember @loginame = N'RDColin', @rolename = N'sysadmin';  
EXEC master..sp_addsrvrolemember @loginame = N'RDDBA_RM', @rolename = N'sysadmin';  