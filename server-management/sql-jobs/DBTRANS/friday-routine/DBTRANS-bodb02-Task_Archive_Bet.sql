USE	bodb02;
GO
ALTER PROCEDURE [dbo].[Task_Archive_Bet]
(
	@winlostdate DATETIME,
	@DeletedTarget VARCHAR(100) = ''
)
AS
/*
	Created: 20171017@Lukas
	Task: delete data on table14 

	Revisions:
		- 20180725@Billy:	Change the way of deleting data of IP2Country tables - [Redmine: #98857]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE	@WaitFor		NVARCHAR(MAX);

	IF @DeletedTarget = 'betParlayDetail'
	BEGIN
		
		SELECT IDENTITY(INT,1,1) id, refno, count(1) AS cnt, 5000/count(1) AS batch_size
		INTO #tmp
		FROM betparlaydetail WITH(NOLOCK)
		WHERE winlostdate <= DATEADD(DAY, - 14, @winlostdate)
		GROUP BY refno 
		ORDER BY cnt DESC 

		CREATE CLUSTERED INDEX CIX_id_TMP ON #tmp(id)
		
		DECLARE @rc INT,@i INT, @topn INT,@refnos VARCHAR(MAX) = ''

		SELECT @rc = MAX(id) FROM #tmp  

		SET @i = 1
		WHILE @i <= @rc 
		BEGIN	
			SELECT @topn = batch_size
			FROM #tmp
			WHERE id = @i 

			IF @topn = 0 OR @topn IS NULL
				SET @topn = 1

			SET @refnos = NULL
			SELECT TOP(@topn) @refnos = COALESCE(@refnos + '^' + CAST(refno AS VARCHAR(50)), CAST(refno AS VARCHAR(50)))
			FROM #tmp
			WHERE id >= @i 
			ORDER BY id ASC 

			EXEC dbo.ExecRep_09 @recommend = 0, @winlostdate = @winlostdate, @parlay = 29, @tableName = 'betParlayDetail', @refnos = @refnos
			SET @i = @i + @topn
		END 
		DROP TABLE #tmp 
		RETURN
	END 
	IF @DeletedTarget = 'betParlayResult'
	BEGIN
		-- call execRep SP
		EXEC dbo.ExecRep_09 @recommend = 0, @winlostdate = @winlostdate, @parlay = 29, @tableName = 'betParlayResult'
	END
	
	-- Dynamic Delay Time --
	SELECT	@WaitFor = N'';
	SELECT	@WaitFor = @WaitFor + N'WAITFOR DELAY ''' + dbo.f_BU_GetDelayTime('IP2Country') + N''';';

	IF	@DeletedTarget = 'Task_bettrans14_IP2Country'
	BEGIN;
		WHILE 0 = 0
		BEGIN;
			DELETE	TOP(10000)
			FROM	dbo.Task_bettrans14_IP2Country WITH (ROWLOCK) 
			WHERE	winlostdate <= @winlostdate;

			IF	@@ROWCOUNT = 0
				BREAK;
			
			EXECUTE	sys.sp_executesql @Query = @WaitFor;
		END;

		RETURN;
	END;

	IF	@DeletedTarget = 'Task_bettransRNG14_IP2Country'
	BEGIN;
		WHILE 0 = 0
		BEGIN;
			DELETE	TOP(10000)
			FROM	dbo.Task_bettransRNG14_IP2Country WITH (ROWLOCK) 
			WHERE	winlostdate <= @winlostdate;

			IF	@@ROWCOUNT = 0
				BREAK;
			
			EXECUTE	sys.sp_executesql @Query = @WaitFor;
		END;

		RETURN;
	END;

	IF	@DeletedTarget = 'Task_bettransLC14_IP2Country'
	BEGIN;
		WHILE 0 = 0
		BEGIN;
			DELETE	TOP(10000)
			FROM	dbo.Task_bettransLC14_IP2Country WITH (ROWLOCK) 
			WHERE	winlostdate <= @winlostdate;

			IF	@@ROWCOUNT = 0
				BREAK;
			
			EXECUTE	sys.sp_executesql @Query = @WaitFor;
		END;

		RETURN;
	END;
END
GO
/*<info serverAlias="DBTXN-bodb02" executers="" viewers="" isFunction="0" isNested="0"></info>*/