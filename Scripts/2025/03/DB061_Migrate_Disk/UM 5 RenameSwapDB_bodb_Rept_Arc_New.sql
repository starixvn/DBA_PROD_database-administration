/*
	Task: Rename (swap) databases
		bodb_Report -> bodb_Report_old
		bodb_Archive -> bodb_Archive_old
		bodb_Report_New -> bodb_Report
		bodb_Archive_New -> bodb_Archive
		
	Created on 20250317 by Daniel
	Run on DB061
*/

use master;
go

ALTER DATABASE bodb_Report SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
ALTER DATABASE bodb_Report MODIFY NAME = bodb_Report_Old;
GO
ALTER DATABASE bodb_Report_Old SET MULTI_USER;
GO

ALTER DATABASE bodb_archive SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
ALTER DATABASE bodb_archive MODIFY NAME = bodb_archive_Old;
GO
ALTER DATABASE bodb_archive_Old SET MULTI_USER;
GO
---

ALTER DATABASE bodb_Report_New SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
ALTER DATABASE bodb_Report_New MODIFY NAME = bodb_Report;
GO
ALTER DATABASE bodb_Report SET MULTI_USER;
GO

ALTER DATABASE bodb_archive_New SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
ALTER DATABASE bodb_archive_New MODIFY NAME = bodb_Archive;
GO
ALTER DATABASE bodb_Archive SET MULTI_USER;
GO

