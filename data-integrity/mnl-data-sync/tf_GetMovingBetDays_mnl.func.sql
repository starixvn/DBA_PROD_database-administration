SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE FUNCTION	dbo.tf_GetMovingBetDays_mnl (
					@CheckDay	DATETIME	= NULL
				)
RETURNS TABLE
AS
RETURN (
	WITH Schedule AS (
		SELECT	ScheduleId, WeekDay, DayDiff
		FROM	(
			VALUES	(1, 2, -4)
				,	(2, 2, -3)
				,	(3, 3, -3)
				,	(4, 4, -3)
				,	(5, 6, -4)
				,	(6, 6, -3)
				,	(7, 7, -3)
		) AS tbl (ScheduleId, WeekDay, DayDiff)
	)
	SELECT	[MovingDay]	= CONVERT(SMALLDATETIME, DATEADD(DAY, s.DayDiff, CONVERT(DATE, ISNULL(@CheckDay, GETDATE()))))
	FROM	Schedule AS s
	WHERE	s.WeekDay = DATEPART(WEEKDAY, ISNULL(@CheckDay, GETDATE()))
);
GO