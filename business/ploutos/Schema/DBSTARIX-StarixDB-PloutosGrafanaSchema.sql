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
		(GroupName   , SecondGroup )
VALUES	('SECOND'    , 1           )
	,	('30 SECONDS', 30          )
	,	('MINUTE'    , 60          )
	,	('10 MINUTES', 60 * 10     )
	,	('15 MINUTES', 60 * 15     )
	,	('30 MINUTES', 60 * 30     )
	,	('HOUR'      , 60 * 60     )
	,	('3 HOURS'   , 60 * 60 * 3 )
	,	('6 HOURS'   , 60 * 60 * 6 )
	,	('12 HOURS'  , 60 * 60 * 12)
	,	('DAY'       , 60 * 60 * 24)
	;
