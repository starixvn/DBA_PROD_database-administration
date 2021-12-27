/*
	DB06 upgrade
	run on DB062
*/

use master;
 
set nocount on
 
select
 
'state_desc' = ssperm.[state_desc]
, 'permission' = ssperm.[permission_name]
, 'to'
, 'grantee' = ssprin.[name]

from
 
sys.server_permissions ssperm join sys.server_principals ssprin
 
on ssperm.grantee_principal_id = ssprin.principal_id
 
where
 
ssperm.[permission_name] in ('view server state', 'view any database', 'view any definition')
 
and ssprin.[name] not in
 
(
 
'sa'
 
, 'NT SERVICEWinmgmt'
 
, 'NT SERVICEMSSQLSERVER'
 
, 'NT AUTHORITYSYSTEM'
 
, 'NT SERVICESQLWriter'
 
, '##MS_SQLAuthenticatorCertificate##'
 
, '##MS_AgentSigningCertificate##'
 
, '##MS_PolicyEventProcessingLogin##'
 
, '##MS_PolicySigningCertificate##'
 
, '##MS_PolicyTsqlExecutionLogin##'
 
, '##MS_SmoExtendedSigningCertificate##'
 
, '##MS_SQLResourceSigningCertificate##'
 
, '##MS_SQLReplicationSigningCertificate##'
 
)
 
order by
 
ssperm.[permission_name] asc


GRANT	VIEW ANY DEFINITION	to	SqlLink
GRANT	VIEW ANY DEFINITION	to	rdsvntrack

GRANT	VIEW ANY DEFINITION	to	RDCharlie
GRANT	VIEW ANY DEFINITION	to	vnBrice
GRANT	VIEW SERVER STATE	to	vnBrice
GRANT	VIEW SERVER STATE	to	SqlLink