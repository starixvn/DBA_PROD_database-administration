use master;
--Select * from sys.configurations 
--exec sp_configure

exec sp_help_revlogin 'vnBobby'


exec sp_helptext sp_help_revlogin


SELECT p.name, p.sid, p.type, p.is_disabled, p.default_database_name, l.hasaccess, l.denylogin 
	, '(''' + p.name + '''),' as [nameEx]
FROM   sys.server_principals p LEFT JOIN sys.syslogins l  
      ON ( l.name = p.name ) WHERE p.type IN ( 'S', 'G', 'U' ) --AND p.name = @login_name  

-- CREATE LOGIN [vnBobby] WITH PASSWORD = 0x01004E2ED9A02E1BAA4FCF655F9BDA59C42D1CA52D7869BA5DB4 HASHED, SID = 0xCA36FD8DDD606640A429E00F1FEFBF25, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF

;
with cte as (
	select name
	from (
		values
		('mondb_user'),
		('bodbAdminNet'),
		('bodbDownlineNet'),
		('bodbDownlineNetView'),
		('Dot_Admin'),
		('bodbExtAccNet'),
		('Dot_3rdparty'),
		('Dot_Casino'),
		('thien'),
		('vnteam'),
		('vnDBA'),
		('Dot_Member'),
		('VnAffiliate'),
		('bodbLicenseeNet'),
		('portal'),
		('RDCooper'),
		('RDVictor'),
		('bodbinternalNet'),
		('SqlLink'),
		('ServerMonitor'),
		('vnLukas'),
		('DataSync'),
		('RDBenLee'),
		('vnDaniel'),
		('RDLeon'),
		('Viet'),
		('vnJoe'),
		('rdsvntrack'),
		('vnprofilers'),
		('vnPatrick'),
		('vnBilly'),
		('RDVivi'),
		('RDSylvia'),
		('RDAlfie'),
		('dba_Cert_User'),
		('vnHelen'),
		('bodbRMSNet'),
		('dwrs2'),
		('bodbSPUNet'),
		('vnSPU'),
		('bodbPloutosNet'),
		('DB053\sql'),
		('vnBobby'),
		('RDCharlie'),
		('RDMei'),
		('vnBrice'),
		('bodbChartNet'),
		('RDColin'),
		('RDDBA_RM')
	) as t(name)
)
select t.cmd
from cte 
cross apply (
	select 'insert into #login' as cmd
	union all
	select 'exec sp_help_revlogin_bobby ''' + name +'''' as cmd
	union all
	select 'insert into #login' as cmd
	union all
	select 'select ''GO'''
) as t
;

go

--drop proc sp_help_revlogin_bobby