/*
	Creator:	20180515@Billy
	Task:		New table for server tags - [Redmine: #94602]
	Server:		StarixDB
*/


--	BEGIN STEP 1:
--		Description
----------------------------------------------------------------------------------------------------

USE	StarixDB;
GO


CREATE TABLE	dbo.vnDBA_Perf_ServerTags (
					ServerName		NVARCHAR(128)
				,	Tag				NVARCHAR(60)
				,	CONSTRAINT	PK_vnDBA_Perf_ServerTags PRIMARY KEY CLUSTERED (
									ServerName	ASC
								,	Tag			ASC
								) ON PerfMon
				) ON PerfMon;

CREATE NONCLUSTERED INDEX	IX_vnDBA_Perf_ServerTags_Tag ON dbo.vnDBA_Perf_ServerTags (
								Tag		ASC
							) ON PerfMon;