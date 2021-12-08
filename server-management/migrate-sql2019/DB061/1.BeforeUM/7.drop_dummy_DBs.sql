/*
	Task - Upgrade SQL Server DB061 to 2019
		+ drop dummy DBs
	Run on DB06N3
*/

IF @@SERVERNAME = 'DB06N3'
	BEGIN
		DROP DATABASE [bodb_acc]
		DROP DATABASE [bodb_archive]
		DROP DATABASE [bodb_Licensee]
		DROP DATABASE [bodb_OWP]
		DROP DATABASE [bodb_report]
		DROP DATABASE [bodb_TGRS]
		DROP DATABASE [bodb02]
		DROP DATABASE [LasDB_Archive]
		DROP DATABASE [LogDB]
		DROP DATABASE [LogPDB]
		DROP DATABASE [MONDB]
	END
