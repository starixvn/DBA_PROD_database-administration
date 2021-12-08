/*
	Task - Upgrade SQL Server DB061 to 2019
		+ drop dummy DBs
	Run on DB061
*/

IF @@SERVERNAME = 'DB061'
	BEGIN
		EXEC sp_detach_db 'bodb_acc', 'true';  
		EXEC sp_detach_db 'bodb_archive', 'true'; 
		EXEC sp_detach_db 'bodb_Licensee', 'true'; 
		EXEC sp_detach_db 'bodb_OWP', 'true'; 
		EXEC sp_detach_db 'bodb_report', 'true'; 
		EXEC sp_detach_db 'bodb_TGRS', 'true'; 
		EXEC sp_detach_db 'bodb02', 'true'; 
		EXEC sp_detach_db 'LasDB_Archive', 'true'; 
		EXEC sp_detach_db 'LogDB', 'true'; 
		EXEC sp_detach_db 'LogPDB', 'true'; 
		EXEC sp_detach_db 'MONDB', 'true'; 
	END
