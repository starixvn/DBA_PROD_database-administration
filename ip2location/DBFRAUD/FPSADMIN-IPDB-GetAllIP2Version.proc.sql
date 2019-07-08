SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.GetAllIP2Location
AS
/*
	Creator:	20190705@Billy
	Task:		Get all IPv4 - [Redmine: #116251]
	Database:	FPSADMIN.IPDB

	Revisions:
		- 20190705@Billy:	Initial - [Redmine: #116251]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET NOCOUNT ON;

	SELECT	[FromIP]		= ipv4.ip_from
		,	[ToIP]			= ipv4.ip_to
		,	[CountryCode]	= ipv4.country_code
		,	[CountryName]	= ipv4.country_name
		,	[Region]		= ipv4.region
		,	[City]			= ipv4.city
		,	[ISPName]		= ipv4.isp_name
	FROM	dbo.IP2Location AS ipv4 WITH (NOLOCK);
END;
GO
/*<info serverAlias="FPSADMIN-IPDB" executers="fpsWinService" viewers="" isFunction="0" isNested="0"></info>*/