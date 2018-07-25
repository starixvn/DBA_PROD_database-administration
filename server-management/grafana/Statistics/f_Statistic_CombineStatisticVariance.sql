USE	StarixDB;
GO
ALTER FUNCTION	dbo.f_Statistic_CombineStatisticVariance (
					@n1				BIGINT
				,	@mean1			DECIMAL(38,10)
				,	@variance1		DECIMAL(38,10)
				,	@n2				BIGINT
				,	@mean2			DECIMAL(38,10)
				,	@variance2		DECIMAL(38,10)
				)
RETURNS TABLE
AS
/*
	Creator:	20180615@Billy
	Task:		Calculate combined statistical values - [Redmine: #96988]
	Database:	StarixDB
	
	Revisions:
		- 20180615@Billy:	Initial - [Redmine: #96988]
		
*/
RETURN (
	SELECT	[n]				= n.n
		,	[mean]			= m.mean
		,	[variance]		= v.variance
		,	[stdeviation]	= sd.stdeviation
	FROM	(
		SELECT	[n]				= @n1 + @n2
	) AS n
	CROSS APPLY	(
		SELECT	[mean]			= (@mean1 * @n1 + @mean2 * @n2) / n.n
	) AS m
	CROSS APPLY	(
		SELECT	[variance]		= ( @n1 * @n1 * @variance1 + @n2 * @n2 * @variance2
								  - @n1 * @variance1 - @n1 * @variance2 - @n2 * @variance1 - @n2 * @variance2
								  + @n1 * @n2 * @variance1 + @n2 * @n1 * @variance2
								  + @n1 * @n2 * SQUARE(@mean1 - @mean2)
								  ) / ((n.n - 1) * n.n)
	) AS v
	CROSS APPLY	(
		SELECT	[stdeviation]	= SQRT(v.variance)
	) AS sd
);
GO