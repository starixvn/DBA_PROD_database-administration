/*
	set up AG on DB054/DB055
	Add bodb_N88Log & bodb_NAPLog to AG
	20230616@Brice: setup AG and add DB to AG 
	run on DB054/DB055
*/

----------------------------------------------------------------------------step1: create endpoint and start AG health check extended event on DB054----------------------------------------------------------------
USE [master]

GO

CREATE ENDPOINT [Hadr_endpoint] 
	AS TCP (LISTENER_PORT = 5022)
	FOR DATA_MIRRORING (ROLE = ALL, ENCRYPTION = REQUIRED ALGORITHM AES)

GO

IF (SELECT state FROM sys.endpoints WHERE name = N'Hadr_endpoint') <> 0
BEGIN
	ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED
END

GO

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER WITH (STARTUP_STATE=ON);
END
IF NOT EXISTS(SELECT * FROM sys.dm_xe_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER STATE=START;
END

GO

----------------------------------------------------------------------------//step1: create endpoint and start AG health check extended event on DB054----------------------------------------------------------------


----------------------------------------------------------------------------step2: create endpoint and start AG health check extended event on DB055----------------------------------------------------------------

USE [master]

GO

CREATE ENDPOINT [Hadr_endpoint] 
	AS TCP (LISTENER_PORT = 5022)
	FOR DATA_MIRRORING (ROLE = ALL, ENCRYPTION = REQUIRED ALGORITHM AES)

GO

IF (SELECT state FROM sys.endpoints WHERE name = N'Hadr_endpoint') <> 0
BEGIN
	ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED
END


GO

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER WITH (STARTUP_STATE=ON);
END
IF NOT EXISTS(SELECT * FROM sys.dm_xe_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER STATE=START;
END

GO

----------------------------------------------------------------------------//step2: create endpoint and start AG health check extended event on DB055----------------------------------------------------------------
-- this endpoints run as acc which is running sql server service, so make sure that acc is added as sql login with SA role and connect to SQL permission
-- after this step, we might run check endpoint script



----------------------------------------------------------------------------step3: create AG and Listener on DB054----------------------------------------------------------------
--create DB brice_AG_UAT to trigger AG creating
USE [master]

GO

CREATE AVAILABILITY GROUP [DB05HA1G1]
WITH (AUTOMATED_BACKUP_PREFERENCE = PRIMARY,
DB_FAILOVER = ON,
DTC_SUPPORT = NONE,
REQUIRED_SYNCHRONIZED_SECONDARIES_TO_COMMIT = 0)
FOR DATABASE [brice_AG_UAT]
REPLICA ON N'DB054' WITH (ENDPOINT_URL = N'TCP://DB054.oneworks.farms.com:5022', FAILOVER_MODE = MANUAL, AVAILABILITY_MODE = SYNCHRONOUS_COMMIT, BACKUP_PRIORITY = 50, SEEDING_MODE = MANUAL, PRIMARY_ROLE(READ_ONLY_ROUTING_LIST = (N'DB055',N'DB054')), SECONDARY_ROLE(READ_ONLY_ROUTING_URL = N'TCP://10.40.40.95:1433', ALLOW_CONNECTIONS = ALL)),
	N'DB055' WITH (ENDPOINT_URL = N'TCP://DB055.oneworks.farms.com:5022', FAILOVER_MODE = MANUAL, AVAILABILITY_MODE = SYNCHRONOUS_COMMIT, BACKUP_PRIORITY = 50, SEEDING_MODE = MANUAL, PRIMARY_ROLE(READ_ONLY_ROUTING_LIST = (N'DB054',N'DB055')), SECONDARY_ROLE(READ_ONLY_ROUTING_URL = N'TCP://10.40.40.82:1433', ALLOW_CONNECTIONS = ALL));

GO



USE [master]

GO

ALTER AVAILABILITY GROUP [DB05HA1G1]
ADD LISTENER N'DB05HA1G1L' (
WITH IP
((N'10.40.40.xx', N'255.255.255.0')
)
, PORT=1433);

GO

----------------------------------------------------------------------------//step3: create AG and Listener  on DB054----------------------------------------------------------------

----------------------------------------------------------------------------step4: join AG on DB055----------------------------------------------------------------


ALTER AVAILABILITY GROUP [DB05HA1G1L] JOIN;

GO

--GRANT CONNECT on ENDPOINT::Hadr_Endpoint TO [DB054\SQL];

GO
----------------------------------------------------------------------------//step4: join AG on DB055----------------------------------------------------------------

----------------------------------------------------------------------------step5: Add DBs into AG on DB054----------------------------------------------------------------
-- on primary node, run

USE [master]

GO

ALTER AVAILABILITY GROUP [DB05HA1G1L]
ADD DATABASE [bodb_N88Log];
GO

ALTER AVAILABILITY GROUP [DB05HA1G1L]
ADD DATABASE [bodb_NAPLog];
go

----------------------------------------------------------------------------//step5: Add DBs into AG on DB054----------------------------------------------------------------

----------------------------------------------------------------------------step6: join DBs into AG on DB055----------------------------------------------------------------
-- on secondary node, run
-- Wait for the replica to start communicating
begin try
declare @conn bit
declare @count int
declare @replica_id uniqueidentifier 
declare @group_id uniqueidentifier
set @conn = 0
set @count = 30 -- wait for 5 minutes 

if (serverproperty('IsHadrEnabled') = 1)
	and (isnull((select member_state from master.sys.dm_hadr_cluster_members where upper(member_name COLLATE Latin1_General_CI_AS) = upper(cast(serverproperty('ComputerNamePhysicalNetBIOS') as nvarchar(256)) COLLATE Latin1_General_CI_AS)), 0) <> 0)
	and (isnull((select state from master.sys.database_mirroring_endpoints), 1) = 0)
begin
    select @group_id = ags.group_id from master.sys.availability_groups as ags where name = N'DB05HA1G1L'
	select @replica_id = replicas.replica_id from master.sys.availability_replicas as replicas where upper(replicas.replica_server_name COLLATE Latin1_General_CI_AS) = upper(@@SERVERNAME COLLATE Latin1_General_CI_AS) and group_id = @group_id
	while @conn <> 1 and @count > 0
	begin
		set @conn = isnull((select connected_state from master.sys.dm_hadr_availability_replica_states as states where states.replica_id = @replica_id), 1)
		if @conn = 1
		begin
			print ('conn = '+ cast(@conn as varchar) + ', try count left = ' + cast (@count as varchar))
			break
		end
		waitfor delay '00:00:10'
		set @count = @count - 1
	end
end
end try
begin catch
	print( 'loop fails, do not stop execution of the alter database statement')
end catch

ALTER DATABASE [bodb_N88Log] SET HADR AVAILABILITY GROUP = [DB05HA1G1L];
go

ALTER DATABASE [bodb_NAPLog] SET HADR AVAILABILITY GROUP = [DB05HA1G1L];

GO

----------------------------------------------------------------------------//step6: join DBs into AG on DB055----------------------------------------------------------------
