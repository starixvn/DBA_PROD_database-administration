SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.GetLocationByIPList
						@IPs			VARCHAR(MAX)
AS
/*
	Creator:	20190709@Billy
	Task:		Get location info from a list of IP formatted as INT - [Redmine: #116536]
	Database:	FPSADMIN.IPDB

	Revisions:
		- 20190709@Billy:	Initial - [Redmine: #116536]

	Developer's Notes:
		- @IPs:		The list of IPs that are formatted as IPDB INT, separated by comma ","

*/
BEGIN;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	IF	@IPs LIKE '%[^, 0-9]%'
	BEGIN;
		RAISERROR(N'@IPs contains invalid character.', 16, 1) WITH NOWAIT;
		RETURN;
	END;

	DECLARE	@IPList AS TABLE (
				ip		BIGINT
			);

	INSERT INTO	@IPList (ip)
	SELECT	DISTINCT
			CAST(ips.val AS BIGINT)
	FROM	dbo.f_SplitString(@IPs, N',', DEFAULT) AS ips;

	SELECT	[IP]			= ips.ip
		,	[Country]		= ipv4.country_name
		,	[CountryCode]	= ipv4.country_code
		,	[Region]		= ipv4.region
		,	[City]			= ipv4.city
		,	[ISP]			= ipv4.isp_name
	FROM		@IPList AS ips
	CROSS APPLY	(
		SELECT	TOP(1)
				ipv4.ip_to, ipv4.country_name, ipv4.country_code, ipv4.region, ipv4.city, ipv4.isp_name
		FROM	dbo.IP2Location AS ipv4 WITH (NOLOCK)
		WHERE	ips.ip >= ipv4.ip_from
		ORDER BY ipv4.ip_from DESC
	) AS ipv4
	WHERE	ips.ip <= ipv4.ip_to;
END;
GO
/*<info serverAlias="FPSADMIN-IPDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/