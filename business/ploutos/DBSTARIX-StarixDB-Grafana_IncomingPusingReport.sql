SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	plo.Grafana_IncomingPusingReport
						@From				DATETIME
					,	@To					DATETIME
					,	@Type				NVARCHAR(128)
					,	@Brand				VARCHAR(20)		= N'ALL'
					,	@TimeGroup			VARCHAR(128)	= N'HOUR'
AS
/*
	Creator:	20191220@Billy
	Task:		Description - [Redmine: #125807]
	Database:	DBSTARIX.StarixDB

	Revisions:
		- 20191220@Billy:	Initial - [Redmine: #125807]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	-- Time related variables --
	DECLARE	@Timezone		SMALLINT
		,	@BaseTime		DATETIME
		,	@_From			INT
		,	@_To			INT
		,	@_TimeGroup		INT
		;

	-- Temporary result timeline --
	DECLARE	@Times AS TABLE (
				TimeTick		INT
					PRIMARY KEY CLUSTERED
			,	TimeReport		DATETIME
			);

	-- Determine fixed time values --
	SELECT	@Timezone = DATEDIFF(HOUR, GETDATE(), GETUTCDATE())
		,	@BaseTime = '2019-01-01'
		;

	-- Convert UTC input to server timezone secondstamp format --
	SELECT	@_From	= DATEDIFF(SECOND, @BaseTime, DATEADD(HOUR, @Timezone, @From))
		,	@_To	= DATEDIFF(SECOND, @BaseTime, DATEADD(HOUR, @Timezone, @To))
		;

	-- Parse time group --
	SELECT	@_TimeGroup	= SecondGroup
	FROM	plo.TimeGroups WITH (NOLOCK)
	WHERE	GroupName = @TimeGroup;

	-- Build timeline based on time group --
	WITH cte AS (
		SELECT	[rn] = ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
		FROM		(VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9)) AS _x10(a)
		CROSS APPLY	(VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9)) AS _x100(a)
		CROSS APPLY	(VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9)) AS _x1000(a)
		CROSS APPLY	(VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9)) AS _x10000(a)
		CROSS APPLY	(VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9)) AS _x100000(a)
	)
	INSERT INTO	@Times (TimeTick, TimeReport)
	SELECT	t.TimeTick, DATEADD(HOUR, -@Timezone, DATEADD(SECOND, t.TimeTick, @BaseTime))
	FROM	cte
	CROSS APPLY	(
		SELECT	[TimeTick] = (FLOOR(@_From / @_TimeGroup) + cte.rn - 1) * @_TimeGroup
	) AS t
	WHERE	cte.rn <= CEILING((@_To - @_From) * 1.0 / @_TimeGroup) + 1;

	-- Get data --
	IF	@Type IN (N'IT', N'IncomingTicket', N'Incoming Ticket')
	BEGIN;
		SELECT	[time]		= t.TimeReport
			,	[value]		= ISNULL(tbl.TotalCount, 0)
			,	[metric]	= N'Incoming Ticket'
		FROM		@Times AS t
		LEFT JOIN	(
			SELECT	[TimeGroup]		= _t.TimeGroup
				,	[TotalCount]	= SUM(_tbl.TicketCount)
			FROM		plo.IncomingTicketRate AS _tbl WITH (NOLOCK)
			CROSS APPLY	(
				SELECT	[TimeGroup] = FLOOR(_tbl.SecondStamp / @_TimeGroup) * @_TimeGroup
			) AS _t
			WHERE	_tbl.BrandCode = @Brand
				AND	_tbl.SecondStamp >= @_From
				AND	_tbl.SecondStamp < @_To
			GROUP BY _t.TimeGroup
		) AS tbl
				ON	t.TimeTick = tbl.TimeGroup;
	END;

	IF	@Type IN (N'IP', N'IncomingPlayer', N'Incoming Player')
	BEGIN;
		SELECT	[time]		= t.TimeReport
			,	[value]		= ISNULL(tbl.TotalCount, 0)
			,	[metric]	= N'Incoming Player'
		FROM		@Times AS t
		LEFT JOIN	(
			SELECT	[TimeGroup]		= _t.TimeGroup
				,	[TotalCount]	= SUM(_tbl.PlayerCount)
			FROM		plo.IncomingPlayerRate AS _tbl WITH (NOLOCK)
			CROSS APPLY	(
				SELECT	[TimeGroup] = FLOOR(_tbl.SecondStamp / @_TimeGroup) * @_TimeGroup
			) AS _t
			WHERE	_tbl.BrandCode = @Brand
				AND	_tbl.SecondStamp >= @_From
				AND	_tbl.SecondStamp < @_To
			GROUP BY _t.TimeGroup
		) AS tbl
				ON	t.TimeTick = tbl.TimeGroup;
	END;

	IF	@Type IN (N'PT', N'APIPushingTicket', N'API Pushing Ticket')
	BEGIN;
		SELECT	[time]		= t.TimeReport
			,	[value]		= ISNULL(tbl.TotalCount, 0)
			,	[metric]	= N'API Pushing Ticket'
		FROM		@Times AS t
		LEFT JOIN	(
			SELECT	[TimeGroup]		= _t.TimeGroup
				,	[TotalCount]	= SUM(_tbl.TicketCount)
			FROM		plo.APIPushingTicketRate AS _tbl WITH (NOLOCK)
			CROSS APPLY	(
				SELECT	[TimeGroup] = FLOOR(_tbl.SecondStamp / @_TimeGroup) * @_TimeGroup
			) AS _t
			WHERE	_tbl.BrandCode = @Brand
				AND	_tbl.SecondStamp >= @_From
				AND	_tbl.SecondStamp < @_To
			GROUP BY _t.TimeGroup
		) AS tbl
				ON	t.TimeTick = tbl.TimeGroup;
	END;

	IF	@Type IN (N'PP', N'APIPushingPlayer', N'API Pushing Player')
	BEGIN;
		SELECT	[time]		= t.TimeReport
			,	[value]		= ISNULL(tbl.TotalCount, 0)
			,	[metric]	= N'API Pushing Player'
		FROM		@Times AS t
		LEFT JOIN	(
			SELECT	[TimeGroup]		= _t.TimeGroup
				,	[TotalCount]	= SUM(_tbl.PlayerCount)
			FROM		plo.APIPushingPlayerRate AS _tbl WITH (NOLOCK)
			CROSS APPLY	(
				SELECT	[TimeGroup] = FLOOR(_tbl.SecondStamp / @_TimeGroup) * @_TimeGroup
			) AS _t
			WHERE	_tbl.BrandCode = @Brand
				AND	_tbl.SecondStamp >= @_From
				AND	_tbl.SecondStamp < @_To
			GROUP BY _t.TimeGroup
		) AS tbl
				ON	t.TimeTick = tbl.TimeGroup;
	END;

	IF	@Type IN (N'DT', N'DeltaTicket', N'Delta Ticket')
	BEGIN;
		SELECT	[time]		= DATEADD(SECOND, @_TimeGroup / 2, t.TimeReport)
			,	[value]		= ISNULL(itbl.TotalCount, 0) - ISNULL(otbl.TotalCount, 0)
			,	[metric]	= N'Delta Ticket'
		FROM		@Times AS t
		LEFT JOIN	(
			SELECT	[TimeGroup]		= _t.TimeGroup
				,	[TotalCount]	= SUM(_tbl.TicketCount)
			FROM		plo.IncomingTicketRate AS _tbl WITH (NOLOCK)
			CROSS APPLY	(
				SELECT	[TimeGroup] = FLOOR(_tbl.SecondStamp / @_TimeGroup) * @_TimeGroup
			) AS _t
			WHERE	_tbl.BrandCode = @Brand
				AND	_tbl.SecondStamp >= @_From
				AND	_tbl.SecondStamp < @_To
			GROUP BY _t.TimeGroup
		) AS itbl
				ON	t.TimeTick = itbl.TimeGroup
		LEFT JOIN	(
			SELECT	[TimeGroup]		= _t.TimeGroup
				,	[TotalCount]	= SUM(_tbl.TicketCount)
			FROM		plo.APIPushingTicketRate AS _tbl WITH (NOLOCK)
			CROSS APPLY	(
				SELECT	[TimeGroup] = FLOOR(_tbl.SecondStamp / @_TimeGroup) * @_TimeGroup
			) AS _t
			WHERE	_tbl.BrandCode = @Brand
				AND	_tbl.SecondStamp >= @_From
				AND	_tbl.SecondStamp < @_To
			GROUP BY _t.TimeGroup
		) AS otbl
				ON	t.TimeTick = otbl.TimeGroup;
	END;

	IF	@Type IN (N'DP', N'DeltaPlayer', N'Delta Player')
	BEGIN;
		SELECT	[time]		= DATEADD(SECOND, @_TimeGroup / 2, t.TimeReport)
			,	[value]		= ISNULL(itbl.TotalCount, 0) - ISNULL(otbl.TotalCount, 0)
			,	[metric]	= N'Delta Player'
		FROM		@Times AS t
		LEFT JOIN	(
			SELECT	[TimeGroup]		= _t.TimeGroup
				,	[TotalCount]	= SUM(_tbl.PlayerCount)
			FROM		plo.IncomingPlayerRate AS _tbl WITH (NOLOCK)
			CROSS APPLY	(
				SELECT	[TimeGroup] = FLOOR(_tbl.SecondStamp / @_TimeGroup) * @_TimeGroup
			) AS _t
			WHERE	_tbl.BrandCode = @Brand
				AND	_tbl.SecondStamp >= @_From
				AND	_tbl.SecondStamp < @_To
			GROUP BY _t.TimeGroup
		) AS itbl
				ON	t.TimeTick = itbl.TimeGroup
		LEFT JOIN	(
			SELECT	[TimeGroup]		= _t.TimeGroup
				,	[TotalCount]	= SUM(_tbl.PlayerCount)
			FROM		plo.APIPushingPlayerRate AS _tbl WITH (NOLOCK)
			CROSS APPLY	(
				SELECT	[TimeGroup] = FLOOR(_tbl.SecondStamp / @_TimeGroup) * @_TimeGroup
			) AS _t
			WHERE	_tbl.BrandCode = @Brand
				AND	_tbl.SecondStamp >= @_From
				AND	_tbl.SecondStamp < @_To
			GROUP BY _t.TimeGroup
		) AS otbl
				ON	t.TimeTick = otbl.TimeGroup;
	END;
END;
GO
/*<info serverAlias="DBSTARIX-StarixDB" executers="vnGrafana" viewers="" isFunction="0" isNested="0"></info>*/