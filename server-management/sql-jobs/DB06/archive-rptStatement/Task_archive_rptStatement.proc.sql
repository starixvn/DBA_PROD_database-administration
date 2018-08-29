SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
ALTER PROCEDURE	dbo.Task_archive_rptStatement
AS
/*
	Creator:	20180829@Billy
	Task:		Move job content to SP - [Redmine: #99955]
	Database:	DBRPT.bodb_Report
	
	Revisions:
		- 20180829@Billy:	Initial - [Redmine: #99955]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@InputDate	DATETIME;
	DECLARE	@TempDate	DATETIME;
	DECLARE	@Count		INT;
	DECLARE	@DateName	VARCHAR(10);

	DECLARE	@MBUDay		AS TABLE (BalanceUpDay SMALLDATETIME, MoveBetsDay SMALLDATETIME);
	DECLARE	@VerifyData	AS TABLE (CustId INT, WinlostDate DATE);

	IF	@InputDate IS NULL
	BEGIN;
		INSERT INTO @MBUDay(BalanceUpDay, MoveBetsDay)
		EXECUTE	bodb02.dbo.Age_SelBalanceUpDay;

		SELECT	@InputDate = BalanceUpDay
		FROM	@MBUDay;
	END;

	WITH tally AS (
		SELECT	[rn] = ROW_NUMBER() OVER(ORDER BY (SELECT NULL))
		FROM	(VALUES (1), (2), (3), (4), (5), (6), (7)) AS a(x)
	)
	INSERT INTO	@VerifyData (CustId, WinlostDate)
	SELECT	vd.CustId, vd.WinlostDate
	FROM	tally AS tmp
	CROSS APPLY	(
		SELECT	TOP(1)
				_rst.CustId, _rst.WinlostDate
		FROM	dbo.rptStatement AS _rst WITH (NOLOCK)
		WHERE	_rst.WinlostDate = DATEADD(DAY, tmp.rn - 1, @InputDate)
	) AS vd;

	IF	EXISTS (
			SELECT	TOP(1) 1
			FROM		dbo.rptStatement_Old AS rso WITH (NOLOCK)
			INNER JOIN	@VerifyData AS vd
					ON	rso.CustId = vd.CustId
					AND	rso.WinlostDate = vd.WinlostDate
		)
		RAISERROR('BalanceUp is not run yet!!!!!', 16, 1) WITH NOWAIT;

	SELECT	@DateName = DATENAME(WEEKDAY, CONVERT(DATE, DATEADD(WEEK, -1, GETDATE())));

	IF	@DateName = 'Thursday'
	BEGIN;
		SELECT	@count = -7;
		WHILE	@count < 0
		BEGIN;
			SELECT	@TempDate = DATEADD(DAY, @Count, @InputDate);
			EXECUTE	dbo.Task_archive_rptStatement_Insert @TempDate;
			SELECT	@count = @count + 1;
		END;
	END;
	ELSE IF	@DateName = 'Friday'
	BEGIN
		SELECT	@count = -7;
		WHILE	@count < 0
		BEGIN;
			SELECT	@TempDate = DATEADD(DAY, @Count, @InputDate);
			EXECUTE	dbo.Task_archive_rptStatement_Delete @TempDate;
			SELECT	@count = @count + 1;
		END;
	END
	ELSE
		RAISERROR ('Invalid BalanceUp Date!!!!!', 16, 1) WITH NOWAIT;
END;
GO
/*<info serverAlias="DBRPT-bodb_Report" executers="" viewers="" isFunction="0" isNested="0"></info>*/