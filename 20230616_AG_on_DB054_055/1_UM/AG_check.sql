--check
---------------------------------check endpoint-----------------------------------------------------------------------------------------
-- run on powershell
Test-NetConnection -ComputerName sitdbgrp03n2 -Port 1433

An error occurred while receiving data: '24(The program issued a command but the command length is incorrect.)'.

SELECT
  tep.name as EndPointName,
  sp.name As CreatedBy,
  tep.type_desc,
  tep.state_desc,
  tep.port
FROM
  sys.tcp_endpoints tep
INNER JOIN sys.server_principals sp ON tep.principal_id = sp.principal_id
WHERE tep.type = 4



select
  r.replica_server_name,
  r.endpoint_url,
  rs.connected_state_desc,
  rs.last_connect_error_description,
  rs.last_connect_error_number,
  rs.last_connect_error_timestamp
from
  sys.dm_hadr_availability_replica_states rs
  join sys.availability_replicas r on rs.replica_id = r.replica_id
where
  rs.is_local = 1


select endpoint_url from sys.availability_replicas

SELECT 
  perm.class_desc,
  prin.name,
  perm.permission_name,
  perm.state_desc,
  prin.type_desc as PrincipalType,
  prin.is_disabled
FROM sys.server_permissions perm
  LEFT JOIN sys.server_principals prin ON perm.grantee_principal_id = prin.principal_id
  LEFT JOIN sys.tcp_endpoints tep ON perm.major_id = tep.endpoint_id
WHERE 
  perm.class_desc = 'ENDPOINT'
  AND perm.permission_name = 'CONNECT'
  AND tep.type = 4;

SELECT 
  ep.name, 
  sp.state,
  CONVERT(nvarchar(38), suser_name(sp.grantor_principal_id)) AS grantor,
  sp.TYPE AS permission,
  CONVERT(nvarchar(46),suser_name(sp.grantee_principal_id)) AS grantee
FROM sys.server_permissions SP 
  INNER JOIN sys.endpoints ep  ON sp.major_id = ep.endpoint_id
AND EP.type = 4
ORDER BY Permission,grantor, grantee;   
  
  ---------------------------------//check endpoint-----------------------------------------------------------------------------------------
  