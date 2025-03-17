/*
	Task: Restore databases recovery from LS secondary
		bodb_archive_New
		bodb_Report_New
		
	Created on 20250317 by Daniel
	Run on DB062
*/

-- Disable LS jobs
use MASTER
GO

RESTORE bodb_Report_New WITH RECOVERY
GO
RESTORE bodb_Archive_New WITH RECOVERY
GO
