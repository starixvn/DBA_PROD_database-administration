/*
	Creator:	20160715@Billy
	Task:		Create Objects Dependencies Staging Table - [Redmine: #61014]
	Server:		*ALL_SERVERS*
*/


--	BEGIN STEP 1:	*ALL_SERVERS*.MonDB
--		Create staging table
----------------------------------------------------------------------------------------------------

CREATE TABLE	vnDBA_Objects_Dependencies (
					session_id			UNIQUEIDENTIFIER
				,	referencer			NVARCHAR(256)
				,	referencer_type		CHAR(2)
				,	referenced_server	NVARCHAR(128)
				,	referenced_database	NVARCHAR(128)
				,	referenced_schema	NVARCHAR(128)
				,	referenced_entity	NVARCHAR(128)
				,	referenced_type		CHAR(2)
				,	level				INT
				)
