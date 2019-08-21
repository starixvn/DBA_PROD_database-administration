/*
	Creator:	20190821@Billy
	Task:		Tables for checksum data - [Redmine: #000000]
	Server:		DBTP.bodb02 & DBMNL.bodb02
*/

USE	bodb02;
GO

--	BEGIN STEP 1:
--		Metadata tables
----------------------------------------------------------------------------------------------------

CREATE TABLE	dbo.ChecksumData_Checklist (
					SchemaName			NVARCHAR(128)
						CONSTRAINT	DF_ChecksumData_Checklist_Schema DEFAULT (N'dbo')
				,	TableName			NVARCHAR(128)
				,	ColumnName			NVARCHAR(128)
				,	ColumnType			NVARCHAR(128)
				,	BatchInterval		BIGINT
				,	SourceServer		NVARCHAR(128)
				,	SourceDatabase		NVARCHAR(128)
				,	TargetServer		NVARCHAR(128)
				,	TargetDatabase		NVARCHAR(128)
				,	isActive			BIT
				,	CONSTRAINT	PK_ChecksumData_Checklist PRIMARY KEY CLUSTERED (
									SourceServer	ASC
								,	SourceDatabase	ASC
								,	TargetServer	ASC
								,	TargetDatabase	ASC
								,	TableName		ASC
								,	ColumnName		ASC
								,	SchemaName		ASC
								) ON DATA
				) ON DATA;

CREATE TABLE	dbo.ChecksumData_ExcludedColumns (
					DatabaseName		NVARCHAR(128)
				,	TableName			NVARCHAR(128)
				,	ColumnName			NVARCHAR(128)
				,	CONSTRAINT	PK_ChecksumData_ExcludedColumns PRIMARY KEY CLUSTERED (
									DatabaseName	ASC
								,	TableName		ASC
								,	ColumnName		ASC
								) ON DATA
				) ON DATA;


--	BEGIN STEP 2:
--		Result tables
----------------------------------------------------------------------------------------------------

CREATE TABLE	dbo.ChecksumData_Result (
					CheckDate			DATETIME
				,	SourceServer		NVARCHAR(128)
				,	SourceDatabase		NVARCHAR(128)
				,	TargetServer		NVARCHAR(128)
				,	TargetDatabase		NVARCHAR(128)
				,	SchemaName			NVARCHAR(128)
				,	TableName			NVARCHAR(128)
				,	ColumnName			NVARCHAR(128)
				,	ValueFrom			BIGINT
				,	ValueTo				BIGINT
				,	SourceChecksum		BIGINT
				,	SourceRowcount		BIGINT
				,	SourceDuration		BIGINT
				,	TargetChecksum		BIGINT
				,	TargetRowcount		BIGINT
				,	TargetDuration		BIGINT
				,	isDone				BIT
				,	CONSTRAINT	PK_ChecksumData_Result PRIMARY KEY CLUSTERED (
									CheckDate		ASC
								,	SourceServer	ASC
								,	SourceDatabase	ASC
								,	TargetServer	ASC
								,	TargetDatabase	ASC
								,	TableName		ASC
								,	ValueFrom		ASC
								,	ValueTo			ASC
								) ON DATA
				) ON DATA;
GO
/*<info serverAlias="DBTP-bodb02" executers="" viewers="" isFunction="0" isNested="0"></info>*/