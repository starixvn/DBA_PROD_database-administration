/***
	- Created@20211124: Bobby
	- Host: Run on DB053
	- Task: DO the backup full of bodb02
***/
use master;
GO
DECLARE @DB_Users TABLE (ServerName SYSNAME, LogInAtServerLevel SYSNAME, UserAtDBLevel SYSNAME, [Database] SYSNAME, DatabaseRoleMembership SYSNAME)
 
INSERT @DB_Users
EXEC sp_MSforeachdb
 
'
USE [?]
SELECT
    CONVERT(VARCHAR(250), SERVERPROPERTY(''ServerName'')) AS ServerName,
 susers.[name]                                         AS LogInAtServerLevel,
 users.[name]                                          AS UserAtDBLevel,
-- DB_NAME()                                             AS [Database],         
 ''?''                                                 AS [Database],      
 roles.name                                            AS DatabaseRoleMembership
FROM sys.database_principals users
       INNER JOIN sys.database_role_members link ON link.member_principal_id = users.principal_id
       INNER JOIN sys.database_principals roles  ON roles.principal_id       = link.role_principal_id
       INNER JOIN sys.server_principals susers   ON susers.sid               = users.sid
WHERE --users.type_desc IN (''WINDOWS_USER'',''SQL_USER'')
      --AND

susers.[name] NOT IN (''sa'',''NT Service\MSSQLSERVER'',''NT SERVICE\SQLSERVERAGENT'',''NT SERVICE\SQLWriter'',''NT SERVICE\Winmgmt'',''NT AUTHORITY\SYSTEM'',''NT AUTHORITY\NETWORK SERVICE'')
   AND susers.[name] NOT LIKE ''##%''
