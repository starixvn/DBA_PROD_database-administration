CREATE TABLE	dbo.match (
					matchid		INT
				,	matchname	NVARCHAR(200)
				,	CONSTRAINT	PK_match PRIMARY KEY CLUSTERED (
									matchid		ASC
								) ON DATA
				);

CREATE TABLE	dbo.transcount (
					transdate	DATETIME
				,	matchid		INT
				,	transcnt	INT
				,	CONSTRAINT	PK_transcount PRIMARY KEY CLUSTERED (
									transdate	ASC
								,	matchid		ASC
								) WITH (DATA_COMPRESSION = PAGE) ON DATA
				);

