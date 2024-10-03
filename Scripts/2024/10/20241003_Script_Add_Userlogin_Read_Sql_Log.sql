/*<info serverAlias="All Server-master></info>*/
/*  
	Created by: 20241003@Sol
	Task: remove unsed login 
	DB: All Server-master
*/

USE master;

GO

CREATE USER [sqllink] FOR LOGIN [sqllink];

GO

GRANT EXECUTE ON xp_readerrorlog TO [sqllink];

GO