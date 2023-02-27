
-- shrink db
use master
go

--shrink files
GO

-- update stats
USE bodb_Archive
GO

EXEC sp_updatestats
GO