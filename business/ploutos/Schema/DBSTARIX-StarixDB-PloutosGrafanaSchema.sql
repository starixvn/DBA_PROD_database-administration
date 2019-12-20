/*
	Creator:	20191220@Billy
	Task:		Schema tables for Grafana support for Ploutos system - [Redmine: #125807]
	Server:		DBSTARIX.StarixDB
*/


--	BEGIN STEP 1:
--		TimeGroup table
----------------------------------------------------------------------------------------------------

CREATE TABLE	plo.TimeGroups (
					GroupName		VARCHAR(128)
				,	SecondGroup		INT
				,	MinuteGroup		AS SecondGroup / 60
				,	HourGroup		AS SecondGroup / 60 / 60
				,	DayGroup		AS SecondGroup / 60 / 60 / 24
				,	CONSTRAINT	PK_TimeGroups PRIMARY KEY CLUSTERED (GroupName ASC) ON DATA
				);

INSERT INTO	plo.TimeGroups
		(GroupName, SecondGroup )
VALUES	('SECOND' , 1           )
	,	('MINUTE' , 60          )
	,	('HOUR'   , 60 * 60     )
	,	('DAY'    , 60 * 60 * 24)
	;