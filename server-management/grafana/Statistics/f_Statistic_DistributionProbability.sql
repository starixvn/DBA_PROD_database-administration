USE	StarixDB;
GO
ALTER FUNCTION	dbo.f_Statistic_DistributionProbability (
					@value			DECIMAL(38,10)
				,	@mean			DECIMAL(38,10)
				,	@variance		DECIMAL(38,10)
				)
RETURNS TABLE
AS
/*
	Creator:	20180615@Billy
	Task:		Calculate distribution probability - [Redmine: #96988]
	Database:	StarixDB
	
	Revisions:
		- 20180615@Billy:	Initial - [Redmine: #96988]
		
*/
RETURN (
	SELECT	[zscore]		= z.zscore
		,	[probdens]		= pd.probdens
	FROM	(
		SELECT	[zscore]		= (@value - @mean) / SQRT(@variance)
	) AS z
	CROSS APPLY	(
		SELECT	[probdens]		= EXP(- SQUARE(@value - @mean) / (2 * @variance)) / SQRT(2 * PI() * @variance)
	) AS pd
);
GO