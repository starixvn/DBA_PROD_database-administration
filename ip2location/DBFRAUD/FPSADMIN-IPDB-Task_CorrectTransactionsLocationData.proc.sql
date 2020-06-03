SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.Task_CorrectTransactionsLocationData
						@ByPassSafetyCheck	BIT				= 0
AS
/*
	Creator:	20190712@Billy
	Task:		Update subscriber transactions' location data - [Redmine: #116536]
	Database:	FPSADMIN.IPDB

	Revisions:
		- 20190712@Billy:	Initial - [Redmine: #116536]
		- 20191001@Billy:	Add safety check to avoid correct data of last month - [Redmine: #000000]
		- 20200603@Patrick: Fix overflowed an int column when converion IP value [Redmine: #135318]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@Query		NVARCHAR(MAX)
		,	@Param		NVARCHAR(MAX)
		,	@Execute	NVARCHAR(MAX)
		,	@SubsQuery	NVARCHAR(MAX)
		,	@SubsParam	NVARCHAR(MAX)
		;

	DECLARE	@Month		DATE
		,	@Server		NVARCHAR(128)
		,	@Database	NVARCHAR(128)
		;

	DECLARE	@Message	NVARCHAR(MAX)
		;


	IF	@ByPassSafetyCheck = 0 AND DATEPART(DAY, GETDATE()) > 7
	BEGIN;
		SELECT	@Message = N'';
		SELECT	@Message += N'\
[Terminated] - FPS IPDB Correction Job is terminated due to safety check failed.
    Current time: ' + CONVERT(NVARCHAR(25), GETDATE(), 121) + N'
    Condition failed: (DATEPART(DAY) = ' + CAST(DATEPART(DAY, GETDATE()) AS NVARCHAR) + N' <= 7
';
		EXECUTE	DBNOTI.NotificationDB.dbo.Skype_SendMessage N'JOBFPS', @Message;

		RAISERROR('Safety check failed!', 16, 1) WITH NOWAIT;
		RETURN;
	END;


	IF	OBJECT_ID('tempdb..#Subscribers') IS NOT NULL
		DROP TABLE	#Subscribers;

	CREATE TABLE	#Subscribers (
						SubscriberId		INT				NOT NULL
					,	SubscriberName		NVARCHAR(50)	NOT NULL
					,	ServerName			NVARCHAR(128)	NOT NULL
					,	DBName				NVARCHAR(128)	NOT NULL	PRIMARY KEY CLUSTERED
					,	IsDone				BIT				NOT NULL
					);

	INSERT INTO	#Subscribers WITH (TABLOCK)
		(	    SubscriberId,     SubscriberName,    ServerName,    DBName, IsDone)
	SELECT	sub.SubscriberId, sub.SubscriberName, db.ServerName, db.DBName, 0
	FROM		FPS_ADMIN.dbo.Subscribers AS sub WITH (NOLOCK)
	INNER JOIN	FPS_ADMIN.dbo.SubDBServers AS db WITH (NOLOCK)
			ON	sub.SubscriberId = db.SubscriberId
	WHERE	sub.IsActive = 1
		AND	sub.IsTest = 0;

	SELECT	@SubsQuery = N'';
	SELECT	@SubsQuery = @SubsQuery + N'\
DECLARE	@IPs	VARCHAR(MAX)
	;

CREATE TABLE	#TransData (
					IPint			BIGINT
				,	IP				NVARCHAR(15)
				,	Country			NVARCHAR(64)
				,	CountryCode		NCHAR(10)
				,	Region			NVARCHAR(128)
				,	City			NVARCHAR(128)
				,	ISP				NVARCHAR(256)
				,	Cnt				INT
				);

CREATE TABLE	#IPDB (
					IPint			BIGINT			PRIMARY KEY CLUSTERED
				,	Country			NVARCHAR(64)
				,	CountryCode		NCHAR(10)
				,	Region			NVARCHAR(128)
				,	City			NVARCHAR(128)
				,	ISP				NVARCHAR(256)
				);

SELECT	@Month = DATEADD(MONTH, DATEDIFF(MONTH, 0, @Month), 0)
	;

INSERT INTO	#TransData (IPint, IP, Country, CountryCode, Region, City, ISP, Cnt)
SELECT	[IPint]			= CONVERT(BIGINT, CONVERT(BINARY(1), CONVERT(INT, PARSENAME(IP, 4))) + CONVERT(BINARY(1), CONVERT(INT, PARSENAME(IP, 3))) + CONVERT(BINARY(1), CONVERT(INT, PARSENAME(IP, 2))) + CONVERT(BINARY(1), CONVERT(INT, PARSENAME(IP, 1))))
	,	[IP]			= IP
	,	[Country]		= Country
	,	[CountryCode]	= CountryCode
	,	[Region]		= Region
	,	[City]			= City
	,	[ISP]			= ISP
	,	[Cnt]			= COUNT(1)
FROM	dbo.Transactions trn WITH (NOLOCK)
WHERE	TransDate >= CAST(@Month AS DATETIME)
	AND	TransDate < CAST(DATEADD(MONTH, 1, @Month) AS DATETIME)
	AND	IP NOT LIKE ''%[^.0-9]%''
	AND LEN(PARSENAME(trn.IP, 4)) <= 3 AND LEN(PARSENAME(trn.IP, 3)) <= 3 AND LEN(PARSENAME(trn.IP, 2)) <= 3 AND LEN(PARSENAME(trn.IP, 1)) <= 3
GROUP BY IP, Country, CountryCode, Region, City, ISP;

SELECT	@IPs = ips.xml.value(''.[1]'', ''VARCHAR(MAX)'')
FROM	(
	SELECT	CAST(IPint AS VARCHAR) + '',''
	FROM	#TransData
	FOR	XML PATH ('''')
	,	TYPE
) ips(xml);

INSERT INTO	#IPDB (IPint, Country, CountryCode, Region, City, ISP)
EXECUTE	FPSADMIN.IPDB.dbo.GetLocationByIPList @IPs;

UPDATE	trn WITH (ROWLOCK)
SET		Country			= ipv4.Country
	,	CountryCode		= ipv4.CountryCode
	,	Region			= ipv4.Region
	,	City			= ipv4.City
	,	ISP				= ipv4.ISP
FROM		dbo.Transactions AS trn
CROSS APPLY	(
	SELECT	[IPint]	= CONVERT(BIGINT, CONVERT(BINARY(1), CONVERT(INT, PARSENAME(IP, 4))) + CONVERT(BINARY(1), CONVERT(INT, PARSENAME(IP, 3))) + CONVERT(BINARY(1), CONVERT(INT, PARSENAME(IP, 2))) + CONVERT(BINARY(1), CONVERT(INT, PARSENAME(IP, 1))))
) AS ipt
INNER JOIN	#IPDB AS ipv4 WITH (NOLOCK)
		ON	ipv4.IPint = ipt.IPint
WHERE	trn.TransDate >= CAST(@Month AS DATETIME)
	AND	trn.TransDate < CAST(DATEADD(MONTH, 1, @Month) AS DATETIME)
	AND	trn.IP NOT LIKE ''%[^.0-9]%''
	AND LEN(PARSENAME(trn.IP, 4)) <= 3 AND LEN(PARSENAME(trn.IP, 3)) <= 3 AND LEN(PARSENAME(trn.IP, 2)) <= 3 AND LEN(PARSENAME(trn.IP, 1)) <= 3
	AND	(	trn.Country <> ipv4.Country
		OR	trn.CountryCode <> ipv4.CountryCode
		OR	trn.Region <> ipv4.Region
		OR	trn.City <> ipv4.City
		OR	trn.ISP <> ipv4.ISP
		);
';

	SELECT	@SubsParam = N'';
	SELECT	@SubsParam = @SubsParam + N'@Month DATE';

	SELECT	@Query = N'';
	SELECT	@Query = @Query + N'\
EXECUTE	[~~Server~~].[~~Database~~].sys.sp_executesql @Query, @Param, @Month;
	';

	SELECT	@Param = N'';
	SELECT	@Param = @Param + N'@Query NVARCHAR(MAX), @Param NVARCHAR(MAX), ' + @SubsParam;

	SELECT	@Month = CAST(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0) AS DATE);

	WHILE	0 = 0
	BEGIN;
		SELECT	TOP(1)
				@Server		= s.ServerName
			,	@Database	= s.DBName
		FROM	#Subscribers AS s WITH (NOLOCK)
		WHERE	s.IsDone = 0;

		IF	@@ROWCOUNT = 0
			BREAK;

		BEGIN TRY;
			SELECT	@Execute = REPLACE(REPLACE(@Query, N'~~Server~~', @Server), N'~~Database~~', @Database);
			EXECUTE	sys.sp_executesql @Execute, @Param, @SubsQuery, @SubsParam, @Month;
		END TRY
		BEGIN CATCH;
			SELECT	@Message = N'';
			SELECT	@Message = @Message + N'\
[Failed] ' + @Server + N'. ' + @Database + N': Update transactions'' location failed.
	(' + CAST(ERROR_NUMBER() AS NVARCHAR) + N') ' + ERROR_MESSAGE();
			EXECUTE	DBNOTI.NotificationDB.dbo.Skype_SendMessage N'JOBFPS', @Message;
		END CATCH;

		UPDATE	#Subscribers WITH (ROWLOCK)
		SET		IsDone = 1
		WHERE	ServerName = @Server
			AND	DBName = @Database;
	END;
END;
GO
/*<info serverAlias="FPSADMIN-IPDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/