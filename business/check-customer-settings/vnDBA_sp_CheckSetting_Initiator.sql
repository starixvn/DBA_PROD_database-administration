USE	CheckResultDB;
GO
SET ANSI_NULLS ON;
SET	QUOTED_IDENTIFIER ON;
GO
ALTER PROCEDURE	dbo.vnDBA_sp_CheckSetting_Initiator
AS
/*
	Creator:	20180718@Billy
	Task:		Initiate Check Settings - [Redmine: #00000]
	Database:	DBDWCSS.CheckResultDB
	
	Revisions:
		- 20180718@Billy:	Initial - [Redmine: #00000]
		- 20180816@Billy:	Integrate Bet Limit & Stake Level checking - [Redmine: #99249]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;
	
	DECLARE	@Message			NVARCHAR(MAX)
		,	@dialog				UNIQUEIDENTIFIER
		,	@threads			SMALLINT
		,	@key				NVARCHAR(128)
		;

	-- Initiate service variable --
	SELECT	@key	= N'CheckSettingThreadCount';
	IF	NOT EXISTS (SELECT 1 FROM dbo.vnDBA_Service_Variables WITH (NOLOCK) WHERE VarKey = @key)
	BEGIN;
		INSERT INTO	dbo.vnDBA_Service_Variables (VarKey, VarValue)
		VALUES	(@key, 0);
	END;
	ELSE IF	NOT EXISTS (SELECT 1 FROM dbo.vnDBA_Service_Variables WITH (NOLOCK) WHERE VarKey = @key AND CAST(VarValue AS SMALLINT) = 0)
	BEGIN;
		RAISERROR('Check setting are already run or was interrupted!', 16, 1) WITH NOWAIT;
		RETURN;
	END;

	-- Check PT Sportbook Credit -- 6 threads --
	BEGIN;
		SELECT	@threads	= 6;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

DECLARE @CustId INT;

WHILE 0 = 0
BEGIN
	SELECT @CustId = NULL;
	UPDATE TOP(1) dbo.Credit_Supers
	SET @CustId = CustId
	, PTSportbook = 2
	WHERE PTSportbook = 0;

	IF @CustId IS NULL BREAK;

	EXECUTE dbo.DBA_CheckPT_Credit @srecommend = @CustId;

	UPDATE dbo.Credit_Supers
	SET PTSportbook = 1
	WHERE CustId = @CustId
	AND PTSportbook = 2;
END;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;

	-- Check PT 3rd Products Credit -- 3 threads --
	BEGIN;
		SELECT	@threads	= 3;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

DECLARE @CustId INT;

WHILE 0 = 0
BEGIN
	SELECT @CustId = NULL;
	UPDATE TOP(1) dbo.Credit_Supers
	SET @CustId = CustId
	, PT3rdProduct = 2
	WHERE PT3rdProduct = 0;

	IF @CustId IS NULL BREAK;

	EXECUTE dbo.DBA_CheckPT3rd_Credit @srecommend = @CustId;

	UPDATE dbo.Credit_Supers
	SET PT3rdProduct = 1
	WHERE CustId = @CustId
	AND PT3rdProduct = 2;
END;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;

	-- Check PT Game Credit -- 3 threads --
	BEGIN;
		SELECT	@threads	= 3;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

DECLARE @CustId INT;

WHILE 0 = 0
BEGIN
	SELECT @CustId = NULL;
	UPDATE TOP(1) dbo.Credit_Supers
	SET @CustId = CustId
	, PTGame = 2
	WHERE PTGame = 0;

	IF @CustId IS NULL BREAK;

	EXECUTE dbo.DBA_CheckPTGame_Credit @srecommend = @CustId;

	UPDATE dbo.Credit_Supers
	SET PTGame = 1
	WHERE CustId = @CustId
	AND PTGame = 2;
END;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;

	-- Check PT DCS Credit -- 3 threads --
	BEGIN;
		SELECT	@threads	= 3;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

DECLARE @CustId INT, @RoleId TINYINT;

WHILE 0 = 0
BEGIN
	SELECT @CustId = NULL;
	UPDATE TOP(1) dbo.Credit_DCS
	SET @CustId = CustId
	, @RoleId = RoleId
	, isFinished = 2
	WHERE isFinished = 0;

	IF @CustId IS NULL BREAK;

	EXECUTE dbo.DBA_CheckPT_DCS @CustId = @CustId, @RoleId = @RoleId;

	UPDATE dbo.Credit_DCS
	SET isFinished = 1
	WHERE CustId = @CustId
	AND RoleId = @RoleId
	AND isFinished = 2;
END;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;

	-- Check Status DCS Credit -- 1 threads --
	BEGIN;
		SELECT	@threads	= 1;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

EXECUTE DBA_CheckStatus_Credit_DCS;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;

	-- Check Status Non-DCS Credit -- 1 threads --
	BEGIN;
		SELECT	@threads	= 1;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

EXECUTE dbo.DBA_CheckStatus_Credit_NonDCS;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;

	-- Check Status DCS Deposit -- 1 threads --
	BEGIN;
		SELECT	@threads	= 1;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

EXECUTE DBA_CheckStatus_Deposit_DCS;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;

	-- Check Status Non-DCS Deposit -- 1 threads --
	BEGIN;
		SELECT	@threads	= 1;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

EXECUTE dbo.DBA_CheckStatus_Deposit_NonDCS;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;

	-- Check Commission Sportbooks Credit -- 3 threads --
	BEGIN;
		SELECT	@threads	= 3;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

DECLARE @CustId INT;

WHILE 0 = 0
BEGIN
	SELECT @CustId = NULL;
	UPDATE TOP(1) dbo.Credit_Supers
	SET @CustId = CustId
	, CommSportbook = 2
	WHERE CommSportbook = 0;

	IF @CustId IS NULL BREAK;

	EXECUTE dbo.DBA_CheckComm_Credit @srecommend = @CustId, @SportType = 0, @RuleId = 0;

	UPDATE dbo.Credit_Supers
	SET CommSportbook = 1
	WHERE CustId = @CustId
	AND CommSportbook = 2;
END;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;

	-- Check Commission 3rd Products Credit -- 3 threads --
	BEGIN;
		SELECT	@threads	= 3;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

DECLARE @CustId INT;

WHILE 0 = 0
BEGIN
	SELECT @CustId = NULL;
	UPDATE TOP(1) dbo.Credit_Supers
	SET @CustId = CustId
	, Comm3rdProduct = 2
	WHERE Comm3rdProduct = 0;

	IF @CustId IS NULL BREAK;

	EXECUTE dbo.DBA_CheckComm3rd_Credit @srecommend = @CustId, @SportType = 0, @RuleId = 0;

	UPDATE dbo.Credit_Supers
	SET Comm3rdProduct = 1
	WHERE CustId = @CustId
	AND Comm3rdProduct = 2;
END;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;

	-- Check Commission Game Credit -- 3 threads --
	BEGIN;
		SELECT	@threads	= 3;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

DECLARE @CustId INT;

WHILE 0 = 0
BEGIN
	SELECT @CustId = NULL;
	UPDATE TOP(1) dbo.Credit_Supers
	SET @CustId = CustId
	, CommGame = 2
	WHERE CommGame = 0;

	IF @CustId IS NULL BREAK;

	EXECUTE dbo.DBA_CheckCommGame_Credit @srecommend = @CustId, @SportType = 0, @RuleId = 0;

	UPDATE dbo.Credit_Supers
	SET CommGame = 1
	WHERE CustId = @CustId
	AND CommGame = 2;
END;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;

	-- Check Commission DCS Credit -- 3 threads --
	BEGIN;
		SELECT	@threads	= 3;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

DECLARE @CustId INT;

WHILE 0 = 0
BEGIN
	SELECT @CustId = NULL;
	UPDATE TOP(1) dbo.Credit_Supers
	SET @CustId = CustId
	, CommDCS = 2
	WHERE CommDCS = 0;

	IF @CustId IS NULL BREAK;

	EXECUTE dbo.DBA_CheckComm_DCS @srecommend = @CustId, @SportType = 0, @RuleId = 0;

	UPDATE dbo.Credit_Supers
	SET CommDCS = 1
	WHERE CustId = @CustId
	AND CommDCS = 2;
END;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;

	-- Check Commission Sportbooks Deposit -- 0 threads --
	BEGIN;
		SELECT	@threads	= 0;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

DECLARE @CustId INT;

WHILE 0 = 0
BEGIN
	SELECT @CustId = NULL;
	UPDATE TOP(1) dbo.Deposit_Supers
	SET @CustId = CustId
	, CommSportbook = 2
	WHERE CommSportbook = 0;

	IF @CustId IS NULL BREAK;

	EXECUTE dbo.DBA_CheckComm_Deposit @srecommend = @CustId, @SportType = 0, @RuleId = 0;

	UPDATE dbo.Deposit_Supers
	SET CommSportbook = 1
	WHERE CustId = @CustId
	AND CommSportbook = 2;
END;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;

	-- Check Commission 3rd Products Deposit -- 0 threads --
	BEGIN;
		SELECT	@threads	= 0;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

DECLARE @CustId INT;

WHILE 0 = 0
BEGIN
	SELECT @CustId = NULL;
	UPDATE TOP(1) dbo.Deposit_Supers
	SET @CustId = CustId
	, Comm3rdProduct = 2
	WHERE Comm3rdProduct = 0;

	IF @CustId IS NULL BREAK;

	EXECUTE dbo.DBA_CheckComm3rd_Deposit @srecommend = @CustId, @SportType = 0, @RuleId = 0;

	UPDATE dbo.Deposit_Supers
	SET Comm3rdProduct = 1
	WHERE CustId = @CustId
	AND Comm3rdProduct = 2;
END;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;

	-- Check Commission Game Deposit -- 0 threads --
	BEGIN;
		SELECT	@threads	= 0;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

DECLARE @CustId INT;

WHILE 0 = 0
BEGIN
	SELECT @CustId = NULL;
	UPDATE TOP(1) dbo.Deposit_Supers
	SET @CustId = CustId
	, CommGame = 2
	WHERE CommGame = 0;

	IF @CustId IS NULL BREAK;

	EXECUTE dbo.DBA_CheckCommGame_Deposit @srecommend = @CustId, @SportType = 0, @RuleId = 0;

	UPDATE dbo.Deposit_Supers
	SET CommGame = 1
	WHERE CustId = @CustId
	AND CommGame = 2;
END;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;

	-- Check Bet Limit Credit -- 3 threads --
	BEGIN;
		SELECT	@threads	= 3;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

DECLARE @CustId INT;

WHILE 0 = 0
BEGIN
	SELECT @CustId = NULL;
	UPDATE TOP(1) dbo.Credit_Supers
	SET @CustId = CustId
	, BetLimit = 2
	WHERE BetLimit = 0;

	IF @CustId IS NULL BREAK;

	EXECUTE dbo.DBA_CheckBetLimit_Credit @srecommend = @CustId, @SportType = 0, @RuleId = 0;

	UPDATE dbo.Credit_Supers
	SET BetLimit = 1
	WHERE CustId = @CustId
	AND BetLimit = 2;
END;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;

	-- Check Bet Limit 3rd Products Credit -- 3 threads --
	BEGIN;
		SELECT	@threads	= 3;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

DECLARE @CustId INT;

WHILE 0 = 0
BEGIN
	SELECT @CustId = NULL;
	UPDATE TOP(1) dbo.Credit_Supers
	SET @CustId = CustId
	, BetLimit3rdProduct = 2
	WHERE BetLimit3rdProduct = 0;

	IF @CustId IS NULL BREAK;

	EXECUTE dbo.DBA_CheckBetLimit3rd_Credit @srecommend = @CustId, @SportType = 0, @RuleId = 0;

	UPDATE dbo.Credit_Supers
	SET BetLimit3rdProduct = 1
	WHERE CustId = @CustId
	AND BetLimit3rdProduct = 2;
END;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;

	-- Check Bet Limit Keno Credit -- 3 threads --
	BEGIN;
		SELECT	@threads	= 3;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

DECLARE @CustId INT;

WHILE 0 = 0
BEGIN
	SELECT @CustId = NULL;
	UPDATE TOP(1) dbo.Credit_Supers
	SET @CustId = CustId
	, BetLimitKeno = 2
	WHERE BetLimitKeno = 0;

	IF @CustId IS NULL BREAK;

	EXECUTE dbo.DBA_CheckKenoBetLimit_Credit @srecommend = @CustId, @RuleId = 0;

	UPDATE dbo.Credit_Supers
	SET BetLimitKeno = 1
	WHERE CustId = @CustId
	AND BetLimitKeno = 2;
END;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;

	-- Check Bet Limit DCS Credit -- 3 threads --
	BEGIN;
		SELECT	@threads	= 3;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

DECLARE @CustId INT;

WHILE 0 = 0
BEGIN
	SELECT @CustId = NULL;
	UPDATE TOP(1) dbo.Credit_Supers
	SET @CustId = CustId
	, BetLimitDCS = 2
	WHERE BetLimitDCS = 0;

	IF @CustId IS NULL BREAK;

	EXECUTE dbo.DBA_CheckBetLimit_Credit_DCS @srecommend = @CustId, @SportType = 0, @RuleId = 0;

	UPDATE dbo.Credit_Supers
	SET BetLimitDCS = 1
	WHERE CustId = @CustId
	AND BetLimitDCS = 2;
END;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;

	-- Check Stake Level Credit -- 3 threads --
	BEGIN;
		SELECT	@threads	= 3;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

DECLARE @CustId INT;

WHILE 0 = 0
BEGIN
	SELECT @CustId = NULL;
	UPDATE TOP(1) dbo.Credit_Supers
	SET @CustId = CustId
	, StakeLevel = 2
	WHERE StakeLevel = 0;

	IF @CustId IS NULL BREAK;

	EXECUTE dbo.DBA_CheckStakeLevel_Credit @srecommend = @CustId, @SportType = 0, @RuleId = 0;

	UPDATE dbo.Credit_Supers
	SET StakeLevel = 1
	WHERE CustId = @CustId
	AND StakeLevel = 2;
END;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;

	-- Check Stake Level DCS Credit -- 3 threads --
	BEGIN;
		SELECT	@threads	= 3;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

DECLARE @CustId INT;

WHILE 0 = 0
BEGIN
	SELECT @CustId = NULL;
	UPDATE TOP(1) dbo.Credit_Supers
	SET @CustId = CustId
	, StakeLevelDCS = 2
	WHERE StakeLevelDCS = 0;

	IF @CustId IS NULL BREAK;

	EXECUTE dbo.DBA_CheckDCSStakeLevel_Credit @srecommend = @CustId, @SportType = 0, @RuleId = 0;

	UPDATE dbo.Credit_Supers
	SET StakeLevelDCS = 1
	WHERE CustId = @CustId
	AND StakeLevelDCS = 2;
END;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;

	-- Check Stake Level Credit -- 3 threads --
	BEGIN;
		SELECT	@threads	= 3;
		UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
		SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) + @threads
		WHERE	VarKey = @key;

		SELECT	@Message	= N'';
		SELECT	@Message	= @Message + N'
SET NOCOUNT ON;

DECLARE @CustId INT;

WHILE 0 = 0
BEGIN
	SELECT @CustId = NULL;
	UPDATE TOP(1) dbo.Deposit_Supers
	SET @CustId = CustId
	, StakeLevelDCS = 2
	WHERE StakeLevelDCS = 0;

	IF @CustId IS NULL BREAK;

	EXECUTE dbo.DBA_CheckDCSStakeLevel_Deposit @srecommend = @CustId, @SportType = 0, @RuleId = 0;

	UPDATE dbo.Deposit_Supers
	SET StakeLevelDCS = 1
	WHERE CustId = @CustId
	AND StakeLevelDCS = 2;
END;

UPDATE	dbo.vnDBA_Service_Variables WITH (ROWLOCK)
SET		VarValue	= ISNULL(CAST(VarValue AS SMALLINT), 0) - 1
WHERE	VarKey = N''' + @key + N''';
';
		
		WHILE	@threads > 0
		BEGIN;
			BEGIN DIALOG CONVERSATION	@dialog
			FROM SERVICE	CheckSettingInitiator
			TO SERVICE		'CheckSettingTarget'
			ON CONTRACT		CheckSettingContract
			WITH	ENCRYPTION	= OFF
				,	LIFETIME	= 172800
				;

			SEND ON CONVERSATION @dialog MESSAGE TYPE CheckSettingMessage (@Message);

			END CONVERSATION @dialog;

			SELECT	@threads = @threads - 1;
		END;
	END;
END;
GO
/*<info serverAlias="DBCHECK-CheckResultDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/