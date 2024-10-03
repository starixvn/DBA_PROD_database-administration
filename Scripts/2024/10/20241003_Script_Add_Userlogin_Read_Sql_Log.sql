/*<info serverAlias="All Server-master></info>*/
/*  
	Created by: 20241003@Sol
	Task: remove unsed login 
	DB: All Server-master
*/

USE master;

GO

IF NOT EXISTS (
		SELECT 1
		FROM sys.database_principals
		WHERE DB_NAME() = 'master'
			AND name = 'sqllink'
		)
BEGIN

	CREATE USER [sqllink] FOR LOGIN [sqllink];

	GRANT EXECUTE ON xp_readerrorlog TO [sqllink];

END

GO