/*<info serverAlias="All Server-master></info>*/
/*  
	Created by: 20241003@Sol
	Task: remove unsed login 
	DB: All Server-master
*/

USE master;

GO

SET NOCOUNT ON;


--full new login table
declare @tblNewLogin table (oldLogin nvarchar(100))
insert into @tblNewLogin
values 
  ('bodbAdminNet'),
  ('bodbDownlineNet'),
  ('bodbDownlineNetView'),
  ('bodbAdmin'),
  ('bodbExtAccNet'),
  ('bodbLicenseeNet'),
  ('bodbRMSNet'),
  ('bodbPolicyNetView'),
  ('bodbPloutosNet'),
  ('bodbSPUNet'),
  ('bodbOWPNet'),
  ('bodbTGRSNet'),
  ('fpsWinService'),
  ('fpsdev'),
  ('fpsWebSub'),
  ('fpsWebService'),
  ('fpsWebAdmin'),
  ('fpsTask'),
  ('bodbDownlineNetView'),
  ('bodbAdminNet'),
  ('bodbAdminNet'),
  ('bodbDownlineNet'),
  ('bodbDownlineNetViewv'),
  ('wsv_aff'),
  ('wsv_affv')

select * from @tblNewLogin


--#######################################################
IF OBJECT_ID('tempdb..#tblApplied', 'U') IS NOT NULL
  DROP TABLE #tblApplied;
create table #tblApplied (serverName varchar(100), newLogin nvarchar(500))

--log throught the table login
DECLARE @sqlogin nvarchar(4000)

declare @oldlogin nvarchar(100) = ''
declare @newlogin nvarchar(100) = ''
declare @newPassword nvarchar(500) = ''
declare @newsid nvarchar(500) = ''

declare @cmdSchema nvarchar(max) = ''
declare @cmd nvarchar(max) = ''

DECLARE c_newLogin CURSOR 
  FOR select oldLogin from @tblNewLogin

OPEN c_newLogin 
  FETCH NEXT FROM c_newLogin INTO @oldlogin

--begin loop
WHILE (@@FETCH_STATUS = 0)
BEGIN

  IF EXISTS(SELECT 1 FROM master.sys.syslogins WITH (NOLOCK) WHERE loginname = @oldlogin)
  BEGIN

    --old login existed and new login will be created
    insert into #tblApplied(serverName, newLogin) select @@SERVERNAME, @oldlogin

    --/*Create User Account*/
    IF OBJECT_ID('tempdb..#tmp_sync_cmd', 'U') IS NOT NULL
      DROP TABLE #tmp_sync_cmd;
    CREATE TABLE #tmp_sync_cmd ([cmd] nvarchar(4000));

    set @cmdSchema = N'
    use [?];
    IF EXISTS(SELECT 1 FROM master.sys.databases WITH (NOLOCK) WHERE [name] = ''?'' AND [state] = 0 AND [is_read_only] = 0 AND [is_in_standby] = 0)
     select CMD = N''use [?];
     IF NOT EXISTS(select 1 from sys.objects o inner join sys.schemas s on o.schema_id = s.schema_id where s.name = ''''' + @oldlogin + ''''')
      DROP SCHEMA [' + @oldlogin + '] ;''
     from sys.schemas
     where name = ''' + @oldlogin + '''
     ;'


    insert into #tmp_sync_cmd  
     exec sp_MSForeachDB @command1= @cmdSchema

    set @cmd = N'
     use [?];
     IF EXISTS(SELECT 1 FROM master.sys.databases WITH (NOLOCK) WHERE [name] = ''?'' AND [state] = 0 AND [is_read_only] = 0 AND [is_in_standby] = 0)
     select CMD = N''use [?];
     IF EXISTS(SELECT 1 FROM sys.database_principals WITH (NOLOCK) WHERE [name] = ''''' + @oldlogin + ''''')
      DROP USER [' + @oldlogin + '] ;''
     from sys.database_principals dp left join sys.server_principals sp
      on (dp.sid = sp.sid)
     where dp.type in (''S'',''U'',''G'')
       and dp.principal_id > 4
       and dp.name = ''' + @oldlogin + '''
       and sys.fn_hadr_backup_is_preferred_replica(''?'')=1
     order by sp.name;'

     --print @cmd

    insert into #tmp_sync_cmd  
     exec sp_MSForeachDB @command1= @cmd

    select * from #tmp_sync_cmd;

    DECLARE @sqlUser nvarchar(4000);
    DECLARE c_Cur CURSOR FOR
      select [cmd] from #tmp_sync_cmd;
    OPEN c_Cur
    FETCH NEXT FROM c_Cur INTO @sqlUser
    WHILE (@@FETCH_STATUS = 0)
    BEGIN

      ------EXEC sp_executesql @sqlUser;

      FETCH NEXT FROM c_Cur INTO @sqlUser;
    END

    CLOSE c_Cur
    DEALLOCATE c_Cur


    --server
    --/*Create Login Account*/
    SELECT @sqlogin = 'IF EXISTS(SELECT 1 FROM master.sys.syslogins WITH (NOLOCK) WHERE loginname = ''' + @oldlogin + ''') 
        DROP LOGIN [' + @oldlogin + '] ;
      '
    FROM master.sys.syslogins WITH (NOLOCK)
    WHERE loginname = @oldlogin
    --print @sqlogin
    --SELECT @@SERVERNAME AS ServerName, @sqlogin AS 'cmd'

    select @sqlogin

    -------EXEC sp_executesql @sqlogin;

    drop table #tmp_sync_cmd;

  END

  SET @cmd = ''
  FETCH NEXT FROM c_newLogin INTO @oldlogin

END


CLOSE c_newLogin
DEALLOCATE c_newLogin

select * from #tblApplied

Drop table #tblApplied

GO