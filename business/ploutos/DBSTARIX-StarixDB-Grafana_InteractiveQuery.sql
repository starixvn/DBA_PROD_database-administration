SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	plo.Grafana_InteractiveQuery
						@Type				NVARCHAR(128)
					,	@Brand				VARCHAR(20)
AS
/*
	Creator:	20191220@Billy
	Task:		Ploutos interactive query - [Redmine: #125807]
	Database:	DBSTARIX.StarixDB

	Revisions:
		- 20191220@Billy:	Initial - [Redmine: #125807]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	-- Constants --
	DECLARE	@BaseTime		DATETIME		= '2019-01-01'
		;

	-- Dynamic query variables --
	DECLARE	@Query			NVARCHAR(MAX)
		,	@Param			NVARCHAR(MAX)
		,	@ExecuteSP		NVARCHAR(256)
		;

	-- Parameter variables --
	DECLARE	@Value			INT
		;

	-- Variables --
	DECLARE	@FromStamp		INT
		,	@ToStamp		INT
		;

	-- Determine execute location
	SELECT	@ExecuteSP = N'KBTDBPLO.bodb_Ploutos.sys.sp_executesql';

	IF	@Type = N'Pending Tickets'
	BEGIN;
		SELECT	@Query = N'';
		SELECT	@Query += N'\
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT	@Value = COUNT(1)
FROM	dbo.BetTicket WITH (NOLOCK)
WHERE	BrandCode = @Brand
	AND	StatusId <> 1;
';

		SELECT	@Param = N'';
		SELECT	@Param += N'@Value INT OUTPUT, @Brand VARCHAR(20)';

		EXECUTE	@ExecuteSP @Query, @Param, @Value OUTPUT, @Brand;

		SELECT	[value] = @Value;
	END;

	IF	@Type = N'Pending Players'
	BEGIN;
		SELECT	@Query = N'';
		SELECT	@Query += N'\
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT	@Value = COUNT(1)
FROM	dbo.PlayerProfile WITH (NOLOCK)
WHERE	BrandCode = @Brand
	AND	StatusId <> 1;
';

		SELECT	@Param = N'';
		SELECT	@Param += N'@Value INT OUTPUT, @Brand VARCHAR(20)';

		EXECUTE	@ExecuteSP @Query, @Param, @Value OUTPUT, @Brand;

		SELECT	[value] = @Value;
	END;

	IF	@Type = N'Estimate Tickets Release Time'
	BEGIN;
		SELECT	@Query = N'';
		SELECT	@Query += N'\
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT	@Value = COUNT(1)
FROM	dbo.BetTicket WITH (NOLOCK)
WHERE	BrandCode = @Brand
	AND	StatusId <> 1;
';

		SELECT	@Param = N'';
		SELECT	@Param += N'@Value INT OUTPUT, @Brand VARCHAR(20)';

		EXECUTE	@ExecuteSP @Query, @Param, @Value OUTPUT, @Brand;

		SELECT	@FromStamp	= DATEDIFF(SECOND, @BaseTime, CAST(GETDATE() AS DATE)) - 7 * 24 * 3600
			,	@ToStamp	= DATEDIFF(SECOND, @BaseTime, CAST(GETDATE() AS DATE))
			;

		SELECT	[value] = @Value / (_delta.releaseRate * 1.0 / (@ToStamp - @FromStamp))
		FROM	(
			SELECT	[inTicket] = SUM(it.TicketCount)
			FROM	plo.IncomingTicketRate AS it WITH (NOLOCK)
			WHERE	it.SecondStamp >= @FromStamp
				AND	it.SecondStamp < @ToStamp
		) AS _in
		CROSS APPLY	(
			SELECT	[releaseRate] = _in.inTicket - SUM(ot.TicketCount)
			FROM	plo.APIPushingTicketRate AS ot WITH (NOLOCK)
			WHERE	ot.SecondStamp >= @FromStamp
				AND	ot.SecondStamp < @ToStamp
		) AS _delta;
	END;

	IF	@Type = N'Estimate Players Release Time'
	BEGIN;
		SELECT	@Query = N'';
		SELECT	@Query += N'\
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

SELECT	@Value = COUNT(1)
FROM	dbo.PlayerProfile WITH (NOLOCK)
WHERE	BrandCode = @Brand
	AND	StatusId <> 1;
';

		SELECT	@Param = N'';
		SELECT	@Param += N'@Value INT OUTPUT, @Brand VARCHAR(20)';

		EXECUTE	@ExecuteSP @Query, @Param, @Value OUTPUT, @Brand;

		SELECT	@FromStamp	= DATEDIFF(SECOND, @BaseTime, CAST(GETDATE() AS DATE)) - 7 * 24 * 3600
			,	@ToStamp	= DATEDIFF(SECOND, @BaseTime, CAST(GETDATE() AS DATE))
			;

		SELECT	[value] = @Value / (_delta.releaseRate * 1.0 / (@ToStamp - @FromStamp))
		FROM	(
			SELECT	[inTicket] = SUM(it.PlayerCount)
			FROM	plo.IncomingPlayerRate AS it WITH (NOLOCK)
			WHERE	it.SecondStamp >= @FromStamp
				AND	it.SecondStamp < @ToStamp
		) AS _in
		CROSS APPLY	(
			SELECT	[releaseRate] = _in.inTicket - SUM(ot.PlayerCount)
			FROM	plo.APIPushingPlayerRate AS ot WITH (NOLOCK)
			WHERE	ot.SecondStamp >= @FromStamp
				AND	ot.SecondStamp < @ToStamp
		) AS _delta;
	END;
END;
GO
/*<info serverAlias="DBSTARIX-StarixDB" executers="vnGrafana" viewers="" isFunction="0" isNested="0"></info>*/