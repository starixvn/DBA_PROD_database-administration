/*
	Task: Change aliases have IP .91 (DB062)  -> .100 (DB061)
		
	Created on 20250303 by Daniel
	Run on DBSPARE to check alias/linked servers need to be change and prepare change file .reg & run
*/

--1.Run script at DBSPARE.starixDB to output content of .reg change file for each server:
SELECT 
    ServerName,
    'Windows Registry Editor Version 5.00' + CHAR(13) + CHAR(10) +
    CHAR(13) + CHAR(10) + '[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo]' + CHAR(13) + CHAR(10) +
    CHAR(13) + CHAR(10) +
    STRING_AGG('"' + linkedName + '"="' + REPLACE(alias64, '.91', '.100') + '"', CHAR(13) + CHAR(10))
    AS RegFileContent
INTO #TempRegFiles -- Store in a temp table
FROM dbo.AliasInfo 
WHERE (Datasource LIKE '10.1.1.91' 
   OR Datasource LIKE '10.40.40.91'
   ) 
   and alias64 like 'DBMSSOCN%'
   and serverName not in('dbspare', 'dbdwcss')
GROUP BY ServerName;

select * from #TempRegFiles

DECLARE @ServerName NVARCHAR(255), @RegFileContent NVARCHAR(MAX)

DECLARE cursor_reg CURSOR FOR
SELECT ServerName, RegFileContent FROM #TempRegFiles

OPEN cursor_reg
FETCH NEXT FROM cursor_reg INTO @ServerName, @RegFileContent

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '=== ' + @ServerName + '.reg ==='
    PRINT @RegFileContent
    PRINT ''
    
    FETCH NEXT FROM cursor_reg INTO @ServerName, @RegFileContent
END

CLOSE cursor_reg
DEALLOCATE cursor_reg

DROP TABLE #TempRegFiles

--check all:
select * from dbo.AliasInfo where Datasource like '10.1.1.91' or Datasource like '10.40.40.91'



--2.Prepare .reg files: Copy the output text and paste to file .reg for each server, then run the .reg file to make change when deploying

/*

=== DB052.reg ===
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo]

"DB06"="DBMSSOCN,10.1.1.100"
"DBARC"="DBMSSOCN,10.1.1.100"
"DBLASARC"="DBMSSOCN,10.1.1.100"
"DBOWP"="DBMSSOCN,10.1.1.100"
"DBPTCSARC"="DBMSSOCN,10.1.1.100"
"DBRPT"="DBMSSOCN,10.1.1.100"
 
=== DB053.reg ===
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo]

"DB06"="DBMSSOCN,10.1.1.100"
"DBARC"="DBMSSOCN,10.1.1.100"
"DBOWP"="DBMSSOCN,10.1.1.100"
"DBPTCSARC"="DBMSSOCN,10.1.1.100"
"DBRPT"="DBMSSOCN,10.1.1.100"
 
=== DB054.reg ===
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo]

"DB06"="DBMSSOCN,10.1.1.100"
 
=== DB061.reg ===
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo]

"DB06"="DBMSSOCN,10.1.1.100"
"DB062"="DBMSSOCN,10.1.1.100"
 
=== DBBACKUP2.reg ===
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo]

"DB06KBT"="DBMSSOCN,10.1.1.100"
 
=== DBDW.reg ===
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo]

"DB06"="DBMSSOCN,10.1.1.100"
"DBWASA"="DBMSSOCN,10.40.40.100"
 
=== DBDW2.reg ===
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo]

"DB06"="DBMSSOCN,10.1.1.100"
"DBWASA"="DBMSSOCN,10.40.40.100"
 
=== DBGRP01N1.reg ===
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo]

"DB062"="DBMSSOCN,10.1.1.100"
"DBTGRS"="DBMSSOCN,10.1.1.100"
 
=== DBGRP02N1.reg ===
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo]

"DB062"="DBMSSOCN,10.1.1.100"
"DBTGRS"="DBMSSOCN,10.1.1.100"
 
=== DBGRP03N1.reg ===
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo]

"DB062"="DBMSSOCN,10.1.1.100"
"DBTGRS"="DBMSSOCN,10.1.1.100"
 
=== DBSITEC1.reg ===
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo]

"DB062"="DBMSSOCN,10.1.1.100"
"DBTGRS"="DBMSSOCN,10.1.1.100"
 
=== DBSITEC2\INST2.reg ===
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo]

"DB062"="DBMSSOCN,10.1.1.100"
"DBTGRS"="DBMSSOCN,10.1.1.100"
 
=== DBSITEC3\INST3.reg ===
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo]

"DB062"="DBMSSOCN,10.1.1.100"
"DBTGRS"="DBMSSOCN,10.1.1.100"
 
=== DBTP10C.reg ===
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo]

"DB06"="DBMSSOCN,10.1.1.100"
 
=== DBTrans.reg ===
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo]

"DB062"="DBMSSOCN,10.1.1.100"
"DBARC62"="DBMSSOCN,10.1.1.100"
"DBRPT"="DBMSSOCN,10.1.1.100"
 


*/



