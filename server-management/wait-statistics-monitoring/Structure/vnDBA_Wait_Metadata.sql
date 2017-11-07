/*
	Creator:	20171009@Billy
	Task:		New Wait Statistics Capturing - [Redmine: #84605]
	Server:		DBDWCSS.StarixDB
*/

USE	StarixDB;
GO

CREATE TABLE	dbo.vnDBA_Wait_Metadata (
					WaitType		NVARCHAR(60)	NOT NULL
				,	Category		NVARCHAR(60)	NOT NULL
				,	Ignorable		BIT				NOT NULL
				,	Report			NVARCHAR(60)	NULL
				,	CONSTRAINT PK_vnDBA_Wait_Metadata PRIMARY KEY CLUSTERED (WaitType ASC) ON WaitStat
				) ON WaitStat;
GO