USE StarixDB;
GO
ALTER PROCEDURE	dbo.vnDBA_sp_Grafana_GetAnnotations
						@annotationtype		INT
AS
BEGIN;
	SELECT	[time]		= DATEADD(HOUR, 4, d.CounterTime)
		,	[title]		= 'Warning'
		,	[text]		= CAST(d.CounterValue AS VARCHAR) + ' - ' + c.MachineName
		,	[tags]		= 'CPU'
	FROM		dbo.CounterDetails AS c WITH (NOLOCK)
	CROSS APPLY	(
		SELECT	TOP(1)
				_d.CounterValue
			,	_d.CounterTime
		FROM	dbo.vnDBA_Perf_CounterData AS _d WITH (NOLOCK)
		WHERE	_d.CounterValue >= 20
			AND	_d.CounterId = c.CounterId
		ORDER BY _d.CounterTime DESC
		) AS d
	WHERE	c.CounterName = '% Processor Time'
		AND	c.ObjectName = 'Processor'
	ORDER BY d.CounterTime DESC;
END;
GO

GRANT EXECUTE ON dbo.vnDBA_sp_Grafana_GetAnnotations TO vnGrafana AS dbo;
GO