/*
	Creator:	20200228@Billy
	Task:		Map SQL Logins with DB Users - [Redmine: #128261]
	Server:		SITDB055
*/

SET NOCOUNT ON;

--	BEGIN STEP 1:
--		Collect Mapping Info
----------------------------------------------------------------------------------------------------
RETURN; -- Prevent accidental execution

IF	OBJECT_ID('tempdb..#LoginUserMapping') IS NOT NULL
	DROP TABLE	#LoginUserMapping;

CREATE TABLE	#LoginUserMapping (
					LoginName			NVARCHAR(128)
				,	LoginSID			VARBINARY(85)
				,	LoginDisabled		BIT
				,	DatabaseName		NVARCHAR(128)
				,	DatabaseReadOnly	BIT
				,	UserName			NVARCHAR(128)
				,	UserSID				VARBINARY(85)
				);

EXECUTE	sys.sp_MSforeachdb	N'\
USE	?;

INSERT INTO	#LoginUserMapping
	(	LoginName, LoginSID, LoginDisabled , DatabaseName, DatabaseReadOnly, UserName, UserSID)
SELECT	sp.name  , sp.sid  , sp.is_disabled, DB_NAME()   , d.is_read_only  , dp.name , dp.sid
FROM		sys.server_principals AS sp WITH (NOLOCK)
RIGHT JOIN	sys.database_principals AS dp WITH (NOLOCK)
			ON	sp.name = dp.name
CROSS APPLY	(
	SELECT	_d.is_read_only
	FROM	sys.databases AS _d WITH (NOLOCK)
	WHERE	_d.name = DB_NAME()
) AS d
WHERE	dp.type = ''S'';
';

SELECT	*
FROM	#LoginUserMapping AS lum WITH (NOLOCK)
WHERE	ISNULL(LoginSID, 0x00) <> UserSID
ORDER BY	CASE	WHEN lum.LoginSID <> lum.UserSID	THEN 0
					WHEN lum.LoginSID IS NULL			THEN 1
														ELSE 2
			END;


--	BEGIN STEP 2:
--		Auto mapping
----------------------------------------------------------------------------------------------------

DECLARE	@SQL	NVARCHAR(2000)
	;

IF	OBJECT_ID('tempdb..#ToBeMapped') IS NOT NULL
	DROP TABLE	#ToBeMapped;

SELECT	DISTINCT
		[UserName]		= UserName
	,	[isDone]		= CAST(0 AS BIT)
INTO	#ToBeMapped
FROM	#LoginUserMapping AS lum WITH (NOLOCK)
WHERE	ISNULL(LoginSID, 0x00) <> UserSID;

WHILE	0 = 0
BEGIN;
	SELECT	@SQL = N'';

	UPDATE	TOP(1) tbm
	SET		@SQL	= @SQL + N'USE	?;
IF	(SELECT is_read_only FROM sys.databases WHERE name = ''?'') = 0
	IF	EXISTS (SELECT 1 FROM sys.database_principals WITH (NOLOCK) WHERE name = N''' + tbm.UserName + N''' AND DATALENGTH(sid) = 16)
		IF	EXISTS (SELECT 1 FROM sys.server_principals WITH (NOLOCK) WHERE name = N''' + tbm.UserName + N''')
		BEGIN;
			EXECUTE	sys.sp_change_users_login ''update_one'', [' + tbm.UserName + N'], [' + tbm.UserName + N'];
			RAISERROR(''~ DONE ~							' + tbm.UserName + N' - ?'', 0, 0) WITH NOWAIT;
		END;
		ELSE
		BEGIN;
			RAISERROR(''!!!! LOGIN DOES NOT EXISTS !!!!		' + tbm.UserName + N' - ?'', 0, 0) WITH NOWAIT;
		END;
	ELSE IF	EXISTS (SELECT 1 FROM sys.database_principals WITH (NOLOCK) WHERE name = N''' + tbm.UserName + N''')
		RAISERROR(''!!! USER IS NOT VALID !!!			' + tbm.UserName + N' - ?'', 0, 0) WITH NOWAIT;
	ELSE
		RAISERROR(''!! USER DOES NOT EXIST !!			' + tbm.UserName + N' - ?'', 0, 0) WITH NOWAIT;
ELSE
	RAISERROR(''! DATABASE IS READONLY !			' + tbm.UserName + N' - ?'', 0, 0) WITH NOWAIT;
'
		,	isDone	= 1
	FROM	#ToBeMapped AS tbm
	WHERE	isDone = 0;

	IF	@@ROWCOUNT = 0
		BREAK;

	EXECUTE	sys.sp_MSforeachdb @SQL;

	RAISERROR('', 0, 0) WITH NOWAIT;
END;
GO
/*<info serverAlias="SITDB055-master" executers="" viewers="" isFunction="0" isNested="0"></info>*/