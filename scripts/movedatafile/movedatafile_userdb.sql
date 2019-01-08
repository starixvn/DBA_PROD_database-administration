/*
	Created: 20190103@Helen
	Task: Movedatafile checklist
	DB: DBxxx
	
	Notes: Should have redmine to keep track with all these basic steps below
*/
-----------------Step 1: Check data file size, is it ok to move new location ? ---------
	-----------------Step 1.1: size of data file
	SELECT name, physical_name AS CurrentLocation, state_desc, size 
	FROM sys.master_files  
	WHERE database_id = DB_ID(N'DBxxx')

	-----------------Step 1.1: check current size of drives, permission sysadmin to run the following commands
	exec master..xp_fixeddrives

-----------------Step 2: Set database offline ---------
	USE DBxxx
	GO
	ALTER DATABASE DBxxx SET SINGLE_USER WITH ROLLBACK IMMEDIATE

	ALTER DATABASE DBxxx SET OFFLINE
	GO
-----------------Step 3: Copy data file to new location ---------
-----------------Step 4: Modify filename ---------
	DECLARE @NewLocation VARCHAR(50) = 'N:\NewLocation'
	
	SELECT physical_name, 
		  'ALTER DATABASE ' + DB_Name() + ' MODIFY FILE (NAME = [' + name + '], FILENAME = ''' 
		 + @NewLocation -- NEW folder
		 + RIGHT(physical_name,CHARINDEX('\',REVERSE(physical_name))-1) -- filename
		 + ''')' AS [Script]
	FROM sys.master_files  
	WHERE database_id = DB_ID(N'DBxxx')
	ORDER BY physical_name

-----------------Step 4: Bring database online ---------
	USE DBxxx
	GO
	ALTER DATABASE DBxxx SET ONLINE
	ALTER DATABASE DBxxx SET MULTI_USER



