/*
	Task: Restore databases recovery from LS secondary
		bodb_archive_New
		bodb_Report_New
		
	Created on 20250317 by Daniel
	Run on DB062
*/

use MASTER
GO

RESTORE DATABASE bodb_Report_New WITH RECOVERY
GO
RESTORE DATABASE bodb_Archive_New WITH RECOVERY
GO
