-- Alter TempDB Modify File Path
/*
SELECT os.Cores, df.Files FROM
   (SELECT COUNT(*) AS Cores FROM sys.dm_os_schedulers WHERE status = 'VISIBLE ONLINE') AS os,
   (SELECT COUNT(*) AS Files FROM tempdb.sys.database_files WHERE type_desc = 'ROWS') AS df;

SELECT name, physical_name,state_desc FROM sys.master_files
WHERE database_id = DB_ID(N'tempdb');

-- Gen Script
SELECT 'ALTER DATABASE ' + DB_NAME(database_id) + ' MODIFY FILE (NAME = ' + name
  + ', FILENAME = ''' + replace(physical_name,'K:\','H:\') + ''');'
FROM sys.master_files
WHERE database_id = DB_ID(N'tempdb');
*/
-----------------------------------------------------------------------------------------------------------


ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev, FILENAME = 'H:\SYS_DB\tempdb.mdf');
ALTER DATABASE tempdb MODIFY FILE (NAME = templog, FILENAME = 'H:\SYS_DB\templog.ldf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev001, FILENAME = 'H:\SYS_DB\tempdev001.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev002, FILENAME = 'H:\SYS_DB\tempdev002.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev003, FILENAME = 'H:\SYS_DB\tempdev003.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev004, FILENAME = 'H:\SYS_DB\tempdev004.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev005, FILENAME = 'H:\SYS_DB\tempdev005.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev006, FILENAME = 'H:\SYS_DB\tempdev006.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev007, FILENAME = 'H:\SYS_DB\tempdev007.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev008, FILENAME = 'H:\SYS_DB\tempdev008.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev009, FILENAME = 'H:\SYS_DB\tempdev009.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev010, FILENAME = 'H:\SYS_DB\tempdev010.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev011, FILENAME = 'H:\SYS_DB\tempdev011.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev012, FILENAME = 'H:\SYS_DB\tempdev012.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev013, FILENAME = 'H:\SYS_DB\tempdev013.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev014, FILENAME = 'H:\SYS_DB\tempdev014.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev015, FILENAME = 'H:\SYS_DB\tempdev015.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev016, FILENAME = 'H:\SYS_DB\tempdev016.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev017, FILENAME = 'H:\SYS_DB\tempdev017.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev018, FILENAME = 'H:\SYS_DB\tempdev018.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev019, FILENAME = 'H:\SYS_DB\tempdev019.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev020, FILENAME = 'H:\SYS_DB\tempdev020.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev021, FILENAME = 'H:\SYS_DB\tempdev021.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev022, FILENAME = 'H:\SYS_DB\tempdev022.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev023, FILENAME = 'H:\SYS_DB\tempdev023.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev024, FILENAME = 'H:\SYS_DB\tempdev024.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev025, FILENAME = 'H:\SYS_DB\tempdev025.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev026, FILENAME = 'H:\SYS_DB\tempdev026.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev027, FILENAME = 'H:\SYS_DB\tempdev027.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev028, FILENAME = 'H:\SYS_DB\tempdev028.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev029, FILENAME = 'H:\SYS_DB\tempdev029.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev030, FILENAME = 'H:\SYS_DB\tempdev030.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev031, FILENAME = 'H:\SYS_DB\tempdev031.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev032, FILENAME = 'H:\SYS_DB\tempdev032.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev033, FILENAME = 'H:\SYS_DB\tempdev033.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev034, FILENAME = 'H:\SYS_DB\tempdev034.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev035, FILENAME = 'H:\SYS_DB\tempdev035.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev036, FILENAME = 'H:\SYS_DB\tempdev036.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev037, FILENAME = 'H:\SYS_DB\tempdev037.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev038, FILENAME = 'H:\SYS_DB\tempdev038.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev039, FILENAME = 'H:\SYS_DB\tempdev039.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev040, FILENAME = 'H:\SYS_DB\tempdev040.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev041, FILENAME = 'H:\SYS_DB\tempdev041.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev042, FILENAME = 'H:\SYS_DB\tempdev042.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev043, FILENAME = 'H:\SYS_DB\tempdev043.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev045, FILENAME = 'H:\SYS_DB\tempdev045.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev046, FILENAME = 'H:\SYS_DB\tempdev046.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev047, FILENAME = 'H:\SYS_DB\tempdev047.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev048, FILENAME = 'H:\SYS_DB\tempdev048.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev049, FILENAME = 'H:\SYS_DB\tempdev049.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev050, FILENAME = 'H:\SYS_DB\tempdev050.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev051, FILENAME = 'H:\SYS_DB\tempdev051.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev052, FILENAME = 'H:\SYS_DB\tempdev052.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev053, FILENAME = 'H:\SYS_DB\tempdev053.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev054, FILENAME = 'H:\SYS_DB\tempdev054.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev055, FILENAME = 'H:\SYS_DB\tempdev055.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev056, FILENAME = 'H:\SYS_DB\tempdev056.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev057, FILENAME = 'H:\SYS_DB\tempdev057.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev058, FILENAME = 'H:\SYS_DB\tempdev058.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev059, FILENAME = 'H:\SYS_DB\tempdev059.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev060, FILENAME = 'H:\SYS_DB\tempdev060.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev061, FILENAME = 'H:\SYS_DB\tempdev061.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev062, FILENAME = 'H:\SYS_DB\tempdev062.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev063, FILENAME = 'H:\SYS_DB\tempdev063.ndf');
ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev044, FILENAME = 'H:\SYS_DB\tempdev044.ndf');