'
;
with cte as (
	SELECT ServerName, [Database], LogInAtServerLevel, UserAtDBLevel, DatabaseRoleMembership
	FROM @DB_Users user1
	GROUP BY ServerName,LogInAtServerLevel, UserAtDBLevel, [Database], DatabaseRoleMembership
	--ORDER BY ServerName,[Database], LogInAtServerLevel, UserAtDBLevel,  DatabaseRoleMembership
)
select t.cmd
from cte
cross apply (
	select 'use ' + [Database] + ';'
	union all
	select 'EXEC sp_addrolemember ''' + [DatabaseRoleMembership] + ''','''+[UserAtDBLevel]+''';'
	union all
	select 'GO'
) as t(cmd)
order by cte.[Database]
GO

/***
	- Created@20211124: Bobby
	- Host: Run on DB053N1
	- Task: DO the database roles migration
***/
--TODO:
use bk;
EXEC sp_addrolemember 'db_datareader','bodbAdminNet';
GO
use bk;
EXEC sp_addrolemember 'db_datareader','bodbSPUNet';
GO
use bk;
EXEC sp_addrolemember 'db_datareader','RDCooper';
GO
use bk;
EXEC sp_addrolemember 'db_datareader','RDVictor';
GO
use bk;
EXEC sp_addrolemember 'db_owner','SqlLink';
GO
use bk;
EXEC sp_addrolemember 'db_datareader','vnBilly';
GO
use bk;
EXEC sp_addrolemember 'db_datareader','vnDBA';
GO
use bk;
EXEC sp_addrolemember 'db_owner','vnDBA';
GO
use bk;
EXEC sp_addrolemember 'db_datareader','vnHelen';
GO
use bk;
EXEC sp_addrolemember 'db_datareader','vnteam';
GO
use bodb_3rdProduct;
EXEC sp_addrolemember 'db_datareader','dwrs2';
GO
use bodb_3rdProduct;
EXEC sp_addrolemember 'db_owner','SqlLink';
GO
use bodb_3rdProduct;
EXEC sp_addrolemember 'db_datareader','vnBilly';
GO
use bodb_3rdProduct;
EXEC sp_addrolemember 'db_datareader','vnBobby';
GO
use bodb_3rdProduct;
EXEC sp_addrolemember 'db_owner','vnDBA';
GO
use bodb_3rdProduct;
EXEC sp_addrolemember 'db_datareader','vnHelen';
GO
use bodb_3rdProduct;
EXEC sp_addrolemember 'db_datareader','vnteam';
GO
use bodb_AGE;
EXEC sp_addrolemember 'db_owner','DataSync';
GO
use bodb_AGE;
EXEC sp_addrolemember 'db_owner','SqlLink';
GO
use bodb_AGE;
EXEC sp_addrolemember 'db_datareader','vnBilly';
GO
use bodb_AGE;
EXEC sp_addrolemember 'db_datareader','vnBobby';
GO
use bodb_AGE;
EXEC sp_addrolemember 'db_owner','vnBrice';
GO
use bodb_AGE;
EXEC sp_addrolemember 'db_owner','vnDBA';
GO
use bodb_AGE;
EXEC sp_addrolemember 'db_datareader','vnHelen';
GO
use bodb_AGE;
EXEC sp_addrolemember 'db_datareader','vnteam';
GO
use bodb_ChatBot;
EXEC sp_addrolemember 'db_denydatawriter','SqlLink';
GO
use bodb_ChatBot;
EXEC sp_addrolemember 'db_owner','SqlLink';
GO
use bodb_ChatBot;
EXEC sp_addrolemember 'db_datareader','vnBilly';
GO
use bodb_ChatBot;
EXEC sp_addrolemember 'db_datareader','vnHelen';
GO
use bodb_ChatBot;
EXEC sp_addrolemember 'db_datareader','vnteam';
GO
use bodb_FraudSensor;
EXEC sp_addrolemember 'db_datareader','bodbSPUNet';
GO
use bodb_FraudSensor;
EXEC sp_addrolemember 'db_datareader','SqlLink';
GO
use bodb_FraudSensor;
EXEC sp_addrolemember 'db_owner','SqlLink';
GO
use bodb_FraudSensor;
EXEC sp_addrolemember 'db_datareader','vnBilly';
GO
use bodb_FraudSensor;
EXEC sp_addrolemember 'db_datareader','vnBobby';
GO
use bodb_FraudSensor;
EXEC sp_addrolemember 'db_datareader','vnDBA';
GO
use bodb_FraudSensor;
EXEC sp_addrolemember 'db_datareader','vnSPU';
GO
use bodb_FraudSensor;
EXEC sp_addrolemember 'db_datareader','vnteam';
GO
use bodb_Licensee;
EXEC sp_addrolemember 'db_datareader','bodbLicenseeNet';
GO
use bodb_Licensee;
EXEC sp_addrolemember 'db_datareader','dwrs2';
GO
use bodb_Licensee;
EXEC sp_addrolemember 'db_owner','SqlLink';
GO
use bodb_Licensee;
EXEC sp_addrolemember 'db_datareader','vnBilly';
GO
use bodb_Licensee;
EXEC sp_addrolemember 'db_datareader','vnBobby';
GO
use bodb_Licensee;
EXEC sp_addrolemember 'db_owner','vnBrice';
GO
use bodb_Licensee;
EXEC sp_addrolemember 'db_owner','vndba';
GO
use bodb_Licensee;
EXEC sp_addrolemember 'db_datareader','vnHelen';
GO
use bodb_Licensee;
EXEC sp_addrolemember 'db_datareader','vnteam';
GO
use bodb_LicenseeReport;
EXEC sp_addrolemember 'db_owner','SqlLink';
GO
use bodb_LicenseeReport;
EXEC sp_addrolemember 'db_datareader','vnBilly';
GO
use bodb_LicenseeReport;
EXEC sp_addrolemember 'db_datareader','vnBobby';
GO
use bodb_LicenseeReport;
EXEC sp_addrolemember 'db_datareader','vnHelen';
GO
use bodb_LicenseeReport;
EXEC sp_addrolemember 'db_datareader','vnteam';
GO
use bodb_LicenseeReportArchive;
EXEC sp_addrolemember 'db_owner','sqllink';
GO
use bodb_LicenseeReportArchive;
EXEC sp_addrolemember 'db_datareader','vnBilly';
GO
use bodb_LicenseeReportArchive;
EXEC sp_addrolemember 'db_owner','vnBobby';
GO
use bodb_LicenseeReportArchive;
EXEC sp_addrolemember 'db_datareader','vnHelen';
GO
use bodb_LicenseeReportArchive;
EXEC sp_addrolemember 'db_datareader','vnteam';
GO
use bodb_N88;
EXEC sp_addrolemember 'db_owner','vnBrice';
GO
use bodb_N88;
EXEC sp_addrolemember 'db_datareader','vnteam';
GO
use bodb_PlaytechCS;
EXEC sp_addrolemember 'db_datareader','dwrs2';
GO
use bodb_PlaytechCS;
EXEC sp_addrolemember 'db_owner','SqlLink';
GO
use bodb_PlaytechCS;
EXEC sp_addrolemember 'db_datareader','vnBilly';
GO
use bodb_PlaytechCS;
EXEC sp_addrolemember 'db_datareader','vnBobby';
GO
use bodb_PlaytechCS;
EXEC sp_addrolemember 'db_owner','vnDBA';
GO
use bodb_PlaytechCS;
EXEC sp_addrolemember 'db_datareader','vnHelen';
GO
use bodb_PlaytechCS;
EXEC sp_addrolemember 'db_datareader','vnteam';
GO
use bodb_Ploutos;
EXEC sp_addrolemember 'db_owner','SqlLink';
GO
use bodb_Ploutos;
EXEC sp_addrolemember 'db_datareader','vnBilly';
GO
use bodb_Ploutos;
EXEC sp_addrolemember 'db_owner','vnBobby';
GO
use bodb_Ploutos;
EXEC sp_addrolemember 'db_datareader','vnteam';
GO
use bodb_Summary;
EXEC sp_addrolemember 'db_datareader','RDCooper';
GO
use bodb_Summary;
EXEC sp_addrolemember 'db_datareader','RDVictor';
GO
use bodb_Summary;
EXEC sp_addrolemember 'db_owner','SqlLink';
GO
use bodb_Summary;
EXEC sp_addrolemember 'db_datareader','vnBilly';
GO
use bodb_Summary;
EXEC sp_addrolemember 'db_datareader','vnBobby';
GO
use bodb_Summary;
EXEC sp_addrolemember 'db_owner','vnBrice';
GO
use bodb_Summary;
EXEC sp_addrolemember 'db_owner','vnDBA';
GO
use bodb_Summary;
EXEC sp_addrolemember 'db_datareader','vnHelen';
GO
use bodb_Summary;
EXEC sp_addrolemember 'db_datareader','vnteam';
GO
use bodb02;
EXEC sp_addrolemember 'db_datareader','bodbSPUNet';
GO
use bodb02;
EXEC sp_addrolemember 'db_owner','DataSync';
GO
use bodb02;
EXEC sp_addrolemember 'db_datareader','dwrs2';
GO
use bodb02;
EXEC sp_addrolemember 'db_datareader','RDCharlie';
GO
use bodb02;
EXEC sp_addrolemember 'db_datareader','RDCooper';
GO
use bodb02;
EXEC sp_addrolemember 'db_datareader','RDVictor';
GO
use bodb02;
EXEC sp_addrolemember 'db_owner','SqlLink';
GO
use bodb02;
EXEC sp_addrolemember 'db_datareader','vnBilly';
GO
use bodb02;
EXEC sp_addrolemember 'db_datareader','vnBobby';
GO
use bodb02;
EXEC sp_addrolemember 'db_datareader','vnBrice';
GO
use bodb02;
EXEC sp_addrolemember 'db_owner','vnBrice';
GO
use bodb02;
EXEC sp_addrolemember 'db_owner','vnDBA';
GO
use bodb02;
EXEC sp_addrolemember 'db_datareader','vnHelen';
GO
use bodb02;
EXEC sp_addrolemember 'db_datareader','vnteam';
GO
use MonDB;
EXEC sp_addrolemember 'db_datareader','MonDB_User';
GO
use MonDB;
EXEC sp_addrolemember 'db_owner','RDCharlie';
GO
use MonDB;
EXEC sp_addrolemember 'db_denydatawriter','SqlLink';
GO
use MonDB;
EXEC sp_addrolemember 'db_owner','SqlLink';
GO
use MonDB;
EXEC sp_addrolemember 'db_datareader','vnBilly';
GO
use MonDB;
EXEC sp_addrolemember 'db_owner','vnBilly';
GO
use MonDB;
EXEC sp_addrolemember 'db_datareader','vnBobby';
GO
use MonDB;
EXEC sp_addrolemember 'db_datareader','vnBrice';
GO
use MonDB;
EXEC sp_addrolemember 'db_owner','vnBrice';
GO
use MonDB;
EXEC sp_addrolemember 'db_denydatawriter','vnDBA';
GO
use MonDB;
EXEC sp_addrolemember 'db_owner','vnDBA';
GO
use MonDB;
EXEC sp_addrolemember 'db_datareader','vnHelen';
GO
use MonDB;
EXEC sp_addrolemember 'db_datareader','vnteam';
GO
use msdb;
EXEC sp_addrolemember 'DatabaseMailUserRole','SqlLink';
GO
use msdb;
EXEC sp_addrolemember 'db_datareader','SqlLink';
GO
use msdb;
EXEC sp_addrolemember 'db_datareader','vnBobby';
GO
use msdb;
EXEC sp_addrolemember 'SQLAgentReaderRole','vnBobby';
GO
use msdb;
EXEC sp_addrolemember 'SQLAgentUserRole','vnBobby';
GO
use msdb;
EXEC sp_addrolemember 'db_datareader','vnBrice';
GO
use msdb;
EXEC sp_addrolemember 'SQLAgentReaderRole','vnBrice';
GO
use msdb;
EXEC sp_addrolemember 'SQLAgentUserRole','vnBrice';
GO
use msdb;
EXEC sp_addrolemember 'db_datareader','vnDBA';
GO
use msdb;
EXEC sp_addrolemember 'SQLAgentOperatorRole','vnDBA';
GO
use msdb;
EXEC sp_addrolemember 'SQLAgentReaderRole','vnDBA';
GO
use msdb;
EXEC sp_addrolemember 'SQLAgentUserRole','vnDBA';
GO
use msdb;
EXEC sp_addrolemember 'SQLAgentReaderRole','vnteam';
GO
use msdb;
EXEC sp_addrolemember 'SQLAgentUserRole','vnteam';
GO