SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE FUNCTION	dbo.tf_GetMBUDay_mnl ()
RETURNS TABLE
AS
RETURN (
	SELECT	bu.BalanceUpDay, mb.MoveBetsDay
	FROM		(
		SELECT	TOP(1)
				[BalanceUpDay]	= CONVERT(SMALLDATETIME, winlostdate)
		FROM	dbo.bettrans WITH (NOLOCK)
		WHERE	matchid = 0
			AND	custid = 3
			AND	bettype = 20000
	) AS bu
	CROSS APPLY	(
		SELECT	TOP(1)
				[MoveBetsDay]	= CONVERT(SMALLDATETIME, eventdate)
		FROM	dbo.match14 WITH (NOLOCK)
		ORDER BY eventdate DESC
	) AS mb
);
GO