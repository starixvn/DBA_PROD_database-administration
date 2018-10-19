/*
	Creator:	20181019@Billy
	Task:		Description - [Redmine: #000000]
	Server:		DB233
*/


USE	StarixDB;
GO


--	BEGIN STEP :
--		Description
----------------------------------------------------------------------------------------------------

CREATE TABLE	dbo.vnDBA_Partition_Status (
					ServerName			NVARCHAR(128)	NOT NULL
				,	DatabaseName		NVARCHAR(128)	NOT NULL
				,	TableName			NVARCHAR(128)	NOT NULL
				,	PartitionScheme		NVARCHAR(128)	NOT NULL
				,	PartitionFunction	NVARCHAR(128)	NOT NULL
				,	Interval			NVARCHAR(50)	NULL
				,	Target				SQL_VARIANT		NULL
				,	MaxValue			SQL_VARIANT		NULL
				,	CONSTRAINT	PK_Partition_Status PRIMARY KEY CLUSTERED (
									ServerName		ASC
								,	DatabaseName	ASC
								,	TableName		ASC
								) ON DATA
				) ON DATA;