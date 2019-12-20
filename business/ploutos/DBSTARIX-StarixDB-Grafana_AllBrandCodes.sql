SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	plo.Grafana_AllBrandCodes
AS
/*
	Creator:	20191220@Billy
	Task:		Get all available brand codes - [Redmine: #125807]
	Database:	DBSTARIX.StarixDB

	Revisions:
		- 20191220@Billy:	Initial - [Redmine: #125807]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	DECLARE	@Brands AS TABLE (
				BrandCode		VARCHAR(20)
					PRIMARY KEY CLUSTERED
			);

	-- Get all available brand code from Incoming Ticket --
	WITH cte AS (
		SELECT	TOP(1)
				it.BrandCode
		FROM	plo.IncomingTicketRate AS it WITH (NOLOCK)
		ORDER BY it.BrandCode ASC
		UNION ALL
		SELECT	it.BrandCode
		FROM	cte
		CROSS APPLY	(
			SELECT	_it.BrandCode, [rn] = ROW_NUMBER() OVER (ORDER BY _it.BrandCode ASC)
			FROM	plo.IncomingTicketRate AS _it WITH (NOLOCK)
			WHERE	_it.BrandCode > cte.BrandCode
		) AS it
		WHERE	it.rn = 1
	)
	MERGE INTO	@Brands AS b
	USING		cte
			ON	cte.BrandCode = b.BrandCode
	WHEN NOT MATCHED BY TARGET
		THEN INSERT (BrandCode) VALUES (cte.BrandCode)
	OPTION (MAXRECURSION 0);

	-- Get all available brand code from Incoming Player --
	WITH cte AS (
		SELECT	TOP(1)
				it.BrandCode
		FROM	plo.IncomingPlayerRate AS it WITH (NOLOCK)
		ORDER BY it.BrandCode ASC
		UNION ALL
		SELECT	it.BrandCode
		FROM	cte
		CROSS APPLY	(
			SELECT	_it.BrandCode, [rn] = ROW_NUMBER() OVER (ORDER BY _it.BrandCode ASC)
			FROM	plo.IncomingPlayerRate AS _it WITH (NOLOCK)
			WHERE	_it.BrandCode > cte.BrandCode
		) AS it
		WHERE	it.rn = 1
	)
	MERGE INTO	@Brands AS b
	USING		cte
			ON	cte.BrandCode = b.BrandCode
	WHEN NOT MATCHED BY TARGET
		THEN INSERT (BrandCode) VALUES (cte.BrandCode)
	OPTION (MAXRECURSION 0);

	SELECT	BrandCode
	FROM	@Brands AS b
	ORDER BY b.BrandCode ASC;
END;
GO
/*<info serverAlias="DBSTARIX-StarixDB" executers="vnGrafana" viewers="" isFunction="0" isNested="0"></info>*/